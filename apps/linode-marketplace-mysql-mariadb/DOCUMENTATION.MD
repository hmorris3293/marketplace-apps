---
title: "Deploy MySQL/MariaDB through the Linode Marketplace"
description: "This guide shows how to install and configure MySQL/MariaDB so you can run databases for anything from a CRM to WordPress by using the Linode One-Click Marketplace."
published: 2020-03-13
modified: 2024-10-25
keywords: ['database','mysql','rdbms','relational database','mariadb']
tags: ["database","cloud-manager","linode platform","mysql","marketplace","mariadb"]
external_resources:
- '[MySQL Guide](https://dev.mysql.com/doc/mysql-tutorial-excerpt/8.0/en/)'
- '[MariaDB Guide](https://mariadb.com/get-started-with-mariadb/)'
aliases: ['/products/tools/marketplace/guides/mysql/','/platform/marketplace/deploy-mysql-with-marketplace-apps/', '/platform/one-click/deploy-mysql-with-one-click-apps/', '/guides/deploy-mysql-with-one-click-apps/', '/guides/deploy-mysql-with-marketplace-apps/','/guides/mysql-marketplace-app/']
authors: ["Akamai"]
contributors: ["Akamai"]
license: '[CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0)'
---

MySQL is an open-source database management system that uses a relational database and SQL (Structured Query Language) to manage its data. MariaDB is an open-source, multi-threaded relational database management system, backward compatible replacement for MySQL. It is maintained and developed by the MariaDB Foundation.

## Deploying a Marketplace App

{{% content "deploy-marketplace-apps-shortguide" %}}

{{% content "marketplace-verify-standard-shortguide" %}}

{{< note >}}
**Estimated deployment time:** MySQL/MariaDB should be fully installed within 2-5 minutes after the Compute Instance has finished provisioning.
{{< /note >}}

## Configuration Options

- **Supported distributions:** Ubuntu 24.04 LTS
- **Recommended plan:** Depends on the size of your MySQL database and the amount of traffic you expect.

### MySQL/MariaDB Options

- **MySQL or MariaDB** *(required)*: Select which database service you'd like to use.
- **MySQL User** *(required)*: The user for your MySQLDB database.


{{% content "marketplace-required-limited-user-fields-shortguide" %}}

{{% content "marketplace-custom-domain-fields-shortguide" %}}

{{% content "marketplace-special-character-limitations-shortguide" %}}

## Getting Started after Deployment

### Access MySQL/MariaDB

Once the deployment is complete, MySQL or Mariadb is now installed and ready to use! You can now SSH into your machine and obtain the credentials which can be found in a .credentials file in the sudo users home directory (`/home/$SUDO_USER/.credentials`)

## Using MySQL/MariaDB

The standard tool for interacting with MySQL is the `mysql` client which installs with the `mysql-server` package. The MySQL client is used through a terminal.

### Root Login

1.  To log in to MySQL/MariaDB as the root user:

        sudo mysql -u root -p

1.  When prompted, enter the MySQL root password that you set when launching the Marketplace App. You'll then be presented with a welcome header and the MySQL prompt as shown below:

        MariaDB [(none)]>

1.  To generate a list of commands for the MySQL prompt, enter `\h`. You'll then see:

        List of all MySQL commands:
        Note that all text commands must be first on line and end with ';'
        ?         (\?) Synonym for `help'.
        clear     (\c) Clear command.
        connect   (\r) Reconnect to the server. Optional arguments are db and host.
        delimiter (\d) Set statement delimiter. NOTE: Takes the rest of the line as new delimiter.
        edit      (\e) Edit command with $EDITOR.
        ego       (\G) Send command to mysql server, display result vertically.
        exit      (\q) Exit mysql. Same as quit.
        go        (\g) Send command to mysql server.
        help      (\h) Display this help.
        nopager   (\n) Disable pager, print to stdout.
        notee     (\t) Don't write into outfile.
        pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
        print     (\p) Print current command.
        prompt    (\R) Change your mysql prompt.
        quit      (\q) Quit mysql.
        rehash    (\#) Rebuild completion hash.
        source    (\.) Execute an SQL script file. Takes a filename as an argument.
        status    (\s) Get status information from the server.
        system    (\!) Execute a system shell command.
        tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
        use       (\u) Use another database. Takes database name as argument.
        charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
        warnings  (\W) Show warnings after every statement.
        nowarning (\w) Don't show warnings after every statement.

        For server side help, type 'help contents'

        MariaDB [(none)]>

1.  To Exit MySQL/MariaDB type:

        exit

### Create a Sample Table

1.  Log back in as **MySQL User** that you set when launching the Marketplace App. In the following example the **MySQL User** is `webuser`.

        sudo mysql -u mysql_user -p

2.  Create a sample table called `customers`. This creates a table with a customer ID field of the type `INT` for integer (auto-incremented for new records, used as the primary key), as well as two fields for storing the customer's name. In the following example `webdata` is the database that you created when launching the Marketplace App.

        use webdata;
        create table customers (customer_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, first_name TEXT, last_name TEXT);

3.  To view the contents of the table that you created:

        describe customers;

       The output would be:

        +-------------+---------+------+-----+---------+----------------+
        | Field       | Type    | Null | Key | Default | Extra          |
        +-------------+---------+------+-----+---------+----------------+
        | customer_id | int(11) | NO   | PRI | NULL    | auto_increment |
        | first_name  | text    | YES  |     | NULL    |                |
        | last_name   | text    | YES  |     | NULL    |                |
        +-------------+---------+------+-----+---------+----------------+


4. Then exit MySQL/MariaDB.

        exit

## Next Steps

{{% content "marketplace-update-note-shortguide" %}}

For more on MySQL/MariaDB, checkout the following guides:

- [MariaDB Clusters with Galera](/docs/guides/set-up-mariadb-clusters-with-galera-debian-and-ubuntu/)