# Akaunting Quick Deploy App

Akaunting is a free, open-source accounting software for small businesses and freelancers that provides ease of accounting and bookkeeping. Its features include invoicing, expense management, and financial reporting.

## Software Included

| Software | Version | Description |
| :---     | :----   | :---        |
| Akaunting | latest | Open-source accounting software |
| PHP-FPM | 8.3.6 | General-purpose scripting language |
| MariaDB | 10.11.14 | Open-source relational database |
| Nginx | 1.24.0 | Web server |

**Supported Distributions:**

- Ubuntu 24.04 LTS

## Linode Helpers Included

| Name  | Action  |
| :---  | :---    |
| Hostname | Assigns a hostname to the Linode based on the domain provided via UDF, or uses the default rDNS. For consistency, DNS and SSL configurations use the Hostname-generated `_domain` var. |
| DNS Record | Creates an A record for the deployment when a Linode API token and domain are supplied via UDF. |
| Sudo User | Creates a limited `sudo` user from the UDF-supplied `username` and generates its password. Usernames containing illegal characters will cause the play to fail. |
| SSH Key | Writes a UDF-supplied SSH pubkey to `/home/$username/.ssh/authorized_keys`. To add an SSH key to `root`, see [Manage SSH Keys](https://techdocs.akamai.com/cloud-computing/docs/manage-ssh-keys). |
| Secure SSH | Standard SSH hardening — writes to `/etc/ssh/sshd_config` to disable password auth and require public-key auth (applied only when `disable_root` is set to `Yes`). |
| Update Packages | Performs standard apt update and upgrade actions as root. |
| Secure MySQL | Generates the DB root password, sets it, and removes anonymous users and the test database. |
| UFW | Imports `ufw_rules.yml` (22, 80, 443) and enables the firewall. The MariaDB port (3306) is never exposed — the server listens on `127.0.0.1` only. |
| Fail2Ban | Installs, activates, and enables the Fail2Ban service. |
| Certbot SSL | Handles SSL/TLS certificate issuance via Let's Encrypt against nginx, and adds the HTTP→HTTPS redirect. |
| Addons | Optional monitoring/observability exporters (`node_exporter`, `mysqld_exporter`, `newrelic`, `opentelemetry_collector`, `alloy`). |

## Post-Deployment

When the playbook finishes, the operator can:

- Browse to the app at `https://<domain-or-rdns>/` — you will be redirected to the login page at
  `/auth/login`.
- Read the generated credentials from `/home/<sudo_user>/.credentials` (mode `0600`). The file
  contains:
  - Sudo username + password
  - Akaunting URL
  - Akaunting admin email + password
  - Database root password, database name, database username + password
- Log in with the Akaunting admin email and password.

There are certain features in Akaunting (such as Invoicing) that require you to add an Akaunting API KEY. To get your API KEY, create an account at [akaunting.com](https://akaunting.com/), visit your [dashboard](https://akaunting.com/dashboard), and copy the API KEY listed.

The Laravel scheduler is installed as a `www-data` cron entry (`* * * * * php /var/www/html/artisan schedule:run`), which drives recurring invoices and bills, invoice/bill reminders, temp-storage cleanup, and record pruning.

## Use our API

Customers can deploy Akaunting through the Linode Marketplace or directly using the API. Before using the commands below, create an [API token](https://techdocs.akamai.com/linode-api/reference/get-started#create-an-api-token) or configure [linode-cli](https://techdocs.akamai.com/cloud-computing/docs/cli-1), and substitute your own values for the defaults.

SHELL:
```
curl -H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-X POST -d '{
    "image": "linode/ubuntu24.04",
    "region": "us-southeast",
    "type": "g6-standard-2",
    "label": "akaunting-occ-us-southeast",
    "tags": [],
    "root_pass": "A_Secure_Password",
    "authorized_users": [
        "user1",
        "user2"
    ],
    "booted": true,
    "backups_enabled": false,
    "private_ip": false,
    "stackscript_id": 923033,
    "stackscript_data": {
        "user_name": "sudo_user",
        "disable_root": "No",
        "token_password": "A_Valid_API_Token",
        "subdomain": "examplesubdomain",
        "domain": "domain.tld",
        "soa_email_address": "email@domain.tld",
        "admin_email": "admin@domain.tld",
        "company_name": "My Company",
        "add_ons": "none"
    }
}' https://api.linode.com/v4/linode/instances
```

CLI:
```
linode-cli linodes create \
  --image 'linode/ubuntu24.04' \
  --region us-southeast \
  --type g6-standard-2 \
  --label akaunting-occ-us-southeast \
  --root_pass A_Secure_Password \
  --authorized_users user1 \
  --authorized_users user2 \
  --booted true \
  --backups_enabled false \
  --private_ip false \
  --stackscript_id 923033 \
  --stackscript_data '{"user_name":"sudo_user","disable_root":"No","token_password":"A_Valid_API_Token","subdomain":"examplesubdomain","domain":"domain.tld","soa_email_address":"email@domain.tld","admin_email":"admin@domain.tld","company_name":"My Company","add_ons":"none"}'
```

## Resources

- [Akaunting Documentation](https://akaunting.com/hc/docs)
- [Akaunting Repository](https://github.com/akaunting/akaunting)
- [Akaunting App Store](https://akaunting.com/apps)
