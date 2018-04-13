#!/bin/bash
#介绍：适合百台以下规模跳板机，批量操作脚本
#作者qq：1969679546
#版本：1.2
#发布时间：2017/11/25

#[使用者设置]
#信息输出语言，cn为中文，en为英文
language=en

#从/etc/hosts文件第几行开始计算主机名
hang=3

#首先填写组名
zu=(web)

#一下皆为组成员，可以是ip或者主机名
web=(web1)

#不允许使用的命令
cuo=(reboot shutdown xixi) #xixi用来测试，看脚本是否禁止了



#[通用函数库]
#提示并退出脚本，$1中文，$2英文
test_exit() {
    clear
    echo
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    [ "$language" == "cn" ] && echo "错误：$1" || echo "Error：$2"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo
    exit 2
}



#[主体内容]
#检查参数
if [ $# -ne 2 ];then
	if [ "$language" == "cn" ];then
		echo "至少2个参数

-a '命令' 操作所有
    例子：$0 -a 'ls'

组名 '命令' 操作单个组
    例子：$0 app 'ls'

目前支持的群组：${zu[*]}"
	else
		echo "At least 2 parameters

-a 'ls' Operate all
	Example: $0 -a 'ls'

GroupName 'Command' Operation Single Group
	Example: $0 app 'ls'

Currently supported groups： ${zu[*]}"
	fi
	exit 2
fi

#禁止命令检测
for o in `echo ${cuo[*]}`
do
	echo "$2" | grep -w "$o"
	[ $? -eq 0 ] && test_exit "不允许使用$o" "Not allowed to use $o"
done

#主程序，如果-a则操作所有，否则检测组名是否在组中，不在则报错
r=0 #初始，如果都没匹配到则错误
t=`echo ${#zu[*]}` #总数量

if [ "$1" == "-a" ];then
	for i in `tail -n +${hang} /etc/hosts|awk '{print $2}'`
	do
		echo "####################$i：####################"
		ssh $i $2
	done
else
	for p in `echo ${zu[*]}`
	do
		echo "$1" | grep -w "$p" &> /dev/null
		if [ $? -eq 0 ];then
			for u in $(eval echo \${$p[*]})
			do
				echo "####################r$u：####################"
				ssh $u $2
			done
			exit #完成后退出，不用继续循环
		else
			let r++ #失败+1，全部失败报错
		fi
	done
	[ $r -eq $t ] && test_exit "组名称不正确" "Incorrect group name"
fi
