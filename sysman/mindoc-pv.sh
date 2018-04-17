#!/bin/bash
#介绍：mindoc自适应查访问量脚本
#作者qq：1969679546
#版本：1.0
#发布时间：2018/4/17

#[使用者设置]
#当前只支持单个日志文件筛选
log_file=/tmp/wiki.log



wiki_name=()
wiki_number=()
#先筛选出有哪些项目，根据docs后面的项目标识
wiki_log() {
    local i a=0
    if [ -f $1 ];then
        for i in `grep "http://www.52wiki.cn/docs" $1 | awk '{print $16}' | sort | uniq |grep "http://www.52wiki.cn/docs/.*\/" |awk -F'/' '{print $5}' | sort |uniq`
        do
            wiki_name[$a]=$i
            let a++
        done
    else
        echo "file does not exist"
    fi
}

#统计出次数
wiki_project() {
    local i a=0
    for i in `echo ${wiki_name[*]}`
    do
        wiki_number[$a]=`grep "http://www.52wiki.cn/docs/${i}" ${1} | wc -l`
        let a++
    done
}

#输出所有项目
wiki_out() {
    local i a=`echo ${#wiki_name[*]}`
    let a--

    for i in `seq 0 ${a}`
    do
        echo "项目：${wiki_name[$i]}，访问次数${wiki_number[$i]}"
    done
}

#输出单个项目
wiki_project_out() {
    echo "项目：${wiki_name[$1]}，访问次数${wiki_number[$1]}"
}

wiki_log $log_file
wiki_project $log_file
if [ "$1" == "1" ];then
    wiki_out
else
    wiki_project_out shell
fi
