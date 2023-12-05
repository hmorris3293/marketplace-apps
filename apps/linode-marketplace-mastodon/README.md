# Linode Joplin Deployment One-Click APP

[Mastodon](https://docs.joinmastodon.org/) is an open-source and decentralized micro-blogging platform. Like Twitter, it lets users follow other users and post text, photos, and video content. Mastodon also allows you to create a non-profit social network based on open web standards and principles. Unlike Twitter, Mastodon is decentralized, meaning that its content is not maintained by a central authority.

What sets the Mastodon platform apart is its federated approach to social networking. Each Mastodon instance operates independently — anyone can create an instance and build their community. But users from different instances can still follow each other, share content, and communicate.

Mastodon participates in the [Fediverse](https://en.wikipedia.org/wiki/Fediverse), a collection of social networks and other websites that communicate using the [ActivityPub](https://en.wikipedia.org/wiki/ActivityPub) protocol. That allows different Mastodon instances to communicate, and also allows other platforms in the Fediverse to communicate with Mastodon.

Mastodon servers range in size from small private instances to massive public instances and typically center on specific interests or shared principles. The biggest Mastodon server is [Mastodon.social](https://mastodon.social/about), a general-interest server created by the developers of the Mastodon platform. It has over 540,000 users and boasts a thorough [Code of Conduct](https://mastodon.social/about/more).

## Software Included

| Software  | Version   | Description   |
| :---      | :----     | :---          |
| Docker    | 20.10    | Container Management tool |
| Docker-Compose  | 1.29   | Container Management tool |
| mastodon | latest | Decentralized Micro-Blogging Platform |
| postgres:14 | 14 | open-source relational database management system |

**Supported Distributions:**

- Ubuntu 22.04 LTS

## Linode Helpers Included

| Name  | Action  |
| :---  | :---    |
| **Linode API Token**	| A valid Linode API token with Read/Write permissions to Domains. *Required*
| **SOA Email** | An email address you control to be the Source of Authority for the generated DNS zone. *Required* 
| **Domain** | A valid domain name for your Mastodon instance, with Linode's name servers configured as the [authoritative name servers](https://www.linode.com/docs/products/networking/dns-manager/get-started/#use-linodes-name-servers). *Required* 
| **Mastodon Owner User** | The username for the Admin user that will be created for the Mastodon server. *Required* 
| **Mastodon Owner Email** | The contact email for the Admin user that will be created for the Mastodon server. *Required*   
| **Single User Mode** | Enabling Single User Mode prevents other users from joining the Mastodon Server, while disabling it allows it. *Required* 

## Use our API

Customers can choose to the deploy the Joplin app through the Linode Marketplace or directly using API. Before using the commands below, you will need to create an [API token](https://www.linode.com/docs/products/tools/linode-api/get-started/#create-an-api-token) or configure [linode-cli](https://www.linode.com/products/cli/) on an environment.

Make sure that the following values are updated at the top of the code block before running the commands:
- TOKEN
- ROOT_PASS

SHELL:
```
export TOKEN="YOUR API TOKEN"
export ROOT_PASS="aComplexP@ssword"
export SOA_EMAIL_ADDRESS="email@domain.com"
export OWNER_EMAIL="aComplexP@ssword"
export OWNER_USERNAME="username"
export DOMAIN="domain.tld"
export SUBDOMAIN="www"

curl -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -X POST -d '{
      "backups_enabled": true,
      "swap_size": 512,
      "image": "linode/ubuntu2204",
      "root_pass": "${ROOT_PASS}",
      "stackscript_id": 1096122,
      "stackscript_data": {
        "soa_email_address": "${SOA_EMAIL_ADDRESS}",
        "postgres_password" : "${POSTGRES_PASSWORD}"
      },
      "authorized_users": [
        "myUser",
        "secondaryUser"
      ],
      "booted": true,
      "label": "linode123",
      "type": "g6-standard-2",
      "region": "us-east",
      "group": "Linode-Group"
    }' \
https://api.linode.com/v4/linode/instances
```

CLI:
```
export TOKEN="YOUR API TOKEN"
export ROOT_PASS="aComplexP@ssword"
export SOA_EMAIL_ADDRESS="email@domain.com"
export POSTGRES_PASSWORD="aComplexP@ssword"

linode-cli linodes create \
  --label linode123 \
  --root_pass ${ROOT_PASS} \
  --booted true \
  --stackscript_id 00000000000 \
  --stackscript_data '{"soa_email_address": "${SOA_EMAIL_ADDRESS}"}, {"yemail": "${POSTGRES_PASSWORD}"}' \
  --region us-east \
  --type g6-standard-2 \
  --authorized_keys "ssh-rsa AAAA_valid_public_ssh_key_123456785== user@their-computer"
  --authorized_users "myUser"
  --authorized_users "secondaryUser"
```

## Resources

- [Create Linode via API](https://www.linode.com/docs/api/linode-instances/#linode-create)
- [Stackscript referece](https://www.linode.com/docs/guides/writing-scripts-for-use-with-linode-stackscripts-a-tutorial/#user-defined-fields-udfs)
