#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root"
	exit 1
else
	echo -n "Name virtual host: "
	read name
	echo -n "Extension virtual host: "
	read ext
	if [ -z $ext ]; then
		ext="local"
		echo "set default extension: $ext"
	fi
	cat > /etc/apache2/sites-available/$name.conf << EOF
	<VirtualHost *:80>
		    ServerAdmin webmaster@localhost
		    ServerName $name.$ext
		    ServerAlias www.$name.$ext
		    DocumentRoot /var/www/$name.$ext/www
		    <Directory />
		            Options FollowSymLinks
		            AllowOverride None
		    </Directory>
		    <Directory /var/www/$name.$ext/www>
		            Options -Indexes FollowSymLinks MultiViews
		            AllowOverride All
		            Order allow,deny
		            allow from all
		    </Directory>

		    ErrorLog /var/www/$name.$ext/log/error.log

		    # Possible values include: debug, info, notice, warn, error, crit,
		    # alert, emerg.
		    LogLevel warn

		    CustomLog /var/www/$name.$ext/log/access.log combined
	</VirtualHost>
EOF
	sudo a2ensite $name
	sudo service apache2 restart ;
fi
