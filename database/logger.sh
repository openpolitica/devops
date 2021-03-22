#!/bin/sh
# Helper to write log
# Based on https://stackoverflow.com/a/36614046/5107192
# Based on https://www.cubicrace.com/2016/03/efficient-logging-mechnism-in-shell.html

LOG_DIR=./log
mkdir -p $LOG_DIR
dt=$(date '+%Y_%m_%d-%H_%M_%S');
SCRIPT_LOG=$LOG_DIR/logfile-${dt}.log
ERROR_LOG=$LOG_DIR/err.log
touch $SCRIPT_LOG

if [ !  -f "$ERROR_LOG" ];then
  touch $ERROR_LOG
fi


function SCRIPTENTRY(){
   timeAndDate=`date`
   script_name=`basename "$0"`
   script_name="${script_name%.*}"
   echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" >> $SCRIPT_LOG
   echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" >> $ERROR_LOG
}

function SCRIPTEXIT(){
   script_name=`basename "$0"`
   script_name="${script_name%.*}"
   echo "[$timeAndDate] [DEBUG]  < $script_name $FUNCNAME" >> $SCRIPT_LOG
   echo "[$timeAndDate] [DEBUG]  < $script_name $FUNCNAME" >> $ERROR_LOG
}

function ENTRY(){
   local cfn="${FUNCNAME[1]}"
   timeAndDate=`date`
   echo "[$timeAndDate] [DEBUG]  > $cfn $FUNCNAME" >> $SCRIPT_LOG
}

function EXIT(){
   local cfn="${FUNCNAME[1]}"
   timeAndDate=`date`
   echo "[$timeAndDate] [DEBUG]  < $cfn $FUNCNAME" >> $SCRIPT_LOG
}


function INFO(){
   local function_name="${FUNCNAME[1]}"
   local msg="$@"
   timeAndDate=`date`
   echo "[$timeAndDate] [INFO]  $msg" >> $SCRIPT_LOG
}


function DEBUG(){
   local function_name="${FUNCNAME[1]}"
   local msg="$@"
   timeAndDate=`date`
   echo "[$timeAndDate] [DEBUG]  $msg" >> $SCRIPT_LOG
}


function ERROR(){
   local function_name="${FUNCNAME[1]}"
   local msg="$1"
   timeAndDate=`date`
   echo "[$timeAndDate] [ERROR]  $msg" >> $SCRIPT_LOG
   echo "[$timeAndDate] [ERROR]  $msg" >> $ERROR_LOG
}

function ERROR_MSG(){
   echo "Some errors has ocurred, please visit $ERROR_LOG"
}


function SUCCESS_MSG(){
   echo "Process run successfully. More details, visit $SCRIPT_LOG"
}
