#!/bin/sh -u
#
# Check non-regression of all NRG cases containing nrgconf.sh
#
bar="------------------------------------------------------------------------"

# --- print usage ---
#
function usage() {
  if [ $1 = 1 ] ; then
    echo "$bar"
    echo "ERROR"
    echo "$bar"
  fi
  echo
  echo "Usage: $SCRIPTNAME [-h] [-d|--diff-cmd <diff-command>]"
  echo "       $SCRIPTSPCE [-l] [--] [<pattern> ...]"
  echo
  echo "       -h:      prints this help"
  echo "       -d|--diff-cmd <diff-command>:"
  echo "                uses <diff-command>"
  echo "       -l:      prints list of cases"
  echo "       -k:      keep (do not delete) TMPDIR and cases"
  echo "       --:      end of options"
  echo
  echo "       <pattern>: selects cases with name matching <pattern>"
  echo
  echo "       default: runs cases"
  echo
  exit $1
}

echo "$bar"
echo TYPHON non regression check
echo "$bar"

# --- directory initialization ---
#
ORIGDIR=$PWD
SCRIPTNAME=$(basename $0)
SCRIPTSPCE=$(sed 's/./ /g' <<< $SCRIPTNAME)
export HOMEDIR=$(cd $(dirname $0) ; pwd)
export  EXEDIR=$HOMEDIR/SOURCE
export  BINDIR=$HOMEDIR/bin
export  NRGDIR=$HOMEDIR/NRG
export MESHDIR=$HOMEDIR/NRG/COMMON
export  TMPDIR=/tmp/typhon.$$
if [ -e $TMPDIR ] ; then
  echo "$TMPDIR exists"
  while [ -e $TMPDIR ] ; do
    TMPDIR=$TMPDIR.0
  done
fi

# --- directory check ---
#
if [ ! -d $MESHDIR ] ; then
  echo directory $MESHDIR not found
  echo $HOMEDIR/$SCRIPTNAME is not in a valid typhon directory
  exit 1
fi

# --- get options ---
#
OPTS=$(getopt -o hd:lk -l diff-cmd: -n "$SCRIPTNAME" -- "$@")
[[ $? != 0 ]] && usage 1
eval set -- "$OPTS"

# --- parse options ---
#
diffcmd=
list=0
keeptmpdir=0
patlist=()
while true ; do
  case "$1" in
    -h) usage 0 ;;
    -d|--diff-cmd)
        shift ; diffcmd=$1 ;;
    -l) list=1 ;;
    -k) keeptmpdir=1 ;;
    --) shift ; break ;;
  esac
  shift
done

# --- check patterns ---
#
if [ ${#} -gt 0 ] ; then
  for pat in "$@" ; do
    if [ -n "$pat" ] ; then
      patlist+=("-e" "$pat")
    fi
  done
  shift ${#}
fi

# --- initialization ---
#
cd $HOMEDIR
. bin/shconf.sh
if [ -n "$diffcmd" ] ; then
  {          cat $0 ;} | $diffcmd - $0 >/dev/null 2>&1 ; r=$?
  { echo a ; cat $0 ;} | $diffcmd - $0 >/dev/null 2>&1 ; r=$?$r
  if [ $r != 10 ] ; then
    echo "ERROR: check diff command:"
    echo "$diffcmd"
    usage 1
  fi
  export DIFF="$diffcmd"
fi
#
export REFCONF=nrgconf.sh
export DIFFCOM=$DIFF
export LD_LIBRARY_PATH=$EXEDIR/Lib:$LD_LIBRARY_PATH

mkdir $TMPDIR
if [ $keeptmpdir -eq 0 ] ; then
  trap "rm -Rf $TMPDIR" 0 2
fi

rm diff.log check.log 2> /dev/null

# --- get list of cases ---
#
cd $NRGDIR
LISTCASES=( $(find * -name $REFCONF | xargs -n 1 dirname | grep "${patlist[@]:-.}") )

if [ ${#LISTCASES[@]} = 0 ] ; then
  echo "NO CASE FOUND"
  echo "$bar"
  exit 0
fi

# --- print list of cases ---
#
if [ $list -eq 1 ] ; then
  echo LISTCASES =
  for CASE in "${LISTCASES[@]}" ; do
    echo "    ${CASE}"
  done
  exit 0
fi

typeset -i ncol0=1
for CASE in "${LISTCASES[@]}" ; do
  i=$(echo $CASE | wc -c)
  if [ $i -gt $ncol0 ] ; then ncol0=i ; fi
done

# --- print parameter ---
#
typeset -i ncol1=ncol0+20 ; col1="\\033[${ncol1}G"
typeset -i ncol2=ncol1+25 ; col2="\\033[${ncol2}G"

# --- tests ---
#
echo diffing with DIFF : $DIFF
echo "$bar"

echo diff-command : $DIFFCOM >> $HOMEDIR/diff.log
for CASE in "${LISTCASES[@]}" ; do
  # init
  CASEDIR=$NRGDIR/$CASE
  # print
  echo -n checking $CASE ...
  # configure
  . $CASEDIR/$REFCONF
  # create dir
  mkdir -p $TMPDIR/$CASE
  cd $TMPDIR/$CASE
  # copy files
  cp $MESHDIR/$MESHFILE $TMPDIR/$CASE
  cp $CASEDIR/$INPUTFILE $TMPDIR/$CASE
  # execute
  hostname > hostfile
  echo "$bar"  >> $HOMEDIR/check.log
  echo $CASE >> $HOMEDIR/check.log
  echo '#' "$bar" >> $HOMEDIR/diff.log
  echo '#' $CASE  >> $HOMEDIR/diff.log
  case $TYPE_EXE in
    seq) $EXEDIR/Typhon-$TYPE_EXE >> $HOMEDIR/check.log 2>&1 ;;
    mpi) mpirun -np ${MPIPROCS:-2} -machinefile hostfile \
         $EXEDIR/Typhon-$TYPE_EXE >> $HOMEDIR/check.log 2>&1 ;;
    *)   echo -e ${col1}$fic unknown typhon executable ;;
  esac
  if [ $? -eq 0 ] ; then
    for fic in $TO_CHECK ; do
      if [ -f "$fic" ] ; then
        fics=( $fic $CASEDIR/$fic )
        $DIFFCOM ${fics[@]} >> diff.log 2>&1
        case $? in
          0) echo -e ${col1}$fic ${col2}identical ;;
          1) echo -e ${col1}$fic ${col2}changed
             echo diff ${fics[@]} >> $HOMEDIR/diff.log
             cat diff.log >> $HOMEDIR/diff.log ;;
          *) echo -e ${col1}$fic ${col2}comparison failed ;;
        esac
        rm -f diff.log
      else
        echo -e ${col1}$fic ${col2}missing
      fi
    done
  else
    echo -e ${col2}computation failed
  fi
  if [ $keeptmpdir -eq 0 ] ; then
    rm -f $TMPDIR/$CASE/* 2> /dev/null
  fi
done

echo "$bar"
if [ $HOMEDIR = $ORIGDIR ] ; then
  echo check.log diff.log
else
  echo $HOMEDIR/check.log
  echo $HOMEDIR/diff.log
fi

echo "$bar"
if [ $keeptmpdir -eq 1 ] ; then
  echo "files kept in   : $TMPDIR"
  echo "$bar"
fi
