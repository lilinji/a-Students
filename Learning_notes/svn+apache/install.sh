#��װapr
tar jxvf apr-1.5.1.tar.bz2  && cd apr-1.5.1

sed -i '/$RM "$cfgfile"/ s/^/#/' configure

./configure --prefix=/usr/local/apr

 make && make install

#��װapr-util
tar jxvf apr-util-1.5.3.tar.bz2 && cd  apr-util-1.5.3

./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config

make && make install

#��װpcre
tar jxvf pcre-8.35.tar.bz2 && cd pcre-8.35

 ./configure --prefix=/usr/local/pcre
 
 make && make install

#����openssl
tar zxvf openssl-1.0.1i.tar.gz
cd openssl-1.0.1i

./config shared zlib
make && make install

mv /usr/bin/openssl /usr/bin/openssl.OFF
mv /usr/include/openssl /usr/include/openssl.OFF
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl

#��װapache

tar jxvf httpd-2.4.7.tar.bz2 && cd httpd-2.4.7
 ./configure --prefix=/usr/local/apache2 --sysconfdir=/etc/httpd --with-apr=/usr/local/apr/bin/apr-1-config --with-apr-util=/usr/local/apr-util/bin/apu-1-config  --with-pcre=/usr/local/pcre/ --enable-so --enable-mods-shared=most --enable-rewirte  --enable-ssl=shared --with-ssl=/usr/local/ssl
 
 make && make install


#��װsqlite
tar zxvf sqlite-autoconf-3080600.tar.gz  && cd   sqlite-autoconf-3080600

./configure --prefix=/usr/local/sqlite

make && make install

#��װsvn
tar  jxvf subversion-1.8.10.tar.bz2 && cd  subversion-1.8.10

./configure --prefix=/usr/local/subversion --with-apxs=/usr/local/apache2/bin/apxs --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/ --with-sqlite=/usr/local/sqlite/

make && make install

make install-tools  #�ڰ�װĿ¼������svn-toolsĿ¼�������һЩ��չ���ߣ�����svnauthz-validate

#Ϊapache���ģ��
cd $prefix
cp   libexec/mod_authz_svn.so  /usr/local/apache2/modules/
cp   libexec/mod_dav_svn.so  /usr/local/apache2/modules/

#��httpd.conf��ӣ�
LoadModule dav_module modules/mod_dav.so
LoadModule dav_svn_module modules/mod_dav_svn.so
LoadModule authz_svn_module modules/mod_authz_svn.so

#ȥ��Include /etc/httpd/extra/httpd-vhosts.conf��ǰע��ʹ֮��Ч

#��httpd-vhosts.conf�������������
<VirtualHost *:80>
    ServerName svn.happigo.com
    <Location /svn>                         #�����/svnҪ������AliasĿ¼����
        DAV svn
        SVNParentPath /data/svn      #svn�汾���Ŀ¼,��Ŀ¼���ж���汾��ʹ��SVNParentPath,�����汾���ʹ��SVNPath
        AuthType Basic
        AuthName "Subversion repository"    #��֤ҳ����ʾ��Ϣ
        AuthUserFile /data/svn/passwd          #�û�������
        Require valid-user                              # ֻ����ͨ����֤���û�����
        AuthzSVNAccessFile /data/svn/authz  #�汾��Ȩ�޿���
    </Location>
</VirtualHost>
# ����passwd��authz�ļ�

# ������֤�ļ�

# �û��������ļ���
/usr/local/apache2/bin/htpasswd -c  /data/svn/passwd  user1  #�״�����û���������û�ʹ��-m��������

# �汾��Ȩ����֤�ļ�

vi  /data/svn/authz  #����svn�汾���µ�authz�ļ���ʽ�༭Ȩ�޼���

#  �����汾��

/usr/local/subversion/bin/svnadmin  create /data/svn/happigo

# ����
http://svn.happigo.com/svn/happigo


# ����apache  https

# ������Ҫ��װ��openssl,�ϱߵĲ������Ѿ���װ��

# apacheҪ����sslģ����߰�װapache��ʱ���Ѿ�ʹ��enable-ssl��̬������ssl

#httpd.conf��ȥ�������е�ע�ͣ�ʹ֮��Ч
LoadModule ssl_module modules/mod_ssl.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
Include /etc/httpd/extra/httpd-ssl.conf

#�༭httpd-ssl.conf�ļ�

<VirtualHost _default_:443>
ServerName svn.happigo.com:443
<Location /svn>
        DAV svn
        SVNParentPath /data/svn
        AuthType Basic
        AuthName "Subversion repository"
        AuthUserFile /data/svn/passwd
        Require valid-user
        AuthzSVNAccessFile /data/svn/authz
</Location>
SSLEngine on
SSLCertificateFile "/etc/httpd/server.crt"     
SSLCertificateKeyFile "/etc/httpd/server.key"
</VirtualHost >

# ����ssl֤��
openssl genrsa  -des3 -out  server.key 1024 #des3 ��˽Կ������룬������ȫ��

openssl req -new   -key server.key  -out server.csr # ��˽Կƥ��Ĺ�Կ�����ӽ�����ù�Կ������ͻ���

openssl req -x509 -days 365 -signkey server.key -in server.csr  -out  server.crt #����Կǩ��������֤��

cp server.key server.key.with_pass

openssl rsa -in server.key.with_pass -out server.key # ����һ���������˽Կ��ר�Ÿ�apache��nginxʹ�õģ���Ϊ���������Ҫʹ��˽Կ�Կͻ���ʹ�õĹ�Կ������֤��ƥ���������

#�����ɵ������ļ��ŵ�/et/httpdĿ¼�£�/etc/httpdĿ¼����һ��httpd-ssl.conf��ָ���ģ�

# ����apache����

#����

https://svn.happigo.com/svn/happigo

#ע��������ģʽ�£�svn���񲢲�������ͨ��http��https������svn������svn�ύ���ݵ�ʱ��Ҫ��֤��������apache���û���svn�汾��Ŀ¼�ж�дȨ�ޣ���Ȼ��������db/txn-current-lock': Permission denied�� �Ĵ���
