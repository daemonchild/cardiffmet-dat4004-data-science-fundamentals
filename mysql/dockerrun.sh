
docker volume create dat4004-mysql-data
docker run -d --name dat4004-mysql -p 43306:3306 -v dat4004-mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=NotAPassw0rd! mysql:latest

