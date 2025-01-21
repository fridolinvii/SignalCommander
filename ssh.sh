# Run this on first time starting 

source .env

ssh -i $PATH_PRIVATE_KEY -tt -R $PORT_LOCAL:0.0.0.0:$PORT_GLOBAL $DOCKER_USER_NAME@$DOCKER_SITE_ADDRESS -p $PORT_SSH
