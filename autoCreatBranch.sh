#!/bin/bash
# 脚本说明
# 功能:
# 从develop分支创建新分支

# 注意事项:
# 1. 可以在任意分支下执行,执行后自动跳转到新创建的分支
# 2. 遇到冲突,网络中断等其他报错,脚本会给出提示并停止运行

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

target_branch="develop" # 目标分支
current_branch=$(git rev-parse --abbrev-ref HEAD) # 当前分支

echo "${SUCCESS_ICON}${GREEN} 程序开始运行"
echo "${SUCCESS_ICON}${GREEN} 当前分支为:${current_branch}。${NC}"

# 检查是否有未提交的更改
if git status --porcelain | grep -q .; then
    echo "${INFO_ICON}${BLUE} 发现未提交的更改在当前分支(${current_branch})。${NC}"
    echo "${ERROR_ICON}${RED} 程序停止运行${NC}"
    exit 1
fi

# 检查当前分支是否未提交到远程仓库
if [[ $(git status --porcelain -b) =~ ahead\ [0-9]+ ]]; then
    echo "${WARNING_ICON}${YELLOW} 发现当前分支未提交到远程。${NC}"
    echo "${ERROR_ICON}${RED} 程序停止运行${NC}"
    exit 1
fi

# 检查目标分支develop是否已经存在
if git show-ref --verify --quiet "refs/heads/$target_branch"; then

    echo "${WARNING_ICON}${YELLOW} 目标分支 ${target_branch} 存在，正在切换到该分支。${NC}"
    if git checkout $target_branch 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 切换到develop分支失败,程序停止运行。${NC}"
        exit 1
    fi

    echo "${INFO_ICON}${BLUE} 正在拉取${target_branch}分支最新代码...${NC}"
    if git pull 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 执行git pull失败,程序停止运行。${NC}"
        exit 1
    fi
else
    echo "${INFO_ICON}${BLUE} 目标分支 ${target_branch} 不存在${NC}"
    exit 1
fi

read -p "请输入需要创建的分支名:" newBranch
if [ -z "$newBranch" ]; then
    echo "${ERROR_ICON}${RED}输入为空,程序停止运行${NC}"
    exit 1
fi

# 检查新创建的分支是否已经存在
if git show-ref --verify --quiet "refs/heads/$newBranch"; then
    echo "${WARNING_ICON}${YELLOW} 分支 ${newBranch} 已存在，正在切换到该分支。${NC}"
    if git checkout $newBranch 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 切换到${newBranch}分支失败,程序停止运行。${NC}"
        exit 1
    fi

    echo "${INFO_ICON}${BLUE} 正在拉取${newBranch}分支最新代码...${NC}"
    if git pull 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 执行git pull失败,程序停止运行。${NC}"
        exit 1
    fi

    echo "${SUCCESS_ICON}${GREEN} 拉取成功,程序执行完成${NC}"
    exit 1
fi

echo "${INFO_ICON}${BLUE}正在创建并切换到${newBranch}分支...${NC}"
if git checkout -b $newBranch 2>&1 | grep -qE '(error|unmerged|both modified)'; then
    echo "${ERROR_ICON}${RED} 创建分支失败,程序停止运行。${NC}"
    exit 1
fi

echo "${INFO_ICON}${BLUE} 正在将新分支 ${newBranch} 推送到远程仓库...${NC}"
if git push --set-upstream origin $newBranch 2>&1 | grep -qE '(error|unmerged|both modified)'; then
    echo "${ERROR_ICON}${RED} 推送到远程仓库失败,程序停止运行。${NC}"
    exit 1
fi

echo "${SUCCESS_ICON}${GREEN} 分支创建完成${NC}"