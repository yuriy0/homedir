## General
alias ls='ls --color=auto --human-readable'
alias git-unite='~/git-unite/src/Git.Unite/bin/Release/Git.Unite.exe'

MSYS_NO_PATHCONV=1

HISTCONTROL=ignoredups # Avoid duplicates
shopt -s histappend # When the shell exits, append to the history file instead of overwriting it
# PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r" # After each command, append to the history file and reread it

## Git completion
source ~/.git-completion.bash
function __git_files {
  _wanted files expl 'local files' _files
}

## Functions
function unix2winPath() {
    if hash cygpath 2>/dev/null; then
        cygpath -w "$1" ;
    else
        echo "$1" | sed -e 's/^\///' -e 's/\//\\/g' ;
    fi
}

function locate_up {
  if (( $# < 1 )); then
    echo Expected at least one argument
    exit 1
  fi
  to_find=$1
  stop_at=$(cygpath ${2:-/})
  looking_in=$PWD

  while [[ $looking_in != $stop_at && $looking_in != / ]] ; do
    find "$looking_in"/ -maxdepth 1 -name "$1"
    looking_in=$(realpath "$looking_in"/..)
  done
}

function cp-path {
  src_path=$1
  src_file=$2
  tgt_path=$3
  shift 3

  old_file="$src_path/$src_file"
  new_file="$tgt_path/$src_file"
  mkdir -p $(dirname $new_file)
  cp "$@" $old_file $new_file
  if [ $? -eq 0 ]; then
    echo Copied \"$old_file\" to \"$new_file\"
  fi
}

function until-success {
  command="$@"
  count=0
  until eval $command; do
    echo \'$command\': run \#$count
    count=$((count+1))
  done;
  echo ==============================================
  echo \'$command\' ran \#$count times before succeeding
}

## For X11 over SSH
export DISPLAY=localhost:0.0

## Haskell stuff
# alias cabal-8.0='cabal --config-file="C:\\ghc8.0\\ghc-8.0.0.20160421\\bin\\config"'
# alias ghc-pkg-8.0='/cygdrive/c/ghc8.0/ghc-8.0.0.20160421/bin/ghc-pkg.exe'
alias ghc='stack ghc --'
alias ghci='stack exec ghci --'
# alias ghc-pkg-7.6.3='/cygdrive/c/Haskell7.6/ghc-7.6.3/bin/ghc-pkg.exe'
alias nomingw="export PATH=\"$(echo $PATH | sed -e 's|:/cygdrive/c/Haskell/mingw/bin||')\""

## Built-in CMD commands
alias mklink='cmd /C mklink'

## Misc
export PKG_CONFIG_PATH=/usr/local/lib/opencv-3.1.0/lib/pkgconfig:$PKG_CONFIG_PATH

## Lumberyard
alias ly_waf='$(locate_up "lmbr_waf.bat")'
alias ly_waf_build='$(locate_up "lmbr_waf.bat") build_win_x64_vs2015_profile -p game'
alias ly_waf_clean='$(locate_up "lmbr_waf.bat") clean_win_x64_vs2015_profile -p game'
alias ly_waf_opts='( $(locate_up "lmbr_waf.bat") show_option_dialog & ) > /dev/null 2>&1'
function ly_populate_ad {
  dir=$(dirname $(locate_up "SetupAssistant.bat"))
  "$dir"/dev/Tools/LmbrSetup/Win/lmbr.exe projects populate-appdescriptors -projects "$1"
}

function kill_ly {
  taskkill /F /FI "WINDOWTITLE eq Lumberyard" > /dev/null
  taskkill /F /FI "WINDOWTITLE eq Starting Lumberyard Editor" > /dev/null
  taskkill /F /FI "WINDOWTITLE eq Editor.exe" > /dev/null
  taskkill /F /FI "IMAGENAME eq AssetProcessor.exe" > /dev/null
  taskkill /F /FI "IMAGENAME eq GridHub_copyapp_.exe" > /dev/null
}

## Git functions
source ~/.gitaliases
