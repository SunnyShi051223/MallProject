@echo off
echo 正在从当前目录恢复数据库...
:: 使用 "%~dp0" 指向当前目录下的 sql 文件
mysql -u root -pshisannian1223 mall_b2c < "%~dp0mall_b2c_backup.sql"
echo 恢复完成！
pause