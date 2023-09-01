#!/bin/bash
# 自动备份脚本

vault_dir="/backup/backup_vault"
# 设置日志文件路径
log_file="/backup/backup_vault/log.txt"
# 重定向所有输出到控制台和日志文件
exec > >(tee -a "$log_file") 2>&1

# 备份命令
unit_name="wordpress_blog"
echo "###### [$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 开始备份 $unit_name"
sudo mkdir -p "$vault_dir/$unit_name/main"
sudo rsync -az --delete "/path/to/your/source/folder" "$vault_dir/$unit_name/main"
sudo mysqldump -uroot -proot_password --opt --databases db_name > "$vault_dir/$unit_name/main/db.sql"
sudo /usr/local/sbin/backup_script/archive_core.sh -d "$vault_dir/$unit_name" -m "12" -b "7"
# 加到这里
mysql -h "<远程数据库地址或IP>" -u "<远程数据库管理员用户名>" -p"<远程数据库管理员密码>" "<远程数据库名>" < "$vault_dir/$unit_name/main/db.sql"

echo "########## [$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 本次备份结束"
echo " "