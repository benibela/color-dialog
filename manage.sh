#/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../../../manageUtils.sh

mirroredProject color-dialog

BASE=$HGROOT/components/delphi/dialogs

case "$1" in
mirror)
  syncHg  
;;

esac

