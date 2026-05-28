#!/usr/bin/env python3
"""
pacman_pty_wrapper.py
Runs `pkexec pacman -Syu` inside a PTY, forwarding stdin from a FIFO and
emitting clean (ANSI-stripped, line-buffered) output to stdout.
"""
import errno
import os
import pty
import re
import select
import signal
import subprocess
import sys

INPUT_FIFO = "/tmp/pacman_input"
ANSI_RE    = re.compile(r"\x1b[^a-zA-Z]*[a-zA-Z]")


def open_fifo():
    try:
        return os.open(INPUT_FIFO, os.O_RDONLY | os.O_NONBLOCK)
    except OSError as exc:
        sys.stderr.write(f"pacman-wrapper: cannot open FIFO: {exc}\n")
        sys.exit(1)


def cleanup(master_fd, fifo_fd, proc):
    # Kill the entire child process group so pkexec + pacman both die.
    try:
        os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
    except OSError:
        pass
    try:
        proc.wait(timeout=3)
    except Exception:
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
        except OSError:
            pass
    for fd in (master_fd, fifo_fd):
        try:
            os.close(fd)
        except OSError:
            pass


def emit(raw_text, line_buf):
    """Strip ANSI codes, flush complete lines; return updated line_buf."""
    text = ANSI_RE.sub("", raw_text)
    text = text.replace("\r\n", "\n")
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


def main():
    fifo_fd            = open_fifo()
    master_fd, slave_fd = pty.openpty()

    proc = subprocess.Popen(
        ["pkexec", "pacman", "-Syu"],
        stdin=slave_fd, stdout=slave_fd, stderr=slave_fd,
        close_fds=True,
        start_new_session=True,  # pkexec+pacman get their own PGID
    )
    os.close(slave_fd)

    def _handle_signal(signum, frame):
        cleanup(master_fd, fifo_fd, proc)
        sys.exit(1)

    signal.signal(signal.SIGTERM, _handle_signal)
    signal.signal(signal.SIGINT,  _handle_signal)

    line_buf = ""
    running  = True

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

    cleanup(master_fd, fifo_fd, proc)
    proc.wait()
    sys.exit(proc.returncode)


if __name__ == "__main__":
    main()
