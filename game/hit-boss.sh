#!/usr/bin/env bash
#介绍：你将挑战大法师
#作者qq：1969679546
#版本：1.0
#发布时间：2017/9/13

p_exit() {
echo -e "\033[?25h"    #显示光标
stty echo    #显示输出内容
clear
exit
}

trap "p_exit;" INT TERM    #当强制退出则执行p_exit函数内容

yuyan() {   #首先检查语言环境，是否支持中文
if [ `echo $LANG` == "en_US.UTF-8" -o `echo $LANG` == "zh_CN.UTF-8" ];then
    kuang_test
else
    echo "The current language is not Chinese！" #告诉他设置中文
    echo "Please use “LANG=en_US.UTF-8” to set up the language！"
    p_exit
fi
}

kuang_test() {   #若边框大小不符合，则提示更改边框大小
if [ `tput lines` -lt 15 ];then
    echo "当前长为`tput lines`，请扩大到15！"
    sleep 5
    p_exit
fi
if [ `tput cols` -lt 90 ];then
    echo "当前宽为`tput cols`，请扩大到！90"
    sleep 5
    p_exit
fi
}


deng() {
{
    for ((i = 0 ; i <= 100 ; i+=20)); do
        sleep 1
        echo $i
    done
} | whiptail --gauge "马上就要开始喽，请等待！" 6 60 0
}
PET=$(whiptail --title "人物角色创建" --inputbox "请给自己起一个名字！" 10 60 火车侠 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    whiptail --title "以下是游戏说明" --msgbox "口袋妖怪玩法，魔兽风格打怪游戏！目前只支持第一章第一节的故事情节，并且是文字游戏！" 10 60
    whiptail --title "以下是控制说明" --msgbox "游戏按A和D来进行攻击选择，按p来退出游戏！回车确认选项" 10 60
    deng
else
    echo "小哥再来玩呦！"
    exit 4
fi
clear
echo -e "\033[?25l" #关闭光标
stty -echo



#数组变量
wei=1 #光标位置初始值
zhu_hp=100
zhu_mp=50
boss_hp=500
boss_mp=800
open=(10 14 29 44)
yuju="大法师*安东尼：$PET，偷了我的东西还想跑！"
chushi() {  #人物信息显示
echo -e "\033[1;10H LV10 $PET"
echo -e "\033[31m\033[2;10H HP 100/${zhu_hp} \033[0m"
echo -e "\033[34m\033[3;10H MP 50/${zhu_mp} \033[0m"
echo -e "\033[1;45H LV99 大法师*安东尼"
echo -e "\033[31m\033[2;45H HP 500/${boss_hp} \033[0m"
echo -e "\033[34m\033[3;45H MP 800/${boss_mp} \033[0m"
}

duihua() {  #对话框,每次只要更改变量yuju
echo -e "\033[40m\033[8;10H $yuju \033[0m"
sleep 3
echo -e "\033[0m\033[8;10H                                                                                                                 \033[0m"
}

xuan() {    #选项
echo -e "\033[10;15H 普通攻击"
echo -e "\033[10;30H 跳斩"
echo -e "\033[10;45H 逃跑"
echo -e "\033["41"m\033[${open[0]};${open[$wei]}H  \033[0m"
}

zuo() { #往左移动
if [ $wei -gt 1 ];then
    echo -e "\033["40"m\033[${open[0]};${open[$wei]}H  \033[0m"
    let wei-=1
    echo -e "\033["41"m\033[${open[0]};${open[$wei]}H  \033[0m"
fi
}

you() { #往右移动
if [ $wei -lt 3 ];then
    echo -e "\033["40"m\033[${open[0]};${open[$wei]}H  \033[0m"
    let wei+=1
    echo -e "\033["41"m\033[${open[0]};${open[$wei]}H  \033[0m"
fi
}

huiche() {  #备用，回车清空选项区域
echo -e "\033[0m\033[10;10H                                                                                                                 \033[0m"
}


wanjie(){
if [ $boss_hp -le 0 ];then
    clear
    echo -e "\033[10;15H 你最终打败了大法师！"
    echo -e "\033[?25h"
    stty echo
    pingjia
    exit
 fi
}


tiaozhan() {    #主角攻击计算
wanjie
if [ $wei -eq 1 ];then
    yuju="$PET：普通攻击！"
    boss_hp=`echo $[boss_hp-180]`
    echo -e "\033[2;60H  -180hp"
    sleep 1.5
    echo -e "\033[0m\033[2;60H             \033[0m"
    echo -e "\033[31m\033[2;45H HP 500/${boss_hp} \033[0m"
    dafashi
    one
elif [ $wei -eq 2 ];then
    yuju="$PET：跳斩！"
    duihua
    boss_hp=`echo $[boss_hp-200]`
    echo -e "\033[2;60H  -200hp"
    sleep 1.5
    echo -e "\033[0m\033[2;60H            \033[0m"
    echo -e "\033[31m\033[2;45H HP 500/${boss_hp} \033[0m"
    dafashi
    one
elif [ $wei -eq 3 ];then
    yuju="大法师*安东尼：你逃不了的，我会吃掉你！"
    duihua
    one
fi
}

dafashi() { #大法师的攻击
wanjie
yuju="大法师*安东尼：烈焰弹！"
duihua
zhu_hp=`echo $[zhu_hp-20]`
echo -e "\033[2;20H  -20hp"
sleep 1.5
echo -e "\033[0m\033[2;20H         \033[0m"
echo -e "\033[31m\033[2;10H HP 100/${zhu_hp} \033[0m"
}


pingjia() {
OPTION=$(whiptail --title "请给本游戏打分" --menu "打分结果不会发送到互联网，只是好看而已QAQ" 15 60 4 \
"1" "不好玩，垃圾！" \
"2" "一般般吧，凑合玩" \
"3" "还可以，风格不错" \
"4" "太好玩了，希望续集"  3>&1 1>&2 2>&3)
exitstatus=$?

if [ $exitstatus = 0 ]; then
    echo "再见！"
else
    echo "再见！"
fi
}


menu() {    
echo -e "\033["41"m\033[${open[0]};${open[$wei]}H  \033[0m"
read -s -n 1 option
}


one(){
while [ 1 ]
do
    read -n 1 key
    if [[ $key == "A" || $key == "a" ]]; then zuo        #S, s
    elif [[ $key == "D" || $key == "d" ]]; then you       #D, d
    elif [[ "[$key]" == "[]" ]]; then tiaozhan  #空格键
    elif [[ $key == "Q" || $key == "q" ]]; then p_exit #Q, q
    fi
done
}



#yuyan #很难检测出是中文
kuang_test
chushi
xuan
duihua
one
