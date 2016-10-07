FROM centos:7

MAINTAINER Yasutaka Kawamoto



ARG APP_NAME=app

#************************************************************
# serviceコマンドを使えるようにする
######` service` コマンドが入ってないため、 `initscripts` をインストールする
####### centos7では `service` コマンドは使えるが、systemctlにリダイレクトされる
#### https://github.com/CentOS/sig-cloud-instance-images/issues/28#issuecomment-135513946
#************************************************************
RUN yum install -y sudo
# To avoid error: sudo: sorry, you must have a tty to run sudo
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

#************************************************************
# phpをインストール
#************************************************************

##### デフォルト以外のバージョンを使用したい場合は、リポジトリを追加してのインストール作業が必要になります。

### EPELとRemiリポジトリを追加します。

RUN yum -y install epel-release
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

### phpをインストール

RUN yum -y install --enablerepo=remi,remi-php70 php php-common  php-mbstring php-pdo php-gd php-xml php-mcrypt php-devel php-pear


#### ※php-develとphp-pearはzipをインストールするために必要

#### zip extensionをインストール
# peclでcコンパイラが見つからないって言われるので
RUN yum install -y make gcc zlib-devel
# として、
RUN pecl install zip

## php.iniに追加しなさいと言われるので、追加する
# You should add "extension=zip.so" to php.ini
# php.iniは/etc/php.iniにある
COPY templates/php.ini /etc/php.ini

#************************************************************
## mysqlのインストール
#************************************************************

RUN rpm -ivh  http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
RUN yum install -y mysql-community-server

RUN echo 'rootpass' | passwd --stdin mysql  

# urlは、mysqlの公式にあるRedhubLinux7用のダウンロードリンクをコピーした
# http://dev.mysql.com/downloads/repo/yum/

#************************************************************
# apacheのインストール
#************************************************************
RUN yum install -y httpd mod_ssl

#### mod_sslはhttpsを使うために必要
#### http://sterfield.co.jp/blog/development/vagrant%E3%81%A7%E3%82%AA%E3%83%AC%E3%82%AA%E3%83%AC%E8%A8%BC%E6%98%8E%E6%9B%B8%EF%BC%88self-signed-ssl-certificate%EF%BC%89-%E3%81%AE%E8%A8%AD%E5%AE%9A%E3%82%92%E8%A1%8C%E3%81%86/


#### apacheを起動
RUN chown -R apache:apache /var/www/ && \
	chmod -R 775 /var/www/

COPY templates/httpd.conf /etc/httpd/conf/httpd.conf
RUN  sed -i 's#DocumentRoot \"/var/www/html\"#DocumentRoot \"/var/www/'${APP_NAME}'/public\"#g' /etc/httpd/conf/httpd.conf

#************************************************************
# composerのインストール
# その後、PATHが遠ってるところに移動
#************************************************************
RUN curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer

RUN yum install -y git


#************************************************************
##  ユーザー追加
#************************************************************
####//    composerでlaravelをインストールするために必要

### dockerグループを追加
RUN groupadd docker 

###  docker ユーザーを新規追加してdockerグループに所属させる。-sはログインシェル
RUN useradd -g docker -d /home/docker -s /bin/bash docker 
###  実際にホームディレクトリは作成されないので、作成する
RUN chown docker:docker /home/docker

#************************************************************
# laravelのインストール
#************************************************************
### dockerユーザーに切り替える
# //    composerを実行するために必要
RUN sudo -u docker mkdir -p /home/docker/.composer/vendor/bin
RUN sudo -u docker /usr/local/bin/composer global require "laravel/installer"
RUN sudo -u docker echo 'export PATH=~/.composer/vendor/bin:$PATH' >> /home/docker/.bash_profile && \
	source /home/docker/.bash_profile


##### TODO:laravelプロジェクトをdockerfileで作成したい
##### 現状、下記エラーが出てしまう。
#####-------------------------------
#####
##### PHP Warning:  proc_open(/dev/tty): failed to open stream: No such device or address in /home/docker/.composer/vendor/symfony/process/Process.php on line 294
##### 
##### 
##### [Symfony\Component\Process\Exception\RuntimeException]  
#####   Unable to launch a new process.                         
##### 
##### 
##### new [--dev] [--5.2] [--] [<name>]
##### 
#************************************************************
# laravelプロジェクトを作成
#************************************************************
# RUN	su docker && \
# 	cd /var/www/ && \
# 	/home/docker/.composer/vendor/bin/laravel new $APP_NAME

#************************************************************
# サービスの起動
#************************************************************
# RUN httpd
RUN sudo -u mysql mysqld &

EXPOSE 80

## https://github.com/CentOS/sig-cloud-instance-images/issues/28#issuecomment-135513946
CMD ["/bin/bash"]


#************************************************************
# dockerコンテナ起動方法の例
#************************************************************
# % docker run --name="laravel" -p 8000:80 -d -v ~/docker/laravel-test/:/var/www -it kwmt/centos-laravel /bin/bash 
# % docker attach laravel
# root@57febdef38fb /]# su docker
# [docker@57febdef38fb /]$ cd /var/www/
# [docker@57febdef38fb www]$ source ~/.bash_profile 
# [docker@57febdef38fb www]$ laravel new app
# [docker@57febdef38fb www]$ exit
# [root@57febdef38fb /]# httpd
# 
# 
# 
# 