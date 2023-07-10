#!/bin/bash

DB_BACKUP_CHARACTERS_DIR="/opt/cmangos/backup/characters"
DB_BACKUP_REALMD_DIR="/opt/cmangos/backup/realmd"
DB_BACKUP_PLAYERBOTS_DIR="/opt/cmangos/backup/playerbots"
DB_DAYS_TO_KEEP_BACKUP=7
PROCESS_PID=0
STOPING_PROCESS=0

function backup_characters_db
{
	echo "Backing up Characters DB..."
	mkdir -p "$DB_BACKUP_CHARACTERS_DIR"
	TIMESTAMP=$(date +"%Y%m%d%H%M%S")
	DB_BACKUP_FILE="$DB_BACKUP_CHARACTERS_DIR/$CHARACTERS_DB-$TIMESTAMP.sql"
	mysqldump -h "$DB_SERVER" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" --no-create-info --replace "$CHARACTERS_DB" > "$DB_BACKUP_FILE"
	
	# Check if the backup was successful
	if [[ $? -eq 0 ]]; then
		echo "Backup created successfully: $DB_BACKUP_FILE"

		# Cleanup old backup files
		find "$DB_BACKUP_CHARACTERS_DIR" -type f -mtime +$DB_DAYS_TO_KEEP_BACKUP -delete
		echo "Old backup files removed."
		return 0
	else
		echo "Backup failed."
		return 1
	fi
}

function backup_realmd_db
{
	echo "Backing up Realmd DB..."
	mkdir -p "$DB_BACKUP_REALMD_DIR"
	TIMESTAMP=$(date +"%Y%m%d%H%M%S")
	DB_BACKUP_FILE="$DB_BACKUP_REALMD_DIR/$REALMD_DB-$TIMESTAMP.sql"
	mysqldump -h "$DB_SERVER" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" --no-create-info --replace "$REALMD_DB" > "$DB_BACKUP_FILE"
	
	# Check if the backup was successful
	if [[ $? -eq 0 ]]; then
		echo "Backup created successfully: $DB_BACKUP_FILE"

		# Cleanup old backup files
		find "$DB_BACKUP_REALMD_DIR" -type f -mtime +$DB_DAYS_TO_KEEP_BACKUP -delete
		echo "Old backup files removed."
		return 0
	else
		echo "Backup failed."
		return 1
	fi
}

function backup_playerbots_db
{
	echo "Backing up Playerbots DB..."
	mkdir -p "$DB_BACKUP_PLAYERBOTS_DIR"
	TIMESTAMP=$(date +"%Y%m%d%H%M%S")
	DB_BACKUP_FILE="$DB_BACKUP_PLAYERBOTS_DIR/$PLAYERBOTS_DB-$TIMESTAMP.sql"
	mysqldump -h "$DB_SERVER" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" --no-create-info --replace "$PLAYERBOTS_DB" > "$DB_BACKUP_FILE"
	
	# Check if the backup was successful
	if [[ $? -eq 0 ]]; then
		echo "Backup created successfully: $DB_BACKUP_FILE"

		# Cleanup old backup files
		find "$DB_BACKUP_PLAYERBOTS_DIR" -type f -mtime +$DB_DAYS_TO_KEEP_BACKUP -delete
		echo "Old backup files removed."
		return 0
	else
		echo "Backup failed."
		return 1
	fi
}

function restore_backup_characters_db
{
	echo "Checking for previous back up to restore for Characters DB..."
	if [ -d "$DB_BACKUP_CHARACTERS_DIR" ]; then
		NEWEST_BACKUP=$(ls -t "$DB_BACKUP_CHARACTERS_DIR"/*.sql | head -n 1)
		if [ -z "$NEWEST_BACKUP" ]; then
			echo "No backup file found in $DB_BACKUP_CHARACTERS_DIR"
			return 1
		fi
		
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$CHARACTERS_DB" < "$NEWEST_BACKUP"
		if [[ $? -eq 0 ]]; then
			echo "Backup restored successfully from: $NEWEST_BACKUP"
			return 0
		else
			echo "Backup restore failed."
			return 1
		fi
	fi
	
	echo "No backup files found..."
	return 1
}

function restore_backup_realmd_db
{
	echo "Checking for previous back up to restore for Realmd DB..."
	if [ -d "$DB_BACKUP_REALMD_DIR" ]; then
		NEWEST_BACKUP=$(ls -t "$DB_BACKUP_REALMD_DIR"/*.sql | head -n 1)
		if [ -z "$NEWEST_BACKUP" ]; then
			echo "No backup file found in $DB_BACKUP_REALMD_DIR"
			return 1
		fi
		
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$REALMD_DB" < "$NEWEST_BACKUP"
		if [[ $? -eq 0 ]]; then
			echo "Backup restored successfully from: $NEWEST_BACKUP"
			return 0
		else
			echo "Backup restore failed."
			return 1
		fi
	fi
	
	echo "No backup files found..."
	return 1
}

function restore_backup_playerbots_db
{
	echo "Checking for previous back up to restore for Playerbots DB..."
	if [ -d "$DB_BACKUP_PLAYERBOTS_DIR" ]; then
		NEWEST_BACKUP=$(ls -t "$DB_BACKUP_PLAYERBOTS_DIR"/*.sql | head -n 1)
		if [ -z "$NEWEST_BACKUP" ]; then
			echo "No backup file found in $DB_BACKUP_PLAYERBOTS_DIR"
			return 1
		fi
		
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$PLAYERBOTS_DB" < "$NEWEST_BACKUP"
		if [[ $? -eq 0 ]]; then
			echo "Backup restored successfully from: $NEWEST_BACKUP"
			return 0
		else
			echo "Backup restore failed."
			return 1
		fi
	fi
	
	echo "No backup files found..."
	return 1
}

function initialize_database
{
	echo "Initializing mangosd database..."
	
	echo "Creating databases..."
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "create database ${CHARACTERS_DB};"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "create database ${LOGS_DB};"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "create database ${MANGOSD_DB};"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "create database ${REALMD_DB};"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "create database ${PLAYERBOTS_DB};"
	
	echo "Creating database user..."
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "create user '${DB_USER}'@'%' identified by '${DB_PASS}';"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "grant all privileges on ${CHARACTERS_DB}.* to '${DB_USER}'@'%';"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "grant all privileges on ${LOGS_DB}.* to '${DB_USER}'@'%';"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "grant all privileges on ${MANGOSD_DB}.* to '${DB_USER}'@'%';"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "grant all privileges on ${REALMD_DB}.* to '${DB_USER}'@'%';"
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} -e "grant all privileges on ${PLAYERBOTS_DB}.* to '${DB_USER}'@'%';"
	
	# Get latest version
	rm -rf /tmp/cmangos
	rm -rf /tmp/db
	echo "Getting latest cmangos core from https://github.com/celguar/mangos-classic.git --branch ike3-bots..."
	git clone https://github.com/celguar/mangos-classic.git --branch ike3-bots /tmp/cmangos
	echo "Getting latest playerbots module from https://github.com/celguar/mangosbot-bots.git..."
	git clone https://github.com/celguar/mangosbot-bots.git /tmp/cmangos/src/modules/Bots
	echo "Getting latest database files from https://github.com/celguar/classic-db.git..."
	git clone https://github.com/celguar/classic-db.git /tmp/db
	
	# Create default database structures
	echo "Create base Characters database"
	if [ -f /tmp/cmangos/sql/base/characters.sql ]; then
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${CHARACTERS_DB} < /tmp/cmangos/sql/base/characters.sql
	fi

	echo "Create base Logs database"
	if [ -f /tmp/cmangos/sql/base/logs.sql ]; then
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${LOGS_DB} < /tmp/cmangos/sql/base/logs.sql
	fi

	echo "Create base World database"
	if [ -f /tmp/cmangos/sql/base/mangos.sql ]; then
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${MANGOSD_DB} < /tmp/cmangos/sql/base/mangos.sql
	fi

	echo "Create base Realmd database"
	if [ -f /tmp/cmangos/sql/base/realmd.sql ]; then
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${REALMD_DB} < /tmp/cmangos/sql/base/realmd.sql
	fi

	echo "Create base Playerbots database"
	if [ -f /tmp/cmangos/src/modules/Bots/sql/playerbot/playerbot.sql ]; then
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${PLAYERBOTS_DB} < /tmp/cmangos/src/modules/Bots/sql/playerbot/playerbot.sql
	fi
	
	# Copy install script
	cp -v /opt/cmangos/etc/InstallFullDB.config /tmp/db/InstallFullDB.config
	chmod 777 /tmp/db/InstallFullDB.config
	cp -vrf /opt/cmangos/scripts/InstallFullDB.sh /tmp/db/InstallFullDB.sh
	chmod 777 /tmp/db/InstallFullDB.sh
	
	# Set ADMINISTRATOR account to level 4 and lock it down and remove other default accounts
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${REALMD_DB} -e 'UPDATE `account` SET gmlevel = "4", locked = "1" WHERE id = "1" LIMIT 1;'
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${REALMD_DB} -e 'DELETE FROM `account` WHERE id = "2" LIMIT 1;'
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${REALMD_DB} -e 'DELETE FROM `account` WHERE id = "3" LIMIT 1;'
	mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${REALMD_DB} -e 'DELETE FROM `account` WHERE id = "4" LIMIT 1;'
	
	# Run install script
	cd /tmp/db
	./InstallFullDB.sh -World
	
	# Check the exit status
	if [[ $? -eq 0 ]]; then
		# Install all sql files placed in the sql custom folder
		echo "> Trying to apply custom sql for characters db..."
		for UPDATEFILE in /opt/cmangos/sql/custom/characters/*.sql; do
			if [ -e "$UPDATEFILE" ]; then
				echo "$UPDATEFILE..."
				mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${CHARACTERS_DB} < ${UPDATEFILE}
			fi
		done
		
		echo "> Trying to apply custom sql for realm db..."
		for UPDATEFILE in /opt/cmangos/sql/custom/realmd/*.sql; do
			if [ -e "$UPDATEFILE" ]; then
				echo "$UPDATEFILE..."
				mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${REALMD_DB} < ${UPDATEFILE}
			fi
		done
		
		echo "> Trying to apply custom sql for world db..."
		for UPDATEFILE in /opt/cmangos/sql/custom/world/*.sql; do
			if [ -e "$UPDATEFILE" ]; then
				echo "$UPDATEFILE..."
				mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${MANGOSD_DB} < ${UPDATEFILE}
			fi
		done
		
		echo "> Trying to apply custom sql for playerbots db..."
		for UPDATEFILE in /opt/cmangos/sql/custom/playerbots/*.sql; do
			if [ -e "$UPDATEFILE" ]; then
				echo "$UPDATEFILE..."
				mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${PLAYERBOTS_DB} < ${UPDATEFILE}
			fi
		done
	
		# Check if we can restore any backup files
		restore_backup_characters_db
		restore_backup_realmd_db
		restore_backup_playerbots_db
		
		# Cleanup
		cd /
		rm -rf /tmp/db
		rm -rf /tmp/cmangos
		
		return 0
	else
		# Cleanup
		cd /
		rm -rf /tmp/db
		rm -rf /tmp/cmangos
		
		return 1
	fi
}

function initialize 
{
    # Move new binaries to correct folder
	if [ -d "/opt/cmangos/bin2" ]; then
		rm -rf /opt/cmangos/bin/warden_modules
		mv -f /opt/cmangos/bin2/* /opt/cmangos/bin
		rm -rf /opt/cmangos/bin2
	fi
	
	if [ -f "/opt/cmangos/etc/.manual_stop" ]; then
		rm -rf /opt/cmangos/etc/.manual_stop
	fi
    
	# Check if already initialized
	if [ -f "/opt/cmangos/etc/.initialized" ]; then
		# TODO Check for updates
		# ...
		
		return 0
	else
	    echo "Initializing mangosd server...";

		if ! initialize_database; then
			return 1
		fi

	    # Create .initialized file
	    touch /opt/cmangos/etc/.initialized

	    return 0
	fi
}

get_process_pid()
{
	local PID=$PROCESS_PID
	if [ "$PID" -eq 0 ]; then
		# Get the process pid by name
		PID=$(pgrep -x "mangosd")
		
		if [ -z "$PID" ]; then
			PID=0
		fi
	fi
	
	echo $PID
}

command()
{
	PROCESS_PID=$(get_process_pid)
	
	if ps -p $PROCESS_PID > /dev/null; then
		echo "Sending command to mangosd server: $1"
		echo "$1" > /proc/$PROCESS_PID/fd/0
		return 0
	else
		echo "The mangosd server is not running"
		return 1
	fi
}

function reset_randombots
{
	# Check if already set to reset bots
	if [ -f "/opt/cmangos/etc/.reset_randombots" ]; then
		rm -rf /opt/cmangos/etc/.reset_randombots
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${PLAYERBOTS_DB} < /opt/cmangos/sql/reset_randombots.sql
		echo "Bots will be scheduled to be reset on server restart"
	fi
	
	return 0
}

function delete_randombots
{
	# Check if already set to delete bots (not in player friends list or guild)
	if [ -f "/opt/cmangos/etc/.delete_randombots" ]; then
		rm -rf /opt/cmangos/etc/.delete_randombots
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${PLAYERBOTS_DB} < /opt/cmangos/sql/delete_randombots.sql
		echo "Bots will be scheduled to be deleted on server restart"
	fi
	
	return 0
}

function delete_all_randombots
{
	# Check if already set to reset bots
	if [ -f "/opt/cmangos/etc/.delete_all_randombots" ]; then
		rm -rf /opt/cmangos/etc/.delete_all_randombots
		mysql -h "$DB_SERVER" -P "$DB_PORT" -u${DB_ROOT_USER} -p${DB_ROOT_PASS} ${PLAYERBOTS_DB} < /opt/cmangos/sql/delete_all_randombots.sql
		echo "Bots will be scheduled to be deleted on server shutdown"
	fi
	
	return 0
}

function schedule_reset_randombots
{
	# Check if already set to reset bots
	if [ ! -f "/opt/cmangos/etc/.reset_randombots" ]; then
		touch /opt/cmangos/etc/.reset_randombots
	fi
	
	echo "Bots will be scheduled to be reset on server restart"
	return 0
}

function schedule_delete_randombots
{
	# Check if already set to delete bots (not in player friends list or guild)
	if [ ! -f "/opt/cmangos/etc/.delete_randombots" ]; then
		touch /opt/cmangos/etc/.delete_randombots
	fi
	
	echo "Bots will be scheduled to be deleted on server restart"
	return 0
}

function schedule_delete_all_randombots
{
	# Check if already set to reset bots
	if [ ! -f "/opt/cmangos/etc/.delete_all_randombots" ]; then
		touch /opt/cmangos/etc/.delete_all_randombots
	fi
	
	echo "Bots will be scheduled to be deleted on server shutdown"
	return 0
}

function schedule_stop
{
	# Check if already requested to stop
	if [ ! -f "/opt/cmangos/etc/.manual_stop" ]; then
		# Create .manual_stop file
		touch /opt/cmangos/etc/.manual_stop
		echo "Sending shutdown request..."
		command "server shutdown 300"
		command "saveall"
		return 0
	fi
	
	echo "Server already scheduled to shutdown"
	return 1
}

function stop
{
	PROCESS_PID=$(get_process_pid)
	
	if [ "$PROCESS_PID" -ne 0 ]; then
		# Check if PID is valid
		echo "Stoping mangosd server..."
		if kill -0 $PROCESS_PID 2>/dev/null; then
		
			# Check if already requested to stop
			if [ ! -f "/opt/cmangos/etc/.manual_stop" ]; then
				# Create .manual_stop file
				touch /opt/cmangos/etc/.manual_stop
				
				STOPING_PROCESS=1
				echo "Sending shutdown request..."
				command "saveall"
				command "server shutdown 1"
				#echo "server shutdown 1" >&3
			fi
			
			# Close the input pipe
			exec 3>&-
			
			while [ -e /proc/$PROCESS_PID ]; do sleep 5; done
			echo "Mangosd server stopped"
			
			reset_randombots
			delete_randombots
			delete_all_randombots
		
			echo "Backing up Database..."
			if ! backup_characters_db; then
				exit 1;
			fi
			
			if ! backup_realmd_db; then
				exit 1;
			fi
			
			if ! backup_playerbots_db; then
				exit 1;
			fi
			
			return 0
		else
			echo "The mangosd server was already stopped"
		fi
	else
		echo "The mangosd server is not running"
		return 1
	fi
}

function interrupt
{
	echo "Mangosd server interrupted"
	exec 3>&-
	
	crash_log_dir="/opt/cmangos/logs/crash"
	timestamp=$(date +"%Y%m%d%H%M%S")
	filename="crashdump-${timestamp}.txt"
	
	source_file="/opt/cmangos/bin/gdb.txt"
	destination_file="${crash_log_dir}/${filename}"
	
	echo "Creating crash dump file in ${destination_file}"
	mv "$source_file" "${destination_file}"
}

function start 
{
	PROCESS_PID=$(get_process_pid)

	if [ "$PROCESS_PID" -ne 0 ]; then
		echo "The mangosd server is already running"
		return 1
	else
		# Check ENV settings and print them.
		echo "==========[ CMaNGOS mangosd Init ]==========";
		echo "[INFO] CHARACTERS_DB: ${CHARACTERS_DB}";
		echo "[INFO] LOGS_DB: ${LOGS_DB}";
		echo "[INFO] MANGOSD_DB: ${MANGOSD_DB}";
		echo "[INFO] REALMD_DB: ${REALMD_DB}";
		echo "[INFO] PLAYERBOTS_DB: ${PLAYERBOTS_DB}";
		echo "[INFO] DB_USER: ${DB_USER}";
		echo "[INFO] DB_PASS: ${DB_PASS}";
		echo "[INFO] DB_PORT: ${DB_PORT}";
		echo "[INFO] DB_SERVER: ${DB_SERVER}";
		echo "";

		# wait for mysql database to initialize
		/opt/cmangos/scripts/wait-for-it.sh ${DB_SERVER}:${DB_PORT} -t 900
		if [ $? -ne 0 ]; then
			echo "[ERR] Timeout while waiting for ${DB_SERVER}!";
			return 1
		else
			if ! initialize; then
				return 1
			fi
			
			# Trap SIGTERM and call the stop function
			trap stop SIGTERM

			echo "Starting mangosd server...";
			cd /opt/cmangos/bin
			
			# Set up an input pipe
			rm /tmp/mangosd_input_pipe
			mkfifo /tmp/mangosd_input_pipe
			
			gdb -x /opt/cmangos/etc/gdb.conf --batch ./mangosd < /tmp/mangosd_input_pipe &
			
			# Save the process PID
			PROCESS_PID=$!
			
			# Open the input pipe for writing
			exec 3> /tmp/mangosd_input_pipe
			
			echo "Mangosd server started (PID ${PROCESS_PID})"

			# Loop indefinitely until the process is stopped or interrupted
			while true; do
				if ! ps -p "$PROCESS_PID" > /dev/null; then
					if [[ $STOPING_PROCESS -eq 0 && ! -f "/opt/cmangos/etc/.manual_stop" ]]; then
						interrupt
						return 1
					else
						echo "Mangosd server stoped gracefully"
						return 0
					fi
				fi
			
				sleep 5;
			done
		fi
	fi
}

# Check if the number of arguments is valid
if [ $# -lt 1 ]; then
    echo "Please specify the action you want (start/stop/command)"
    exit 1
fi

action=$1

case $action in
    "start")
        if start; then
			exit 0
		fi
		
		exit 1
        ;;
    "stop")
        if schedule_stop; then
			exit 0
		fi
		
		exit 1
        ;;
    "command")
        if [ $# -lt 2 ]; then
            echo "Insufficient arguments for command. Please specify the command with the following format: command \"cmangos command to execute\""
            exit 1
        fi
		
        argument=$2
		if command "$argument"; then
			exit 0
		fi
		
		exit 1
        ;;
    "reset-randombots")
        if schedule_reset_randombots; then
			exit 0
		fi
		
		exit 1
        ;;
    "delete-randombots")
        if schedule_delete_randombots; then
			exit 0
		fi
		
		exit 1
        ;;
    "delete-all-randombots")
        if schedule_delete_all_randombots; then
			exit 0
		fi
		
		exit 1
        ;;
    "backup")
        if backup_characters_db; then
			exit 0
		fi
		
		if backup_realmd_db; then
			exit 0
		fi
		
		if backup_playerbots_db; then
			exit 0
		fi
		
		exit 1
        ;;
    *)
        echo "Invalid action: $action"
        exit 1
        ;;
esac

exit 1