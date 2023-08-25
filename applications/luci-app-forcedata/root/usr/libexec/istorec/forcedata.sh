#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  echo 1 >  /tmp/ok
  local id=`uci get forcedata.@forcedata[0].id 2>/dev/null`
  echo $id
  echo "Install OK!"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the forcedata"
  echo "      upgrade                Upgrade the forcedata"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the forcedata"
  echo "      status                 Onething  status"
  echo "      port                   Onething  port"
}


case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
  ;;
  "start" | "stop" | "restart")
  ;;
  "status")

  ;;
  "port")

  ;;
  *)
    usage
    exit 1
  ;;
esac

