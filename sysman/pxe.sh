#!/bin/bash
#介绍：pxe一键安装
#作者qq：1969679546
#版本：1.0
#发布时间：2017/9/20

caidan(){    #菜单
OPTION=$(whiptail --title "PXE自动部署" --menu "上下键进行选择" 15 60 4 \
"1" "选择网卡" \
"2" "选择镜像" \
"3" "开始部署" \
"4" "自动应答" \
"5" "还原卸载"  3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    xuan
else
	echo "caidan函数错误"
    exit 4
fi
}


xuan(){    #执行选项
if [ $OPTION -eq 1 ];then
    wangka
elif [ $OPTION -eq 2 ];then
    jingxiang
elif [ $OPTION -eq 3 ];then
	kaishibushu
elif [ $OPTION -eq 4 ];then
	zidongyingda
elif [ $OPTION -eq 5 ];then
	huanyuanxiezai
fi
}


wangka(){    #选择网卡
ka=$(whiptail --title "选择网卡" --inputbox "请输入网卡名,默认为eth0" 10 60 eth0 3>&1 1>&2 2>&3)
ka_ok=$?
if [ $ka_ok = 0 ]; then
    ifconfig $ka
	if [ $? -ne 0 ];then
		echo "没有那张网卡，使用ifconfig命令查看网卡名"
		exit 5
	fi
	
	ifconfig $ka |grep "netmask 255.255.255.0"
	if [ $? -ne 0 ];then
		echo "目前只支持/24网段"
		exit 5
	fi
	caidan
else
    caidan
fi
}


jingxiang(){    #输入镜像
jing=$(whiptail --title "镜像地址" --inputbox "请输入镜像位置，光盘是/dev/sr0，镜像文件是/root/xx.iso，默认/dev/sr0 " 10 60 /dev/sr0 3>&1 1>&2 2>&3)
jing_ok=$?
if [ $jing_ok = 0 ]; then
	mkdir rijiutianduan
	mount $jing rijiutianduan
	if [ $? -ne 0 ];then
		echo "镜像地址错误"
		umount $jing rijiutianduan
		rm -rf rijiutianduan
		exit	
	fi
	umount $jing rijiutianduan
	rm -rf rijiutianduan
	caidan
else
    caidan
fi
}


kaishibushu() {
if (whiptail --title "脚本说明" --yes-button "确定" --no-button "退出"  --yesno "Vserion 2.0 使用dhcpd,tftp-server,httpd这3种安装包，请准备好yum源和镜像地址！" 10 60) then
	app_install
	bushu
else
    caidan
fi
}


app_install() { #安装软件
yum -y install httpd
if [ $? -ne 0 ];then
	echo "安装httpd失败，请检查yum源"
	exit 0
else
	yum -y install httpd dhcp tftp-server syslinux wget
fi
}


zidongyingda(){    #自动应答
kick=$(whiptail --title "自动应答" --inputbox "请输入kickstart文件在本机地址，默认则不使用自动应答" 10 60 book 3>&1 1>&2 2>&3)
kick_ok=$?
if [ $kick_ok = 0 ]; then	
	caidan
else
    caidan
fi
}

bushu() {
mkdir /var/www/html/bookttt
mount $jing /var/www/html/bookttt
systemctl restart httpd
	
ipdizhi=`ifconfig $ka | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |head -n 1`

ipone=`echo ${ipdizhi} | awk -F'.' '{print $1}'`
iptwo=`echo ${ipdizhi} | awk -F'.' '{print $2}'`
ipthree=`echo ${ipdizhi} | awk -F'.' '{print $3}'`

ipduan=`echo ${ipone}.${iptwo}.${ipthree}`

ipp=`echo ${ipduan}.0`


echo "
subnet $ipp netmask 255.255.255.0 {
     range  ${ipduan}.190 ${ipduan}.240;
     next-server  $ipdizhi;
     filename  "pxelinux.0";
}
" > /etc/dhcp/dhcpd.conf
sed  -i '5c filename  "pxelinux.0";' /etc/dhcp/dhcpd.conf 
systemctl restart dhcpd
systemctl restart tftp
jing_one=${ipdizhi}/bookttt


cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
cd /var/lib/tftpboot/
wget http://${ipdizhi}/bookttt/isolinux/vmlinuz
wget http://${ipdizhi}/bookttt/isolinux/initrd.img
mkdir /var/lib/tftpboot/pxelinux.cfg
wget  http://${ipdizhi}/bookttt/isolinux/vesamenu.c32
wget  http://${ipdizhi}/bookttt/isolinux/splash.png
wget  -O  pxelinux.cfg/default  http://${ipdizhi}/bookttt/isolinux/isolinux.cfg
sed  -i "64c append initrd=initrd.img inst.stage2=$jing_one" pxelinux.cfg/default
sed  -i "96c append initrd=initrd.img inst.stage2=$jing_one rescue" pxelinux.cfg/default
sed -i "109a menu default" pxelinux.cfg/default

if [ "$kick" != "book" ];then
	a=`echo ${kick##*/}`
	cp $kick /var/www/html/
	sed  -i "64c append initrd=initrd.img ks=http://${ipdizhi}/$a" pxelinux.cfg/default
	clear
	echo "完事"
fi
}


huanyuanxiezai(){
if (whiptail --title "还原卸载" --yes-button "确定" --no-button "退出"  --yesno "Vserion 1.0 会还原到原本环境！" 10 60) then
    xiezai
else
    caidan
fi
}

xiezai() {

systemctl stop dhcpd
systemctl stop httpd
systemctl stop ftpd
yum -y remove install httpd dhcp tftp-server syslinux

umount $jing /var/www/html/bookttt
rm -rf /var/www/html/bookttt
rm -rf /var/lib/tftpboot/*
clear

echo "完事"
}


caidan
