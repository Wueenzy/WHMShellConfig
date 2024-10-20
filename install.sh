#!/bin/bash

set -e  # Exit immediately if any command returns a non-zero status

USER=${USER:-$(id -u -n)}
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"


WHMCONFIG="$HOME/.whm_shell"


# functions

lnif ()
{
  local dst="${@: -1}"
  if ! [[ -e "$dst" ]]; then
    ln $@
  fi
}

ensure ()
{
  local program="$(command -v $1)"
  if ! [ -x "$program" ]; then
    echo "[-] Error: $1 is not installed." >&2
    return 1
  fi
  return 0
}

ensure-all ()
{
  for program in "$@"
  do
    if ! ensure $program; then
      return 1
    fi
  done
}


ensure-all git wget || exit 1;


if ! [[ -d "$WHMCONFIG" ]]; then
  git clone "https://github.com/VKWHM/WHMShellConfig.git" "$WHMCONFIG"
fi

# Link files
if ensure tmux; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  lnif -s "$WHMCONFIG/tmux.conf" "$HOME/.tmux.conf"
fi

if ensure-all zsh fd eza zoxide fzf bat; then
  lnif -s "$WHMCONFIG/myshell" "$HOME/.myshell"
  lnif -s "$WHMCONFIG/zshrc" "$HOME/.zshrc" 
  if ! [[ -z "$HOME/.oh-my-zsh" ]];then
    zsh_install_file="$(mktemp)"
    wget -O $zsh_install_file "https://install.ohmyz.sh/"
    chmod u+x $zsh_install_file
    $zsh_install_file --keep-zshrc
    rm $zsh_install_file
  fi
else
  echo "[-] zsh config is not linked."
fi

if ! [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi
lnif -s "$WHMCONFIG/p10k.zsh" "$HOME/.p10k.zsh"

if ensure vim; then
  lnif -s "$WHMCONFIG/vimrc" "$HOME/.vimrc"
else
  echo "[-] vim config is not linked."
fi

if ensure-all nvim rg; then
  mkdir -p "$HOME/.config"
  lnif -s "$WHMCONFIG/nvim" "$HOME/.config/nvim"
else
  echo "[-] nvim config is not linked."
fi

