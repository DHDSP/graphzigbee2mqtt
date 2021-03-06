#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

MQTT_USERNAME=$(jq --raw-output ".mqtt_username" $CONFIG_PATH)
MQTT_PASSWORD=$(jq --raw-output ".mqtt_password" $CONFIG_PATH)
MQTT_HOST=$(jq --raw-output ".mqtt_host" $CONFIG_PATH)
MQTT_DOTTOPIC=$(jq --raw-output ".mqtt_dottopic" $CONFIG_PATH)
MQTT_IMAGETOPIC=$(jq --raw-output ".mqtt_imagetopic" $CONFIG_PATH)
MQTT_PORT=$(jq --raw-output ".mqtt_port" $CONFIG_PATH)


echo "------------------------------------------------------------------------------------"
echo "$(date -u) [INFO] Using mqtt username: $MQTT_USERNAME"
echo "$(date -u) [INFO] Using mqtt host: $MQTT_HOST"
echo "$(date -u) [INFO] Using mqtt serverport: $MQTT_PORT"
echo "$(date -u) [INFO] Using mqtt topic for receiving the graphviz dotfile: $MQTT_DOTTOPIC"
echo "$(date -u) [INFO] Using mqtt topic for sending the .png image: $MQTT_IMAGETOPIC"
echo "------------------------------------------------------------------------------------"

while true
do

echo "$(date -u) [INFO] Now connecing to mqtt server with the following command:"
echo "$(date -u) [INFO] mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -P notdisclosed -u $MQTT_USERNAME -C 1 -t $MQTT_DOTTOPIC | circo -Tpng > latest_network_scan.png"
echo "$(date -u) [INFO] waiting for a dotfile to arrive..."

mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -P $MQTT_PASSWORD -u $MQTT_USERNAME -C 1 -t $MQTT_DOTTOPIC | circo -Tpng > latest_network_scan.png

echo "$(date -u) [INFO] received dotfile and generated .png"

echo "$(date -u) [INFO] Now sending the .png with command:"
echo "$(date -u) [INFO] mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -P $MQTT_PASSWORD -u $MQTT_USERNAME -t $MQTT_IMAGETOPIC -f latest_network_scan.png"

mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -P $MQTT_PASSWORD -u $MQTT_USERNAME -t $MQTT_IMAGETOPIC -f latest_network_scan.png
echo "------------------------------------------------------------------------------------"

done


# DATABASES=$(jq --raw-output ".databases[]" $CONFIG_PATH)
# LOGINS=$(jq --raw-output '.logins | length' $CONFIG_PATH)
# RIGHTS=$(jq --raw-output '.rights | length' $CONFIG_PATH)

# Init mariadb
#if [ ! -d "$MARIADB_DATA" ]; then
#    echo "[INFO] Create a new mariadb initial system"
#    mysql_install_db --user=root --datadir="$MARIADB_DATA" > /dev/null
#else
#    echo "[INFO] Use exists mariadb initial system"
#fi

# Start mariadb
#echo "[INFO] Start MariaDB"
#mysqld_safe --datadir="$MARIADB_DATA" --user=root --skip-log-bin < /dev/null &
#MARIADB_PID=$!

# Wait until DB is running
#while ! mysql -e "" 2> /dev/null; do
#    sleep 1
#done

# Init databases
#echo "[INFO] Init custom database"
#for line in $DATABASES; do
#    echo "[INFO] Create database $line"
#    mysql -e "CREATE DATABASE $line;" 2> /dev/null || true
#done

# Init logins
#echo "[INFO] Init/Update users"
#for (( i=0; i < "$LOGINS"; i++ )); do
#    USERNAME=$(jq --raw-output ".logins[$i].username" $CONFIG_PATH)
#    PASSWORD=$(jq --raw-output ".logins[$i].password" $CONFIG_PATH)
#    HOST=$(jq --raw-output ".logins[$i].host" $CONFIG_PATH)

#    if mysql -e "SET PASSWORD FOR '$USERNAME'@'$HOST' = PASSWORD('$PASSWORD');" 2> /dev/null; then
#        echo "[INFO] Update user $USERNAME"
#    else
#        echo "[INFO] Create user $USERNAME"
#        mysql -e "CREATE USER '$USERNAME'@'$HOST' IDENTIFIED BY '$PASSWORD';" 2> /dev/null || true
#    fi
#done

# Init rights
#echo "[INFO] Init/Update rights"
#for (( i=0; i < "$RIGHTS"; i++ )); do
#    USERNAME=$(jq --raw-output ".rights[$i].username" $CONFIG_PATH)
#    HOST=$(jq --raw-output ".rights[$i].host" $CONFIG_PATH)
#    DATABASE=$(jq --raw-output ".rights[$i].database" $CONFIG_PATH)
#    GRANT=$(jq --raw-output ".rights[$i].grant" $CONFIG_PATH)
#
#    echo "[INFO] Alter rights for $USERNAME@$HOST - $DATABASE"
#    mysql -e "GRANT $GRANT $DATABASE.* TO '$USERNAME'@'$HOST';" 2> /dev/null || true
#done

# Register stop
#function stop_mariadb() {
#    mysqladmin shutdown
#}
#trap "stop_mariadb" SIGTERM SIGHUP

#wait "$MARIADB_PID"
