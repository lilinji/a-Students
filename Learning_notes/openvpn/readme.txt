###网络设置
#### 1.开启服务器端路由转发功能和tun支持
# vi /etc/sysctl.conf
net.ipv4.ip_forward = 1
sysctl -p

##tun
cat /dev/net/tun
如果返回信息为：cat: /dev/net/tun: File descriptor in bad state 说明正常
 
####2.设置nat转发:
###注：保证VPN地址池可路由出外网(两个网卡都要设置，与内网其他机器通信，与公网通信)
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth1 -j MASQUERADE

###3.设置openvpn端口通过：
iptables -A INPUT -p TCP --dport 1194 -j ACCEPT
iptables -A INPUT -p TCP --dport 7505 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#### 3.时间同步(重要)：
yum install -y ntpdate
ntpdate asia.pool.ntp.org


###deps####
yum install -y openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig make wget gcc gcc+


##download###
https://openvpn.net/index.php/open-source/downloads.html
git clone https://github.com/OpenVPN/openvpn
git clone git://openvpn.git.sourceforge.net/gitroot/openvpn/openvpn

##install####

tar zxvf openvpn-2.3.4.tar.gz && cd openvpn-2.3.4 && ./configure && make && make install

mkdir -p /etc/openvpn

###openvpn配置文件####
cp -a sample /etc/openvpn/
cp /etc/openvpn/sample/sample-config-files/server.conf /etc/openvpn/


###easy-rsa####
wget -c https://github.com/OpenVPN/easy-rsa/archive/release/2.x.zip

unzip 2.x.zip
cp -a  easy-rsa-release-2.x/easy-rsa  /etc/openvpn/
cd  /etc/openvpn/easy-rsa/2.0
vi vars
####在后面生成服务端ca证书时，这里的配置会作为缺省配置####
export KEY_COUNTRY="CN"
export KEY_PROVINCE="BJ"
export KEY_CITY="beijing"
export KEY_ORG="example"
export KEY_EMAIL="user01@example.com"

ln -s openssl-1.0.0.cnf openssl.cnf

chmod +x vars
source ./vars

####开始配置证书####

##### 1.清空原有证书：
# ./clean-all
####注：这个命令在第一次安装时可以运行，以后在添加完客户端后慎用，因为这个命令会清除所有已经生成的证书密钥，和上面的提示对应
 

###  2.生成服务器端ca证书
./build-ca
### 注：由于之前做过缺省配置，这里一路回车即可
 

####  3.生成服务器端密钥证书, 后面这个openvpn.example.com就是服务器名，也可以自定义
./build-key-server openvpn.example.com
###注：这个过程中会要求输入一个challenge password，一个An optional company name，还有两次y



######4.生成所需客户端证书密钥文件：
# ./build-key client1
# ./build-key client2
注：这里与生成服务端证书配置类似，中间一步提示输入服务端密码，其他按照缺省提示一路回车即可。

#######5.再生成diffie
#hellman参数，用于增强openvpn安全性（生成需要漫长等待）####./build-dh


###6.打包keys
tar zcvf keys.tar.gz keys/
####打包的文件发送给客户端

###配置openvpn server####
#内容见server.conf##



####创建日志目录：
mkdir -p /var/log/openvpn/

###启动###

openvpn --config /etc/openvpn/server.conf &


#################################################################################
#####################openvpn如何使用用户名密码登录###############################
#################################################################################


# 1. 进到openvpn源码目录下的src/plugins目录
cd openvpn-2.3.4/src/plugins/auth-pam/.libs
cp openvpn-plugin-auth-pam.so /usr/lib/

# 2. 修改server.conf，添加如下内容
plugin /usr/lib/openvpn-plugin-auth-pam.so login #使用linux的系统用户验证登录
client-cert-not-required #关闭证书验证，只接受用户名密码
username-as-common-name  #优先使用用户名 

# 3. 修改client.ovpn
# 注释掉以下两行，省略了客户端证书，但是仍然需要服务端证书用来加密
;cert client1.crt
;key client1.key

#添加以下内容
auth-user-pass

#以上这样配置后，客户端就可以使用server端的系统帐号来进行验证
