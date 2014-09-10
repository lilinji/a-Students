#!/bin/sh


TIME=`date "+%G-%m-%d %H:%M:%S"`
echo   "\n" >>/root/log/rsync_log.txt
echo "Proton(172.25.19.10)----start at $TIME" >>/root/log/rsync_log.txt

/usr/bin/rsync -av --exclude "*/block_X*"  --exclude "*/*/block_X*" --exclude "*_tn_*"  --exclude "*/sigproc_results*"   -e ssh /results/analysis/output/Home/  bgi_solexa@192.168.6.4:/WORK/home/bgi_solexa/Proton_rsync/proton1 >>/root/log/rsync_log.txt

TIME2=`date "+%G-%m-%d %H:%M:%S"`
echo "---------------------\n" >>/root/log/rsync_log.txt
echo "Proton(172.25.19.10)----finished at $TIME2 " >>/root/log/rsync_log.txt
