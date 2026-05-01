# Akamai Cloud Compute – Appwrite Deployment One-Click APP

Appwrite is an open-source, self-hosted Backend-as-a-Service (BaaS) platform that provides developers with a set of tools and APIs to build web and mobile applications faster. It handles common backend tasks including user authentication, database management, file storage, serverless functions, and real-time event subscriptions.

Our Marketplace application deploys **Appwrite** as a fully containerized stack using Docker Compose, fronted by Nginx with automatic SSL certificates via Let's Encrypt. This gives you a production-ready self-hosted BaaS that you control entirely.

## Software Included

| Software | Version | Description |
| :--- | :---- | :--- |
| Docker | `29.2.0` | Container Management Runtime |
| Docker Compose | `5.0.2` | Tool for multi-container applications |
| Nginx | `1.24.0` | HTTP server used as a reverse proxy |
| Appwrite | `latest` tag | Open-source Backend-as-a-Service platform |
| MariaDB | `10.11` | Relational database used by Appwrite |
| Redis | `7.2` | In-memory cache and queue for Appwrite |
| Traefik | `2.11` | Internal reverse proxy and router for Appwrite services |
| OpenRuntimes Executor | `0.4.8` | Serverless function execution runtime |

**Supported Distributions:**

- Ubuntu 24.04 LTS

## Linode Helpers Included

| Name | Description | Actions |
| :--- | :--- | :--- |
| UFW | Add UFW firewalls to the Linode | The UFW module will import a `ufw_rules.yml` provided in `roles/common/tasks` and enables the service. |
| Certbot SSL | Generates and sets auto-renew for Certbot SSL certificates | The Certbot module installs Certbot Python plugin and certificates based on the webserver detected by Ansible. The default renewal cron runs Mondays at 00:00AM and can be manually edited. |
| Fail2Ban | Installs, activates and enables Fail2Ban | The Fail2Ban module installs, activates and enables the Fail2Ban service. |
| Hostname | Assigns a hostname to the Linode based on domains provided via UDF or uses default rDNS | The Hostname module accepts a UDF to assign a FQDN and write to the `/etc/hosts` file. If no domain is provided the default `ip.linodeusercontent.com` rDNS will be used. For consistency, DNS and SSL configurations should use the Hostname generated `_domain` var when possible. |
| Secure SSH | Performs standard SSH hardening | The Secure SSH module writes to `/etc/ssh/sshd_config` to prevent password authentication and enable public key authentication for all users, including root. |
| Sudo User | Creates limited `sudo` user with variable supplied username | Creates limited user from UDF supplied `username`. Note that usernames containing illegal characters will cause the play to fail. |
| SSH Key | Writes SSH pubkey to `sudo` user's `authorized_keys` | Writes UDF supplied `pubkey` to `/home/$username/.ssh/authorized_keys`. To add an SSH key to `root` please use [Cloud Manager SSH Keys](https://www.linode.com/docs/products/tools/cloud-manager/guides/manage-ssh-keys/). |
| Update Packages | Performs standard apt updates and upgrades | The Update Packages module performs apt update and upgrade actions as root. |

# Architecture

## Overview

The Appwrite stack consists of multiple containerized services that work together to provide a complete Backend-as-a-Service platform:

1. **Core Service** (`appwrite`) – REST API, authentication, database, storage, and functions
2. **Realtime Service** (`appwrite-realtime`) – WebSocket-based event subscriptions
3. **Worker Services** – Background job processing for audits, webhooks, deletes, databases, builds, certificates, functions, mails, messaging, migrations, maintenance, usage, and scheduling
4. **Executor** (`openruntimes-executor`) – Serverless function runtime
5. **MariaDB** – Persistent relational database
6. **Redis** – Cache and message queue
7. **Traefik** – Internal reverse proxy routing requests to Appwrite services

All services are managed via Docker Compose and configured to restart automatically.

## Containerized Services

### Core Service (Appwrite)

- **Internal Port**: `80` (via Traefik)
- **Container**: `appwrite/appwrite:latest`
- **Purpose**: Main API server handling all client requests
- **Features**:
  - REST and GraphQL APIs
  - User authentication (email, OAuth, magic URL, phone)
  - Database with real-time subscriptions
  - File storage with image transformation
  - Serverless functions

### Database (MariaDB)

- **Container**: `mariadb:10.11`
- **Purpose**: Persistent storage for all Appwrite data

### Cache / Queue (Redis)

- **Container**: `redis:7.2-alpine`
- **Purpose**: Session cache, task queuing, and pub/sub

## Web Service

### HTTPS (Nginx)

- **Port**: `443`
- **Features**:
  - HTTPS-secured domain via Let's Encrypt
  - Reverse proxy for Appwrite
  - WebSocket support for real-time features
  - 100MB upload limit for file storage

## Resource Requirements

- **Recommended**: 4GB Dedicated CPU or Shared Compute instance
- **Storage**: At least 25GB for database, uploads, and function builds
