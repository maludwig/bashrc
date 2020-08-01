if [[ "$-" == *i* ]]; then
  IS_INTERACTIVE='y'
else
  IS_INTERACTIVE='n'
fi
if [[ "$IS_INTERACTIVE" == "y" ]]; then
  if [[ -n "$BASH_VERSION" ]]; then
    bind 'Space: magic-space'
  elif [[ -n "$ZSH_VERSION" ]]; then
    bindkey " " magic-space
  fi
fi
