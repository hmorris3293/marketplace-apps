# Akaunting Quick Deploy App

Deploy [Akaunting](https://akaunting.com/) on Akamai Cloud Compute — a free, open-source,
online accounting software for small businesses and freelancers (invoicing, expenses,
recurring transactions, multi-company).

The deployment installs the latest stable Akaunting release (resolved at deploy time from the
official GitHub releases) on a hardened LEMP stack:

- nginx + PHP 8.3 FPM serving Akaunting directly (fastcgi), with the upstream-hardened vhost
- MariaDB bound to localhost, secured, with per-deployment generated credentials
- HTTPS via Let's Encrypt (certbot) with HTTP→HTTPS redirect
- No setup wizard: the CLI installer and the in-app onboarding wizard are both completed
  during deployment — first login lands on the Dashboard
- Laravel scheduler cron (recurring invoices/bills, reminders) installed and firing
- Limited sudo user, UFW (22/80/443), fail2ban, optional SSH root lockout

## Deployment

Deploy from the [Linode Marketplace](https://www.linode.com/marketplace/apps/) or with this
repository's StackScript (`deployment_scripts/linode-marketplace-akaunting/`).

### UDF fields

| Field | Description |
|---|---|
| `user_name` | Limited sudo user created on the Linode (required) |
| `disable_root` | Disable root access over SSH? (`Yes`/`No`) |
| `token_password` | Linode API token, only needed to create DNS records (optional) |
| `domain` / `subdomain` | DNS record for the deployment (optional; defaults to the Linode's rDNS) |
| `soa_email_address` | Email for the Let's Encrypt certificate (required) |
| `admin_email` | Email for the Akaunting admin login; can match the SSL email or differ (required) |
| `company_name` | Company name for your Akaunting books (default: `My Company`) |
| `add_ons` | Optional data-exporter add-ons |

## Getting started

After deployment, all generated credentials are in `/home/$SUDO_USER/.credentials` (mode 0600):
the sudo user password, the Akaunting admin email/password, and the database passwords.

Log in at `https://<your-domain>/auth/login` with the Akaunting admin email and password —
you land directly on the Dashboard; no installer or onboarding wizard will appear.

**Next steps:** to install apps from the [akaunting.com](https://akaunting.com) app store,
connect your own akaunting.com account in the UI — no API key is baked into the deployment.
