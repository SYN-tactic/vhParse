
## Purpose
I created this after using [LinuxGSM](https://github.com/GameServerManagers/LinuxGSM) for a while to run my valheim server. I wanted a way to get friendly notifications on my discord server when players would log in or out of my server, and this is the result.

You could pretty easily change the message that is sent to the discord server by editing the `MSG` variable in the `vh_info_parse.sh` file.

## Usage
Here's how you can use these series of scripts:
```bash
tail -f -n 1 <your-log-file> | ./vh_console_parse.sh | ./vh_info_parse.sh
```
Make sure you setup your webhook url in your environment:
```bash
export $DISCORD_VALHEIM_WEBHOOK="your-discord-url"
```
You could also export the shell variable as part of loading up the script:
```
export DISCORD_VALHEIM_WEBHOOK="your-discord-url" | tail -f -n 1 <your-log-file> | ./vh_console_parse.sh | ./vh_info_parse.sh
```

## How to get this running

There are a few ways you could go about this. I'll tell you how I do it, and you can see if that works for you.

I have a dedicated user on my ubuntu server that is in charge of running the valheim server. Its username is `vhserver` and I've downloaded the [LinuxGSM](https://github.com/GameServerManagers/LinuxGSM) into its root directory.

What I do is download this repo into the root directory for my `vhserver` user.
```bash
git clone git@github.com:SYN-tactic/vhParse.git
# Now move into the directory of this project
cd vhParse
```
Since linuxGSM is running in the root directory, I know exactly where the console log file for my valheim server is located in relation to this directory.
First, though, I open a window using tmux so that I can just leave this script running:
```bash
tmux new -s vhParse
```
This will open tmux in the same directory. Now you can run the script - here's what mine looks like: 
```bash
export DISCORD_VALHEIM_WEBHOOK=https://replace-all-this-with-your-webhook-no-dont-copy-this | tail -f -n 1 ../log/console/vhserver-console.log | ./vh_console_parse.sh | ./vh_info_parse.sh
```
Now click the keys `ctrl+b` and `d`. This will leave tmux running in the background and you are good to go!

It may be that your console log file is located somewhere different. Replace the `../log/console/vhserver-console.log` part above with the [path](https://unix.stackexchange.com/a/131585) to where your console file is located. 