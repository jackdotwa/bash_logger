
##
#
# This logger write to stdout (in absence of logfile), or to file, in the format:
#    Month HH:MM:SS TZDATA user prognane[PID] message here, 
# e.g. 
#    Aug 30 14:38:43 +0200 myuser someprog.sh[3388]
#
# To use this logger, include the following at the top of your bash script
#
# 1) PROGNAME=$(basename $0)
# 2) [[ -f /usr/local/lib/logger.sh ]] && . /usr/local/lib/logger.sh || { echo -e 'ERROR: logger.sh not found'; exit 1; }
# 3) logfile=$HOME/log/ip.log  # if you don't use this entry, it will output to stdout only (useful for testing)
#
##

red='\033[0;31m'
nc='\033[0m'
if [ -z $PROGNAME ]; then
    echo -e "${red} Calling function has not defined PROGNAME ${nc}"
    exit 1
fi

[[ -z $SPROCID ]] && sproc_id=-1 || sproc_id=$SPROCID

msg_log() {
    local msg=$@
    # args: logfile_path script_name process_id message 
    #   we use the process id of the parent (immediately calling function) via $$
    if [ -z $logfile ]; then
	format "stderr" $PROGNAME $sproc_id $$ $msg
    else
	format $logfile  $PROGNAME $sproc_id $$ $msg
    fi
}

err_log() {
    local msg=$@
    echo -e "[$PROGNAME] \e[01;31mERROR: $msg\e[0m" 
    msg_log "ERROR:: $msg"
    exit 1
}




##
# Simple formatter which writes the following columns to a logfile or stdout:
# column 1: timestamp (determined by datelogfmt.sh, e.g. Feb 01 16:02:37 +0200)
# column 2: hostname 
# column 3: initial proc id (deactivate with -1)
# column 3: script name/proc id
# column 4: message
# 
# If the LOGFQFILE variable is stdout, then output to stdout.
##
format() {
	local USAGE="format() requires params: LOGFQFILE SCRIPTNAME SPROCID PROCID MSG"

	local LOGFQFILE=${1:?Path to log file required. $USAGE}; shift;       
	local SCRIPTNAME=${1:?Executing script name is required. $USAGE}; shift;
	local SPROCID=${1:?The super process id is required (to tie processes together. Provide \"\" for none. $USAGE}; shift;
	local PROCID=${1:?The process identifier of the executing script is required. $USAGE}; shift;
	local MSG=${1:?A log message is required. $USAGE}; shift;
	    # get the rest of the log msg in case it is not provided within " "
	while ! [ -z $1 ]; do
	    MSG="$MSG $1"
	    shift;
	done


	[[ "$SPROCID" == "-1" ]] && sprocid_str="" || sprocid_str="[$SPROCID]" 

	now=$(date +"%b %d %H:%M:%S %z")
	if [ "stderr" == "$LOGFQFILE" ]; then
	    echo -e $now $(hostname) ${SCRIPTNAME}$sprocid_str[${PROCID}] $MSG >&2
	else
	    echo -e $now $(hostname) ${SCRIPTNAME}$sprocid_str[${PROCID}] $MSG  >> $LOGFQFILE
	fi
}


