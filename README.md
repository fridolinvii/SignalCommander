# SignalCommander

This gives to some extend a step by step explanation, how you can control your server with the Messagener app Signal. 
Currently, you can send a message with a torrent link and it will download this torrent on your server. In addition you can check status, etc of the torrent app.


## Installing 

### installing signal-cli
I follwed the description to install it from this GitHub repository: [signal-cli](https://github.com/AsamK/signal-cli).




# Change username in these files to access the folder you choose
sudo nano /etc/init.d/transmission-daemon


# change here the username to yours + add your username to the groupe transmission-daemon, and change the folder permission accodingly


https://askubuntu.com/questions/221081/permission-denied-when-downloading-with-transmission-daemon
"rpc-authentication-required": true, -> change to false
sudo nano /etc/transmission-daemon/settings.json
sudo chown debian-transmission:debian-transmission -R Videos
