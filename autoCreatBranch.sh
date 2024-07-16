#!/bin/bash
# 脚本说明
# 功能:
# 从develop分支创建新分支

# 注意事项:
# 可以在任意分支下执行,执行后自动跳转到新创建的分支

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
target_branch="develop" # 目标分支
current_branch=$(git rev-parse --abbrev-ref HEAD) # 当前分支

# 检查是否有未提交的更改
if git status --porcelain | grep -q .; then
    echo "${INFO_ICON}${BLUE} 发现未提交的更改在当前分支。${NC}"
    exit 1
fi

# 更新下分支
git pull

# 检查目标分支是否已经存在
if git show-ref --verify --quiet "refs/heads/$target_branch"; then
    echo "${INFO_ICON}${RED} 目标分支 ${target_branch} 已存在，正在切换到该分支。${NC}"
    git checkout $target_branch
    echo "${INFO_ICON}${BLUE} 正在拉取代码...${NC}"
    git pull
else
    echo "${INFO_ICON}${BLUE} 目标分支 ${target_branch} 不存在${NC}"
    exit 1
fi

read -p "请输入需要创建的分支名:" newBranch

if [ -z "$newBranch" ]; then
    echo "${ERROR_ICON}${RED}请输入分支名${NC}"
    exit 1
fi

# 检查新创建的分支是否已经存在
if git show-ref --verify --quiet "refs/heads/$newBranch"; then
    echo "${INFO_ICON}${RED} 分支 ${newBranch} 已存在，正在切换到该分支。${NC}"
    git checkout $newBranch
    echo "${INFO_ICON}${BLUE} 正在拉取代码...${NC}"
    git pull
    echo "${SUCCESS_ICON}${GREEN} 拉取成功,程序执行完成${NC}"
    exit 1
fi

echo "${INFO_ICON}${BLUE}正在创建${newBranch}分支...${NC}"
git checkout -b $newBranch
echo "${INFO_ICON}${BLUE} 正在将新分支 ${newBranch} 推送到远程仓库...${NC}"
git push --set-upstream origin $newBranch
echo "${SUCCESS_ICON}${GREEN} 分支创建完成${NC}"