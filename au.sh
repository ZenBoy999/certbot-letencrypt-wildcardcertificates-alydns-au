#!/bin/bash
# 原作者声明： ywdblog@gmail.com 欢迎关注我的书《深入浅出HTTPS：从原理到实战》
# Last Modified by Albert Xu. axu@yj777.cn -上海甬洁网络科技 tech.yj777.cn
# ##################################################
# dns.cfg file format
# key=xxx  
# secret=xxxx

CWD=`dirname $0`
CFG=$CWD/dns.cfg

[ ! -f "$CFG" ] && echo "Please write your DNS provider's AccessKey and Secret into $CFG file" && exit 0
key=`awk -F"=" '/^key/ {print $2}' $CFG`
secret=`awk -F"=" '/^secret/ {print $2}' $CFG`
[ -z "$key" -o -z "$secret" ] && echo "No DNS Access Key and Secret found!" && exit 1

# 命令行参数
# 第一个参数：使用的语言 php|python
# 第二个参数：使用的 DNS 云厂商 aly|txy|godaddy
# 第三个参数：添加或者清除 add|clean
plang=$1 #python or php 
pdns=$2 #aly or txy
paction=$3 #add or clean
[ -z "$plang" -o -z "$pdns" -o -z "$paction" ] && echo "Syntax: $0 python|php aly|txy add|clean" && exit 0

cmd=`/usr/bin/which ${plang}`
[ -z "${cmd}" ] && echo "${cmd} not found! Auto update certificate failed." && exit 1
dnsapi=${pdns}dns.${plang}
[ ! -f "$CWD/${dnsapi}" ] && echo "$CWD/${dnsapi} not found! Auto update certificate failed." && exit 1
[ $pdns == "godaddy" -a $plang == "python" ] && echo "目前不支持 python 版本的 Godaddy DNS处理" && exit 1

# 添加日志
echo "`date` $cmd $dnsapi $paction $CERTBOT_DOMAIN "_acme-challenge" $CERTBOT_VALIDATION key_xxx secret_xxx" >> $CWD/certbot.log
$cmd $dnsapi $paction $CERTBOT_DOMAIN "_acme-challenge" $CERTBOT_VALIDATION $key $secret >> $CWD/certbot.log

if [[ "$paction" == "add" ]]; then
        # DNS TXT 记录刷新时间
        /bin/sleep 20
fi
