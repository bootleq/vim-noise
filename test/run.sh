#!/usr/bin/env bash

if [[ ! -x test/vim-themis/bin/themis ]]; then
  echo 'Error: vim-themis not installed, clone it now? (y/N)'
  read choice
  if [[ $choice == 'y' ]]; then
    git clone https://github.com/thinca/vim-themis.git test/vim-themis
  else
    echo 'Aborted.'
    exit 1
  fi
fi

./test/vim-themis/bin/themis test
