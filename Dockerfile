FROM centos:7

MAINTAINER Yasutaka Kawamoto


## https://github.com/CentOS/sig-cloud-instance-images/issues/28#issuecomment-135513946
CMD ["/bin/bash"]

ARG APP_NAME=app
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
RUN yum install -y gcc
# として、
RUN pecl install zip

## php.iniに追加しなさいと言われるので、追加する
# You should add "extension=zip.so" to php.ini
# php.iniは/etc/php.iniにある
COPY templates/php.ini /etc/php.ini

#************************************************************
## mysqlのインストール・起動
#************************************************************

RUN rpm -ivh  http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
RUN yum install -y mysql-community-server

RUN service mysqld start

# urlは、mysqlの公式にあるRedhubLinux7用のダウンロードリンクをコピーした
# http://dev.mysql.com/downloads/repo/yum/

#************************************************************
# apacheのインストールと起動
#************************************************************
RUN yum install -y httpd mod_ssl

#### mod_sslはhttpsを使うために必要
#### http://sterfield.co.jp/blog/development/vagrant%E3%81%A7%E3%82%AA%E3%83%AC%E3%82%AA%E3%83%AC%E8%A8%BC%E6%98%8E%E6%9B%B8%EF%BC%88self-signed-ssl-certificate%EF%BC%89-%E3%81%AE%E8%A8%AD%E5%AE%9A%E3%82%92%E8%A1%8C%E3%81%86/


#### apacheを起動
######` service` コマンドが入ってないため、 `initscripts` をインストールする
####### centos7では `service` コマンドは使えるが、systemctlにリダイレクトされる
#### https://github.com/CentOS/sig-cloud-instance-images/issues/28#issuecomment-135513946

RUN yum install -y initscripts
RUN chown -R apache:apache /var/www/ && \
	chmod -R 775 /var/www/

COPY templates/httpd.conf /etc/httpd/conf/httpd.conf
RUN  sed -i 's#DocumentRoot \"/var/www/html\"#DocumentRoot \"/var/www/'${APP_NAME}'/public\"#g' /etc/httpd/conf/httpd.conf

RUN service httpd start
#************************************************************
# dockerコンテナ起動方法の例
#************************************************************
### % docker run --privileged --name="httpd"  -p 8000:80 -d -v ~/docker/laravel-test/volume:/home/docker/volume centos-apache-php-mysql /sbin/init
### % docker exec -it httpd /bin/bash
#####参考: http://qiita.com/yunano/items/9637ee21a71eba197345

#************************************************************
# composerのインストール
#************************************************************
# // PATHが遠ってるところに移動

RUN curl -sS https://getcomposer.org/installer | php \
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
RUN mkdir /home/docker && \
	chown docker:docker /home/docker


#************************************************************
# laravelのインストール
#************************************************************
### dockerユーザーに切り替える
# //    composerを実行するために必要
RUN su docker

RUN mkdir -p $HOME/.composer/vendor/bin && \
	composer global require "laravel/installer"


#// PATHを通す
RUN echo 'export PATH=~/.composer/vendor/bin:$PATH' >> ~/.bash_profile && \
	source ~/.bash_profile


WORKDIR /var/www/
RUN laravel new $APP_NAME




