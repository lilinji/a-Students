http://sourceforge.net/projects/ntop/files/ntop/Stable/

http://sourceforge.net/projects/ntop/files/ntop/Stable/ntop-5.0.1.tar.gz/download

#���Ȱ�װGeoIP GeoIP-devel��Ĭ�ϵ�yumԴ��û���������������epel  yumԴ
wget http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6-8.noarch.rpm

yum install ntop
#����ntop����Ա������
ntop -A

#���һ����ͨ�û�������ntop
useradd -M -s /sbin/nologin -r ntop
#����ntop
ntop -i eth0 -d -L -u ntop
#�鿴ntop��Ч��
http://ip:3000


#���밲װ

yum install -y libtool automake autoconf svn gdbm-devel zlib-devel rrdtool-devel libpcap-devel openssl-devel

python�汾����2.6

#��װGeoIP
rpm -ivh ftp://rpmfind.net/linux/epel/6/i386/GeoIP-1.4.8-1.el6.i686.rpm
rpm -ivh ftp://rpmfind.net/linux/epel/6/i386/GeoIP-devel-1.4.8-1.el6.i686.rpm

tar zxvf ntop-5.0.1.tar.gz && cd ntop-5.0.1

./autogen.sh --with-tcpwrap --prefix=/usr/local/ntop

make && make install

#����ntop����

useradd -s /sbin/nologin ntop #����ntop�û�
chown -R ntop:ntop /usr/local/ntop/share/ntop 
cp /tmp/ntop-5.0.1/packages/RedHat/ntop.conf.sample /etc/ntop.conf
mkdir -p /var/log/ntop
chown -R ntop:root /var/log/ntop
ln -s /usr/local/ntop/bin/ntop /usr/bin/

#�޸�ntop����Ա����
ntop -A

#����

ntop -d -L -u ntop --access-log-file /var/log/ntop/access.log -i eth0

#��������

-------��������-----
1.��ǰ������tcpwrap���ܣ�����ʹ��hosts.allow��hosts.deny��������Щ�������Է���ntop

        echo 'ntop:192.168.0.*' >> /etc/hosts.allow  //��������192.168.0.* ������η���NTOP����
        echo 'ntop:ALL' >> /etc/hosts.deny	     //�ܾ�������������ntop 

2.����������--������Ҫ�޸��������Ȼ����ӵ� /etc/rc.loacl�ļ���

ntop -d -L -u ntop -P /var/lib/ntop --access-log-file /var/log/ntop/access.log -i eth0,eth1 -M -p /etc/ntop/protocol.list -O /var/log/ntop -n 0 & > /dev/null 2>&1
