  最近尝试了在VMWare9下的CentOS 6.3安装测试 Mysql+heartbeat+drbd+LVS 
第一次安装配置写一写心得体会：
 
CentOS 6.3 安装配置DRBD+Heartbeat

 
1. 这里简单介绍一下heartbeat和drbd。如果主服务器down机，造成的损失是不可估量的。要保证主服务器不间断服务，就需要对服务器实现冗余。在众多的实现服务器冗余的解决方案中，heartbeat为我们提供了廉价的、可伸缩的高可用集群方案。我们通过heartbeat+drbd在Linux下创建一个高可用(HA)的集群服务器。
2. DRBD是一种块设备，可以被用于高可用(HA)之中。它类似于一个网络RAID-1功能。当你将数据写入本地文件系统时，数据还将会被发送到网络中另一台主机上。以相同的形式记录在一个文件系统中。本地(主节点)与远程主机(备节点)的数据可以保证实时同步。当本地系统出现故障时，远程主机上还会保留有一份相同的数据，可以继续使用。在高可用(HA)中使用DRBD功能，可以代替使用一个共享磁盘阵。因为数据同时存在于本地主机和远程主机上。切换时，远程主机只要使用它上面的那份备份数据，就可以继续进行服务了。
 
 
 
3. 在主备两台虚拟机里新增2块硬盘，模拟raw device，只分区不要格式化
查看硬盘: fdisk &ndash;l 
Disk /dev/sdb: 2147 MB, 2147483648 bytes
255 heads, 63 sectors/track, 261 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000
对/dev/sdb进行分区: fdisk /dev/sdb
步骤: n----p----1----1---261-----w
再次查看硬盘: fdisk &ndash;l
  Device Boot      Start        End      Blocks  Id  System
/dev/sdb1              1        261    2096451  83  Linux
 
 
4. 由于CentOS6.3的iso并没有drbd的rpm包采用互联网上的资源下载安装elrep,可以直接yum install drbd
wget http://elrepo.org/elrepo-release-6-4.el6.elrepo.noarch.rpm
rpm -ivUh elrepo-release-6-4.el6.elrepo.noarch.rpm
vi /etc/yum.repos.d/elrepo.repo  #把第8行改成enabled=0
安装kmod-drdb可能会遇到kernel版本不支持的问题,如有需要先升级kernel下载163的YUM源进行kernel升级
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
mv CentOS6-Base-163.repo / /etc/yum.repos.d
yum --enablerepo=updates install kernel
kernel更新好以后就可以使用yum安装drbd
yum --enablerepo=elrepo install drbd83-utils kmod-drbd83
安装完成后让内核加载drbd
modprobe drbd
使用modprobe -l |grep drbd  和 lsmod |grep drbd查看是否加载成功
[root@web1 ~]# modprobe -l |grep drbd
extra/drbd83/drbd.ko
[root@web1 ~]# lsmod |grep drbd
drbd                  318209  0
5. 2台机器都修改主机名并设定hosts文件drbd和heartbeat都要依赖于主机名来通信
vi /etc/hosts
192.168.135.128 web1
192.168.159.129 web2
6. 修改drbd配置文件
vi /etc/drbd.conf
global {
  usage-count yes;
}
common {
  protocol C;            #定义当数据被写入块设备时候的一致性级别（数据同步协议），A、B、C三个级别，C为数据被确认写到本地磁盘和远程磁盘后返回，确认成功
  syncer { rate 100M;}    #设置两个节点间的同步速率
}
resource r0 {
  on test1 {              #节点名称一定要与hostname保持一致
    device    /dev/drbd1;
    disk      /dev/sdb1;
    address  192.168.135.28:7789;
    meta-disk internal;
  }
  on web2{
    device    /dev/drbd1;
    disk      /dev/sdb1;
    address  192.168.135.29:7789;
    meta-disk internal;
  }
}
 
7. 第一次启用并初始化resource
创建resource metadata （需要在2台server上执行）
drbdadm create-md r0
 
在iptables里开启TCP 7789端口重启服务后，启动dbrd服务（需要在2台server上执行）
/etc/init.d/drbd start 
 
观察drbd状态
[root@web1 ~]# cat /proc/drbd         
version: 8.3.13 (api:88/proto:86-96)
GIT-hash: 83ca112086600faacab2f157bc5a9324f7bd7f77 build by dag@Build32R6, 2012-09-04 12:05:34
 1: cs:Connected ro:Secondary/Secondary ds:Inconsistent/Inconsistent C r-----
    ns:0 nr:0 dw:0 dr:0 al:0 bm:0 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:2096348
"/proc/drbd"中显示了drbd当前的状态.第一行的ro表示两台主机的状态,都是"备机"状态.
ds是磁盘状态,都是"不一致"状态.这是由于,DRBD无法判断哪一方为主机,以哪一方的磁盘数据作为标准数据.所以,我们需要初始化
8. 将test1设置为primary并初始化
初始化primary
drbdsetup /dev/drbd1 primary -o
 
观察drbd状态，正在同步drbd
[root@web1 ~]# watch -n1 'cat /proc/drbd'
1: cs:SyncSource ro:Primary/Secondary ds:UpToDate/Inconsistent C r-----
    ns:1320832 nr:0 dw:0 dr:1329688 al:0 bm:80 lo:1 pe:3 ua:64 ap:0 ep:1 wo:b oos:775772
        [===========>........] sync'ed: 63.1% (775772/2096348)K
        finish: 0:00:10 speed: 73,364 (73,364) K/sec
完成初始化,查看primary状态
[root@web1 ~]# cat /proc/drbd
1: cs:Connected ro:Primary/Secondary ds:UpToDate/UpToDate C r-----
ns:2096348 nr:0 dw:0 dr:2097012 al:0 bm:128 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0
完成初始化,查看secondary状态
[root@web2 ~]# cat /proc/drbd
1: cs:Connected ro:Secondary/Primary ds:UpToDate/UpToDate C r-----
    ns:0 nr:2096348 dw:2096348 dr:0 al:0 bm:128 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0
9. 现在可以把Primary上的DRBD设备挂载到一个目录上进行使用.备机的DRBD设备无法被挂载,因为它是用来接收主机数据的,由DRBD负责操作.
格式化成EXT3
mkfs.ext3 /dev/drbd1
挂载到系统上就可以使用了
mkdir /drbd
mount /dev/drbd1 /drbd
 
10. drbd主备切换测试，查看数据同步
在/drbd目录写入一个测试文件
dd if=/dev/zero of=drbdtest bs=4k count=10240
在原来的primary上卸载drbd，并设置为secondary
umount /drbd
drbdadm secondary r0
把原来的secondary设置为primary,并挂载drbd
drbdadm primary r0
mount /dev/drbd1 /drbd
查看刚才的文件是否存在，说明同步成功
[root@web2 drbd]# ll -h /drbd/drbdtest
-rw-r--r--. 1 root root 40M Nov  7 14:55 /drbd/drbdtest
之后 初始化 现在文件系统 。
[root@web2 drbd]# umount  /drbd 
[root@web2 drbd]# drbdadm secondary r0 
 
在主节点 运行
 
[root@web1 drbd]# drbdadm primary r0
[root@web1 drbd]# mount /dev/drbd1 /drbd
 
至此  DRDB 部署 节本完成。