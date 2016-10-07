# Dockerfile-for-centos-laravel

## dockerコンテナ起動方法の例

```
% docker run --name="laravel" -p 8000:80 -d -v ~/docker/laravel-test/:/var/www -it kwmt/centos-laravel /bin/bash 
% docker attach laravel

# TODO: 下記はDockerfile内に持っていきたい
[root@57febdef38fb /]# su docker
[docker@57febdef38fb /]$ cd /var/www/
[docker@57febdef38fb www]$ source ~/.bash_profile 
[docker@57febdef38fb www]$ laravel new app
[docker@57febdef38fb www]$ exit
[root@57febdef38fb /]# httpd
```


