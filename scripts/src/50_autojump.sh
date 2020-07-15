if [[ -f "$BASHRC_DIR/modules/autojump/bin/autojump.sh" ]]; then
  AUTOJUMP_SH="$BASHRC_DIR/modules/autojump/bin/autojump.sh"
elif [[ -f '/usr/share/autojump/autojump.sh' ]]; then
  AUTOJUMP_SH='/usr/share/autojump/autojump.sh'
elif [[ -f '/usr/local/etc/profile.d/autojump.sh' ]]; then
  AUTOJUMP_SH='/usr/share/autojump/autojump.sh'
else
  msg-error "Could not find autojump, expected it here: 
    $BASHRC_DIR/modules/autojump/bin/autojump.sh
  "
fi
# autojump
if [[ -f "$AUTOJUMP_SH" ]]; then
  source "$AUTOJUMP_SH"
fi
if [[ "$BASH_VERSION" > "4" ]]; then
  shopt -s autocd
fi
