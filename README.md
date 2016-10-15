# Dockerfile-for-centos-laravel

## 事前準備

### VMが立ち上がっているか確認

```
% docker-machine ls                                                                                                 (git)-[master]
NAME      ACTIVE   DRIVER       STATE     URL   SWARM   DOCKER    ERRORS
default   -        virtualbox   Stopped                 Unknown  
```

```
% docker-machine start default
Starting "default"...
(default) Check network to re-create if needed...
(default) Waiting for an IP...
Machine "default" was started.
Waiting for SSH to be available...
Detecting the provisioner...
Started machines may have new IP addresses. You may need to re-run the `docker-machine env` command.

% docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
default   -        virtualbox   Running   tcp://192.168.99.100:2376           v1.12.1   
```

立ち上がってること確認

### macのターミナルでdockerコマンドが使えるように設定

```
% eval $(docker-machine env default)
```



## dockerコンテナ起動方法の例

```
% docker run --name="laravel" -p 8000:80 -d -v ~/docker/laravel-test/:/var/www -it kwmt/centos-laravel /bin/bash 
% docker attach laravel

※ もしすでにあるよって言われたら場合は `docker start laravel` でOK


# TODO: 下記はDockerfile内に持っていきたい
[root@57febdef38fb /]# su docker
[docker@57febdef38fb /]$ cd /var/www/
[docker@57febdef38fb www]$ source ~/.bash_profile 
[docker@57febdef38fb www]$ laravel new app
[docker@57febdef38fb www]$ exit
[root@57febdef38fb /]# httpd
```

## ブラウザで確認

% docker-machine ip
192.168.99.100

ブラウザに `http://192.168.99.100:8000` を入力

![Laravelトップ](https://raw.github.com/kwmt/laravel-tutorial/master/images/laravel-top.png)
