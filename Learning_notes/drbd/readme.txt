  �����������VMWare9�µ�CentOS 6.3��װ���� Mysql+heartbeat+drbd+LVS 
��һ�ΰ�װ����дһд�ĵ���᣺
 
CentOS 6.3 ��װ����DRBD+Heartbeat

 
1. ����򵥽���һ��heartbeat��drbd�������������down������ɵ���ʧ�ǲ��ɹ����ġ�Ҫ��֤������������Ϸ��񣬾���Ҫ�Է�����ʵ�����ࡣ���ڶ��ʵ�ַ���������Ľ�������У�heartbeatΪ�����ṩ�����۵ġ��������ĸ߿��ü�Ⱥ����������ͨ��heartbeat+drbd��Linux�´���һ���߿���(HA)�ļ�Ⱥ��������
2. DRBD��һ�ֿ��豸�����Ա����ڸ߿���(HA)֮�С���������һ������RAID-1���ܡ����㽫����д�뱾���ļ�ϵͳʱ�����ݻ����ᱻ���͵���������һ̨�����ϡ�����ͬ����ʽ��¼��һ���ļ�ϵͳ�С�����(���ڵ�)��Զ������(���ڵ�)�����ݿ��Ա�֤ʵʱͬ����������ϵͳ���ֹ���ʱ��Զ�������ϻ��ᱣ����һ����ͬ�����ݣ����Լ���ʹ�á��ڸ߿���(HA)��ʹ��DRBD���ܣ����Դ���ʹ��һ�������������Ϊ����ͬʱ�����ڱ���������Զ�������ϡ��л�ʱ��Զ������ֻҪʹ����������Ƿݱ������ݣ��Ϳ��Լ������з����ˡ�
 
 
 
3. ��������̨�����������2��Ӳ�̣�ģ��raw device��ֻ������Ҫ��ʽ��
�鿴Ӳ��: fdisk &ndash;l 
Disk /dev/sdb: 2147 MB, 2147483648 bytes
255 heads, 63 sectors/track, 261 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000
��/dev/sdb���з���: fdisk /dev/sdb
����: n----p----1----1---261-----w
�ٴβ鿴Ӳ��: fdisk &ndash;l
  Device Boot      Start        End      Blocks  Id  System
/dev/sdb1              1        261    2096451  83  Linux
 
 
4. ����CentOS6.3��iso��û��drbd��rpm�����û������ϵ���Դ���ذ�װelrep,����ֱ��yum install drbd
wget http://elrepo.org/elrepo-release-6-4.el6.elrepo.noarch.rpm
rpm -ivUh elrepo-release-6-4.el6.elrepo.noarch.rpm
vi /etc/yum.repos.d/elrepo.repo  #�ѵ�8�иĳ�enabled=0
��װkmod-drdb���ܻ�����kernel�汾��֧�ֵ�����,������Ҫ������kernel����163��YUMԴ����kernel����
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
mv CentOS6-Base-163.repo / /etc/yum.repos.d
yum --enablerepo=updates install kernel
kernel���º��Ժ�Ϳ���ʹ��yum��װdrbd
yum --enablerepo=elrepo install drbd83-utils kmod-drbd83
��װ��ɺ����ں˼���drbd
modprobe drbd
ʹ��modprobe -l |grep drbd  �� lsmod |grep drbd�鿴�Ƿ���سɹ�
[root@web1 ~]# modprobe -l |grep drbd
extra/drbd83/drbd.ko
[root@web1 ~]# lsmod |grep drbd
drbd                  318209  0
5. 2̨�������޸����������趨hosts�ļ�drbd��heartbeat��Ҫ��������������ͨ��
vi /etc/hosts
192.168.135.128 web1
192.168.159.129 web2
6. �޸�drbd�����ļ�
vi /etc/drbd.conf
global {
  usage-count yes;
}
common {
  protocol C;            #���嵱���ݱ�д����豸ʱ���һ���Լ�������ͬ��Э�飩��A��B��C��������CΪ���ݱ�ȷ��д�����ش��̺�Զ�̴��̺󷵻أ�ȷ�ϳɹ�
  syncer { rate 100M;}    #���������ڵ���ͬ������
}
resource r0 {
  on test1 {              #�ڵ�����һ��Ҫ��hostname����һ��
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
 
7. ��һ�����ò���ʼ��resource
����resource metadata ����Ҫ��2̨server��ִ�У�
drbdadm create-md r0
 
��iptables�￪��TCP 7789�˿��������������dbrd������Ҫ��2̨server��ִ�У�
/etc/init.d/drbd start 
 
�۲�drbd״̬
[root@web1 ~]# cat /proc/drbd         
version: 8.3.13 (api:88/proto:86-96)
GIT-hash: 83ca112086600faacab2f157bc5a9324f7bd7f77 build by dag@Build32R6, 2012-09-04 12:05:34
 1: cs:Connected ro:Secondary/Secondary ds:Inconsistent/Inconsistent C r-----
    ns:0 nr:0 dw:0 dr:0 al:0 bm:0 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:2096348
"/proc/drbd"����ʾ��drbd��ǰ��״̬.��һ�е�ro��ʾ��̨������״̬,����"����"״̬.
ds�Ǵ���״̬,����"��һ��"״̬.��������,DRBD�޷��ж���һ��Ϊ����,����һ���Ĵ���������Ϊ��׼����.����,������Ҫ��ʼ��
8. ��test1����Ϊprimary����ʼ��
��ʼ��primary
drbdsetup /dev/drbd1 primary -o
 
�۲�drbd״̬������ͬ��drbd
[root@web1 ~]# watch -n1 'cat /proc/drbd'
1: cs:SyncSource ro:Primary/Secondary ds:UpToDate/Inconsistent C r-----
    ns:1320832 nr:0 dw:0 dr:1329688 al:0 bm:80 lo:1 pe:3 ua:64 ap:0 ep:1 wo:b oos:775772
        [===========>........] sync'ed: 63.1% (775772/2096348)K
        finish: 0:00:10 speed: 73,364 (73,364) K/sec
��ɳ�ʼ��,�鿴primary״̬
[root@web1 ~]# cat /proc/drbd
1: cs:Connected ro:Primary/Secondary ds:UpToDate/UpToDate C r-----
ns:2096348 nr:0 dw:0 dr:2097012 al:0 bm:128 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0
��ɳ�ʼ��,�鿴secondary״̬
[root@web2 ~]# cat /proc/drbd
1: cs:Connected ro:Secondary/Primary ds:UpToDate/UpToDate C r-----
    ns:0 nr:2096348 dw:2096348 dr:0 al:0 bm:128 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0
9. ���ڿ��԰�Primary�ϵ�DRBD�豸���ص�һ��Ŀ¼�Ͻ���ʹ��.������DRBD�豸�޷�������,��Ϊ�������������������ݵ�,��DRBD�������.
��ʽ����EXT3
mkfs.ext3 /dev/drbd1
���ص�ϵͳ�ϾͿ���ʹ����
mkdir /drbd
mount /dev/drbd1 /drbd
 
10. drbd�����л����ԣ��鿴����ͬ��
��/drbdĿ¼д��һ�������ļ�
dd if=/dev/zero of=drbdtest bs=4k count=10240
��ԭ����primary��ж��drbd��������Ϊsecondary
umount /drbd
drbdadm secondary r0
��ԭ����secondary����Ϊprimary,������drbd
drbdadm primary r0
mount /dev/drbd1 /drbd
�鿴�ղŵ��ļ��Ƿ���ڣ�˵��ͬ���ɹ�
[root@web2 drbd]# ll -h /drbd/drbdtest
-rw-r--r--. 1 root root 40M Nov  7 14:55 /drbd/drbdtest
֮�� ��ʼ�� �����ļ�ϵͳ ��
[root@web2 drbd]# umount  /drbd 
[root@web2 drbd]# drbdadm secondary r0 
 
�����ڵ� ����
 
[root@web1 drbd]# drbdadm primary r0
[root@web1 drbd]# mount /dev/drbd1 /drbd
 
����  DRDB ���� �ڱ���ɡ�