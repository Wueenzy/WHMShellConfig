#!/bin/bash
WHMCONFIG="$HOME/.whm_shell";

ensure ()
{
  local program="$(command -v $1)"; shift
  if ! [ -x "$program" ]; then
    echo "Error: $(basename $program) is not installed." >&2
    return 1
  fi
  $program $@
}

roq () # run or quit
{
  if ! ensure $@; then
    exit 1;
  fi
}

if ![[ -d "$WHMCONFIG" ]]; then
  roq git clone "https://github.com/VKWHM/WHMShellConfig.git" "$WHMCONFIG"
fi

# Link files
ln "$WHMCONFIG/zshrc" "$HOME/.zshrc"
ln "$WHMCONFIG/myshell" "$HOME/.myshell"
ln "$WHMCONFIG/p10k.zsh" "$HOME/.p10k.zsh"
ln "$WHMCONFIG/vimrc" "$HOME/.vimrc"
