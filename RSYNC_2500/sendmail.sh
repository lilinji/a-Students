#!/bin/sh
/usr/bin/sendEmail  -f P_tj_hpc@genomics.cn -t lilinji@genomics.cn -t liuhaisheng@genomics.cn -cc yangmeng@genomics.cn  -s mail.genomics.cn  -u "Hiseq2500-D177-Report" -xu P_tj_hpc -xp LLJllj123 -o message-file=/root/RSYNC_2500/body.txt  -a /root/log/rsync_log.txt -a /root/log/rsync_log2.txt
sleep  3
/root/RSYNC_2500/rsync_tmbackup.sh  /root/log/  /data/back_log >/dev/null 2>&1
sleep  3
/bin/rm -rf /root/log/rsync_log.txt
/bin/rm -rf /root/log/rsync_log2.txt
