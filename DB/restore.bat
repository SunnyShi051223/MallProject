@echo off
echo 正在恢复数据库...
mysql -u root -pshisannian1223 mall_b2c < D:\mall_b2c_backup.sql
echo 恢复完成！
pause