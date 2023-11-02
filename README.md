
## Purpose
I created this after using LinuxGSM for a while to run my valheim server. I wanted a way to get friendly notifications on my discord server when players would log in or out of my server, and this is the result. 

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