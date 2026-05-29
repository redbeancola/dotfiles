# Package manager detection
echo "=== Package Managers ==="
for pm in pacman yay paru trizen pikaur aurman; do
  if command -v $pm &>/dev/null; then
    echo "✓ $pm $($pm --version 2>&1 | head -1)"
  else
    echo "✗ $pm"
  fi
done

# Core dotfile deps
echo ""
echo "=== Dotfile Dependencies ==="
for pkg in awesome conky kitty nvim picom polybar rofi zsh stow; do
  if command -v $pkg &>/dev/null; then
    ver=$(pacman -Q $pkg 2>/dev/null | awk '{print $2}')
    bin=$(command -v $pkg)
    echo "✓ $pkg  $ver  ($bin)"
  else
    echo "✗ $pkg  (not found)"
  fi
done

# Fork/variant detection
echo ""
echo "=== Fork Detection ==="
# picom fork detection via pacman -Qm instead of --version
picom_pkg=$(pacman -Qm 2>/dev/null | grep picom | grep -v debug | awk '{print $1}')
if [ -n "$picom_pkg" ]; then
  echo "  picom fork: $picom_pkg (AUR)"
else
  echo "  picom: $(pacman -Q picom 2>/dev/null | awk '{print $2}') (official)"
fi

# neovim vs vim
if command -v nvim &>/dev/null; then
  echo "  neovim: $(nvim --version | head -1)"
elif command -v vim &>/dev/null; then
  echo "  vim (no neovim): $(vim --version | head -1)"
fi

# zsh
if command -v zsh &>/dev/null; then
  echo "  zsh: $(zsh --version)"
  [ -d "$HOME/.oh-my-zsh" ]  && echo "    + oh-my-zsh"
  [ -f "$HOME/.zinit/bin/zinit.zsh" ] || [ -d "$HOME/.local/share/zinit" ] && echo "    + zinit"
  [ -d "$HOME/.zplug" ] && echo "    + zplug"
  command -v sheldon &>/dev/null && echo "    + sheldon"
fi

# Display server
echo ""
echo "=== Display ==="
echo "  Xorg: $(xdpyinfo | grep "X.Org version")"
echo "  DISPLAY=$DISPLAY"
