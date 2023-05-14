# mangosbot-docker

# How to use
To generate the docker image you just need to download this repository and set up a couple things before starting the container

## Set up the Mangosd Data
You will need to generate or download the vmaps, mmaps, etc...  and place it in the data folder

## Custom sql
You can place all your custom sql on the sql/custom folder and it will get executed at the initialization state in alphabetical order. Keep in mind it needs to be placed into the world/realms/playerbots folder depending on what the sql is editing

## Backups
Server backups will be done at server shutdown automatically and placed in the backup folder. Please let the server stop gracefully to avoid rollbacks and other nasty stuff. It does take a while, just go get a coffee.

# Start the container
Just do "docker-compose up -d" in the main folder of the container. First launch will get a very long time as the docker needs to build the code and initialize the database.

# Stop the container
To stop the container without issues you should stop the mangosd container first and let it close itself, it does take a while because it has to disconnect all bots and backup everything. Don't force kill the container or you will probably get a rollback on your progress. After mangosd has closed you can close the database and realmd containers

You can edit the timeout for the docker compose to stop in the docker-compose.yml file changing the stop_grace_period, in case your container gets stuck

# Reinstall the container
To make a fresh install of the container you should remove the ".initialized" file in the config file and remove all the containers from docker. After that you can do the "docker-compose up -d" to restart it

# How to use the mangosd command window
As docker doesn't allow direct input on the containers, there are two workarounds for sending commands to the mangosd service:

- Use the dedicated script on the mangosd container through a new terminal. You can call the script located in: /opt/cmangos/scripts/mangosd.sh and send mangosd commands just like this: ./mangosd.sh command "account create username password"
- Connect through telnet to the mangosd service: telnet <docker-ip> <mangosd-port (default 3443)> If you don't have a username created you will only be allowed to use the default one: username: administrator password: administrator
