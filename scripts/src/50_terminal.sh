
set_terminal_title ()
{
  echo -ne "\033]0;"$1"\007"
}
