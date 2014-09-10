#!/bin/sh

TIME=`date "+%G-%m-%d %H:%M:%S"`
echo "Hiseq(D177)----start at $TIME" >>/root/log/rsync_log.txt

/bin/sh /root/RSYNC_2500/rsync.sh 
/root/RSYNC_2500/rsync.pl -input1 /root/RSYNC_2500/old_hiseq_2500.list   -input2 /root/RSYNC_2500/new_hiseq_2500.list
sleep 10
/bin/mv /root/RSYNC_2500/new_hiseq_2500.list /root/RSYNC_2500/old_hiseq_2500.list

echo_PATH=`ls /data/TJ_D177/dir_A`
CP_PATH=`perl /root/reach_dir.pl /data/TJ_D177/$echo_PATH`
CREAT_PATH="/data/TJ_D177/dir_A/$echo_PATH"

if [ -e "$CREAT_PATH/ok" ] ; then

/usr/bin/rsync -av   -e ssh $CP_PATH  bgi_solexa@192.168.6.4:/WORK/home/bgi_solexa/hiseq-2500/hiseq-D177 >>/root/log/rsync_log.txt

else

echo "no Hiseq_2500 data create\n"
fi

TIME2=`date "+%G-%m-%d %H:%M:%S"`
echo "---------------------\n" >>/root/log/rsync_log.txt
echo "Hiseq(D177)----finished at $TIME2 " >>/root/log/rsync_log.txt
