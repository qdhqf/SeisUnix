#!/bin/bash

# /*********************** self documentation **********************/
# RAMAC2SU - converts RAMAC GPR files to su format with a nominal geometry
#
# Usage: ramac2su name_pattern >stdout
#
# Required parameter:
#        name_pattern of RAMAC files to be converted
# Optional parameter:
#        verbose=1 for verbose output
#
# Notes:
# This is a shell script using standard GNU/UNIX utilities that reads
# the information from the .RAD text file and the .RD3 binary file 
# (16bits integer) to produce a SU file with nominal geometry.
#
# To modify geometry (header values) use:  sushw/suchw
# 
# Output SU file base units are cm and microseconds. First X midoint is 0
#
# Example:    ramac2su DATA_1234 > DATA_1234.su 
#
# Caveat: 
# The script requires that the files DATA_1234.rad and DATA_1234.rd3
# be present in the users working directory where ramac2su is being run.
#
# Author: University of Pau: Hervé Perrou,d  12/2000
# Modified by: University of Pau:Dominique Rousset,  2019 
# 
# /**************** end self doc ********************************/

if [ $# -eq 0 ] 
then
   echo
   echo
   echo
   echo
   echo
   echo "RAMAC2SU - converts RAMAC GPR files to su format with a nominal geometry"
   echo 
   echo "Usage: ramac2su name_pattern >stdout"
   echo
   echo "Required parameter:" 
   echo "      name_pattern of RAMAC files to be converted"
   echo "Optional parameter:"
   echo "      verbose=1 for verbose output"
   echo
   echo "Notes:"
   echo "This is a shell script using standard GNU/UNIX utilities that reads" 
   echo "the information from the .RAD text file and the .RD3 binary file "
   echo "(16bits integer) to produce a SU file with nominal geometry." 
   echo
   echo "To modify geometry (header values) use:  sushw/suchw"
   echo
   echo "Output SU file base units are cm and microseconds. First X midoint is 0"
   echo
   echo "Example:    ramac2su DATA_1234 > DATA_1234.su "
   echo
   echo "Caveat:"
   echo "The script requires that the files DATA_1234.rad and DATA_1234.rd3"
   echo "be present in the users working directory where ramac2su is being run."
   exit 1
fi


OPT=s
if [ $# -eq 2 ]
then 
   if [ $1 == "verbose=1" ] 
   then
      file=$2
      OPT=v
   elif [ $2 == "verbose=1" ]
   then
      file=$1
      OPT=v
   else 
      echo Error in parameters
      exit 1
   fi
elif [ $# -eq 1 ]
then
   file=$1
else 
   echo Error in parameters >&2
   exit 1   
fi

[ $OPT == "v" ] && echo "processing file $file.rad" >&2
# initialisation
export LANG=C7

# Checking presence/read permission of RAMAC files
[ ! -r $file.rad ] && { echo "error reading $file.rad" >&2; exit 2; }
[ ! -r $file.rd3 ] && { echo "error reading $file.rd3" >&2; exit 3; }

# get samples and traces number
NS=`grep SAMPLES <$file.rad | cut -d: -f2 | awk '{printf("%d\n",$1)}'`
NT=`grep "LAST TRACE" <$file.rad | cut -d: -f2 | awk '{printf("%d\n",$1)}'`
[ $OPT == "v" ] && echo "number of samples = $NS" - number of traces = $NT >&2

# get sample interval
FREQ=`grep FREQUENCY <$file.rad | head -1 | cut -d: -f2 | awk '{printf("%.3f\n",$1)}'`
DT=`echo $FREQ | a2b n1=1 outpar=/dev/null 2>/dev/null | farith op=scale scale=0.000001 \
| farith op=pinv | recast outpar=/dev/null out=int | recast outpar=/dev/null \
in=int out=float | b2a n1=1 outpar=/dev/null | awk '{printf("%d\n",$1)}'`
[ $OPT == "v" ] && echo "sampling frequency = $FREQ Mhz -> dt = $DT ps" >&2

# get offset
OFFSET=`grep "ANTENNA SEPARATION" <$file.rad | cut -d: -f2 | a2b n1=1 2>/dev/null \
outpar=/dev/null | farith op=scale scale=100 | recast outpar=/dev/null out=int | recast \
outpar=/dev/null in=int out=float | b2a n1=1 outpar=/dev/null | awk '{printf("%d\n",$1)}'`

# get start position
START=`grep "START POSITION" <$file.rad | cut -d: -f2 | a2b n1=1 2>/dev/null \
outpar=/dev/null  | farith op=scale scale=100 | recast outpar=/dev/null out=int | recast \
outpar=/dev/null in=int out=float | b2a n1=1 outpar=/dev/null | awk '{printf("%d\n",$1)}'`

# get distance interval
INTERVAL=`grep "DISTANCE INTERVAL" <$file.rad | cut -d: -f2 | a2b n1=1 2>/dev/null \
outpar=/dev/null  | farith op=scale scale=100 | b2a n1=1 outpar=/dev/null \
| awk '{printf("%.4f\n",$1)}'`

[ $OPT = "v" ] && echo "Offset = $OFFSET cm - Start position = $START cm - Distance interval = $INTERVAL cm" >&2

# get stack number
NVS=`grep STACKS <$file.rad | cut -d: -f2 | tr -d "\r\n"`

[ $OPT = "v" ] && echo "Number of stacked traces = $NVS" >&2


# convert data and build su file
cat <$file.rd3 |\
recast in=short out=float outpar=/dev/null | \
suaddhead ns=$NS |\
sushw key=dt,nvs,offset,gx,scalco a=$DT,$NVS,$OFFSET,$START,1 \
b=0,0,0,$INTERVAL,0 |\
suchw key1=sx,gx key2=gx,gx key3=offset,offset b=1,1 c=0.5,-0.5
