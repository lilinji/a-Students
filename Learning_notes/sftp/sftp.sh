Ҫ��

openssh�汾����5

yum install pam pam-devel

#���openssh�汾���ͣ�����openssh

wget http://openbsd.org.ar/pub/OpenBSD/OpenSSH/portable/openssh-5.8p2.tar.gz

tar zxvf openssh-5.8p2.tar.gz && cd openssh-5.8p2 


./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-zlib --with-ssl --with-md5-passwords --mandir=/usr/share/man && make && make install


# ����sftp,��www�û�������/data/wwwĿ¼��,ע���Ŀ��Ŀ¼���ϼ�Ŀ¼��Ҳ���Ǳ����е�/dataĿ¼������������Ϊroot


vi /etc/ssh/sshd_config

# Subsystem   sftp    /usr/libexec/openssh/sftp-server

Subsystem   sftp  internal-sftp
Match User www
X11Forwarding no
ChrootDirectory /data/www
AllowTcpForwarding no
ForceCommand internal-sftp

#����Ŀ¼Ȩ��
chown root:root /data  #�ϼ�Ŀ¼������Ϊroot
chown www:www /data/www  #Ŀ��Ŀ¼����������Ϊwww����֤www�û��Դ�Ŀ¼����ȫȨ��

#����www�û�������

passwd www

#����sshd
service sshd restart












##�����Ҫ����openssl�����²���

wget  http://www.openssl.org/source/openssl-1.0.1g.tar.gz



tar zxvf openssl-1.0.1g.tar.gz
cd openssl-1.0.1g
./config shared zlib
make
make install
mv /usr/bin/openssl /usr/bin/openssl.OFF
mv /usr/include/openssl /usr/include/openssl.OFF
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl

