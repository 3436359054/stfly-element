#!/bin/bash
# 脚本说明
# 功能:
# 把当前分支提交到Test分支

# 注意事项
# 1. 当前分支存在未提交的更改会自动提交
# 2. 遇到冲突脚本会停止

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

target_branch="test" # 目标分支
current_branch=$(git rev-parse --abbrev-ref HEAD) # 当前分支

# 检查是否有未提交的更改
if git status --porcelain | grep -q .; then
    echo "${WARNING_ICON}${YELLOW} 发现未提交的更改在当前分支。${NC}"

    # 执行git add .
    echo "${INFO_ICON}${BLUE} 执行git add ."
    git add .
    
    # 执行git commit -m $current_branch...
    echo "${INFO_ICON}${BLUE} 执行git commit -m $current_branch...${NC}"
    git commit -m "$current_branch"
    
    # 执行git push
    echo "${INFO_ICON}${BLUE} 执行git push将分支($current_branch)推送到远程仓库...${NC}"
    git push
    echo "${SUCCESS_ICON}${GREEN} 当前分支($current_branch)已成功提交并推送至远程仓库。${NC}"
fi
# 检查当前分支是否未提交到远程仓库
git_status=$(git status --porcelain -b)
if [[ $git_status =~ ahead\ [0-9]+ ]]; then
    echo "${WARNING_ICON}${YELLOW} 发现当前分支未提交到远程。${NC}"
    # 执行git push
    echo "${INFO_ICON}${BLUE} 执行git push将分支($current_branch)推送到远程仓库...${NC}"
    git push
    echo "${SUCCESS_ICON}${GREEN} 当前分支($current_branch)已成功提交并推送至远程仓库。${NC}"
fi

# 检查目标分支是否已经存在
if git show-ref --verify --quiet "refs/heads/$target_branch"; then
    echo "${INFO_ICON}${BLUE} 目标分支 ${target_branch} 存在，正在切换并拉取最新代码。${NC}"
    git checkout $target_branch
    git pull
else
    echo "${ERROR_ICON}${RED} 目标分支 ${target_branch} 不存在。${NC}"
    exit 1
fi

# 合并当前分支到目标分支
echo "${INFO_ICON}${BLUE} 正在将${current_branch}分支合并当前分支到 ${target_branch}...${NC}"
git merge $current_branch --no-ff

# 检查合并是否有冲突
merge_status=$(git status)
if echo "$merge_status" | grep -qE '(unmerged|both modified)'; then
    echo "${ERROR_ICON}${RED} 合并时发现冲突, 脚本停止运行${NC}"
    exit 1
fi

# 提交合并结果
# git add .
# read -p "${CYAN}请输入合并提交的信息: ${NC}" merge_commit_message
# git commit -m "$merge_commit_message"

# 推送合并结果到远程仓库
echo "${INFO_ICON}${BLUE} 正在推送合并结果到远程仓库(${target_branch})...${NC}"
git push
echo "${SUCCESS_ICON}${GREEN} 合并结果已成功推送至远程仓库(${target_branch})。${NC}"