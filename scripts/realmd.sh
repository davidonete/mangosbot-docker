#!/bin/bash

PROCESS_PID=0

function initialize 
{
	# Move binaries to correct folder
	if [ -d "/opt/cmangos/bin2" ]; then
		mv -f /opt/cmangos/bin2/* /opt/cmangos/bin
		rm -rf /opt/cmangos/bin2
	fi

	return 0
}

function start 
{
	if [ ! -f "/opt/cmangos/etc/.initialized" ]; then
		echo "Waiting for mangosd server to initialize..."
		
		ELAPSED_TIME=0
		while [ ! -f "/opt/cmangos/etc/.initialized" ] && [ "$ELAPSED_TIME" -lt 900 ]; do
			sleep 5
			ELAPSED_TIME=$((ELAPSED_TIME + 5))
		done
	fi
	
	if [ -f "/opt/cmangos/etc/.initialized" ]; then
		echo "Realmd server initialized"
		
		echo "Starting realmd server...";
		cd /opt/cmangos/bin
		./realmd
		
		# Save the process PID
		PROCESS_PID=$!
		
		echo "Realmd server started (PID ${PROCESS_PID})"

		# Loop indefinitely until the process is stopped or interrupted
		while true; do
			if ! ps -p "$PROCESS_PID" > /dev/null; then
				echo "Realmd server stoped gracefully"
				return 0
			fi
		
			sleep 5;
		done
	else
		echo "[ERR] Timeout while waiting for realmd server to initialize"
		return 1
	fi
}

function stop
{
	exit 0;
}

# Check ENV settings and print them.
echo "==========[ CMaNGOS realmd Init ]==========";
echo "[INFO] DB_SERVER: ${DB_SERVER}";
echo "[INFO] DB_PORT: ${DB_PORT}";
echo "";

# wait for mysql database to initialize
/opt/cmangos/scripts/wait-for-it.sh ${DB_SERVER}:${DB_PORT} -t 900
if [ $? -ne 0 ]; then
	echo "[ERR] Timeout while waiting for ${DB_SERVER}!";
	exit 1;
else
	if ! initialize; then
		exit 1;
	fi

	# Trap SIGTERM and call the stop function
	trap stop SIGTERM

	if ! start; then
		exit 1;
	fi

	exit 0;
fi