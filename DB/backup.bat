@echo off
echo 正在备份数据库到当前目录...
:: 使用 "%~dp0" 获取当前 bat 文件所在路径
mysqldump -u root -pshisannian1223 mall_b2c > "%~dp0mall_b2c_backup.sql"
echo 备份完成！
pause