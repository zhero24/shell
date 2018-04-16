#!/bin/bash
#介绍：禁止弱口令登陆
#作者qq：1969679546
#版本：1.0
#发布时间：2017/11/1

cat /var/log/secure|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{print $2"="$1;}' > black.txt #尝试登录的次数和ip

DEFINE="5"  #单个ip尝试登录最大值

for i in `cat /root/black.txt`
do

    IP=`echo $i |awk -F= '{print $1}'`
    NUM=`echo $i|awk -F= '{print $2}'`

    if [ $NUM -gt $DEFINE ]; then
        grep $IP /etc/hosts.deny > /dev/null

        if [ $? -gt 0 ]; then
            echo "sshd:$IP" >> /etc/hosts.deny  #扔到hosts文件中
        fi
    fi
done
