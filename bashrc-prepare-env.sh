#! /bin/bash
#
# vim-prepare-env.sh
# Copyright (C) 2016 witcher <witcher@MaciejPlachta>
#
# Distributed under terms of the MIT license.
#

source colors.inc

BASH_DIR="$HOME/.bash"
BASH_PREPARE_SCRIPT_DIR=`pwd`

create_directory(){
  local path_to_directory=$1;
  if [ -d ${path_to_directory} ]; then
    echo -e "[${YELLOW} Warning ${RESTORE}] Directory: ${path_to_directory} exists $ ";
  else
    echo -e "[${CYAN}INFO${RESTORE}] Creating directory: ${path_to_directory} ${RESTORE}";
    mkdir -p ${path_to_directory};
  fi
}

copy_directory_recursively(){
  cp -R $1 $2
}

download_git_aware_prompt(){
  echo -e "[${CYAN}INFO${RESTORE}] Trying to obtain git-aware-prompt from source..."
  ( git clone git://github.com/jimeh/git-aware-prompt.git > /dev/null 2>&1 )
}

install_git_aware_prompt(){
  create_directory ${BASH_DIR}
  pushd ${BASH_DIR}
  download_git_aware_prompt
  local returnCode=$?
  local success=0
  if [ ${returnCode} -ne ${success} ]; then
    echo -e "[${RED}ERROR${RESTORE}] Obtain git-aware-prompt from source code failed"
    echo -e "[${CYAN}INFO${RESTORE}] Obtaining git-aware-prompt from the current directory"
    copy_directory_recursively ${BASH_PREPARE_SCRIPT_DIR}/git-aware-prompt .
  fi
  popd
}

test_if_files_are_identical(){
  diff -q $1 $2 > /dev/null 2>&1
}

set_up_bashrc(){
  test_if_files_are_identical $HOME/.bashrc ${BASH_PREPARE_SCRIPT_DIR}/bashrc
  local success=$?
  if [ ${success} -eq 0 ]; then
    echo -e "[${YELLOW}WARNINIG${RESTORE}] Your current $HOME/.bashrc is identical to ${BASH_PREPARE_SCRIPT_DIR}/bashrc !"
    echo -e "....skipping routine"
    exit 0
  else
    echo -e "[${CYAN}INFO${RESTORE}] Transfer of an old ~/.bashrc to ${BASH_PREPARE_SCRIPT_DIR}/bashrc.old"
    mv $HOME/.bashrc ${BASH_PREPARE_SCRIPT_DIR}/bashrc.old
    ln -sf ${BASH_PREPARE_SCRIPT_DIR}/bashrc $HOME/.bashrc
  fi
}

setup_global_git_ignore_file(){
  echo -e "[${CYAN}INFO${RESTORE}] ${BLUE} Setting up global git ignore config ... ${RESTORE}"
  local ignore_file=".gitignore_global"
  touch ${HOME}/${ignore_file}
  echo -e "*~" >> ${HOME}/${ignore_file}
  echo -e "*.swp" >> ${HOME}/${ignore_file}
  echo -e ".ycm_extra_conf.py*" >> ${HOME}/${ignore_file}
  git config --global core.excludesfile ${HOME}/${ignore_file}
}

enhance_git_global_conf(){
  echo -e "[${CYAN}INFO${RESTORE}] ${BLUE} Setting up global git config ... ${RESTORE}"
  setup_global_git_ignore_file

  git config --global diff.tool vimdiff
  git config --global merge.tool meld
  git config --global alias.d difftool
  git config --global alias.last "log -1 HEAD"
  git config --global alias.unstage "reset HEAD --"
  git config --global alias.hist "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short"
  git config --global alias.logp "log --pretty=format:\"%h %s\" --graph -n 20"
}

install_git_aware_prompt
enhance_git_global_conf
set_up_bashrc
