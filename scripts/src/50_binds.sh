if [[ -n "$BASH_VERSION" ]]; then
  bind '" ": magic-space'
elif [[ -n "$ZSH_VERSION" ]]; then
  bindkey " " magic-space
fi
