#!/bin/bash
#作者：www.52wiki.cn
#时间：2017/11/20
#版本：1.5

baocun() {
> wiki_book.ttt
echo "名字：$name" >> wiki_book.ttt
echo "天数：$day" >> wiki_book.ttt
echo "体力：$xue" >> wiki_book.ttt
echo "法力：$lan" >> wiki_book.ttt
}

p_exit() {
echo -e "\033[?25h"    #显示光标
baocun
clear
exit
}


trap "p_exit;" INT TERM    #当强制退出则执行p_exit函数内容
name=xx
xue=100 #体力
lan=30 #法力
ka=(0 治愈 恢复 圣光 逃脱 命运 世界) #可买商品名
jieshao=(0 "+10体力     " "+15体力     " "+20体力     " "1/10几率逃脱" "随机1次     " "随机10次    ")
money=(0 10 15 20 60 13 160) #商品价格
tao=0 #获得的逃脱卡牌
day=1 #天数
shu=(0 0 0 0 0) #十连抽

k() { #显示商品
for i in `seq 1 6`
do
    echo "$i 卡片:${ka[$i]} 效果:${jieshao[$i]} 耗费法力:${money[$i]}"
done
echo "世界卡片至少获得一张逃脱，按9将进入下一天，exit退出"
}

bao() { #背包
echo -e "\033["33"m\033[1;55H 玩家：${name} 体力：${xue} 法力：${lan}\033[0m"
echo -e "\033["33"m\033[3;55H 天数：${day}\033[0m"
echo -e "\033["33"m\033[4;55H 逃脱：${tao} 按8使用此卡片\033[0m"
echo -e "\033["33"m\033[5;55H 地牢：你被困在地牢里，每天都会受到诅咒从而-10体力\033[0m"
echo -e "\033["33"m\033[6;55H 法师：因为你是一个低级法师，每天可以+12法力从而召唤卡牌\033[0m"
echo -e "\033["33"m\033[7;55H 获胜：获得6张逃脱召唤六芒星或者使用一张逃脱成功则胜利！\033[0m"
}

xiaoguo() { #卡牌效果
if [ "$1" -eq "1" ];then
    let xue+=10
    xiaoxi 获得一张治愈，体力+10
elif [ "$1" -eq "2" ];then
    let xue+=15
    xiaoxi 获得一张恢复，体力+15
elif [ "$1" -eq "3" ];then
    let xue+=20
    xiaoxi 获得一张圣光，体力+20
elif [ "$1" -eq "4" ];then
    let tao+=1
    xiaoxi 获得一张逃脱卡牌
fi
}


chou() { #抽奖一次
local a b
a=`echo $[RANDOM%13]` #随机
if [ "$a" -le "4" ];then
    b=1
elif [ "$a" -gt "4" -a "$a" -le "8" ];then
    b=2
elif [ "$a" -eq "9" ];then
    b=3
else
    b=4
fi
if [ "$1" -eq "0" ];then
    xiaoguo $b
else
    let shu[b]+=1 #此次数量增加
fi
}


chou_shi() { #抽10张计算
local a b c d e
a=`echo ${shu[1]}`
b=`echo ${shu[2]}`
c=`echo ${shu[3]}`
d=`echo ${shu[4]}`
let a*=10
let b*=15
let c*=30
e=`echo $[a+b+c]`
let xue+=e
let tao+=d
xiaoxi 获得张${shu[1]}治愈，${shu[2]}张恢复，${shu[3]}张圣光，${shu[4]}张逃脱
xiaoxi 恢复$e体力
}

xiaoxi() { #消息
echo -e "\033[?25l"
echo -e "\033["35"m\033[2;55H ${1}\033[0m"
sleep 2
echo -e "\033[?25h"
}


qian() { #法力不够检测
local a
a=`echo ${money[num]}`
if [ "$lan" -lt "$a" ];then
    xiaoxi 法力不足！
    continue
fi
}


taotuo() {
local a
a=`echo $[RANDOM%9]`
if [ "$tao" -ge "1" ];then
    let tao-=1
    if [ "$a" -eq "5" ];then
        xiaoxi 使用逃脱成功
        sheng
    else
        xiaoxi 使用逃脱失败
    fi
else
    xiaoxi 没有逃脱卡牌
fi
}


sheng() {
xiaoxi 耗费$day天你终于逃脱了地牢！
p_exit
}
gameover() {
xiaoxi 你被诅咒所杀害，重新开始游戏！
rm -rf wiki_book.ttt
clear
exit
}


if [ -f wiki_book.ttt ];then
    name=`awk -F'：' '{print $2}' wiki_book.ttt | sed -n '1p'`
    day=`awk -F'：' '{print $2}' wiki_book.ttt | sed -n '2p'`
    xue=`awk -F'：' '{print $2}' wiki_book.ttt | sed -n '3p'`
    lan=`awk -F'：' '{print $2}' wiki_book.ttt | sed -n '4p'`
else
    clear
    read -p "请输入用户名：" name
fi
while [ 1 ] #开始
do
    clear
    k
    bao
    read -p "请选择：" num
    if [ "$num" -le "4" ];then
        qian
        let lan-=money[num]
        xiaoguo $num
    elif [ "$num" -eq "5" ];then
        qian
        let lan-=money[num]
        chou 0
    elif [ "$num" -eq "6" ];then
        qian
        let lan-=money[num]
        for i in {1..9}
        do
            chou 1
        done
        let shu[4]+=1 #必定一次逃脱
        chou_shi
        shu=(0 0 0 0 0) #清零
    elif [ "$num" -eq "8" ];then
        taotuo
    elif [ "$num" -eq "9" ];then
        if [ "$xue" -le 10 ];then
            gameover
        fi
        xiaoxi 法力恢复12，体力减少10
        let day+=1
        let xue-=10
        let lan+=12
    elif [ "$num" == "exit" ];then
        p_exit
    else
        xiaoxi 选项错误！
    fi
    if [ "$tao" -eq 6 ];then
        xiaoxi 召唤六芒星，成功逃脱！
        sheng
    fi
done
