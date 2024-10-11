#!/bin/bash
WHMCONFIG="$HOME/.whm_shell";

# functions

lnif ()
{
  local dst="${@: -1}";
  if ! [[ -e "$dst" ]]; then
    ln $@;
  fi
}

ensure ()
{
  local program="$(command -v $1)";
  if ! [ -x "$program" ]; then
    echo "[-] Error: $1 is not installed." >&2;
    return 1;
  fi
  return 0;
}

ensure-all ()
{
  for program in "$@"
  do
    if ! ensure $program; then
      return 1;
    fi
  done
}

safe-run () # run or quit
{
  local program=$1; shift;
  if ! ensure $program;  then
    exit 1;
  fi
  $program $@;
}

if ! [[ -d "$WHMCONFIG" ]]; then
  safe-run git clone "https://github.com/VKWHM/WHMShellConfig.git" "$WHMCONFIG"
fi

# Link files
if ensure-all zsh fd eza zoxide fzf bat; then
  lnif -s "$WHMCONFIG/myshell" "$HOME/.myshell"
  lnif -s "$WHMCONFIG/zshrc" "$HOME/.zshrc" 
else
  echo "[-] zsh config is not linked."
fi

lnif -s "$WHMCONFIG/p10k.zsh" "$HOME/.p10k.zsh"

if ensure vim; then
  lnif -s "$WHMCONFIG/vimrc" "$HOME/.vimrc"
else
  echo "[-] vim config is not linked."
fi

if ensure-all nvim rg; then
  mkdir -p "$HOME/.config";
  lnif -s "$WHMCONFIG/nvim" "$HOME/.config/nvim";
else
  echo "[-] nvim config is not linked."
fi

