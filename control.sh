## control.sh
## Version 0.9.5.1
## Tested with jq 1.5.1 on Ubuntu 16.04.1
#!/bin/bash

SH_FILE="check_height_and_rebuild.sh"
LOG_FILE="heightRebuild.log"
CONSENSUS_SH_FILE="check_consensus.sh"
CONSENSUS_LOG_FILE="consensus.log"
MANAGE_SH_FILE="manage.sh"
MANAGE_LOG_FILE="manage.log"

start_height() {
	## Check for config file
	CONFIG_FILE="config.json"
	if [[ ! -e "$CONFIG_FILE" ]] ; then
		wget "https://raw.githubusercontent.com/Stoner19/ONZCoinScripts/master/config.json"
		PS3='Please select an editor to input config details: '
		options=("nano" "vi")
		select opt in "${options[@]}"
		do
		    case $opt in
			"nano")
			    nano config.json
			    break
			    ;;
			"vi")
			    vi config.json
			    break
			    ;;
			*) echo invalid option;;
		    esac
		done
	fi
	if [[ ! -e "$LOG_FILE" ]] ; then
		touch "$LOG_FILE"
	fi
	if [[ ! -e "$SH_FILE" ]] ; then
		wget "https://raw.githubusercontent.com/Stoner19/ONZCoinScripts/master/check_height_and_rebuild.sh"
	fi

	echo "Starting heightRebuild Script"
	nohup bash $SH_FILE -S $SRV  > $LOG_FILE 2>&1&  ## SRV???
}

check_height_running() {
	# Check if it is running
	if pgrep -fl $SH_FILE > /dev/null
	then
		echo "Killing heightRebuild process"
		pkill -f $SH_FILE -9
	else
		echo "heightRebuild is not currently running"
	fi
}

upgrade_height() {
	if [[ -e "$SH_FILE" ]] ;
	then
		rm "$SH_FILE"
	fi

	wget "https://raw.githubusercontent.com/Stoner19/ONZCoinScripts/master/check_height_and_rebuild.sh"
	echo "Starting heightRebuild Script"
	nohup bash $SH_FILE -S $SRV  > $LOG_FILE 2>&1&
}

start_consensus() {
	## Check for config file
	CONFIG_FILE="config.json"
	if [[ ! -e "$CONFIG_FILE" ]] ; then
		wget "https://raw.githubusercontent.com/Stoner19/ONZCoinScripts/master/config.json"
		PS3='Please select an editor to input config details: '
		options=("nano" "vi")
		select opt in "${options[@]}"
		do
		    case $opt in
			"nano")
			    nano config.json
			    break
			    ;;
			"vi")
			    vi config.json
			    break
			    ;;
			*) echo invalid option;;
		    esac
		done
	fi
	if [[ ! -e "$CONSENSUS_LOG_FILE" ]] ; then
		touch "$CONSENSUS_LOG_FILE"
	fi
	if [[ ! -e "$CONSENSUS_SH_FILE" ]] ; then
		wget "https://raw.githubusercontent.com/Stoner19/ONZCoinScripts/master/check_consensus.sh"
	fi

	echo "Starting consensus Script"
	nohup bash $CONSENSUS_SH_FILE -S $SRV  > $CONSENSUS_LOG_FILE 2>&1&
}

check_consensus_running() {
	# Check if it is running
	if pgrep -fl $CONSENSUS_SH_FILE > /dev/null
	then
		echo "Killing consensus process"
		pkill -f $CONSENSUS_SH_FILE -9
	else
		echo "Consensus is not currently running"
	fi
}

upgrade_consensus() {
	if [[ -e "$CONSENSUS_SH_FILE" ]] ;
	then
		rm "$CONSENSUS_SH_FILE"
	fi

	wget "https://raw.githubusercontent.com/Stoner19/ONZCoinScripts/master/check_consensus.sh"
	echo "Starting consensus Script"
	nohup bash $CONSENSUS_SH_FILE -S $SRV  > $CONSENSUS_SH_FILE 2>&1&
}

start_manage() {
	if [[ ! -e "$MANAGE_LOG_FILE" ]] ; then
		touch "$MANAGE_LOG_FILE"
	fi
	if [[ ! -e "$MANAGE_SH_FILE" ]] ; then
		wget "https://raw.githubusercontent.com/Stoner19/ONZCoinScripts/master/manage.sh"
	fi

	echo "Starting Management Script"
	nohup bash $MANAGE_SH_FILE -S $SRV  > $MANAGE_LOG_FILE 2>&1&
}

check_manage_running() {
	# Check if it is running
	if pgrep -fl $MANAGE_SH_FILE > /dev/null
	then
		echo "Killing management script process"
		pkill -f $MANAGE_SH_FILE -9
	else
		echo "Management script is not currently running"
	fi
}

status() {
	# Check if consensus is running
	if pgrep -fl $CONSENSUS_SH_FILE > /dev/null
	then
		echo "Consensus is running"
	else
		echo "Consensus is not currently running"
	fi

	# Check if heightRebuild is running
	if pgrep -fl $SH_FILE > /dev/null
	then
		echo "HeightRebuild is running"
	else
		echo "HeightRebuild is not currently running"
	fi

	# Check if manage.sh is running
	if pgrep -fl $MANAGE_SH_FILE > /dev/null
	then
		echo "Management script is running"
	else
		echo "Management script is not currently running"
	fi
}

logs() {
	LOG_FILES=""
	if [[ -e "$LOG_FILE" ]] ; then
		LOG_FILES+="-cT ANSI "$LOG_FILE" "
	fi
	if [[ -e "$CONSENSUS_LOG_FILE" ]] ; then
		LOG_FILES+="-cT ANSI "$CONSENSUS_LOG_FILE" "
	fi
	if [[ -e "$MANAGE_LOG_FILE" ]] ; then
		LOG_FILES+="-cT ANSI "$MANAGE_LOG_FILE" "
	fi
	multitail $LOG_FILES
}

usage() {
  echo "Usage: $0 <start|stop|upgrade>"
  echo "start			-- starts consensus & height_rebuild scripts"
  echo "startc			-- starts consensus script"
  echo "starth         		-- starts height_rebuild script"
  echo "startm         		-- starts manage script"
  echo "stop          		-- stops all scripts"
  echo "stopc          		-- stops consensus script"
  echo "stoph			-- stops height_rebuild script"
  echo "stopm         		-- stops manage script"
  echo "status          	-- check if scripts are running"
  echo "logs          		-- display all logs (requires multitail)"
  echo "upgrade       		-- upgrades and runs both scripts"
}

case $1 in
"start" )
	check_height_running
	start_height
	check_consensus_running
	start_consensus
;;
"startc" )
	check_consensus_running
	start_consensus
;;
"starth" )
	check_height_running
	start_height
;;
"startm" )
	check_manage_running
	start_manage
;;
"stop" )
	check_height_running
	check_consensus_running
	check_manage_running
;;
"stopc" )
	check_consensus_running
;;
"stoph" )
	check_height_running
;;
"stopm" )
	check_manage_running
;;
"status" )
	status
;;
"logs" )
	logs
;;
"upgrade" )
	check_height_running
	check_consensus_running

	upgrade_height
	upgrade_consensus
;;
*)
	echo "Error: Unrecognized command."
	echo ""
	echo "Available commands are: "
	usage
	exit 1
exit 1
;;
esac
