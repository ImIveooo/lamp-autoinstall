#!/bin/bash

echo -e "
        ____          ____                               
       /  _/___ ___  /  _/   _____  ____  ____  ____     
       / // __  __ \ / /| | / / _ \/ __ \/ __ \/ __ \    
     _/ // / / / / // / | |/ /  __/ /_/ / /_/ / /_/ /    
    /___/_/ /_/ /_/___/ |___/\___/\____/\____/\____/_____
                                                  /_____/
    Script made by ImIveooo_ : https://imiveooo.fr, https://github.com/imiveooo
                                        
        The purpose of this script is to do an 
    auto-installation of various packages for LAMP.
                            ImIveooo_
"

export aptrepd="/etc/apt/sources.list.d";
export aptrep="/etc/apt";

# Checking If the user is Root!
if ! [ $(id -u) = 0 ]; then
    echo "Please run as root!"
    exit 1
fi
echo "Run as root! The script may continue."

# Checking If their is an internet Connection.
echo "Checking Internet connection !"
if ping -q -c 1 -W 1 google.com >/dev/null; then
    echo "The network is up!"
else
    echo "The network is down!"
    exit 1
fi

# Request for confirmation to proceed with auto-install.
read -r -p "Proceed to the execution of the script? (y/N) " response

case $response in
    y|Y|yes|Yes)
        echo "Execute the script."
        # Adding netbytes repositories.
        read -r -p "Do you want to add netbytes repositories? (y/N) " aptupdate
        case $aptupdate in
            y|Y|yes|Yes)
              echo "Added netbytes repositories!"
              cp $aptrep/sources.list $aptrep/sources.list.back
              mv sources.list $aptrep/sources.list
              apt update;;
            n|N|no|No)
              echo "Repositories will not be added.";;
        *) echo "Invalid character, repositories will not be added."
        esac
        # Update system.
        read -r -p "Would you like to update and fully update your system? (y/N) " optupdate
        case $optupdate in
            y|Y|yes|Yes)
              apt update && apt full-upgrade -y;;
            n|N|no|No)
              echo "Your system will not be updated.";;
        *) echo "Invalid character, your system will not be updated."
        esac
        #Install lamp.

        # Fire-wall
        ufw allow http
        ufw allow https

        # install apache2
        apt install apache2 -y
        systemctl start apache2

        # config apache2
        a2dissite 000-default
        systemctl reload apache2
        read -r -p "Name of your site? " namesite
        mkdir /var/www/$namesite
        read -r -p "Your user name? " username
        chown -R $username:www-data /var/www/$namesite/
        chmod -R 750 /var/www/$namesite/
        touch /etc/apache2/sites-available/$namesite.conf
        echo "<VirtualHost *:80>
              DocumentRoot "/var/www/$namesite"
              <Directory "/var/www/$namesite">
                    Options +FollowSymLinks -Indexes
                    AllowOverride All
                    Require all granted
              </Directory>
                    ErrorLog ${APACHE_LOG_DIR}/error.$namesite.log
                    CustomLog ${APACHE_LOG_DIR}/access.$namesite.log combined
        </VirtualHost>" >> /etc/apache2/sites-available/$namesite.conf
        a2ensite $namesite
        systemctl reload apache2
        touch /var/www/$namesite/index.html
        echo "<!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>[TEST] Website!</title>
        </head>
        <body>
            <h1>Welcome to our website.</h1>
        </body>
        </html>" >> /var/www/$namesite/index.html
        a2enmod rewrite
        systemctl restart apache2

        # install php
        apt install php libapache2-mod-php -y
        touch /var/www/$namesite/test.php
        echo "<?php phpinfo(); ?>" >> /var/www/$namesite/test.php
        apt install php-intl php-mbstring php-mysql php-json -y
        systemctl restart apache2

        # install mariadb
        apt install mariadb-server mariadb-client -y
        echo "Now mariadb will ask you some questions to configure your database server."
        mysql_secure_installation

        # install phpmyadmin
        echo "During the installation, the installer will ask to configure a web server, the answer is YES! (apache2)"
        apt install phpmyadmin -y

        # create user for phpmyadmin
        read -r -p "Name of your new user for phpmyadmin? " usersql
        read -r -p "Password for your new user? " mdpsql
        read -r -p "Root password for your database? " rootsql
        mariadb -u root -p$rootsql -Bse "CREATE USER '$usersql'@'localhost' IDENTIFIED BY '$mdpsql'; GRANT ALL ON *.* TO '$usersql'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"
        ;;
    n|N|no|No)
        echo "No an expected answer. Abording."
        exit
        ;;
*) echo "Invalid character, no an expected answer. Abording."
esac