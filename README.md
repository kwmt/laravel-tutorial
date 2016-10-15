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



## チュートリアル

```
$ su docker
$ cd /var/www
## 
$ /usr/local/bin/composer create-project laravel/laravel quickstart --prefer-dist
$ cd quickstart/
$ /usr/local/bin/composer install
ポート80でListenさせたいので、rootでport80を指定する
$ exit
# php artisan serve --port=80 --host=172.17.0.2  

```

### 画面を作成

http://qiita.com/shosho/items/f34276561a342dc85180#3-%E3%83%AB%E3%83%BC%E3%83%88%E7%94%BB%E9%9D%A2%E3%81%AE%E4%BD%9C%E3%82%8A%E6%96%B9

までやる

### マイグレーション

http://qiita.com/shosho/items/f34276561a342dc85180#4-%E3%83%9E%E3%82%A4%E3%82%B0%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3

```
[root@57febdef38fb quickstart]# php artisan make:migration create_tasks_table --create=tasks
Created Migration: 2016_10_15_072416_create_tasks_table
```

