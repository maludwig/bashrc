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

find_autojump_db () {
  AUTOJUMP_DB=`autojump -s | grep -E '^data:' | sed -E $'s/^data:[\t ]+//'`
  if echo "$AUTOJUMP_DB" | grep -Fq 'C:'; then
    echo "$AUTOJUMP_DB" | sed -E 's%\\%/%g;s%C:/%/c/%'
  fi
}