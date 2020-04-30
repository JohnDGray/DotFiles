#!/bin/bash

dot_vim_dir=$(realpath ~/.vim) || exit 1;
if [ ! -d $dot_vim_dir ]; then
  echo "Error: no .vim directory in home directory";
  exit 1
fi
cd $dot_vim_dir || exit 1;

declare -a dir_tree=("testdir" "my-plugins" "start")
for i in "${dir_tree[@]}"
do
  mkdir "$i" && cd "$i" || exit 1;
done

if [ "$(basename "$(pwd)")" != "start" ]; then
  echo "Error creating directory tree";
  exit 1;
fi

declare -a repos=("gruvbox" "dracula" "ultisnips" "vim-commentary" "vim-snippets")
for i in "${repos[@]}"
do
  mkdir "$i" || exit 1;
done

cd "gruvbox" && git clone "https://github.com/morhetz/gruvbox.git";

cd "../dracula" && git clone "https://github.com/dracula/vim.git";
cd "../vim-commentary" && git clone "https://github.com/tpope/vim-commentary.git";
cd "../ultisnips" && git clone "https://github.com/SirVer/ultisnips.git";
cd "../vim-snippets" && git clone "https://github.com/honza/vim-snippets.git";

echo "done";
