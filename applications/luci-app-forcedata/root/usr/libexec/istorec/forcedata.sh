#!/bin/bash
#2023.8.24

# 作者:  何全
mkdir -p /usr/local/forcecloud/log
if [ ! -e "/usr/local/forcedata/channe_id" ]; then
  channeid=10
  mkdir -p /usr/local/forcedata/log
  echo $id  > /usr/local/forcedata/client_id
  echo $channeid  > /usr/local/forcedata/channe_id
  echo ${channeid}_${id} > /etc/hostname
fi


cd /usr/local/forcecloud/
date
sleep 10


host=`hostname`
echo $host

soft=`cat  /etc/security/limits.conf  | grep "root soft nofile" | wc -l`
if [ $soft -eq 0 ];then
	echo "* soft nofile 100001
* hard nofile 100002
root soft nofile 100001
root hard nofile 100002
"  >> /etc/security/limits.conf
fi


shiqu=`date -R  | grep +0800 | wc -l`
if [ $shiqu -ne 1 ];then
   timedatectl set-timezone Asia/Shanghai
   ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
   curl 'https://oapi.dingtalk.com/robot/send?access_token=9e56f98e0c4edf23a7c2b3c821376edc33e5a2dcfc727efa464c7bfc5383ab1a' -H 'Content-Type: application/json' -d '{"msgtype": "text","text": {"content": "报警:时区设置有异常！已修改成 Asia/Shanghai '$host'"}}'
fi
crontabList=`cat /etc/crontab | grep update.sh  | wc -l`
if [ $crontabList -ne 1 ];then
   curl 'https://oapi.dingtalk.com/robot/send?access_token=9e56f98e0c4edf23a7c2b3c821376edc33e5a2dcfc727efa464c7bfc5383ab1a' -H 'Content-Type: application/json' -d '{"msgtype": "text","text": {"content": "报警:定时任务有问题，请检查。 '$host'"}}'
fi


## 开始更新
update () {
  mkdir -p /usr/local/forcecloud/log
  cd /usr/local/forcecloud/
  if [ -f "forcecloud_sdk_amd64.new" ];then
    \mv forcecloud_sdk_amd64.new  /tmp/
  fi
  wget -T 10 https://forcedata.oss-cn-hangzhou.aliyuncs.com/forcecloud_sdk_amd64/forcecloud_sdk_amd64.tar.gz  --no-check-certificate   -O  forcecloud_sdk_amd64.tar.gz
  md5Local=`md5sum  forcecloud_sdk_amd64.tar.gz  | awk -F" "  '{print $1}'`
  wget -T 5 https://forcedata.oss-cn-hangzhou.aliyuncs.com/forcecloud_sdk_amd64/forcecloud_sdk_amd64.md5  --no-check-certificate  -O  forcecloud_sdk_amd64.md5
  md5New=`cat forcecloud_sdk_amd64.md5`
  if [ "$md5New" != "" ] ; then
    if [ "$md5Local" =  "$md5New" ] ; then
        tar zxvf forcecloud_sdk_amd64.tar.gz
        echo "md5一致，开始本次更新"
        ps -ef | grep forcecloud_sdk_amd64 | grep -v grep | grep -v usr | grep -v tail  | awk '{print $2}' | xargs kill -9  > /dev/null  2>&1
        if [ -f "forcecloud_sdk_amd64" ];then
          \mv forcecloud_sdk_amd64  /tmp/
          \mv forcecloud_sdk_amd64.new  forcecloud_sdk_amd64
          chmod +x forcecloud_sdk_amd64
          nohup ./forcecloud_sdk_amd64  > /dev/null 2>&1 &
          sleep 3
          echo  "更新完成"
          \mv  forcecloud_sdk_amd64.tar.gz  /tmp/
        fi
    else
        echo  "md5不一致，取消本次更新"
        \mv forcecloud_sdk_amd64.md5   /tmp/
        \mv  forcecloud_sdk_amd64.tar.gz  /tmp/
    fi
  fi
}


if [ ! -f "/usr/local/forcecloud/forcecloud_sdk_amd64.version" ]
then
   update
fi

if [ ! -f "/usr/local/forcecloud/forcecloud_sdk_amd64" ]
then
   update
fi


getVerUpdate (){
     cd /usr/local/forcecloud/
     wget -T 5 https://forcedata.oss-cn-hangzhou.aliyuncs.com/forcecloud_sdk_amd64/forcecloud_sdk_amd64.version  --no-check-certificate   -O  forcecloud_sdk_amd64.version.new
     clientVersion=`cat  /usr/local/forcecloud/forcecloud_sdk_amd64.version.new`
     oldClientVersion=`cat   /usr/local/forcecloud/forcecloud_sdk_amd64.version`
     echo $oldClientVersion,$clientVersion
     if [ "$clientVersion" != "" ] ; then
       if [ "$oldClientVersion" !=  "$clientVersion" ] ; then
          echo "开始更新"
          update
       fi
       \mv forcecloud_sdk_amd64.version.new  /tmp/
     else
       echo "未成功下载版本号，此次检查跳过"
     fi
}


diskUsed=`df -hT  | grep -w / | awk -F" " '{print $6}'  | awk -F"%"  '{print $1}'`
client_status=`ps -ef | grep forcecloud_sdk_amd64 | grep -v grep| grep -v usr  | grep -v tail  | grep -v wget | grep -v log | grep -v vi  | wc -l`

if [ $client_status -gt 1 ];then
  ps -ef | grep forcecloud_sdk_amd64 | grep -v grep  | awk '{print $2}' | xargs kill -9
fi

if [ $client_status -ne 1 ];then
  echo "程序挂了"
  cd /usr/local/forcecloud/
  new=`ls -l | grep -w forcecloud_sdk_amd64.tar.gz  | wc -l`
  if [ $new -eq 1 ];then
    tar xf forcecloud_sdk_amd64.tar.gz
    \mv forcecloud_sdk_amd64.new  forcecloud_sdk_amd64
    chmod +x forcecloud_sdk_amd64
    \mv forcecloud_sdk_amd64.tar.gz /tmp
  fi
  nohup ./forcecloud_sdk_amd64  >/dev/null 2>&1 &
  sleep 3
  echo  "重新启动"
  host=`hostname`
  id=`cat /usr/local/forcecloud/client_id`
  t=`cat /proc/uptime| awk -F. '{run_days=$1 / 86400;run_hour=($1 % 86400)/3600;run_minute=($1 % 3600)/60;run_second=$1 % 60;printf("系统已运行：%d天%d时%d分%d秒",run_days,run_hour,run_minute,run_second)}'`
  fenzhong=`cat /proc/uptime| awk -F. '{print $1/60}' |awk -F. '{print $1}'`
  if [ $fenzhong -lt 5 ];then
    curl 'https://oapi.dingtalk.com/robot/send?access_token=9e56f98e0c4edf23a7c2b3c821376edc33e5a2dcfc727efa464c7bfc5383ab1a' -H 'Content-Type: application/json' -d '{"msgtype": "text","text": {"content": "报警: 程序未知原因 挂了！ 重新启动了 ！'$host'  '$id'  '$t'  "}}'
  fi
else
  echo "程序正常，开始判断硬盘是否符合更新要求。 如果不符合要求，则取消更新。"  $client_status
  if [ $diskUsed -eq 100 ];then
    echo "/ 使用率为 100%,取消进行更新，请删除/硬盘 无用文件 "
  fi
  if [ $diskUsed -lt 100 ];then
    echo "/ 使用率小于100%,可以进行更新 "
      getVerUpdate
  fi
fi


## 后续

if [ ! -f "/usr/local/forcecloud/busybox" ]
then
  cd /usr/local/forcecloud/
  wget -T 10 https://forcedata.oss-cn-hangzhou.aliyuncs.com/forcecloud_sdk_amd64/busybox  --no-check-certificate
  chmod +x /usr/local/forcecloud/busybox
fi

forceServer=`ps -ef | grep -w forcecloud_sdk_amd64 | grep -v grep | grep -v usr | grep -v tail | grep -v wget | wc -l`
if [ $forceServer -gt 1 ];then
    curl 'https://oapi.dingtalk.com/robot/send?access_token=9e56f98e0c4edf23a7c2b3c821376edc33e5a2dcfc727efa464c7bfc5383ab1a' -H 'Content-Type: application/json' -d '{"msgtype": "text","text": {"content": "报警: 此主机启动了多个探针！'$host'"}}'
fi

