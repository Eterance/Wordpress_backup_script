#!/bin/bash

vault_dir="/backup/backup_vault"

sudo mkdir -p  "$vault_dir"

echo "##########"
echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 开始备份，备份库路径：$vault_dir"


./archive_all.sh -d "/backup/backup_folder" -l "true" -m "12" -b "35"

echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 备份结束"
echo "##########"
echo ""