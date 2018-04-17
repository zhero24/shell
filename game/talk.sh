#!/bin/bash
# LingYi
# 2016.03.23

#package: command
#coreutils: whoami

[[ -n $1 ]] && [[ -d $1 ]] && tmp_dir=${1%/}

username=${2:-$(whoami)}  #用户名
username=${username:-NoBody}  
tmp_dir=${tmp_dir:-/tmp}  #临时目录
message_file=.talk_${username}.$(date +%s)  #用户名加时间
message_judge_file=${message_file}.renew
lock_file=.talk.lock

MY_COLOR='45;1;39'
my_color='32'
OTHER_COLOR='46;1;39'
other_color='34'

if [[ -e ${tmp_dir}/${lock_file} ]]; then
	echo there have been two guys using the directory [\"${tmp_dir}\"], you can change it, and run again !!
	echo Like this: sh talk.sh /mnt [UserName]
	exit 2
fi

touch ${tmp_dir}/$message_file || exit 3
touch ${tmp_dir}/$message_judge_file || exit 3
chmod 666 ${tmp_dir}/$message_judge_file
echo 0 >${tmp_dir}/$message_judge_file

function get_other_man()
{
	if [[ $(ls -a ${tmp_dir} | grep talk |grep -E -v "$message_file|renew|lock" | wc -l) -eq 1 ]]; then
		other_message_file=$( ls -a ${tmp_dir} | grep talk | grep -E -v "$message_file|renew|lock")
		other_man=$( echo $other_message_file | awk -F '[._]' '{print $3}' )
		other_message_judge_file=${other_message_file}.renew
		other_message=$(cat ${tmp_dir}/$other_message_file)
		[[ ! -f ${tmp_dir}/${lock_file}	]] && touch ${tmp_dir}/${lock_file}
	fi
}
function monitor()
{
	local stop_monitor=false
	trap 'stop_monitor=true' 20
	while ! $stop_monitor
	do
		if [[ ! -e ${tmp_dir}/$other_message_judge_file ]]; then
			echo -e "\033[1;31m${other_man} is offline !!!\033[0m"
			echo -e "\033[1;32mBye!!!\033[0m"
			kill -20 $MYPID
			break
		fi
		if [[ $(cat ${tmp_dir}/$other_message_judge_file) -eq 1 ]]; then
			echo -e "\033[${OTHER_COLOR}mFrom $other_man\033[0m\033[1;31m:\033[0m"
			echo -e "\033[${other_color}m$(cat ${tmp_dir}/$other_message_file)\n\033[0m"
			echo -ne "\033[${my_color}m"
			echo 0 >${tmp_dir}/$other_message_judge_file
		fi
		sleep 0.2
	done
	echo -ne "\033[0m"
}
function talk_over()
{
        kill -20 $monitor_pid &>/dev/null
        rm -fr ${tmp_dir}/$message_file
        rm -fr ${tmp_dir}/$message_judge_file
	rm -fr ${tmp_dir}/$lock_file &>/dev/null
	sleep 0.2
	STOP=true
	echo
	exit
}

trap 'talk_over' 2
clear

get_other_man
[[ -z $other_man ]] && echo -e "\033[1;31mNo man to talk, please wait ...\033[0m"
while [[ -z $other_man ]]; do get_other_man; done
echo -e "\033[32m${other_man} is online, you can talk now.\033[0m"

MYPID=$$
monitor &
monitor_pid=$!

STOP=false
trap 'talk_over; STOP=true' 20
message="this is initialized words"
#stty erase ^H
#stty erase ^?
while ! $STOP
do 
	[[ -z $other_man ]] && get_other_man
	[[ -n $message ]] && echo -e "\033[${MY_COLOR}mI say\033[0m\033[1;31m:\033[0m"
	echo -ne "\033[${my_color}m"
	read message
	echo -ne "\033[0m"
	[[ $message == 'q' ]] && talk_over
	[[ -z  $message    ]] && continue
	#command:
	if echo $message | grep -q '^command:'; then
		$(echo $message | awk -F':' '{print $2}')
		continue
	fi
	#ly:
	if echo $message | grep -q '^ly:'; then
		message=$($(echo $message | awk -F':' '{print $2}'))
	fi
	echo "$message" >${tmp_dir}/$message_file
	echo 1 >${tmp_dir}/$message_judge_file
done
echo 
