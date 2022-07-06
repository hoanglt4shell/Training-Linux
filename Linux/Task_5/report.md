# PROXY SERVER

1. <a href='#1'> Reverse proxy
2. <a href='#2'> Mysql
3. <a href='#3'> vsftpd
4. <a href='#4'> phpmyadmin


<div id='1'></div>
  
# 1. Reverse proxy
![](Png/nginx-reverse-proxy.png)
* Install nginx on ubuntu to setup reverse proxy:
  * sudo apt install nginx -y
* Set up reverser proxy on nginx
![](Png/proxy.png)

* Check log on reverproxy when login two domain on web browser

![](Png/result-proxy.png)


<div id='2'></div>

## 2. Mysql 
* By default, this value is set to **127.0.0.1**, which means the server will only look for connections locally. You need to change this market only to refer to an external IP address. 
* Edit file config in **sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf**
* Change the ip local 127.0.0.1 to ip_server_mysql or 0.0.0.0
![](Png/edit-mysql-cnf.png)

* Create user for remote mysql 
  * **sudo mysql -u root -p**
  * > CREATE USER 'user'@'remote_server_ip' IDENTIFIED BY 'password';
  * > GRANT ALL on *.* TO 'user'@'remote_server_ip' WITH GRANT OPTION;
  * > FLUSH PRIVILEGES;
  * > exit

![](Png/create-user-remotemysql.png)

* Open port 3306 - the port default of MySQL - which to allow traffic to MySQL
  * sudo ufw allow from remote_IP to any port 3306
  * sudo ufw allow 3306
![](Png/allow-port-3306.png)

* Check the remote database on client by commned
  * **mysqp -u user -h database_server_ip -p**
![](Png/database-server.png)
![](Png/check-on-client.png)

<div id='3'></div>

# 3. Vsftpd
* Install vsftpd by command: **sudo apt-get install vsftpd**
![](Png/ftp-install.png)

* Creat the file backup and edit finf vsftpd.conf by command:
  * sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
  * sudo nano /etc/vsftpd.conf
    * anonymous_enable=NO
    * local_enable=YES
    * write_enable=YES
    * allow_writeable_chroot=YES
    * chroot_local_user=YES
    * local_umask=022 
    * userlist_deny=NO
    * userlist_enable=YES
    * userlist_file=/etc/vsftpd.allowed_users 
![](Png/ftp-config.png)

* Create the files to allow user coonect ftp :
    *  sudo touch /etc/vsftpd.allowed_users 
* Add user for FTP:
  * sudo useradd ftpuser
  * sudo passwd 123
* Add user to file user_list to access: 
  * echo 'ftpuser' | sudo tee -a /etc/vsftpd.allowed_users
* Creat a folder for the new user
  * sudo mkdir -p /home/ftpuser/ftp/test
  * sudo chmod 550 /home/ftpuser/ftp/
  * sudo chmod 750 /home/ftpuser/ftp/test
  * sudo chown -R ftpuser: /home/ftpuser/ftp/
![](Png/folder-ftp.png)

* Edit the firewall to open port 20 21 to accept connect with ftp
![](Png/ufw-ftp.png)

* Restart and check status of vsftpd
  * sudo systemctl restart vsftpd
  * sudo systemctl status vsftpd
![](Png/ftp-status.png)

* Open the client and test connect with ftp server
  * ftp -p **ip server**

![](Png/ftp-result.png)

<div id='4'></div>

# 4. Phpmyadmin
* Creat user for phpmyadmin on databases mysql
  * > CREATE DATABASE phpmyadmin;
  * > GRANT ALL PRIVILEGES on phpmyadmin.* TO 'phpmyadmin'@'localhost' IDENTIFIED BY 'hoanglt';
  * > FLUSH PRIVILEGES;
  * > exit

![](Png/phpmyadmin-database.png)

* Install phpmyadmin by command: **sudo apt install phpmyadmin**
![](Png/phpmyadmin-install.png)

* Config alias document root for phpmyadmin to allow login on web browser 
![](Png/phpmyadmin-config.png)

* This is the result after install and set up phpmyadmin
![](Png/phpmyadmin-result.png)

* Set up user and group for web laravel and wordpress 
  * In file config of web server laravrel:  wirte the content **AssignUserId: laravel laravel** into the file /etc/apache2/site-available/laravel.conf
![](Png/uidcnf-laravel.png)

  * In file config of web server wordpress:  wirte the content **AssignUserId: wordpress wordpress** into the file /etc/apache2/site-available/wordpress.conf
![](Png/uidcnf-wordpress.png)

* To check the result after set up the config, in the document root of web server, creat the file **info.php** and write down the content below to: 
  *  *'<php?
    system("id");
    ?>'*

* On the web browser enter a format domain/info.php to check the result:

![](Png/uid-wordpress.png)
![](Png/uid-laravel.png)