#!/bin/bash

# ANSI color codes for colored output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 图标
INFO_ICON="[*]"
WARNING_ICON="[!]"
SUCCESS_ICON="[✔]"
ERROR_ICON="[✗]"

# 获取当前日期，格式化为YYYYMMDD
current_date=$(date +%Y%m%d)
target_branch="master-$current_date"

# 检查是否有未提交的更改
if git status --porcelain | grep -q .; then
    echo "${INFO_ICON}${BLUE} 发现未提交的更改在当前分支。${NC}"
    git add .
    
    read -p "${CYAN}请输入提交信息（当前分支）: ${NC}" commit_message
    
    # 执行提交
    git commit -m "$commit_message"
    
    # 推送提交到远程仓库
    echo "${INFO_ICON}${BLUE} 正在推送当前分支到远程仓库...${NC}"
    git push $(git rev-parse --abbrev-ref HEAD)
    echo "${SUCCESS_ICON}${GREEN} 当前分支已成功提交并推送至远程仓库。${NC}"
else
    echo "${WARNING_ICON}${YELLOW} 当前分支上没有更改需要提交。${NC}"
fi

# 检查目标分支是否已经存在
if git show-ref --verify --quiet "refs/heads/$target_branch"; then
    echo "${INFO_ICON}${BLUE} 目标分支 ${target_branch} 已存在，正在切换并拉取最新代码。${NC}"
    git checkout $target_branch
    git pull $target_branch
else
    echo "${INFO_ICON}${BLUE} 目标分支 ${target_branch} 不存在，正在创建。${NC}"
    git checkout -b $target_branch
    echo "${INFO_ICON}${BLUE} 正在将新分支 ${target_branch} 推送到远程仓库。${NC}"
    git push $target_branch
fi

# 合并当前分支到目标分支
echo "${INFO_ICON}${BLUE} 正在合并当前分支到 ${target_branch}...${NC}"
git merge $(git rev-parse --abbrev-ref HEAD) -m "合并当前分支至 ${target_branch}"

# 检查合并是否有冲突
if git diff --name-only --diff-filter=U; then
    echo "${ERROR_ICON}${RED} 合并时发现冲突，请解决冲突后再继续。${NC}"
    exit 1
fi

# 提交合并结果
git add .
read -p "${CYAN}请输入合并提交的信息: ${NC}" merge_commit_message
git commit -m "$merge_commit_message"

# 推送合并结果到远程仓库
echo "${INFO_ICON}${BLUE} 正在推送合并结果到远程仓库...${NC}"
git push $target_branch
echo "${SUCCESS_ICON}${GREEN} 合并结果已成功推送至远程仓库。${NC}"