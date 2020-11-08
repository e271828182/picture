Install MySQL and mysqlclient:

```sh
# Assume you are activating Python 3 venv
$ brew install mysql
$ pip install mysqlclient
```

If you don't want to install MySQL server, you can use mysql-client instead:

```sh
# Assume you are activating Python 3 venv
$ brew install mysql-client
$ echo 'export PATH="/usr/local/opt/mysql-client/bin:$PATH"' >> ~/.bash_profile
$ export PATH="/usr/local/opt/mysql-client/bin:$PATH"
$ pip install mysqlclient
```

可以使用开源客户端 DBeaver 

vim /Applications/DBeaver.app/Contents/Eclipse/dbeaver.ini

加入

```ini
-vm
/Users/star/develop/java/jdk-8u261/Contents/Home/bin/java
```

