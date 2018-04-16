#!/bin/bash
#介绍：输出系统信息
#作者qq：1969679546
#版本：1.0
#发布时间：2017/10/25

ipp=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v  "^127" | head -n 1`
cpuu=`awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//'`
cppu=`awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//'`
hexin=`awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo`
cun_one=`free -m | awk '/Mem/ {print $2}'`
cun_two=`free -m | awk '/Mem/ {print $4}'`
yingpan_one=`df -Th | grep '/dev/' | awk '{print $3}' | head -n 1`
yingpan_two=`df -Th | grep '/dev/' | awk '{print $5}' | head -n 1`
swa_one=`free -m | awk '/Swap/ {print $2}'`
swa_two=`free -m | awk '/Swap/ {print $4}'`
timee=`awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=$1%60} {printf("%ddays, %d:%d:%d\n",a,b,c,d)}' /proc/uptime`
jiagou=`uname -m`
weishu=`getconf LONG_BIT`
hostn=`hostname`
chang=`tput lines`
kuan=`tput cols`
yuyan=`echo $LANG`


#判断是否centos或ubuntu
if cat /proc/version | grep -Eqi "ubuntu"; then
        banben=`lsb_release -a`
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        banben=`awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release`
fi


quan_ying() { #精简信息
clear
echo "-c Display Chinese"
echo
echo "system：$banben"
echo "cpu：$cpuu"
echo "cpu frequency：$cppu"
echo "cpu core number：$hexin"
echo "architecture： $jiagou"
echo "digits：$weishu"
echo "total memory：$cun_one"
echo "remaining memory：$cun_two"
echo "swap zone total：$swa_one"
echo "total remainder os wap partitions：$swa_two"
echo "total boot time：$timee"
echo "root partition capacity：$yingpan_one"
echo "root zone residual capacity：$yingpan_two"
echo "ip address：$ipp"
echo "host name：$hostn"
echo "current language：$yuyan"
echo "current operation interface border length：$chang"
echo "current operating interface border width：$kuan"
}


quan_zhong() { #全部信息
clear
echo "默认显示英文"
echo
echo "系统：$banben"
echo "cpu：$cpuu"
echo "cpu频率：$cppu"
echo "cpu核心数：$hexin"
echo "架构： $jiagou"
echo "位数：$weishu"
echo "总内存数：$cun_one"
echo "剩余内存：$cun_two"
echo "交换分区总量：$swa_one"
echo "交换分区剩余总量：$swa_two"
echo "总开机时间：$timee"
echo "根分区容量：$yingpan_one"
echo "根分区剩余容量：$yingpan_two"
echo "ip地址：$ipp"
echo "主机名：$hostn"
echo "当前语言：$yuyan"
echo "当前操作界面边框长：$chang"
echo "当前操作界面边框宽：$kuan"
}

if [ $1 == "-c" ];then
    quan_zhong
else
    quan_ying
fi
