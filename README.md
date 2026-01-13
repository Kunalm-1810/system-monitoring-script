# system-monitoring-script.

A simple shell script to monitor system resources and emit alerts when thresholds are exceeded.

## Features
- Monitor CPU, memory, and disk (/) usage
- Print clear alert messages when thresholds are exceeded
- Show top CPU- or memory-consuming processes when relevant
- Optional logging to a file (enabled by default)

## Usage
1. Make the script executable:

   chmod +x system_monitor.sh

2. Run it (background or foreground):

   ./system_monitor.sh

You can configure thresholds with environment variables before running:

- CPU_THRESHOLD (default: 80)
- MEMORY_THRESHOLD (default: 80)
- DISK_THRESHOLD (default: 80)
- SLEEP_INTERVAL (default: 60 seconds)
- LOG_FILE (default: system_usage.log)
- LOG_ENABLED (1 to log, 0 to disable)

Example:

  CPU_THRESHOLD=70 MEMORY_THRESHOLD=70 LOG_ENABLED=1 ./system_monitor.sh

## Sample alert output

ALERT: CPU usage is at 92% (threshold 80%)

--- Top CPU-consuming processes ---
  PID COMMAND %CPU %MEM
  1234 myproc  75.0 10.2
  2345 other   10.0  1.1

## Notes
- This script does not ship with email alerting configured (avoid storing credentials in scripts).
- Logs are appended to `system_usage.log` by default; set `LOG_ENABLED=0` to disable logging.
- Run it as a daemon with your system's preferred service manager if you want continuous monitoring.

## License
MIT
# system-monitoring-script
monitor disk usage and display warning beyond o define threshold
