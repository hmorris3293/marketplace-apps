# OpenFang Marketplace App

OpenFang is an open-source Agent Operating System built in Rust. This marketplace app provides a quick-deploy solution for running OpenFang on Linode compute instances with a full automation stack.

## Features

- **Single 32MB Binary** - Lightweight agent OS with zero bloat
- **7 Built-in Autonomous Hands** - Researcher, Lead Generation, Collector, Predictor, Browser, Twitter, Clip
- **40 Channel Adapters** - Telegram, Discord, Slack, WhatsApp, Signal, Matrix, Email, and more
- **27+ LLM Providers** - OpenAI, Anthropic, Gemini, Groq, DeepSeek, and others
- **16 Security Systems** - WASM sandbox, Merkle audit trail, taint tracking, and more
- **Web Dashboard** - Real-time agent monitoring and control at `https://your-domain/`

## Architecture

- **Container**: Docker-based deployment with persistent data volume
- **Reverse Proxy**: NGINX with automatic HTTP→HTTPS redirect
- **SSL/TLS**: Let's Encrypt certificate generation and auto-renewal
- **Database**: SQLite for agent memory and session history
- **API**: OpenAI-compatible REST API + WebSocket support

## Deployment

### Prerequisites

- A Linode compute instance with Ubuntu 22.04+
- A domain name pointing to your instance (for SSL certificates)
- LLM provider API keys (OpenAI, Anthropic, Groq, etc.)

### Quick Deploy

1. **Initialize credentials and configuration:**
   ```bash
   ansible-playbook provision.yml -e "domain=your-domain.com" -e "username=openfang"
   ```

2. **Deploy the application:**
   ```bash
   ansible-playbook site.yml
   ```

3. **Access the dashboard:**
   - URL: `https://your-domain.com/`
   - Bearer Token: Check `/home/openfang/.credentials`

### Environment Variables

Set these before running the playbooks to configure LLM providers:

```bash
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export GROQ_API_KEY="gsk_..."
```

## Configuration

### LLM Provider Setup

Edit the config file after deployment:

```bash
nano /home/openfang/openfang_data/config.toml
```

**Example: Using OpenAI:**
```toml
[default_model]
provider = "openai"
model = "gpt-4-turbo"
api_key_env = "OPENAI_API_KEY"
```

**Example: Using Anthropic:**
```toml
[default_model]
provider = "anthropic"
model = "claude-sonnet-4-20250514"
api_key_env = "ANTHROPIC_API_KEY"
```

### Channel Adapters

Enable Telegram, Discord, Slack, and other integrations by updating the config:

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

Then restart the container:
```bash
docker restart openfang
```

## Useful Commands

### Container Management
```bash
# Check status
docker ps -a | grep openfang

# View logs
docker logs -f openfang

# Restart service
docker restart openfang

# Enter container shell
docker exec -it openfang /bin/bash
```

### API Access
```bash
# Test health endpoint
curl -H "Authorization: Bearer YOUR_API_KEY" https://your-domain/health

# List agents
curl -H "Authorization: Bearer YOUR_API_KEY" https://your-domain/v1/agents

# Activate a Hand
curl -X POST -H "Authorization: Bearer YOUR_API_KEY" \
  https://your-domain/v1/hands/activate \
  -d '{"name": "researcher"}'
```

### Configuration Management
```bash
# Backup data and config
docker cp openfang:/data /home/openfang/openfang_data_backup

# Edit configuration
nano /home/openfang/openfang_data/config.toml

# Restart after config changes
docker restart openfang
```

## Monitoring

OpenFang logs are available in:

```bash
# Application logs
docker logs openfang

# NGINX reverse proxy logs
tail -f /var/log/nginx/openfang_access.log
tail -f /var/log/nginx/openfang_error.log
```

## Security

- **API Authentication**: All endpoints require Bearer token authentication
- **SSL/TLS**: Automatic HTTPS with Let's Encrypt
- **Database**: SQLite with optional encryption
- **Rate Limiting**: Built-in GCRA rate limiting per IP
- **Network Isolation**: API listens on localhost, proxied through NGINX

## Troubleshooting

### Container won't start
```bash
docker logs openfang
# Check for environment variable issues
docker inspect openfang
```

### SSL certificate issues
```bash
# Check certificate status
sudo certbot certificates

# Renew manually
sudo certbot renew --force-renewal

# Check NGINX logs
tail -f /var/log/nginx/openfang_error.log
```

### API authentication errors
```bash
# Verify Bearer token in credentials file
cat /home/openfang/.credentials

# Test with correct token
curl -H "Authorization: Bearer YOUR_TOKEN" https://your-domain/health
```

### Memory/performance tuning
- Monitor Docker stats: `docker stats openfang`
- Adjust session compaction in config.toml
- Review decay_rate and memory settings

## Updates

To update to a newer OpenFang version:

```bash
# Edit the version in roles/openfang/defaults/main.yml
# Then redeploy
ansible-playbook site.yml
```

Docker will pull the latest image and restart the container.

## Documentation

- [OpenFang Official Docs](https://openfang.sh/docs/)
- [OpenFang GitHub](https://github.com/RightNow-AI/openfang)
- [LLM Provider Setup](https://openfang.sh/docs/llm-providers)
- [Channel Adapters](https://openfang.sh/docs/channels)

## Support

- Report issues on [GitHub](https://github.com/RightNow-AI/openfang/issues)
- Join the [Discord community](https://discord.gg/sSJqgNnq6X)
- Follow on [Twitter/X](https://x.com/openfangg)

## License

OpenFang is licensed under the MIT License. See LICENSE files for details.
