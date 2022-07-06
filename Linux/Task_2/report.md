# RESEARCH ABOUT THE SSL, DOMAIN, DNS, VHOST

1. <a href='#1'> SSL
2. <a href='#2'> Domain
3. <a href='#3'> DNS
4. <a href='#4'> Hosting, VPS, Server
5. <a href='#5'> Reverse proxy
6. <a href='#6'> Nginx and Apache


<div id='1'></div>

## 1. SSL
* SSL is a secure protocol developed for sending information securely over the Internet. Many websites use SSL for secure areas of their sites, such as user account pages and online checkout
* Types of SSL:
  * Domain Validation – DV SSL: checks the right of the applicant to use a specific domain name.
  * Organization Validation – OV SSL: checks the right of the applicant to use a specific domain name PLUS it conducts some vetting of the organization.
  * Extended Validation – EV SSL: checks the right of the applicant to use a specific domain name plus, it conducts a thorough vetting of the organization.
* Components of SSL
  * CSR (Certificate Signing Request):
  * CRT (Certificate): the component after the CSR is confirmed and returned to the subscriber
  * Private key: an encrypted file generated at the same time when creating a CSR
  * CA (Certificate Authority hoặc Certification Authority): The ognazation which provide the information about SSL cerfiticate
* How does SSL work 
  * User connect witch the service support SSL
  * The user's application requests the server's public key in exchange for its own public key.
  * when the users sent a message to server, the application will use pulic key's serverto encrypted a message
  * The server receive a message's user and decrypt it by use key's server 
  
  
<div id='2'></div>

## 2. Domain
* Domain is the address of website active on the Internet. A place that people use to search on a browser to access any website. Domains are represented by letters or numbers in the alphabet instead of the server's IP address.
* Types of domain
  * TLD: top-level domain is the last part after the dot of a domain name and is the domain extension listed at the top level in DNS. Example: .com, .org, .net and .vn
    * ccTLD: are the domains used in a particular country according to the ISO code. Example: .vn(VietNam), .es(United States), ....
    * gTLD: is a commonly used domain name and is used all over the world regardless of any country code. Example: .com, .net, .biz, ...
    * sTLD: are top-level domains restricted to government organizations. Example .gov, .mil, .edu, ...
    * uTLD: top-level domains such as: .biz, .pro, .name, .info.
    * iTLD: is the .arpa domain that represents ARPA and is dedicated to ICANN to address infrastructure issues.

<div id='3'></div>

## 3. DNS
* DNS(Domain Name Server): is a domain name resolution system. DNS is a system that allows setting correspondence between IP addresses and domain names on the Internet.
* Types of DNS record 
  * CNAME Record: Is a Canonical Name Record. This is a type of resource record in the domain name system.
  * A Record: Used to point the website domain name to a specific IP address. This is considered the simplest DNS record.
  * MX Record: This record you can use to point the domain name to the mail server. The MX Record specifies which server manages that domain's Email services.
  * SRV Record: This is a special DNS record, used to determine exactly which service is running on which port. And through this record you can add **Priority, Port, Weight, TTL, Point to.**
  * NS Record:This record can specify a Name Server for each subdomain and in addition can create a new Name Server, TTL or host name.
  
<div id='4'></div>

## 4. Hosting, VPS, Server
### a. Web Hosting
* Web hosting is a service that allows organizations and individuals to post a website or web page onto the Internet.
* Types of Hosting:
  * Shared hosting is the solution for website owners with lower traffic sites.
  * Dedicated hosting you rent an entire physical server for your business.
  * VPS hosting (Virtual Private Server) A physical server is installed virtualization application to create many virtual servers.
  * Cloud hosting is a hosting service operated on a cloud computing platform. 

### b. VPS
* VPS(Virtual Private Server): is a virtual server, created by dividing the physical server into many other servers.
* VPS is created using virtualization technology instead of using conventional management software (hosting control panel) to manage. 

### c. Server
* A server is a computer program or device that provides a service to another computer program and its user, also known as the client. In a data center, the physical computer that a server program runs on is also frequently referred to as a server. That machine might be a dedicated server or it might be used for other purposes.
* Types of Server:
  * **Mail server**: Support sending and receiving mail (gmail, yahoo mail, yandex, amazon email service).
  * **Web server**: is a server with the function of storing information and data of the website, creating a connection environment for customers to access the website easily.
  * **Proxy server**: Proxy servers act as a bridge between a host server and a client server. A proxy sends data from a website to your computer IP address after it passes through the proxy's server.
  * **File transfer protocol (FTP) server**: FTP servers are used to relocate files from one computer to another.
  * **Database server**: A dedicated server used for database administration. On the server, professional database management software is installed: SQL server, MySQL, Oracle...
  * **File server**: A file server stores data files for multiple users. They allow for faster data retrieval and saving or writing files to a computer.

<div id='5'></div>

## 5. Reverse proxy
* A **reverse proxy** is a common type of proxy server that is accessible from the public network. Large sites and CDNs use reverse proxies – along with other techniques to balance loads between internal servers. Reverse proxies can keep a cache of static content. This reduces the load on these internal servers and the internal network. Reverse proxies also often add features such as TLS compression or encryption to the communication channel between the client and the reverse proxy.
* A **proxy server** is a go‑between or intermediary server that forwards requests for content from multiple clients to different servers across the Internet.
* Working principle of Reverse proxy:
  * Receive connection request from user
  * Implement TCP three-way handshake
  * Connect to the origin server and forward the original request

<div id='6'></div>

## 6. Nginx and Apache
* Nginx: can also be used as a reverse proxy server which revises the request from the client and sends the request to the proxy server
* Apache: is "Apache HTTP Server". It is an open-source, high-performance web server software developed and maintained by Apache Software Foundation. Apache is designed to create a secure, robust and efficient commercial-grade web server in line with the current HTTP standards.
* Differents between Nginx and Apache

| | **Apache** |**Nginx**|
|:---|:----------------|---:|
| |Apache is an open-source web server.|Nginx is also used as a reverse proxy server which revices the request from client and send the request to proxy server. |
| |A single thread can only process one connection.|A single thread can handle multiple connections.|
| |The performance of Apache for static content is lower than Nginx. |Nginx run times faster than Apache and uses little less memory. |
| |Apache is written in C and XML. |Nginx is written in C language. |


