#!/bin/bash
# vim:set et ts=4 sw=4:

# 切换到当前目录
current_dir=`dirname $0`
current_dir=`readlink -f $current_dir`
cd ${current_dir} && export current_dir


Mongodump="/usr/bin/mongodump"
date_time=$(date "+%Y%m%d-%H:%M")
bak_dir='/home/nucleus-h7/global/mongodb/backup'



# gs backup 27017
$Mongodump --archive=$bak_dir/${date_time}-unmove.gz --gzip -u root -p YXTxsaj22WSJ7wTG  --authenticationDatabase admin -d unmovelog  &>$bak_dir/${date_time}-bak.log \
&& $Mongodump --archive=$bak_dir/${date_time}-game.gz --gzip -u root -p YXTxsaj22WSJ7wTG  --authenticationDatabase admin -d game &>>$bak_dir/${date_time}-bak.log
# gs restore 27017 
# gzip -d archivefile
# mongorestore --archive=${date_time} --username root --password YXTxsaj22WSJ7wTG -d xxx
# zcat $bak_dir/${date_time}.gz | mongorestore  --username root --password YXTxsaj22WSJ7wTG -d xxx

ret=$?

if [ $ret -eq 0 ] ;then
    echo '{ "Action": "Mongo Backup Success", "RetCode": 0 }'
    exit 0
else
    echo '{ "Action": "Mongo Backup Failed", "RetCode": 1 }'
    exit 1
fi

