!!!Br-srv!!!

samba-tool domain provision
В строке пароль - P@ssw0rd
samba-tool domain info 127.0.0.1
smbclient -L -u 127.0.0.1 administrator
Пароль P@ssw0rd

kinit Administrator@AU-TEAM.IRPO

Пароль: P@ssw0rd
klist

samba-tool group add hq
for i in 1 2 3 4 5; do
> samba-tool user create hquser$i 'P@ssw0rd1'
> samba-tool group addmembers hq hquser$i
> done
samba-tool group listmembers hq

!!!HQ-CLI!!!

su -
acc 
Открываем интерфейсы и сразу жмем применить чтобы ens3 активировался

mcedit /etc/net/ifaces/ens3/options

Меняем две строки
DISABLED=no
NM_CONTROLLED=no
systemctl restart network

аcc
Открываем интерфейсы и пишем 
адрес 10.10.200.2/28
шлюз 10.10.200.1
DNS 10.20.20.2

systemctl restart network
reboot
ip -c a 
Проверяем чтобы не было двух адресов на ens3


ЛУЧШЕ ПРОВЕРИТЬ ПИНГ

ping 10.20.20.2
Если пинг не идёт, надо перезапускать hq-rtr isp br-rtr до тех пор пока все не будут между собой пинговать:

Hq-rtr→isp 172.16.1.1
Br-rtr → isp 172.16.2.1
Isp →hq-rtr 172.16.1.2
Isp →br-rtr 172.16.2.2
Br-rtr →br-rtr 10.20.20.1

Если все пингует то hq-cli зайдет в домен

mcedit /etc/sudoers
Cmnd_Alias  SHELLCMD = /bin/cat, /bin/grep, /usr/bin/id
WHEEL_USERS ALL=(ALL:ALL) SHELLCMD
user ALL=(ALL:ALL) NOPASSWD: ALL

roleadd wheel hq

!!!Hq-srv!!!

chmod 777 /raid/nfs
systemctl enable —now nfs-server
mkdir /mnt/nfs
chmod -R 777 /mnt/nfs


Проверка через клиента: открываем файловую систему, ищем папку mnt, nfs и создаём любой файл.

На hq-srv: ls -l /raid/nfs 

!!!hq-srv, hq-cli!!!

mcedit /etc/chrony.conf 
#pool pool.ntp.org iburst
server 172.16.1.1 iburst
systemctl restart chronyd

!!!br-srv!!!

mcedit /etc/chrony.conf
#pool pool.ntp.org iburst
server 172.16.2.1 iburst
systemctl restart chronyd

!!!hq-rtr!!!

ntp server 172.16.1.1
security none

!!br-rtr!!!

ntp server 172.16.2.1
security none

!!!br-srv!!!

mcedit /etc/ansible/hosts

Убираем только br-cli. Остальное дописываем

строчка Hq-srv: ansible_user=sshuser ansible_password=P@ssw0rd ansible_port=2026
строчка Hq-cli: ansible_user=user ansible_password=resu 
строчка Hq-rtr: ansible_user=net_admin ansible_password=P@ssw0rd ansible_connection=network_cli ansible_network_os=ios
строчка Br-rtr: ansible_user=net_admin ansible_password=P@ssw0rd ansible_connection=network_cli ansible_network_os=ios

[all:vars]
ansible_python_interpreter=/usr/bin/python3
Проверка: ansible -m ping all

Если всё зелёненькое, то всё норм

!!!Br-srv!!!

apt-get update
apt-get install -y docker-engine docker-compose-v2
mount /home/user/Additional.iso /mnt/

cd /opt/testapp
docker compose up -d
systemctl enable --now docker

!!!ISP!!!

apt-get install -y apache2
htpasswd -c /etc/nginx/.htpasswd WEB
P@ssw0rd
systemctl enable --now nginx


!!!Hq-srv!!!

apt-get install -y lamp-server
mount /home/user/Additional.iso /mnt/
cp /mnt/web/index.php /var/www/html
cp /mnt/web/logo.png /var/www/html
mcedit /var/www/html/index.php

!!!Hq-srv!!!

mariadb
> Create user 'webc'@'localhost' identified by 'P@ssw0rd';
> Grant all privileges on webdb.* to 'webc'@'localhost' with grant option;
> Exit;
systemctl enable --now mariadb

!!!Hq-cli!!!

Открыть браузер. 
В поисковой строке вписать

http://10.10.100.2

http://web.au-team.irpo

http://docker.au-team.irpo

В терминале
apt-get install -y yandex-browser-stable
