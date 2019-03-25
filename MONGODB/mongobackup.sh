#!/bin/bash
mkdir -pv /home/backup
echo '#!/bin/bash
# Enviroment
export PATH=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/bin:$PATH

# Configure The Directory of Backup
BACKUPDIR=/home/backup
SAVE=2

# define
MONGODIR=$BACKUPDIR/mongodb
MTMPDIR=$BACKUPDIR/mongodb/mongotmp
DATETIME=`date -d now +%Y-%m-%d_%H-%M`

# Create Directory
if [ ! -d $MONGODIR ]; then
  mkdir -p $MONGODIR
fi
rm -rf $MTMPDIR
mkdir -p $MTMPDIR

# ----- Backup Mongodb -----
echo $DBLIST
DBLIST=" admin local zabbix "

# Backup with Database
for mdbname in $DBLIST
do
    mongodump -h 127.0.0.1:27017 -d $mdbname -o $MTMPDIR
done

# create Mongodb tar
cd $MONGODIR
tar -zcvf $MONGODIR/mongodb_backup.$DATETIME.tar.gz ./mongotmp
rm -rf $MTMPDIR
[ -d $MONGODIR ] && find $MONGODIR -type f -mtime +$SAVE -delete
' > /home/backup/mongodb/mongobackup.sh
chmod 744 /home/backup/mongobackup.sh

echo '30 1 * * * root /home/backup/mongobackup.sh >/dev/null 2>&1' >> /etc/crontab  
