# OpenFang Marketplace App

OpenFang is an open-source Agent Operating System built in Rust. This marketplace app provides a quick-deploy solution for running OpenFang on Linode compute instances with a full automation stack.

## Features

- **Single lightweight binary** - Agent OS installed from the official GitHub release
- **7 Built-in Autonomous Hands** - Researcher, Lead Generation, Collector, Predictor, Browser, Twitter, Clip
- **40 Channel Adapters** - Telegram, Discord, Slack, WhatsApp, Signal, Matrix, Email, and more
- **27+ LLM Providers** - OpenAI, Anthropic, Gemini, Groq, DeepSeek, and others
- **16 Security Systems** - WASM sandbox, Merkle audit trail, taint tracking, and more
- **Web Dashboard** - Real-time agent monitoring and control, reached over an SSH tunnel

## Architecture

- **Service**: OpenFang binary run as the `openfang` systemd service
- **Network**: API and dashboard bind to `127.0.0.1:4200` (loopback only) — no public web port is exposed
- **Access**: The dashboard is reached from your local machine through an SSH tunnel
- **Database**: SQLite for agent memory and session history
- **API**: OpenAI-compatible REST API + WebSocket support, protected by a Bearer token

## Deployment

### Prerequisites

- A Linode compute instance with Ubuntu 24.04 LTS
- LLM provider API keys (OpenAI, Anthropic, Groq, etc.)

### Access the dashboard

OpenFang listens on `127.0.0.1` only. From your local machine, open an SSH tunnel to the instance:

```bash
ssh -L 4200:127.0.0.1:4200 <username>@<your-instance-ip-or-domain>
```

Then browse to `http://127.0.0.1:4200`. The API Bearer token and sudo credentials are written to `/home/<username>/.credentials`.

## Configuration

### LLM Provider Setup

Configure your LLM provider from the OpenFang dashboard, or supply keys through
the OpenFang environment file. Add your keys to `~/.openfang/.env`, then restart
the service:

```bash
tee -a ~/.openfang/.env <<'EOF'
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GROQ_API_KEY=gsk_...
EOF
sudo systemctl restart openfang
```

### Application config

The OpenFang config lives at `~/.openfang/config.toml`:

```bash
nano ~/.openfang/config.toml
sudo systemctl restart openfang
```

**Example: Using OpenAI**
```toml
[default_model]
provider = "openai"
model = "gpt-4-turbo"
api_key_env = "OPENAI_API_KEY"
```

**Example: Using Anthropic**
```toml
[default_model]
provider = "anthropic"
model = "claude-sonnet-4-20250514"
api_key_env = "ANTHROPIC_API_KEY"
```

### Channel Adapters

Enable Telegram, Discord, Slack, and other integrations by updating the config, then restarting the service:

```toml
[telegram]
bot_token_env = "TELEGRAM_BOT_TOKEN"
allowed_users = []  # Empty = allow all

[discord]
bot_token_env = "DISCORD_BOT_TOKEN"
guild_ids = []      # Empty = all guilds

[slack]
bot_token_env = "SLACK_BOT_TOKEN"
app_token_env = "SLACK_APP_TOKEN"
```

```bash
sudo systemctl restart openfang
```

## Useful Commands

### Service Management
```bash
# Check status
systemctl status openfang

# View logs
journalctl -u openfang -f

# Restart service
sudo systemctl restart openfang
```

### API Access

Run these from a shell on the instance, or through the SSH tunnel from your local machine (using `127.0.0.1`):

```bash
# Test health endpoint
curl -H "Authorization: Bearer YOUR_API_KEY" http://127.0.0.1:4200/health

# List agents
curl -H "Authorization: Bearer YOUR_API_KEY" http://127.0.0.1:4200/v1/agents

# Activate a Hand
curl -X POST -H "Authorization: Bearer YOUR_API_KEY" \
  http://127.0.0.1:4200/v1/hands/activate \
  -d '{"name": "researcher"}'
```

## Monitoring

OpenFang logs are managed by systemd:

```bash
journalctl -u openfang -f
```

## Security

- **Loopback bind**: The API and dashboard listen only on `127.0.0.1` — no public web port is opened
- **SSH tunnel access**: The dashboard is reachable only by users who can SSH to the instance
- **API Authentication**: All endpoints require Bearer token authentication
- **Firewall**: UFW default-deny with only SSH (22) allowed
- **Database**: SQLite with optional encryption
- **Rate Limiting**: Built-in GCRA rate limiting per IP

## Troubleshooting

### Service won't start
```bash
systemctl status openfang
journalctl -u openfang -n 100 --no-pager
```

### Can't reach the dashboard
```bash
# Confirm the service is listening locally (run on the instance):
ss -ltnp | grep 4200
curl -H "Authorization: Bearer YOUR_API_KEY" http://127.0.0.1:4200/health
```

### API authentication errors
```bash
# Verify Bearer token in credentials file
cat /home/<username>/.credentials

# Test with correct token
curl -H "Authorization: Bearer YOUR_TOKEN" http://127.0.0.1:4200/health
```
