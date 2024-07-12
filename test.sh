#!/bin/bash

# 设置变量
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 检查是否有未提交的更改
if git status --porcelain | grep -q .; then
    echo "发现没提交的分支 '$current_branch'."
    echo "执行git add ."
    # 添加所有更改到暂存区
    git add .
    
    # 请求提交信息
    read -p "输入提交信息 $current_branch: " commit_message
    echo "执行git commit -m '$commit_message'"
    # 执行提交
    git commit -m "$commit_message"
    
    # 推送提交到远程仓库
    echo "执行git push'$commit_message'"
    git push $current_branch
else
    echo "没有发现需要提交的代码 '$current_branch'."
fi
