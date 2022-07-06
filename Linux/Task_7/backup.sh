#!/bin/bash

check_proxy(){
     
     block="/etc/nginx/site-availables/proxy"
     echo "Enter ip to check proxy"
     read IP


     ip_array=($(grep "$IP" $block |awk '{print $2}'|awk -F":" '{print $1}'))
     while true
     do

     for((i=0;i<${#ip_array[*]};i++))

     do

         egrep "^#.*${ip_array[$i]}.*" $block &>/dev/null

         [ $? -eq 0 ] && continue

         status=`curl -s -w "%{http_code}" -o /dev/null ${ip_array[$i]}`

         if [ ${status} -ne 200 ]

             then

              sed -i "s/server ${ip_array[$i]}/#server ${ip_array[$i]}/g" $block

              /etc/init.d/nginx reload

         fi

    done
     sleep 5

     for((i=0;i<${#ip_array[*]};i++))
     do
 a=`curl -s -w "%{http_code}" -o /dev/null ${ip_array[$i]}`

     if [ ${a} -eq 200 ];then

      egrep "^#.*${ip_array[$i]}.*" $block &>/dev/null

      if [ $? -eq 0 ];then

           sed -i -r "s/#(.*${ip_array[$i]}.*)/\1/g" $block

           /etc/init.d/nginx reload

          fi

          fi
     done
     done
}

Install_Proxy(){
 # Configuration
     PROXY_DOMAIN=""
     PROXY_HOST=""
     PROXY_USER=""
     PROXY_PASSWORD=""
     PROXY_PORT=""
     block="/etc/ngix/sites-available/$domain"

     echo "[ Setup proxy ]"
     echo -n "Domain"
     read PROXY_DOMAIN
     echo -n "Host: "
     read PROXY_HOST
     echo -n "Port: "
     read PROXY_PORT
     #echo -n "Username: "
     #read PROXY_USER
     #echo -n "Password: "
     #read -s PROXY_PASSWORD
     echo "Updating home dir"
     sudo mkdir /home/$PROXY_USER

     echo_statement "Configuring NGINX reverse proxy server"
     sudo apt-get install nginx-full -y

 # Set apt proxy settings

 echo "Sudo privileges required to write to /etc/ngix/sites-available/pro"
 apt_conf_proxy="
 server {xy
      listen $PROXY_PORT;
      server_name $domain;
      access_log /var/log/nginx/access.log;
      proxy_set_header Host $host;
      proxy_set_headerr X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For '$proxy_add_x_forwarded_for';

      location / {
           proxy pass http://$PROXY_IP:$PROXY_POST;
      }
 }
  "

 echo "$apt_conf_proxy" | sudo tee -a $block > /dev/null

 echo ""
 sudo ln -s $block /etc/nginx/sites-enabled/
 
 echo "Reload the Server"
 sudo nginx -t && sudo service nginx reload
 
 echo "Proxy enabled."
}

addhost(){
     HOSTNAME=$2
     if [ -n "$(grep $HOSTNAME /etc/hosts)"]
     then
          echo "$HOSTNAME already exist : $(grep $HOSTNAME $ETC_HOSTS)";
     else
          echo "Adding $HOSTNAME to the $ETC_HOSTS";
          printf "%s\t%s\n" "$IP" "$HOSTNAME" | sudo tee -a /etc/hosts > /dev/null

          if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
               then
                    echo "$HOSTNAME was add successfully \n $(grep $HOSTNAME /etc/hosts)";
          else 
               echo "Failed to Add $HOSTNAME, Try again!";
          fi
     fi
}

removehots(){
     echo "Enter a domain and ip of domain to remove"
     read HOSTNAME
     read IP
     ETC_HOSTS=/etc/hosts

     if [ -n "$(grep $HOSTNAME /etc/hosts)"]
     then
          echo "$HOSTNAME found in $ETC_HOSTS, Removing now..."
          #sudo sed -i ".bak" "/$HOSTNAME/d" $ETC_HOSTS
          sudo sed -i "$IP" "/$HOSTNAME/d" $ETC_HOSTS
     else
          echo "$HOSTNAME was not found in your $ETC_HOSTS"
     fi
}

create_folder_new_domain(){
     
          APACHEDIR=/etc/apache2
          #TEMPLATEFILE=_TEMPLATE_
          WWWDIR=/var/www/html
          HTMLDIR=public_html
          WWWUSER=www-data
          WWWGROUP=www-data
          TOKEN=%DOMAIN%


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
 sudo chown $WWWUSER:$WWWGROUP $APACHEDIR/sites-available/$DOMAIN
 sudo chmod 775 $APACHEDIR/sites-available/$DOMAIN
 echo "+ chowned/chmoded vhosts file"

 sudo ln -s $APACHEDIR/sites-available/$DOMAIN $APACHEDIR/sites-enabled/

 echo "+ Enabling the domain and reloading Apache:"
 sudo a2ensite $DOMAIN
 sudo service apache2 reload

 echo "! Finished! Domain \"$DOMAIN\" was added"
     exit
     fi
}

create_new_domain(){
     create_linux_user_and_group
     name=
     WEB_ROOT_DIR=
     IP=

     echo "Enter a name of domain"
     read name
     echo "Enter a root directory of domain"
     read WEB_ROOT_DIR
     echo "Enter the IP"
     read IP

 sitesEnable='/etc/apache2/sites-enabled/'
 sitesAvailable='/etc/apache2/sites-available/'
 sitesAvailabledomain=$sitesAvailable$name.conf
 echo "Creating a vhost for $sitesAvailabledomain with a webroot $WEB_ROOT_DIR"

 ### create virtual host rules file
 echo "
    <VirtualHost *:80>
      ServerName $name
      DocumentRoot $WEB_ROOT_DIR
      <Directory $WEB_ROOT_DIR/>
        Options Indexes FollowSymLinks
        AllowOverride all
      </Directory>
    </VirtualHost>" > $sitesAvailabledomain
 echo -e $"\nNew Virtual Host Created\n"

 echo "$IP $name" | sudo tee -a > /etc/hosts

 service apache2 reload
 sudo a2ensite $name
 service apache2 restart

 echo "Done, please browse to http://$name to check!"
}

delete_domain(){
 ##Delete the domain 
 AVAILABLE=~/available.txt
 DOMAIN=~/domain.txt

 lockfile whois-scrip.lock

 while read -r domain; do
     whois $DOMAIN | grep -qci "No match"
     if [ $? -ne 0 ]; then
     echo $DOMAIN >> $AVAILABLE
     fi
 done < $DOMAIN

 rm -rf whois-scrip.lock

 while read -r domain; do
     sed -i "/$DOMAIN/d" $DOMAIN
 done < $AVAILABLE

 ##
 ETC_HOSTS=/etc/hosts
 IP=$1
 HOSTNAME=$2
}

viewdomain(){
     _command_exists(){
               type "$1" &> /dev/null
          }

          _usage(){
               echo "Usage : $0 [-d domain name ]"
               echo "-d domain"
          }

          function _get_ipaddress(){
                DOMAIN=${1}
	           domainalias=""
	           ipaddress=""
	          domainalias=$(host -t A "${DOMAIN}" | grep "is\ an\ alias" | awk '{print $6}' | sed 's/.$//')
	          ipaddress=$(host -t A "${DOMAIN}" | grep -v "has\ no" | awk '{print $4}' | sed '/^ *$/d' | tr '\n' ' ' | sed 's/ $//')
	          #ipaddress=$(dig "${DOMAIN}" +short | tr '\n' ' ' | sed 's/ $//')
	          if [ -n "${domainalias}" ]; then
		     echo -e "Domain:\t\t${DOMAIN} is alias for ${domainalias}"
		     ipaddress=$(host -t A "${domainalias}" | grep -v "has\ no" | awk '{print $4}' | sed '/^ *$/d' | tr '\n' ' ' | sed 's/ $//')
	          else
		     echo -e "Domain:\t\t${DOMAIN}"
	          fi
	          if [ -n "${ipaddress}" ]; then
		     echo -e "IP Address:\t${ipaddress}"
	          else
		     echo -e "IP Address:\t'A' record not found"
	          fi

          }

          function _get_nameserver(){
                DOMAIN=${1}
	           nservercnt=0
	           ipnserver=""
                i=1
                ns=""
	          nservercnt=$(host -t NS ${DOMAIN} | grep -v "has\ no NS" wc -1)
               echo -e "DOMAINAME:\tFound ${nservercnt} NS record"
               for ns in $(dig ns "${DOMAIN}" | grep -v '^;' | grep NS | awk {'print $5'} | sed '/^$/d' | sed 's/.$//' | sort); do
		 #ipnsserver=$(getent hosts "${ns}" | awk '{print $1}')
		     ipnsserver=$(host -t A "${ns}" | grep -v "not\ found" | awk '{print $4}' | sed '/^ *$/d' | tr '\n' ' ' | sed 's/ $//')
		 if [ -n "${ipnsserver}" ]; then
			echo -e "Name Server $i:\t${ns} (${ipnsserver})";
		 else
			echo -e "Name Server $i:\t${ns} (DNS resolv error)";
		 fi
		 let i++;
	      done;
          }

          function _view_domain_infor(){
               local DOMAIN=${1}
               local whoisdomain=""
               local nslookupdomain=""
               local whoisdomain_delagated=""
               local domainalias=""
               echo "Checking the domain '${DOMAIN}', please wait..."
               whoisdomain=$(whois "${DOMAIN}" | grep -Ei 'state|status')
               nslookupdomain=$(nslookup "${DOMAIN}" 2>/dev/null | awk '/^Address: / { print $2 }')
	     if [ -n "${whoisdomain}" ]; then
		whoisdomain_delagated=$(whois "${DOMAIN}" 2>/dev/null | grep -Ei 'NOT DELEGATED')
		     if [ -n "${whoisdomain_delagated}" ]; then
			echo "Domain ${DOMAIN} is not delegated."
			exit 1
		     fi
		_get_ip_address "${DOMAIN}"
		domainalias=$(host -t A "${DOMAIN}" | grep "is\ an\ alias" | awk '{print $6}' | sed 's/.$//')
		     if [ -n "${domainalias}" ]; then
			_get_nameserver "${domainalias}"
			
		     else
			_get_nameserver "${DOMAIN}"
			
		     fi
	     elif [ -n "${nslookupdomain}" ]; then
		_get_ip_address "${DOMAIN}"
		domainalias=$(host -t A "${DOMAIN}" | grep "is\ an\ alias" | awk '{print $6}' | sed 's/.$//')
		     if [ -n "${domainalias}" ]; then
			_get_nameserver "${domainalias}"			
		     else
			_get_nameserver "${DOMAIN}"
		     fi 
          else
               echo "Domain '${DOMAIN}' is not registed"
               exit 1
          fi
 }

 if ! _command_exists whois; then
     echo "ERROR: Command 'whois' not found"
     exit 1
 fi

 if ! _command_exists nslookup; then
     echo "ERROR: Command 'nslookup' not found"
     exit 1
 fi

 if ! _command_exists dig; then
     echo "ERROR: Command 'dig' not found"
     exit 1
 fi

 while getopts hd: option
 do
	case "${option}"
	in
		d)
			DOMAIN=${OPTARG}
		;;
		\?)
			_usage
			exit 1
		;;
		esac
 done

 if [ "${DOMAIN}" != "" ]
 then
	_view_domain_info "${DOMAIN}"
 else
	_usage
	exit 1
 fi

 exit 0
}


create_user_group (){
	USERNAME=
     USERGROUP=

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
     --------Program manager domain(vhost) on server web---------- 
     1. Check the reverser proxy have been existed
     2. Install reverser proxy for Server
     3. Server have been installed reverser proxy
     0. Quit
     Choose an option: "

     read -r choice
     case $choice in
     1) 
          ;;
     2)
          ;;
     3)
          ;;
     0)
          echo ""
          exit 0
          ;;
     *)
          echo "ERROR"
          exit 1
          ;;   
    esac
}

submenu(){
          echo -ne "
     --------Program create a new domain---------- 
     1. Creata a new domain(new user, new vhost)
     2. Delete a old domain on webserver
     3. List domain
     4. Check the domain have been existed
     5. Go back to the main menu
     0. Exit
     Choose an option: "
          read -r choice
          case $choice in
          1)
               ;;
          2)
               ;;
          3)
               ;;
          4)
               ;;
          5)
               menu
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

nginx_reverse_proxy_check(){
        echo "Input URL of website to check Reverse Proxy: "
        read URL
        RESPONSE_MESSAGE=curl -S -I ${URL} 2> /dev/null | grep "Server" | awk '{print $2}'
        if [ -z "$RESPONSE_MESSAGE" ] 
        then
            echo "Server not installed Reverse Proxy yet"
            install_nginx_as_rp
         
        elif [ "$RESPONSE_MESSAGE"=="nginx"* ] 
        then
            echo "Server already installed Reverse Proxy - ${RESPONSE_MESSAGE}"
           
        else
            echo "WARNING - Server not installed Nginx Reverse Proxy yet"
            install_nginx_as_rp
            
        fi
}


          



