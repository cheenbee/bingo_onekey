#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 设置字体颜色函数
function blue(){
    echo -e "\033[34m\033[01m $1 \033[0m"
}
function green(){
    echo -e "\033[32m\033[01m $1 \033[0m"
}
function greenbg(){
    echo -e "\033[43;42m\033[01m $1 \033[0m"
}
function red(){
    echo -e "\033[31m\033[01m $1 \033[0m"
}
function redbg(){
    echo -e "\033[37;41m\033[01m $1 \033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m $1 \033[0m"
}
function white(){
    echo -e "\033[37m\033[01m $1 \033[0m"
}

#工具安装
install_pack() {
    pack_name="基础工具"
    echo "===> Start to install curl"    
    if [ -x "$(command -v yum)" ]; then
        command -v curl > /dev/null || yum install -y curl
    elif [ -x "$(command -v apt)" ]; then
        command -v curl > /dev/null || apt install -y curl
    else
        echo "Package manager is not support this OS. Only support to use yum/apt."
        exit -1
    fi    
}

#srt安装编译
install_srt() {
    echo "===> Start to install srt" 
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install tclsh pkg-config cmake libssl-dev build-essential zlib1g-dev git
    sudo git clone https://github.com/Haivision/srt.git
    cd srt
    sudo ./configure
    sudo make
    sudo make install
    echo "srt安装完成"
}

install_sls() {
    install_srt
    echo "===> Start to install srt-live-server"
    sudo git clone https://github.com/Edward-Wu/srt-live-server.git
    cd srt-live-server
    sudo make
    echo "===> 以默认配置文../sls.conf件启动sls"
    export LD_LIBRARY_PATH=/usr/local/lib/
    cd bin
    ./sls -c ../sls.conf
}

install_srs() {
    echo "===> Start to install srs"
    sudo git clone https://github.com/ossrs/srs
    cd srs/trunk
    sudo ./configure
    sudo make
    echo "====> 以默认配置文件conf/rtmp.conf启动rtmp实例"
    ./objs/srs -c conf/rtmp.conf
}


#开始菜单
start_menu(){
    clear
    echo
    greenbg "=============================================================="
    greenbg "简介：一键部署直srt直播服务                                        "
    greenbg "适用范围：Centos7、Ubuntu                                        "
    greenbg "==============================================================="
    echo
    white "—————————————环境安装——————————————"
    white "1.编译安装srt"
    blue "2.编译安装srt-live-server"
    white "3.编译安装srs"
    echo
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
    install_srt
    srt-live-transmit srt://:1234 srt://:4201 -v
	;;
    102)
    install_sls
	;;
    3)
    install_srs    
	;;                                   
	0)
	exit 1
	;;
	*)
	clear
	echo "请输入正确数字"
	sleep 3s
	start_menu
	;;
    esac
}

start_menu