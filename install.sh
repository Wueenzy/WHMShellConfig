#!/bin/bash

# set -e  # Exit immediately if any command returns a non-zero status

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

check_file_exist() {
  return test -e "$1"
}

check_program_exist()
{
  local program="$(command -v $1)"
  test -x "$program"
  return $?
}

ensure ()
{
  if ! check_program_exist "$1"; then
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

download() {
  url="$1"
  if [[ -z "$2" ]];
    dst=$(mktemp)
  else
    dst="$2"
  fi
  echo "$dst"
  curl -Lo "$dst" "$url"
  return $?
}

confirm ()
{
  read -p "$1 (y/n): " choice
  case "$choice" in
    [Yy]* ) return 0;;
    *) echo "Operation cancelled."; return 1;;
  esac
}

install_package ()
{
  local package="$1"

  case "$OSTYPE" in
    "linux-gnu"*)
      if check_program_exist apt; then
        sudo apt update && sudo apt install -y "$package"
      elif check_program_exist yum; then
        sudo yum install -y "$package"
      elif check_program_exist dnf; then
        sudo dnf install -y "$package"
      elif check_program_exist pacman; then
        sudo pacman -Syu --noconfirm "$package"
      else
        echo "No supported package maanger found. Unable to install $package."
      fi
      ;;
    "darwin"*)
      if check_program_exist brew; then
        brew install "$package"
      else
        echo "Homebrew is not installed. Please install Homebrew to use this function on macOS"
        return 1
      fi
      ;;
    *)
      echo "Unsupported OS: $OSTYPE"
      return 1
      ;;
  esac
  return $?;
}


ensure-all git curl || exit 1;


if ! check_file_exist "$WHMCONFIG"; then
  git clone "https://github.com/VKWHM/WHMShellConfig.git" "$WHMCONFIG"
fi

# Link files
if ensure tmux; then
  if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  lnif -s "$WHMCONFIG/tmux.conf" "$HOME/.tmux.conf"
fi

if confirm "Do you want install required tools?"; then
  # zsh
  echo "Installing zsh..."
  install_package zsh

  # fzf
  echo "Installing fzf..."
  install_package fzf

  # zoxide
  echo "Installing zoxide...";
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

  # fd
  echo "Installing fd"
  install_package fd || (install_package fd-find && sudo ln -s "$(which fdfind)" "$(dirname $(which fdfind))/fd")

  # eza
  echo "Installing eza"
  if [[ "$OSTYPE" == "linux-gnu"* && $(check_program_exist apt) ]]; then
    sudo apt update
    sudo apt install -y gpg

    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
  else
    install_package eza
  fi

  # bat
  echo "Installing bat"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb
  fi
  install_package bat
  lnif -s "$WHMCONFIG/bat-cache" "$HOME/.cache/bat"
  lnif -s "$WHMCONFIG/bat-config" "$HOME/.config/bat"
  
  # ripgrep
  install_package ripgrep
  
  # Neovim
  if ! check_program_exist nvim; then
    if [[ "$OSTYPE" == "darkwin"* ]]; then
      install_package neovim
    else
      if neovim_archive="$(download https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz)";then
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf $neovim_archive
        rm $neovim_archive
      else
        echo "[-] Error when installing Neovim!"
      fi
    fi
  fi

  # Vim
  install_package vim
fi

if ensure-all zsh fd eza zoxide fzf bat; then
  lnif -s "$WHMCONFIG/myshell.sh" "$HOME/.myshell.sh"
  lnif -s "$WHMCONFIG/zshrc" "$HOME/.zshrc" 
  if ! [[ -z "$HOME/.oh-my-zsh" ]];then
    if zsh_install_file="$(download https://install.ohmyz.sh/)"; then
      chmod u+x $zsh_install_file
      $zsh_install_file --keep-zshrc --skip-chsh --unattended
      rm $zsh_install_file
    else
      echo "[-] Error when installing oh-my-zsh"
    fi
  fi
  
  zshplugdir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins"

  # installing zsh-syntax-highlighting
  ! check_file_exist "$zshplugdir/zsh-syntax-highlighting" && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zshplugdir/zsh-syntax-highlighting"

  # installing zsh-autosuggestions
  ! check_file_exist "$zshplugdir/zsh-autosuggestions"  && git clone https://github.com/zsh-users/zsh-autosuggestions "$zshplugdir/zsh-autosuggestions"

  # installing zsh-vi-mode
  ! check_file_exist "$zshplugdir/zsh-vi-mode" && git clone https://github.com/jeffreytse/zsh-vi-mode "$zshplugdir/zsh-vi-mode"
else
  echo "[-] zsh config is not linked."
fi

if ! check_file_exist "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"; then
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

