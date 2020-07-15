
# Package Manager aliases
be_root () {
  if [[ `whoami` == "root" ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

getpip () { wget https://bootstrap.pypa.io/get-pip.py; sudo python get-pip.py; }
getbrew () { /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }
rmbrew () { ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"; }

npmi () { npm install "$@"; }
npmu () { npm update "$@"; }
npmlg () { npm search "$@"; }
npmli () { npm ls; }
npmlig () { npm ls | grep "$@"; }

yarni () { yarn add "$@"; }
yarna () { yarn add "$@"; }

bri () { brew install "$@"; }
bru () { brew update "$@"; }
brlg () { brew search "$@"; }
brli () { brew list --versions; }
brlig () { brew list --versions | grep "$@"; }
brr () { brew remove "$@"; }

brci () { brew cask install "$@"; }
brcu () { brew cask update "$@"; }
brclg () { brew cask search "$@"; }
brcli () { brew cask list --versions; }
brclig () { brew cask list --versions | grep "$@"; }

apti () { be_root apt-get -y install "$@"; }
apts () { be_root apt-get -s install "$@"; }
aptu () { be_root apt-get update && be_root apt-get upgrade "$@"; }
aptlg () { apt list | grep "$@"; }
aptli () { apt --installed list "$@"; }
aptlig () { apt --installed list | grep "$@"; }
aptr () { be_root apt-get -y remove "$@"; }
aptp () { be_root apt-file update && apt-file search "$@"; }
aptdev () { be_root apt-get install build-essential sudo python rsync git passwd zsh net-tools netcat-openbsd; }

yumi () { be_root yum -y install "$@"; }
yumlg () { yum list | grep "$@"; }
yumli () { yum list installed "$@"; }
yumlig () { yum list installed | grep "$@"; }
yumu () { be_root yum -y update "$@"; }
yumr () { be_root yum -y remove "$@"; }
yump () { be_root yum provides "$@"; }
yumdev () { yumi sudo rsync vim git nano epel-release; sudo yum groupinstall "Development Tools"; }

dnfi () { be_root dnf -y install "$@"; }
dnflg () { dnf list | grep "$@"; }
dnfli () { dnf list installed "$@"; }
dnflig () { dnf list installed | grep "$@"; }
dnfu () { be_root dnf -y update "$@"; }
dnfr () { be_root dnf -y remove "$@"; }
dnfp () { be_root dnf provides "$@"; }
dnfdev () { dnfi sudo rsync vim git nano epel-release; sudo dnf groupinstall "Development Tools"; }

pipi () { pip install "$@"; }
pipu () { pip install --upgrade "$@"; }
piplg () { pip search "$@"; }
pipli () { pip freeze "$@"; }
piplig () { pip freeze | grep "$@"; }
pipr () { pip uninstall "$@"; }

scoopi () { scoop install "$@"; }
scoopu () { pip install --upgrade "$@"; }
scooplg () { scoop search "$@"; }
scoopli () { scoop list "$@"; }
scooplig () { scoop list | grep "$@"; }
scoopr () { scoop uninstall "$@"; }

function yuminode {
  NODEVERSION="$1"
  if [[ "$NODEVERSION" == "" ]]; then
    NODEVERSION=9
  fi
  if [ -f "$(which node)" ]; then
    echo "Node is already installed"
  else
    curl --silent --location https://rpm.nodesource.com/setup_${NODEVERSION}.x | sudo bash -
    yum install -y nodejs
  fi
}

pkg () {
  local COMMAND="$1"
  shift
  if [[ "$COMMAND" == "install" ]] || [[ "$COMMAND" == "i" ]]; then
    COMMAND="i"
  elif [[ "$COMMAND" == "remove" ]] || [[ "$COMMAND" == "uninstall" ]] || [[ "$COMMAND" == "r" ]]; then
    COMMAND="r"
  elif [[ "$COMMAND" == "search" ]] || [[ "$COMMAND" == "lg" ]]; then
    COMMAND="lg"
  elif [[ "$COMMAND" == "update" ]] || [[ "$COMMAND" == "u" ]]; then
    COMMAND="u"
  elif [[ "$COMMAND" == "list-installed" ]] || [[ "$COMMAND" == "li" ]]; then
    COMMAND="li"
  elif [[ "$COMMAND" == "grep-installed" ]] || [[ "$COMMAND" == "lig" ]]; then
    COMMAND="lig"
  elif [[ "$COMMAND" == "provides" ]] || [[ "$COMMAND" == "p" ]]; then
    COMMAND="p"
  elif [[ "$COMMAND" == "dev" ]]; then
    COMMAND="dev"
  else
    msg-error "Unknown command '$COMMAND'"
    return 1
  fi
  if commands_exist dnf; then
    PKGMGR="dnf"
  elif commands_exist yum; then
    PKGMGR="yum"
  elif commands_exist apt-get; then
    PKGMGR="apt"
  elif commands_exist brew; then
    PKGMGR="br"
  elif commands_exist scoop; then
    PKGMGR="scoop"
  else
    msg-error "Could not find supported package manager"
    return 2
  fi
  PKG_FN="$PKGMGR""$COMMAND"
  if declare -f "$PKG_FN" &> /dev/null; then
    "$PKG_FN" "$@"
  else
    msg-error "Unsupported command for $PKGMGR"
    return 3
  fi
}