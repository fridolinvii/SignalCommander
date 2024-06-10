
# Change username in these files to access the folder you choose
sudo nano /etc/init.d/transmission-daemon


# change here the username to yours + add your username to the groupe transmission-daemon, and change the folder permission accodingly


https://askubuntu.com/questions/221081/permission-denied-when-downloading-with-transmission-daemon
"rpc-authentication-required": true, -> change to false
sudo nano /etc/transmission-daemon/settings.json
sudo chown debian-transmission:debian-transmission -R Videos
