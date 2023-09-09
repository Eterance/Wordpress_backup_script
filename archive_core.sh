#!/bin/bash

# 默认参数值
monthly_limit=12
daily_limit=35
manual_backup=false

# 解析参数
while getopts "d:m:b:n" opt; do
    case $opt in
        d) subfolder="$OPTARG";;
        m) monthly_limit="$OPTARG";;
        b) daily_limit="$OPTARG";;
        n) manual_backup=true;;
        \?) echo "无效的选项: -$OPTARG" >&2
            exit 1;;
        :) echo "选项 -$OPTARG 需要参数." >&2
            exit 1;;
    esac
done

if [ -z "$subfolder" ]; then
    echo "必须指定子文件夹路径：-d <路径>"
    exit 1
fi

echo "---------- [$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 正在处理：$subfolder"

main_folder="$subfolder/main"
if [ -d "$main_folder" ]; then  # 确保子文件夹内存在main文件夹
    # 创建archive文件夹
    archive_folder="$subfolder/archive"
    mkdir -p "$archive_folder"

    # 获取当前的UTC日期时间戳
    timestamp=$(date -u +"%Y%m%d%H%M%S")

    if [ "$manual_backup" = true ]; then
        # 手动备份，不执行任何数量检查
        manual_folder="$archive_folder/manual"
        mkdir -p "$manual_folder"
        new_filename="$manual_folder/$timestamp.tar.gz"
        tar -czpf "$new_filename" -C "$manual_folder" $main_folder
        echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 已将 $subfolder/main 文件夹打包为 $new_filename"
    else
        # 自动备份
        # 打包文件为日期时间戳格式
        new_filename="$archive_folder/$timestamp.tar.gz"
        tar -czpf "$new_filename" -C "$archive_folder" $main_folder
        echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 已将 $subfolder/main 文件夹打包为 $new_filename"

        # 从文件名中提取年、月、日信息
        year=${timestamp:0:4}
        month=${timestamp:4:2}
        day=${timestamp:6:2}

        # 在archive文件夹中创建yearly和monthly文件夹
        mkdir -p "$archive_folder/yearly"
        mkdir -p "$archive_folder/monthly"

        # 判断日期并进行复制
        if [ "$month" == "01" ] && [ "$day" == "01" ]; then
            yearly_copy="$archive_folder/yearly/$year$month$day.tar.gz"
            cp "$new_filename" "$yearly_copy"
            echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 已将 $new_filename 复制到 $yearly_copy"
        fi

        if [ "$day" == "01" ]; then
            monthly_copy="$archive_folder/monthly/$year$month$day.tar.gz"
            cp "$new_filename" "$monthly_copy"
            echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 已将 $new_filename 复制到 $monthly_copy"
        fi

        if [ "$daily_limit" -gt 0 ]; then
            # 检查和限制archive文件夹内的每日备份数量
            all_backups=("$archive_folder"/*.tar.gz)
            num_all_backups=${#all_backups[@]}
            if [ $num_all_backups -gt $daily_limit ]; then
                num_to_delete=$((num_all_backups - daily_limit))
                sorted_all_backups=($(ls -tr "$archive_folder"/*.tar.gz))
                for ((i = 0; i < num_to_delete; i++)); do
                    backup_to_delete=${sorted_all_backups[$i]}
                    rm "$backup_to_delete"
                    echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 已删除旧的每日备份副本：$backup_to_delete"
                done
            fi
        fi

        if [ "$monthly_limit" -gt 0 ]; then
            # 检查和限制archive文件夹内的月度备份数量
            monthly_backups=("$archive_folder/monthly"/*.tar.gz)
            num_monthly_backups=${#monthly_backups[@]}
            if [ $num_monthly_backups -gt $monthly_limit ]; then
                num_to_delete=$((num_monthly_backups - monthly_limit))
                sorted_monthly_backups=($(ls -tr "$archive_folder/monthly"/*.tar.gz))
                for ((i = 0; i < num_to_delete; i++)); do
                    monthly_backup_to_delete=${sorted_monthly_backups[$i]}
                    rm "$monthly_backup_to_delete"
                    echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 已删除旧的月度备份副本：$monthly_backup_to_delete"
                done
            fi
        fi
    fi
else
    echo "[$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 警告：$subfolder 中不存在 main 文件夹，跳过。"
fi
echo "---------- [$(date +'%Y-%m-%d %H:%M:%S UTC%:::z')] 结束处理：$subfolder"
echo ""
