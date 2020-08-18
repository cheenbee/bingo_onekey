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

#docker安装
install_docker() {
    echo y | bash <(curl -L -s https://raw.githubusercontent.com/cheenbee/bingo_onekey/master/docker.sh)
}

#srt安装编译
install_srt() {

    if [ -f /usr/local/lib64/libsrt.a ]; then
        green "srt已安装，接下来直接进行sls编译安装"
    elif [ -f /usr/local/lib/libsrt.a ]; then
        green "srt已安装，接下来直接进行sls编译安装"
    else
        install_srt
    fi
    # Check Linux version
    if test -f /etc/os-release ; then
	    . /etc/os-release
    else
	    . /usr/lib/os-release
    fi
    if [ "$ID" = "centos" ] && [ "$VERSION_ID" != "7" ] && [ "$VERSION_ID" != "8" ]; then
	    echo -e "该脚本仅适用于 CentsOS 7  或 CentsOS 8"
	    exit 1
    elif [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" != "14.04" ] && [ "$VERSION_ID" != "16.04" ] && [ "$VERSION_ID" != "18.04" ] && [ "$VERSION_ID" != "19.04" ] && [ "$VERSION_ID" != "20.04" ]; then
	    echo -e "该脚本仅适用于Ubuntu 14.04、Ubuntu 16.04、Ubuntu 18.04、19.04或20.04 "
	    exit 1
    elif [ "$ID" != "centos" ] && [ "$ID" != "ubuntu" ]; then
	    echo -e "该脚本仅适用于Ubuntu 14.04、Ubuntu 16.04、Ubuntu 18.04、19.04或20.04，CentsOS 7  或 CentsOS 8"
	    exit 1
    fi

    white "===> Start to install srt" 
    if [ "$ID" = "ubuntu" ]; then
		install_srt_ubuntu
	else
        $LD_LIBRARY_PATH = ”/usr/local/lib64/“
		install_srt_centos
	fi
    
    sudo git clone https://gitee.com/cheenbee/srt.git
    cd srt
    sudo git remote set-url origin https://github.com/Haivision/srt.git && sudo git pull
    sudo ./configure
    sudo make
    sudo make install
    green "srt安装完成"
}

install_srt_centos() {
    sudo yum update
    sudo yum install tcl pkgconfig openssl-devel cmake gcc gcc-c++ make automake git
}

install_srt_ubuntu() {
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install tclsh pkg-config cmake libssl-dev build-essential zlib1g-dev git
}

#安装sls
install_sls() {
    # 检测srt是否已安装
    if [[ -f /usr/local/lib64/libsrt.a ]] || [[ -f /usr/local/lib/libsrt.a ]]; then
        green "srt已安装，接下来直接进行sls编译安装"
    else
        install_srt
    fi
    white "===> Start to install srt-live-server"
    # Check Linux version
    if test -f /etc/os-release ; then
	    . /etc/os-release
    else
	    . /usr/lib/os-release
    fi

    LD_LIBRARY_PATH="/usr/local/lib/"
    if [ "$ID" = "centos" ]; then LD_LIBRARY_PATH="/usr/local/lib64/"; fi

    # export LD_LIBRARY_PATH=$LD_LIBRARY_PATH 环境变量 指定srt安装路径
    sudo echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> ~/.bashrc
    . ~/.bashrc

    sudo git clone https://gitee.com/cheenbee/srt-live-server.git
    cd srt-live-server
    sudo git remote set-url origin https://github.com/Edward-Wu/srt-live-server.git && sudo git pull
    sudo make
    yellow "===> 以默认配置文件../sls.conf件启动sls"
    cd bin
    ./sls -c ../sls.conf
    green "下面是默认的测试配置,如要测试请放行8080端口白名单"
    green "推流地址：srt://YourServerIP:8080?streamid=uplive.sls.com/live/test"
    green "拉流地址：srt://YourServerIP:8080?streamid=live.sls.com/live/test"
    white "教程参考：https://www.yuque.com/zizairufengdeshaonian-gqqqm/nf3lkf/kueeh5"
}

#安装srs
install_srs() {
    echo "===> Start to install srs"
    sudo git clone https://gitee.com/winlinvip/srs.oschina.git srs
    cd srs/trunk
    sudo git remote set-url origin https://github.com/ossrs/srs.git && sudo git pull
    sudo ./configure
    sudo make
    yellow "====> 以默认配置文件conf/rtmp.conf启动rtmp实例"
    ./objs/srs -c conf/rtmp.conf
}


#开始菜单
start_menu(){
    clear
    echo
    greenbg "============================================"
    greenbg "简介：一键部署srt、srt-live-server、srs服务     "
    greenbg "适用范围(srt)：Centos、Ubuntu                 "
    greenbg "适用范围(srs)：Centos、Ubuntu、Debian          "
    greenbg "============================================="
    echo
    white "—————————————环境安装——————————————"
    white "1.编译安装srt"
    white "2.编译安装srt-live-server"
    white "3.编译安装srs"
    echo
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
    install_srt
    blue "srt直播(srt-live-transmit)测试"
    blue "推流地址: srt://YourServerIP:4200，拉流地址: srt://YourServerIP:4201"
    blue "如果你使用的是云服务器，请放行对应的安全组端口"
    srt-live-transmit srt://:4200 srt://:4201 -v
    white "教程说明：https://www.yuque.com/zizairufengdeshaonian-gqqqm/nf3lkf/va592y"
	;;
    2)
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