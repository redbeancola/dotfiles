#!/usr/bin/env python3
"""
pacman_pty_wrapper.py
Runs `pkexec pacman -Syu` inside a PTY, forwarding stdin from a FIFO and
emitting clean (ANSI-stripped, line-buffered) output to stdout.

Cancel protocol
---------------
pacman runs as root via pkexec setuid, so user-level signals (SIGTERM, SIGKILL)
cannot reach it — they fail with EPERM. The only reliable cross-privilege kill
mechanism is the PTY itself: when the master fd is closed, the kernel sends
SIGHUP to the slave's foreground process group automatically, regardless of UID.

Flow:
  Lua reads wrapper PID from PID_FILE and sends SIGTERM to the wrapper.
  Wrapper SIGTERM handler closes master_fd.
  Kernel sends SIGHUP to pkexec/pacman (slave foreground group).
  pacman dies. Wrapper exits. on_exit() fires in Lua.
"""
import errno
import fcntl
import os
import pty
import re
import select
import signal
import subprocess
import sys
import termios

INPUT_FIFO = "/tmp/pacman_input"
PID_FILE   = "/tmp/pacman_wrapper.pid"
ANSI_RE    = re.compile(r"\x1b[^a-zA-Z]*[a-zA-Z]")


# ── PID file ──────────────────────────────────────────────────────────────────

def write_pid():
    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()) + "\n")

def remove_pid():
    try:
        os.unlink(PID_FILE)
    except OSError:
        pass


# ── PTY / process setup ───────────────────────────────────────────────────────

def make_controlling_tty(slave_fd):
    """
    Called as preexec_fn in the child process.
    Creates a new session and acquires the slave PTY as the controlling
    terminal. This is what makes the kernel deliver SIGHUP when the master
    side is closed.
    """
    os.setsid()
    fcntl.ioctl(slave_fd, termios.TIOCSCTTY, 0)


# ── Output processing ─────────────────────────────────────────────────────────

def emit(raw_text, line_buf):
    """Strip ANSI codes, flush complete lines; return updated line_buf."""
    text = ANSI_RE.sub("", raw_text).replace("\r\n", "\n")
    line_buf += text

    while "\n" in line_buf:
        line, line_buf = line_buf.split("\n", 1)
        sys.stdout.write(line + "\n")
        sys.stdout.flush()

    while "\r" in line_buf:
        line, line_buf = line_buf.rsplit("\r", 1)
        prev = line.rsplit("\r", 1)[-1] if "\r" in line else line
        if prev.strip():
            sys.stdout.write(prev + "\n")
            sys.stdout.flush()

    if line_buf and re.search(r"\[[Yy]/[Nn]\]\s*$", line_buf):
        sys.stdout.write(line_buf + "\n")
        sys.stdout.flush()
        line_buf = ""

    return line_buf


# ── FIFO ──────────────────────────────────────────────────────────────────────

def open_fifo():
    try:
        return os.open(INPUT_FIFO, os.O_RDONLY | os.O_NONBLOCK)
    except OSError as exc:
        sys.stderr.write(f"pacman-wrapper: cannot open FIFO: {exc}\n")
        sys.exit(1)


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    write_pid()

    fifo_fd             = open_fifo()
    master_fd, slave_fd = pty.openpty()

    # preexec_fn runs in the child (before exec), setting up the controlling
    # terminal so the kernel can deliver SIGHUP on master close.
    # Do NOT use start_new_session=True here — make_controlling_tty calls
    # os.setsid() itself, and combining both would break TIOCSCTTY.
    proc = subprocess.Popen(
        ["pkexec", "pacman", "-Syu"],
        stdin=slave_fd, stdout=slave_fd, stderr=slave_fd,
        close_fds=True,
        preexec_fn=lambda: make_controlling_tty(slave_fd),
    )
    os.close(slave_fd)

    def _close_master():
        """Close master fd — kernel delivers SIGHUP to pacman (root-safe)."""
        try:
            os.close(master_fd)
        except OSError:
            pass

    def _handle_signal(signum, frame):
        # Closing the master is the only way to kill a root-owned pacman
        # from user space. The kernel sends SIGHUP to the slave foreground
        # process group automatically — no privilege check involved.
        _close_master()
        remove_pid()
        try:
            fifo_fd and os.close(fifo_fd)
        except OSError:
            pass
        sys.exit(128 + signum)

    signal.signal(signal.SIGTERM, _handle_signal)
    signal.signal(signal.SIGINT,  _handle_signal)

    line_buf = ""
    running  = True
    master_closed = False

    while running:
        try:
            r, _, _ = select.select([master_fd, fifo_fd], [], [], 0.1)
        except (ValueError, OSError):
            break

        if master_fd in r:
            try:
                data     = os.read(master_fd, 4096)
                line_buf = emit(data.decode("utf-8", errors="replace"), line_buf)
            except OSError as exc:
                if exc.errno == errno.EIO:
                    running = False
                break

        if fifo_fd in r:
            try:
                data = os.read(fifo_fd, 256)
                if data:
                    os.write(master_fd, data)
            except OSError:
                pass

        if proc.poll() is not None:
            try:
                while select.select([master_fd], [], [], 0.2)[0]:
                    data = os.read(master_fd, 4096)
                    if not data:
                        break
                    line_buf = emit(data.decode("utf-8", errors="replace"), line_buf)
            except OSError:
                pass
            running = False

    if line_buf:
        sys.stdout.write(line_buf + "\n")
        sys.stdout.flush()

    _close_master()
    remove_pid()
    try:
        os.close(fifo_fd)
    except OSError:
        pass

    proc.wait()
    sys.exit(proc.returncode)


if __name__ == "__main__":
    main()
