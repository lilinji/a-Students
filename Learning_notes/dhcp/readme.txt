wget ftp://ftp.isc.org/isc/dhcp/4.2.4rc2/dhcp-4.2.4rc2.tar.gz

tar zxvf dhcp-4.2.4rc2.tar.gz

cd dhcp-4.2.4rc2

./configure && make && make install

#ȷ�Ϲ㲥·�ɣ�Ҫ��ͨ��eth0�㲥DHCP������Ϣ�����뽫eth0����㲥·�ɱ����� 

route add -host 255.255.255.255 dev eth0

#���������ļ�

touch /etc/dhcpd.conf

ddns-update-style none;

ignore client-updates;
subnet 192.168.127.0 netmask 255.255.255.0 {
        option routers 192.168.127.2;
        option subnet-mask 255.255.255.0;
        option domain-name "ipw.com";
        option domain-name-servers 192.168.127.2;
        range 192.168.127.139 192.168.127.150;
        default-lease-time 21600;
        max-lease-time 43200;
	#�̶�ip����
        #host ipw2 {
        #       hardware ethernet 00:0C:29:8F:81:FB;
        #       fixed-address 192.168.127.130;
        #}
}

#����dhcpdhcp���ڵļ�¼�ļ����Ѿ�����Ŀͻ��˻��¼������

touch /var/db/dhcpd.leases

/usr/local/sbin/dhcpd  #��������