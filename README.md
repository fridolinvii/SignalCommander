# SignalCommander

This gives to some extend a step by step explanation, how you can control your server with the Messagener app Signal. 
Currently, you can send a message with a torrent link and it will download this torrent on your server. In addition you can check status, etc of the torrent app.


## Installing 

### installing signal-cli
I follwed the description to install it from this GitHub repository: [signal-cli](https://github.com/AsamK/signal-cli) and [https://oren.github.io/articles/signal-terminal/](https://oren.github.io/articles/signal-terminal/).
There are two option you can use signal-cli. Either you register a new phone number or you add it to your **Linked devices** on your phone.

##### Option 1: Register new number
You can register your number:
```
signal-cli -a [YOUR_NUMBER] register
```
You will recive a CODE per SMS and you can verify it with the command:
```
signal-cli -a [YOUR_NUMBER] verify [CODE]
```

##### Option 2: **Linked devices**
If you want to link signal-cli instead of register a new number run the following command
```
signal-cli link -n "[NAME]"
```
This will generate a link. Create a QR-Code from this link and scan it with you mobile device. 
Do not generate the QR-Code online, but rather generate it on your local machine if possible.

### ***install torrent client**
To install the torrent client use
```
sudo apt install transmission-cli transmission-daemon
```

You need to do some additional changes:
```
sudo nano /etc/transmission-daemon/settings.json
```
find *"rpc-authentication-required"* and set it to false:
```
"rpc-authentication-required": false,
```
And if you want to change the download folder to */path/to/folder* edit:
```
"download-dir": "/path/to/folder",
```
```
"incomplete-dir": "/path/to/folder/incomplete",
```
And change the owner of the folder to:
```
sudo chown debian-transmission:debian-transmission -R [/path/to/folder]
```

# Change username in these files to access the folder you choose
sudo nano /etc/init.d/transmission-daemon


# change here the username to yours + add your username to the groupe transmission-daemon, and change the folder permission accodingly


https://askubuntu.com/questions/221081/permission-denied-when-downloading-with-transmission-daemon
"rpc-authentication-required": true, -> change to false
sudo nano /etc/transmission-daemon/settings.json
sudo chown debian-transmission:debian-transmission -R Videos
