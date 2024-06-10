# SignalCommander
This provides a step-by-step guide on how to control your server using the Signal messaging app.

Currently, you can send a message containing a torrent link, and the server will download the torrent. Additionally, you can check the status and perform other operations on the torrent application.

## 1. Installing 

First Download the Github repository and enter it:
```
git clone git@github.com:fridolinvii/SignalCommander.git
cd SignalCommander
```


### 1.1 Installing signal-cli
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


### 1.2 Signal Groupe
Create a signal groupe. You can check all the groups you have access to with:
```
signal-cli listGroups
```
Find your Groupe name, and copy the Id into 
```
nano .env
```
under the variabel name
```
TARGET_GROUP_ID=[Id]
```


### 1.3 Install torrent client
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
Or change the *USER* in 
```
sudo nano /etc/init.d/transmission-daemon
```

### 1.4 Activate autostart transmission
Enable and start *transmission-daemon*
```
sudo systemctl enable transmission-daemon
sudo systemctl start transmission-daemon
```
To check the status and error of *transmission-daemon*
```
sudo systemctl start transmission-daemon
```

If you edit */etc/transmission-daemon/settings.json* or/and */etc/init.d/transmission-daemon* you either need to stop and start the *transmission-daemon*, or restart the *transmission-daemon*
```
sudo systemctl [restart|stop|start] transmission-daemon
```




# TO DO: 
* How to find signal group
* setup automation of automation with crontab
* sudo nano /etc/init.d/transmission-daemon