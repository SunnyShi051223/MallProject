@echo off
echo 正在备份数据库...
mysqldump -u root -pshisannian1223 mall_b2c > D:\mall_b2c_backup.sql
echo 备份完成！
pause