#!/bin/bash

dot_vim_dir=$(realpath ~/.vim) || exit 1;
if [ ! -d $dot_vim_dir ]; then
  echo "Error: no .vim directory in home directory";
  exit 1
fi
cd $dot_vim_dir || exit 1;

declare -a dir_tree=("pack" "my-plugins" "start")
for i in "${dir_tree[@]}"
do
  mkdir "$i" && cd "$i" || exit 1;
done

if [ "$(basename "$(pwd)")" != "start" ]; then
  echo "Error creating directory tree";
  exit 1;
fi

git clone "https://github.com/morhetz/gruvbox.git";
git clone "https://github.com/dracula/vim.git";
git clone "https://github.com/tpope/vim-commentary.git";
git clone "https://github.com/SirVer/ultisnips.git";
git clone "https://github.com/honza/vim-snippets.git";

echo "done";
