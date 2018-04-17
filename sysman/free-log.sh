#!/bin/bash
#双向免密登陆，一般用作hadoop，要求密码统一
#作者qq：1969679546
#版本：1.0
#发布时间：2018/3/15


#填写所有ip，空格分开
ip=(192.168.2.107 192.168.2.113 192.168.2.188)

#填写密码
passwd=123456



#检测是否有值
if [ ! $passwd ];then
    echo '$passwd not found'
    exit
fi

a=`echo ${ip[0]}`

if [ ! ${a} ];then
    echo '$ip not found'
    exit
fi

create_sha() {
mkdir -p ~/.ssh
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
}

安装sshp，如果没装则装上
sshp() {
rpm -q sshpass
if [ $? -ne 0 ];then
    yum -y install sshpass
    rpm -q sshpass
    if [ $? -eq 0 ];then
        echo "sshpass install no"
    fi
fi
}

#检测本机
[ -f ~/.ssh/id_rsa ] || create_sha

sshp

#当前机器生成秘钥，然后复制到远程机器，再将当前脚本复制过去，远程运行
for ip in `echo ${ip[*]}`
do
    a="sshpass -p $passwd  ssh root@${ip} -o StrictHostKeyChecking=no"

    $a mkdir -p /root/.ssh
    cat /root/.ssh/id_rsa.pub | $a 'cat >> /root/.ssh/authorized_keys'
    $a chmod 600 /root/.ssh/authorized_keys
    
    b=`$a [ -f mi.sh ] && echo 1 || echo 2`
    if [ $b -eq 1 ];then
        echo " $ip ok"
    else
        sshpass -p "$passwd" scp mi.sh root@${ip}:/root/
        $a chmod +x mi.sh
        $a bash mi.sh
    fi
done
