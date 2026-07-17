# SSHcontrol

A lightweight Bash script to monitor SSH login attempts in real-time and send instant alerts to Telegram when a non-whitelisted IP connects or fails to connect.

## Features
* **Real-time monitoring**: Tails `/var/log/auth.log` (or `/var/log/secure`) for successful/failed logins.
* **Telegram alerts**: Sends instant notifications via Telegram Bot API.
* **IP Whitelisting**: Suppresses alerts for your trusted IPs.
* **Daemon mode**: Runs in the background with PID tracking (Start/Stop controls).
* **Daily Reports**: Generates a sorted summary of unauthorized login attempts.

---

## Prerequisites
* Sudo/Root privileges (needed to read auth logs).
* `curl` installed.
* A Telegram Bot token and your Chat ID.

---

## Configuration

Open the script and configure your details at the top:

# Telegram Bot Configuration
API_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"

# Whitelist file path (one IP per line)
WHITELIST_IPS="/home/pc/whitel.txt"

### Create the Whitelist file:
mkdir -p /home/pc/
echo "127.0.0.1" > /home/pc/whitel.txt
*(Add any other safe IPs you want to ignore, one per line)*

---

## Installation & Usage

1. Make it executable:
   chmod +x SSHcontrol

2. Move it to your PATH (Optional but recommended):
   sudo cp SSHcontrol /usr/local/bin/

3. Run the tool:
   sudo SSHcontrol

---

## How to Use

When you run the tool, it checks if the background monitor is already running:

* If Stopped: You can choose to "Start SSH Analyzing" (runs in background) or "See The Report" (generates a .txt file of filtered attempts sorted by frequency).
* If Running: You can choose to "Stop SSH Analyzing" or "See The Report".

### Report Example
The report will be saved in your current directory as YYYY-MM-DD_report.txt format:

 15  198.51.100.42
  3  203.0.113.5
