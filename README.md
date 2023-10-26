

## Usage
Here's how you can use these series of scripts:
```bash
tail -f -n 1 <your-log-file> | ./vh_console_parse.sh | ./vh_info_parse.sh
```
Make sure you setup your webhook url in your environment:
```bash
export $DISCORD_VALHEIM_WEBHOOK="your-discord-url"
```