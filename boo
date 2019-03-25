echo "$0"
if [[ $SHELL == "/bin/zsh" ]]; then
  export BASHRC_DIR="$( cd "$( dirname "${0}" )" && pwd )"
elif [[ $SHELL == "/bin/bash" ]]; then
  export BASHRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi
echo $BASHRC_DIR
#env
#echo '-----'
#echo '-----'
#echo '-----'
#set
