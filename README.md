# SignalCommander
This provides a step-by-step guide on how to control your server using the Signal messaging app.

Currently, you can send a message containing a torrent link, and the server will download the torrent. Additionally, you can check the status and perform other operations on the torrent application.
In addition, you can send LaTeX files in a zip file and convert them to a PDF.

## 1. Setup & Installation 

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


### 1.2 Signal Group
Create a signal Group. You can check all the groups you have access to with:
```
signal-cli listGroups
```
Find your Group name, and copy the Id into 
```
nano .env
```
under the variable name
```
TARGET_GROUP_ID='["Id"]'
```
If you have multiple groups:
TARGET_GROUP_ID='["Id1","Id2",...]'

### 1.3 Install torrent client
To install the torrent client use
```
sudo apt install transmission-cli transmission-daemon
```


 <!---And if you want to change the download folder to */path/to/folder* edit:
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
Or change the *USER* in (unclear if this works)
```
sudo nano /etc/init.d/transmission-daemon
```
--->
### 1.4 Activate autostart transmission
Enable and start *transmission-daemon*
```
sudo systemctl enable transmission-daemon
sudo systemctl start transmission-daemon
sudo service transmission-daemon start
```
To check the status and error of *transmission-daemon*
```
systemctl status transmission-daemon
```
You need to do some additional changes. To do so stop the *transmission-daemon*
```
sudo systemctl stop transmission-daemon
```
Edit the file
```
sudo nano /etc/transmission-daemon/settings.json
```
find *"rpc-authentication-required"* and set it to false:
```
"rpc-authentication-required": false,
```
and start the *transmission-daemon*
```
sudo systemctl start transmission-daemon
```

### 1.5  Compatibility
Install LaTeX on the server (and any additional packages you want and need).
```
sudo apt install texlive-latex-base texlive-fonts-recommended -y
sudo apt install texlive-fonts-extra texlive-xetex texlive-science -y
sudo apt install texlive-lang-german texlive-latex-extra texlive-font-utils -y
sudo apt install latexmk -y
sudo apt install biber -y
```


### 1.6 Automation 
If you send a message in the Group, you can run the script:
```
./signal_listening.sh
```
This will check for new Signal messages, filter the ones which were used in the Group, and are further processed. See further down for the commands.

If you want to automate the process:
```
crontab -e
```
and add a following line:
```
*/5 * * * * /[PATH]/signal_listening.sh >> /[PATH]/signal_listening_crontab.log 2>&1 &
```
Change the *PATH* accordingly. A logfile is created under the name `signal_listening_crontab.log`. Every 5min the bash-script is executed.

## 2. Download Files
```
sudo apt install p7zip-full
python -m venv venv
source venv/bin/activate
pip install flask
pip install gunicorn

```


## 3. Commands
In the Signal Group you created, you can send commands, which will be read and executed. You will recieve a txt file with with the report.
Each message should only contain one command, or an error may arrise. If you don't recieve a message, either the command is unvalid or there is an error.

### 3.1 General Commands
| Command        | Description                            |
|----------------|----------------------------------------|
| `help`         | Display available commands.            |


### 3.2 Torrent Commands
| Command         | Description                            |
|-----------------|----------------------------------------|
| `magnet:?xt=...`| Download torrent using a magnet link.  |
| `status`        | Check the status of current torrents.  |
| `delete_all`    | Delete all torrents.                   |
| `delete_1-3,5`  | Delete torrents 1-3, and 5.            |

### 3.3 LaTeX Commands
Only one zip file can be converted to a PDF at a time. Attach the zip file to the message and specify which file should be converted, e.g., `main.tex`.

| Attachment | Text | Description |
|------------|------|-------------|
| file.zip   | main.tex | Convert main.tex from file.zip into a pdf|
| file.zip   | main.tex log | Converts main.tex to pdf and sends log file |

### 3.4 Show and Delete Files
| Command               | Description                            |
|-----------------------|----------------------------------------|
| `files_`              | Show your files and folders.           |
| `files_delete_1`      | Delete file/folder number 1.           |
| `files_delete_1-3,5`  | Delete file/folder number 1-3, and 5.  |
| `files_delete_all`    | Delete all files and folders.          |


### 3.4 Download Files
| Command               | Description                              |
|-----------------------|------------------------------------------|
| `download_1`          | Download file/folder number 1.           |
| `download_1-3,5`      | Download file/folder number 1-3, and 5.  |
