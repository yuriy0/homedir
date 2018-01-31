## General
alias ls='ls --color=auto --human-readable'

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
alias lmbr_waf_do_build='./lmbr_waf.bat build_win_x64_vs2015_profile -p game'

function kill_ly {
  taskkill /F /FI "WINDOWTITLE eq Lumberyard" > /dev/null
  taskkill /F /FI "IMAGENAME eq AssetProcessor.exe" > /dev/null
}

## Functions
function unix2winPath() {
    if hash cygpath 2>/dev/null; then
        cygpath -w "$1" ;
    else
        echo "$1" | sed -e 's/^\///' -e 's/\//\\/g' ;
    fi
}

## Git functions
source ~/.gitaliases
