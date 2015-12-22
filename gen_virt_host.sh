#!/bin/bash

ROOT_UID=0

if [ $UID != $ROOT_UID ]; then
    echo "Run script as ROOT."
    exit 1
fi

echo -n "Name virtual host: "
read name
echo -n "Extension virtual host: "
read ext
if [ -z $ext ]; then
	ext="local"
	echo "set default extension: $ext"
fi
sudo cat > /etc/apache2/sites-available/$name.conf << EOF
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
	    	Options Indexes FollowSymLinks MultiViews
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

for i in log www; do sudo mkdir -p /var/www/$name.$ext/$i; done
for i in error access; do sudo touch /var/www/$name.$ext/log/$i.log; done
sudo touch /var/www/$name.$ext/www/readme.md
sudo chown www-data:www-data -R /var/www/$name.$ext

sudo a2ensite $name.conf
sudo service apache2 restart
echo "Complete!"
