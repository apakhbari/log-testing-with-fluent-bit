# log-testing-with-fluent-bit
```
 ___      _______  _______  _______  ___   __    _  _______      _     _ /     _______  ___      __   __  _______  __    _  _______         _______  ___   _______ 
|   |    |       ||       ||       ||   | |  |  | ||       |    | | _ | |     |       ||   |    |  | |  ||       ||  |  | ||       |       |  _    ||   | |       |
|   |    |   _   ||    ___||    ___||   | |   |_| ||    ___|    | || || |     |    ___||   |    |  | |  ||    ___||   |_| ||_     _| ____  | |_|   ||   | |_     _|
|   |    |  | |  ||   | __ |   | __ |   | |       ||   | __     |       |     |   |___ |   |    |  |_|  ||   |___ |       |  |   |  |____| |       ||   |   |   |  
|   |___ |  |_|  ||   ||  ||   ||  ||   | |  _    ||   ||  |    |       |     |    ___||   |___ |       ||    ___||  _    |  |   |         |  _   | |   |   |   |  
|       ||       ||   |_| ||   |_| ||   | | | |   ||   |_| |    |   _   |     |   |    |       ||       ||   |___ | | |   |  |   |         | |_|   ||   |   |   |  
|_______||_______||_______||_______||___| |_|  |__||_______|    |__| |__|     |___|    |_______||_______||_______||_|  |__|  |___|         |_______||___|   |___|  
```

A Docker-based log generator for testing Fluent Bit configurations with GELF output.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Usage](#usage)
- [Log Format](#log-format)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## Overview

This project provides a simple Docker setup to test Fluent Bit log aggregation. It includes:

- A log generator container that produces structured logs
- Fluent Bit configured to receive Docker logs via the Fluentd driver
- Lua script for adding custom identifiers to logs
- GELF output to send logs to a remote server

## Architecture

```
┌─────────────────┐
│ Log Generator   │
│ Container       │
└────────┬────────┘
         │ Fluentd Driver
         │ (port 24224)
         ▼
┌─────────────────┐
│   Fluent Bit    │
│                 │
│  ┌───────────┐  │
│  │ Lua Filter│  │
│  └───────────┘  │
└────────┬────────┘
         │ GELF/TCP
         ▼
┌─────────────────┐
│  GELF Server    │
│  10.10.21.151   │
│  Port 31221     │
└─────────────────┘
```

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 1.29+
- Network access to GELF server (10.10.21.151:31220)

## Project Structure

```
.
├── Dockerfile              # Log generator image
├── docker-compose.yml      # Service orchestration
├── log-generator.sh        # Log generation script
├── fluent-bit.conf         # Fluent Bit configuration
├── functions.lua           # Lua filter for log enrichment
└── README.md              # This file
```

## Configuration

### Fluent Bit Configuration

The `fluent-bit.conf` file includes:

- **INPUT**: Forward protocol listener on port 24224
- **FILTER**: Lua script to add `dividing_name` field
- **OUTPUT**: GELF output to remote server

### Lua Filter

The `functions.lua` script:

1. Extracts container name from Docker tag (format: `docker.container_name`)
2. Creates `dividing_name` field with format: `ubuntu_prod:container_name`
3. Ensures `log` field exists for GELF compatibility

### Docker Logging Driver

Containers use the Fluentd logging driver with:

```yaml
logging:
  driver: "fluentd"
  options:
    fluentd-address: "localhost:24224"
    tag: "docker.{{.Name}}"
```

## Usage

### Start the Services

```bash
# Build and start all services
docker-compose up --build

# Run in detached mode
docker-compose up --build -d
```

### View Logs

```bash
# View log generator output
docker-compose logs -f log-generator

# View Fluent Bit processing
docker-compose logs -f fluent-bit

# View all logs
docker-compose logs -f
```

### Stop the Services

```bash
docker-compose down
```

### Restart Services

```bash
docker-compose restart
```

## Log Format

The log generator produces logs in the following format:

```
[LEVEL] YYYY-MM-DD HH:MM:SS - Message content
```

**Log Levels:**
- `[INFO]` - General information messages
- `[DEBUG]` - Debug information with system metrics
- `[WARN]` - Warning messages about potential issues
- `[ERROR]` - Error messages indicating failures

**Example Logs:**
```
[INFO] 2025-12-03 10:30:45 - Processing request #1
[DEBUG] 2025-12-03 10:30:47 - Debug message 2 - Memory usage: 45%
[WARN] 2025-12-03 10:30:49 - Warning: High latency detected - 1234ms
[ERROR] 2025-12-03 10:30:51 - Error processing item 4 - Retrying...
```

## Customization

### Change Log Frequency

Edit `log-generator.sh` and modify the sleep interval:

```bash
sleep 2  # Change to desired interval in seconds
```

### Modify Server Identifier

Edit `functions.lua` and change the server name:

```lua
record["dividing_name"] = "your_server_name:" .. container_name
```

### Update GELF Server

Edit `fluent-bit.conf` OUTPUT section:

```properties
[OUTPUT]
    Name                    gelf
    Match                   *
    Host                    your.gelf.server.ip
    Port                    your_port
    Mode                    tcp
    Gelf_Short_Message_Key  log
```

### Add More Log Types

Edit `log-generator.sh` and add new cases in the switch statement:

```bash
case $((counter % 6)) in
    5)
        echo "[CRITICAL] $(date '+%Y-%m-%d %H:%M:%S') - Critical error!"
        ;;
esac
```

## Troubleshooting

### Fluent Bit Not Receiving Logs

1. Check if Fluent Bit is running:
   ```bash
   docker-compose ps
   ```

2. Verify port 24224 is accessible:
   ```bash
   docker-compose exec fluent-bit netstat -tlnp | grep 24224
   ```

3. Check Fluent Bit logs for errors:
   ```bash
   docker-compose logs fluent-bit
   ```

### Cannot Connect to GELF Server

1. Test network connectivity:
   ```bash
   docker-compose exec fluent-bit ping 10.10.21.151
   ```

2. Verify GELF port is open:
   ```bash
   docker-compose exec fluent-bit nc -zv 10.10.21.151 31220
   ```

3. Check firewall rules on both client and server

### Log Generator Not Producing Logs

1. Check container status:
   ```bash
   docker-compose ps log-generator
   ```

2. View container logs directly:
   ```bash
   docker logs $(docker-compose ps -q log-generator)
   ```

3. Verify the script is executable:
   ```bash
   docker-compose exec log-generator ls -la /log-generator.sh
   ```

### Lua Script Errors

1. Check Fluent Bit logs for Lua errors:
   ```bash
   docker-compose logs fluent-bit | grep -i lua
   ```

2. Verify `functions.lua` is mounted correctly:
   ```bash
   docker-compose exec fluent-bit ls -la /fluent-bit/etc/functions.lua
   ```

3. Test the Lua syntax:
   ```bash
   docker-compose exec fluent-bit lua -l /fluent-bit/etc/functions.lua
   ```

### General Debugging

Enable debug logging in `fluent-bit.conf`:

```properties
[SERVICE]
    Flush        1
    Log_Level    debug
    Parsers_File parsers.conf
```

Then restart the services:

```bash
docker-compose restart fluent-bit
```

---

**Note:** Make sure to update the GELF server IP address and port in `fluent-bit.conf` to match your environment before deploying.

## Acknowledgment

### Contributors

* APA 🖖🏻

### Links
- [go2docs.graylog.org](go2docs.graylog.org)


```
  aaaaaaaaaaaaa  ppppp   ppppppppp     aaaaaaaaaaaaa   
  a::::::::::::a p::::ppp:::::::::p    a::::::::::::a  
  aaaaaaaaa:::::ap:::::::::::::::::p   aaaaaaaaa:::::a 
           a::::app::::::ppppp::::::p           a::::a 
    aaaaaaa:::::a p:::::p     p:::::p    aaaaaaa:::::a 
  aa::::::::::::a p:::::p     p:::::p  aa::::::::::::a 
 a::::aaaa::::::a p:::::p     p:::::p a::::aaaa::::::a 
a::::a    a:::::a p:::::p    p::::::pa::::a    a:::::a 
a::::a    a:::::a p:::::ppppp:::::::pa::::a    a:::::a 
a:::::aaaa::::::a p::::::::::::::::p a:::::aaaa::::::a 
 a::::::::::aa:::ap::::::::::::::pp   a::::::::::aa:::a
  aaaaaaaaaa  aaaap::::::pppppppp      aaaaaaaaaa  aaaa
                  p:::::p                              
                  p:::::p                              
                 p:::::::p                             
                 p:::::::p                             
                 p:::::::p                             
                 ppppppppp                                                        
```