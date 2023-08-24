#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  local path=`uci get forcedata.@forcedata[0].cache_path 2>/dev/null`
  local uid=`uci get forcedata.@forcedata[0].uid 2>/dev/null`
  local image_name=`uci get forcedata.@forcedata[0].image_name 2>/dev/null`

  if [ -z "$path" ]; then
      echo "path is empty!"
      exit 1
  fi

  [ -z "$image_name" ] && image_name="jinshanyun/jinshan-x86_64:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f forcedata

  local cmd="docker run --restart=unless-stopped -d \
    --privileged \
    --network=host \
    --dns=127.0.0.1 \
    --tmpfs /run \
    --tmpfs /tmp \
    -v \"$path:/data/ksc1\" \
    -v \"$path/containerd:/var/lib/containerd\" \
    -e ksc_supplier_code=\"92101\" \
    -e ksc_datadir=\"/data/ksc1\" \
    -e ksc_machine_code=\"lsyK17032_$uid\" \
    -e ksc_refer=\"ruiyun_node\""

  local tz="`uci get system.@system[0].zonename`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name forcedata \"$image_name\""

  echo "$cmd"
  eval "$cmd"

  if [ "$?" = "0" ]; then
    if [ "`uci -q get firewall.forcedata.enabled`" = 0 ]; then
      uci -q batch <<-EOF >/dev/null
        set firewall.forcedata.enabled="1"
        commit firewall
EOF
      /etc/init.d/firewall reload
    fi
  fi

  echo "Install OK!"

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the forcedata"
  echo "      upgrade                Upgrade the forcedata"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the forcedata"
  echo "      status                 Onething Edge status"
  echo "      port                   Onething Edge port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f forcedata
    if [ "`uci -q get firewall.forcedata.enabled`" = 1 ]; then
      uci -q batch <<-EOF >/dev/null
        set firewall.forcedata.enabled="0"
        commit firewall
EOF
      /etc/init.d/firewall reload
    fi
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} forcedata
  ;;
  "status")
    docker ps --all -f 'name=forcedata' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=forcedata' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac

