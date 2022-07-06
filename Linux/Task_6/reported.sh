#!/bin/bash

# On command lind type "crontap -e" to set up run script auto daily
# 0 0 * * * * /home/hoanglt/scripts/mysql_backup.sh 
 
# directory to put the backup files
BACKUP_DIR=/home/hoanglt/backup

# MYSQL Parameters
MYSQL_UNAME=  
MYSQL_PWORD=
MYSQL_DBNAME=

#echo "Enter the databases name"
#read MYSQL_UNAME
#echo "Enter the passwd of databases"
#read MYSQL_PWORD

# Không backup các databases với các tên
IGNORE_DB="(^mysql|_schema$)"

# include mysql and mysqldump binaries
PATH=$PATH:/usr/share/mysql/

# Giữ file backup trong 3 ngày
KEEP_BACKUPS_FOR=3 #days


# YYYY-MM-DD
TIMESTAMP="$(date +"%d-%m-%y_%s")"

function delete_old_backups()
{
  find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \
  
}

function mysql_login() {
  local mysql_login="-u $MYSQL_UNAME"
  if [ -n "$MYSQL_PWORD" ]; then
    local mysql_login+=" -p$MYSQL_PWORD"
  fi
  echo $mysql_login
}

function database_list() {
  local show_databases_sql="SHOW DATABASES WHERE \`Database\` NOT REGEXP '$IGNORE_DB'"
  #DBS="$($MYSQL -h $MyHOST -u $MyUSER -p$MyPASS -Bse 'show databases')"
  echo $(mysql $(mysql_login) -e "$show_databases_sql"|awk -F " " '{if (NR!=1) print $1}')
}

function echo_status(){
  printf '\r';
  printf ' %0.s' {0..100}
  printf '\r';
  printf "$1"'\r'
}

function backup_database(){
    backup_file="$BACKUP_DIR/$TIMESTAMP.$database.sql.gz"
    output+="$database => $backup_file\n"
    echo_status "...backing up $count of $total databases: $database"
    $(mysqldump $(mysql_login) $database | gzip -9 > $backup_file)
}

function backup_databases(){
  local databases=$(database_list)
  local total=$(echo $databases | wc -w | xargs)
  local output=""
  local count=1
  for database in $databases; do
    backup_database
    local count=$((count+1))
  done
  echo -ne $output | column -t
}

# RUN SCRIPT
main(){
  delete_old_backups
  backup_databases
}

