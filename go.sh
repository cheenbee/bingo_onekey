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

    sudo git clone https://github.com/Haivision/srt.git
    cd srt
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
    install_srt
    white "===> Start to install srt-live-server"
    # Check Linux version
    if test -f /etc/os-release ; then
	    . /etc/os-release
    else
	    . /usr/lib/os-release
    fi

    LD_LIBRARY_PATH
    if [ "$ID" = "centos" ]; then
        $LD_LIBRARY_PATH = "/usr/local/lib64/"
	else
        $LD_LIBRARY_PATH = "/usr/local/lib/"
	fi

    #由于source命令在shell脚本中是开启子shell执行，这里先用 export 令环境变量在本次登录生效，下次登录环境变量会自动生效
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
    sudo echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> ~/.bashrc

    sudo git clone https://github.com/Edward-Wu/srt-live-server.git
    cd srt-live-server
    sudo make
    yellow "===> 以默认配置文../sls.conf件启动sls"
    export LD_LIBRARY_PATH=/usr/local/lib/
    cd bin
    ./sls -c ../sls.conf
}

#安装srs
install_srs() {
    echo "===> Start to install srs"
    sudo git clone https://github.com/ossrs/srs
    cd srs/trunk
    sudo ./configure
    sudo make
    yellow "====> 以默认配置文件conf/rtmp.conf启动rtmp实例"
    ./objs/srs -c conf/rtmp.conf
}


#开始菜单
start_menu(){
    clear
    echo
    greenbg "=============================================================="
    greenbg "简介：一键部署srt、srt-live-server、srs服务                       "
    greenbg "适用范围(srt)：Centos、Ubuntu                                   "
    greenbg "适用范围(srs)：Centos、Ubuntu、Debian                           "
    greenbg "=============================================================="
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
    blue "srt直播(srt-live-transmit)测试"
    blue "默认以srt://YourIP:4200推流，srt://YourIP:4201拉流"
    blue "如果你使用的云服务器，请放行对应的安全组端口"
    srt-live-transmit srt://:4200 srt://:4201 -v
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