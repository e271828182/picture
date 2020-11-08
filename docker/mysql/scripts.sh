# for get config file
docker run --rm -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -it mysql:8.0.19
docker run --rm -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:8.0.19 cat /etc/mysql/conf.d/mysql.cnf > conf/mysql.cnf
echo -e "[mysqld]\nbind-address=0.0.0.0" >> conf/mysql.cnf

