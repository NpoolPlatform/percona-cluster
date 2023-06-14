# percona-mysql-cluster
## MySQL 监控
- mysql pod内部署pmm agent，采集监控数据
- 具体内容参考mysql-cluster仓库

## MySQL备份
- pmm网页添加备份location（s3）
- 备份计划选择mysql-0进行备份
- 备份时间选择按月备份
- 目前只支持mysql完整备份

## MySQL备份恢复
- 选用ubuntu2004服务器进行临时数据恢复
- 禁用apparmor并重启
  
```
systemctl stop apparmor
systemctl disable apparmor
init 6
```

- 安装 MySQL 5.7 版本客户端和服务端

```
vim /etc/apt/sources.list.d/mysql.list
deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-apt-config
deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-5.7
deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-tools
deb-src http://repo.mysql.com/apt/ubuntu/ bionic mysql-5.7

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29
apt-get install debian-archive-keyring debian-keyring
apt --fix-broken install -y
apt-get update

apt install mysql-server=5.7.42-1ubuntu18.04
apt install mysql-client=5.7.42-1ubuntu18.04
apt install mysql-community-server=5.7.42-1ubuntu18.04
```

- 安装percona-xtrabackup

```
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
percona-release enable-only tools release
apt-get update
apt install percona-xtrabackup-24 -y
apt install qpress -y
```
- 从s3下载备份文件，准备backup目录

```
mkdir /backup/
cd /backup/
apt install lrzsz -y
apt install unzip -y
unzip mysql-0-ps_2023-06-07T09_55_59Z.zip
mv mysql-0-ps_2023-06-07T09:55:59Z mysql-0-backup

# 创建新数据目录
mkdir mysql-new-data

# 解包：
cat mysql-0-backup/*.qp.* | xbstream -x -v -C mysql-new-data
cat mysql-0-backup/*/*.qp.* | xbstream -x -v -C mysql-new-data

# 解压：
innobackupex --decompress --remove-original mysql-new-data
ls mysql-new-data/

# 为数据目录授权
chown -R mysql.mysql mysql-new-data

# 停止mysql
service mysql stop
```

- 切换mysql运行目录，启动mysql

```
vim /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
# datadir		= /var/lib/mysql
datadir		= /backup/mysql-new-data

service mysql start
```

- 检查数据
