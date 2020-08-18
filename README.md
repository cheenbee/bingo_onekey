# srt、sls、srs一键编译安装脚本
## 一键脚本使用

```
bash <(curl -L -s https://raw.githubusercontent.com/cheenbee/bingo_onekey/master/go.sh)
```

为了提升源码下载速度，脚本中使用srt、sls、srs仓库的gitee镜像克隆代码,请知悉.
srt示例：

```
sudo git clone https://gitee.com/cheenbee/srt.git
cd srt
sudo git remote set-url origin https://github.com/Haivision/srt.git && sudo git pull
```


## TODO
docker install srt、sls、srs