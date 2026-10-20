# Linode Coolify Deployment One-Click APP

Coolify is an open-source, self-hostable platform for deploying and managing applications, databases, and services on your own server.

## Software Included

| Software  | Version   | Description   |
| :---      | :----     | :---          |
| Docker    | Latest    | Container Management tool |
| Coolify   | Latest    | Self-hosted PaaS for applications, databases and services. |

**Supported Distributions:**

- Ubuntu 24.04 LTS

## Linode Helpers Included

| Name  | Action  |
| :---  | :---    |
| Hostname   | The Hostname module uses `dnsdomainname -A` to detect the Linode's FQDN and write to the `/etc/hosts` file. |
| Update Packages   | The Update Packages module performs apt update and upgrade actions as root.  |
| UFW   | The UFW module enables the firewall with the app specific rules in `roles/common/tasks/ufw_rules.yml`.  |
| Fail2Ban   | The Fail2Ban module installs, activates and enables the Fail2Ban service.  |

## Use our API

Make sure that the following values are updated at the top of the code block before running the commands:
- TOKEN
- ROOT_PASS

```
export TOKEN="YOUR API TOKEN"
export ROOT_PASS="aComplexP@ssword"
export USERNAME="user1"
export SOA_EMAIL_ADDRESS="email@domain.com"

curl -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -X POST -d '{
      "image": "linode/ubuntu24.04",
      "root_pass": "${ROOT_PASS}",
      "stackscript_id": 0,
      "stackscript_data": {
        "soa_email_address": "${SOA_EMAIL_ADDRESS}",
        "user_name" : "${USERNAME}"
      },
      "booted": true,
      "label": "coolify",
      "type": "g6-standard-2",
      "region": "us-east"
    }' \
https://api.linode.com/v4/linode/instances
```

## Resources

- [Coolify documentation](https://coolify.io/docs)
- [Create Linode via API](https://www.linode.com/docs/api/linode-instances/#linode-create)
