#!/bin/bash
# 自动备份vault文件夹中的所有子备份单元

# 默认参数值
monthly_limit=12
daily_limit=35

# 解析参数
while getopts "d:m:b:" opt; do
    case $opt in
        d) backup_folder="$OPTARG";;
        m) monthly_limit="$OPTARG";;
        b) daily_limit="$OPTARG";;
        \?) echo "无效的选项: -$OPTARG" >&2
            exit 1;;
        :) echo "选项 -$OPTARG 需要参数." >&2
            exit 1;;
    esac
done

if [ -z "$backup_folder" ]; then
    echo "必须指定子文件夹路径：-d <路径>"
    exit 1
fi
# 遍历remote_backup文件夹中的子文件夹
for subfolder in "$backup_folder"/*; do
    if [ -d "$subfolder" ]; then
        ./archive_core.sh -d "$subfolder" -m "$monthly_limit" -b "$daily_limit"
    fi
done