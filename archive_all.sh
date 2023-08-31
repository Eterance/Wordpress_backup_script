#!/bin/bash

# 默认参数值
monthly_limit=12
daily_limit=35
enable_limit="true"

# 解析参数
while getopts "d:l:m:b:" opt; do
    case $opt in
        d) backup_folder="$OPTARG";;
        l) enable_limit="$OPTARG";;
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
        ./archive_core.sh -d "$subfolder" -l "$enable_limit" -m "$monthly_limit" -b "$daily_limit"
    fi
done