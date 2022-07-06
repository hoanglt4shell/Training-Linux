#!/bin/bash
USERNAME=""
USERGROUP=""
DOMAIN=""
IP=""
WEB_ROOT_DIR=/home/$USERNAME/$DOMAIN
APACHEDIR=/etc/apache2
PROXY_PORT=""
block="/etc/ngix/sites-available/$DOMAIN"
HOSTNAME=""

install_service() {
    echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
    sudo apt-get update -y && sudo apt-get upgrade -y

    echo -e "\n\nInstalling Apache2 Web server\n"
    
    sudo apt-get install apache2 apache2-utils 
    sudo systemctl restart apache2
    sudo systemctl enable apache2

    echo -e "\n\nInstalling PHP & Requirements\n"
    sudo apt install software-properties-common apt-transport-https -y
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
    sudo apt upgrade
    sudo apt install php7.4-fpm php7.4-common libapache2-mod-fcgid php7.4-cli
    sudo a2enmod proxy_fcgi setenvif && sudo a2enconf php7.4-fpm

    echo -e "\n\nInstalling MySQL\n"
    sudo apt-get install mysql-server mysql-client -y

    echo -e "\n\nRestarting Apache\n"
    sudo service apache2 restart

      echo -e "\n\nPermissions for /var/www\n"
    sudo chmod -R 0755 /var/www/html/
    sudo chown -R www-data:www-data /var/www/
    echo -e "\n\n Permissions have been set\n"

    echo -e "\n\nInstall Nginx Reverse Proxy Server\n"
    sudo apt-get install nginx
    sudo ufw disable

    echo 'Finally Checking status of services'
    echo Apache service is $(systemctl show -p ActiveState --value apache2)
    echo MYSQL service is $(systemctl show -p ActiveState --value mysqld)

    exit 0

}

Install_Proxy(){
     echo "[ Setup proxy ]"
     echo -n "Domain"
     read DOMAIN
     
 # Set apt proxy settings
 apt_conf_proxy="
 server {
      listen 80;
      server_name $DOMAIN;
      access_log /var/log/nginx/access.log;
      proxy_set_header Host "'$host'";
      proxy_set_headerr X-Real-IP "'$remote_addr'";
      proxy_set_header X-Forwarded-For "'$proxy_add_x_forwarded_for'";

      location / {
           proxy pass http://$IP:$PROXY_POST;
      }
 }"

 echo "$apt_conf_proxy" | sudo tee -a $block > /dev/null

 sudo ln -s $block /etc/nginx/sites-enabled/
 
 sudo nginx -t && sudo service nginx reload
}

delete_old_domain(){
     if [ -z $DOMAIN ]
     then
  	     echo "You did not include the domain ..."
  	     exit 1
     fi

     sudo rm -rf /home/$USERNAME/$DOMAIN
     sudo rm -rf $APACHEDIR/sites-available/$DOMAIN
}

create_folder_new_domain(){

     read DOMAIN

 ## Make sure a domain was passed
     if [ -z $DOMAIN ]
     then
  	     echo "You did not include the new domain name..."
  	     exit 1
     fi

 ## Create the directory for the new domain
 mkdir -p /home/$USERNAME/$DOMAIN
 echo "+ Created dir /home/$USERNAME/$DOMAIN"

 ## Copy the vhosts template
 sudo mkdir -p $APACHEDIR/sites-available/$DOMAIN
 echo "+ Created vhosts file at $APACHEDIR R/sites-available/$DOMAIN"

 ## chown/chmod the vhosts files
 sudo chown $USERNAME:$USERGROUP $APACHEDIR/sites-available/$DOMAIN
 sudo chmod 775 $APACHEDIR/sites-available/$DOMAIN
 echo "+ chowned/chmoded vhosts file"

 sudo ln -s $APACHEDIR/sites-available/$DOMAIN $APACHEDIR/sites-enabled/

 echo "+ Enabling the domain and reloading Apache:"
 sudo a2ensite $DOMAIN
 sudo service apache2 reload

 echo "! Finished! Domain \"$DOMAIN\" was added"
     
}

create_new_domain(){
     create_user_group
     create_folder_new_domain
     create_databases

     echo "Enter a name of domain"
     read DOMAIN
     #echo "Enter a root directory of domain"
     #read WEB_ROOT_DIR
     echo "Enter the IP"
     read IP
     echo "Enter a Port"
     read PROXY_POST

 sitesEnable='/etc/apache2/sites-enabled/'
 sitesAvailable='/etc/apache2/sites-available/'
 sitesAvailabledomain=$sitesAvailable$DOMAIN.conf
 echo "Creating a vhost for $sitesAvailabledomain with a webroot $WEB_ROOT_DIR"

 ### create virtual host rules file
 echo "
    <VirtualHost *:$PROXY_POST>
      ServerName $DOMAIN
      DocumentRoot /home/$USERNAME/$DOMAIN
      <IfModule mpm_itk_module>
                AssignUserId $USERNAME $USERGROUP
        </IfModule>
      <Directory $WEB_ROOT_DIR/>
        Options Indexes FollowSymLinks
        AllowOverride all
      </Directory>
    </VirtualHost>" > $sitesAvailabledomain
 echo -e $"\nNew Virtual Host Created\n"

 echo "$IP $DOMAIN" | sudo tee -a > /etc/hosts

 service apache2 reload
 sudo a2ensite $DOMAIN
 service apache2 restart
 
 #addhost
 echo "Done, please browse to http://$DOMAIN to check!"
}

create_user_group(){
	
     echo "Enter a new user: "
     read USERNAME
     echo "Enter a new group for user"
     read USERGROUP

     groupadd $USERGROUP
     useradd -d /home/$USERNAME -g $USERGROUP -s /bin/bash -m $USERNAME
     passwd $USERNAME

     id $USERNAME

     echo "Add a user successfully"

		
}

menu(){
          echo -ne "
     --------Program create a new domain---------- 
     1. Creata a new domain(new user, new vhost)
     2. Delete a old domain on webserver
     3. List domain
     4. Check the domain have been existed
     0. Exit
     Choose an option: "
          read -r choice
          case $choice in
          1)
               create_new_domain
               ;;
          2)
               delete_old_domain  
               ;;
          3)
               ;;
          4)
               ;;
          0)
               echo ""
               exit 0
               ;;
          *)
               echo "ERROR"
               exit 1   
     esac 
}

create_databases(){

 Q1="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
 Q2="CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
 Q3="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
 Q4="FLUSH PRIVILEGES;"
 SQL="${Q1}${Q2}${Q3}${Q4}"
  
 echo "Please enter root user MySQL password!"
 read rootPassword
 mysql -u root -p${rootPassword} -e "$SQL"
     
 echo "MySQL DB / User creation completed!"
 echo " >> Host      : ${DB_HOST}"
 echo " >> Database  : ${DB_NAME}"
 echo " >> User      : ${DB_USER}"
 echo " >> Pass      : ${DB_PASS}"
 

}

main(){
     install_service
     Install_Proxy
     menu
}
          
main



