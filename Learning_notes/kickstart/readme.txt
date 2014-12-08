kickstart������

#��װhttp/vsftp/nfs(pxe֧������������һ�ַ�ʽ��ȡ��װ�ļ�)

#��װdhcp

ddns-update-style none;

ignore client-updates;
subnet 192.168.127.0 netmask 255.255.255.0 {
        option routers 192.168.127.2;
        option subnet-mask 255.255.255.0;
        option domain-name "ipw.com";
        option domain-name-servers 192.168.127.2;
        range 192.168.127.139 192.168.127.150;
        filename "pxelinux.0"    #������Ҫ�ģ�pxe client����dhcp����������ip��ַ������dhcp�������ϵ�tftp������������pxelinux.0(bootloader)ȡ�ر���ִ�С�
	default-lease-time 21600;
        max-lease-time 43200;
	#�̶�ip����
        #host ipw2 {
        #       hardware ethernet 00:0C:29:8F:81:FB;
        #       fixed-address 192.168.127.130;
        #}
}

#��װtftp

yum install tftp-server

vi /etc/xinetd.d/tftp

# default: off
# description: The tftp server serves files using the trivial file transfer \
#       protocol.  The tftp protocol is often used to boot diskless \
#       workstations, download configuration files to network-aware printers, \
#       and to start the installation process for some operating systems.
service tftp
{
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /var/lib/tftpboot
        disable                 = no  #�����Ϊno,��tftp��xinetd����
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}

#����xinetd

/etc/init.d/xinetd start

#����ISO����

mount -o loop /path/xxx.iso  /data/www/centos #�����õ���http��ʽ

#���Ʊ�Ҫ�ļ���tftpboot

cp /usr/share/syslinux/pxelinux.0  /var/lib/tftpboot  #����pxe��ʽ��bootloader,��Ҫ��װsyslinux(yum install syslinux)

cp /data/www/centos/images/pxeboot/initrd.img /var/lib/tftpboot 

cp /data/www/centos/images/pxeboot/vmlinuz /var/lib/tftpboot

# ����bootloader,Ҳ����pxelinux.0����Ҫ�Ĳ����ļ���û�в����ļ�����װֻ��ͣ����boot>����

mkdir /var/lib/tftpboot/pxelinux.cfg

cp /data/www/centos/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default  #bootloaderҪ���ļ��ز���ϵͳ�ں���������װ������������ļ���ָ���ġ�

#derault������

default text
prompt 1
timeout 600

display boot.msg

menu background splash.jpg
menu title Welcome to CentOS 6.4!
menu color border 0 #ffffffff #00000000
menu color sel 7 #ffffffff #ff000000
menu color title 0 #ffffffff #00000000
menu color tabmsg 0 #ffffffff #00000000
menu color unsel 0 #ffffffff #00000000
menu color hotsel 0 #ff000000 #ffffffff
menu color hotkey 7 #ffffffff #ff000000
menu color scrollbar 0 #ffffffff #00000000

label text
kernel vmlinuz
append ks=http://192.168.127.129/ks.cfg initrd=initrd.img #���������bootloaderҪ���ص��ں��ļ���������װ��Ȼ����߿ͻ���ks.cfg�����ks.cfg����߰�װ������Ѱ�Ұ�װ�ļ����Լ���Ҫ��װ��Щ�׼��������ڰ�װ��ɺ���Ҫִ����Щ������


����pxe��װ�������������ģ�

�ͻ�����������pxe��������ip��ַ�����䵽ip��ַ������tftp�ӷ���˻�ȡbootloader,����bootloader�ͽ����˰�װ���棬����Ҫ���ص��ں��ļ����ģ�pxelinux.0�Ĳ����ļ�Ҳ����default�������������ص����ں��ļ��Ϳ���������װ�ˣ���������Ҫ�İ�װ�ļ����ģ�����default�ļ���ָ����ks=xxxx/ks.cfg,ks.cfg�����þ��Ǹ��߰�װ��������ȥѰ�Ұ�װ�ļ���������Ҫ��װ��Щ�׼��Լ���װ�����������Ĳ����������������ʽ������װ���ԡ�ʱ��ѡ��ȵȡ�



�������μ��ص��ļ��� pxelinux.0  --> default --->ks.cfg
#kickstartѡ��˵��
http://man.ddvip.com/os/redhat9.0cut/s1-kickstart2-options.html

