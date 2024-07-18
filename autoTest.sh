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
echo "${INFO_ICON}${BLUE} 程序开始运行"
# 检查是否有未提交的更改
if git status --porcelain | grep -q .; then
    echo "${WARNING_ICON}${YELLOW} 发现未提交的更改在当前分支$current_branch。${NC}"

    # 执行git add .
    echo "${INFO_ICON}${BLUE} 执行git add ."
    git add .
    
    # 执行git commit -m $current_branch...
    echo "${INFO_ICON}${BLUE} 执行git commit -m ${current_branch}...${NC}"
    git commit -m "$current_branch"
    
    # 执行git push
    echo "${INFO_ICON}${BLUE} 执行git push将分支${current_branch}推送到远程仓库...${NC}"
    if git push 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 执行git push失败,程序停止运行。${NC}"
        exit 1
    fi
    echo "${SUCCESS_ICON}${GREEN} 当前分支${current_branch}已成功提交并推送至远程仓库。${NC}"
fi
# 检查当前分支是否未提交到远程仓库
if [[ $(git status --porcelain -b) =~ ahead\ [0-9]+ ]]; then
    echo "${WARNING_ICON}${YELLOW} 发现当前分支${current_branch}未提交到远程。${NC}"
    # 执行git push
    echo "${INFO_ICON}${BLUE} 执行git push将分支${current_branch}推送到远程仓库...${NC}"
    if git push 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 执行git push失败,程序停止运行。${NC}"
        exit 1
    fi
    echo "${SUCCESS_ICON}${GREEN} 当前分支${current_branch}已成功提交并推送至远程仓库。${NC}"
fi

# 检查目标分支是否已经存在
if git show-ref --verify --quiet "refs/heads/$target_branch"; then
    echo "${INFO_ICON}${BLUE} 正在切换到${target_branch}分支...${NC}"
    if git checkout $target_branch 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 切换到test分支失败,程序停止运行。${NC}"
        exit 1
    fi

    echo "${INFO_ICON}${BLUE} 正在拉取test分支最新代码...${NC}"
    if git pull 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 执行git pull失败,程序停止运行。${NC}"
        exit 1
    fi
else
    echo "${ERROR_ICON}${RED} 目标分支 ${target_branch} 不存在, 程序停止运行${NC}"
    exit 1
fi

# 合并当前分支到目标分支
echo "${INFO_ICON}${BLUE} 正在将${current_branch}分支合并当前分支到 ${target_branch}...${NC}"
git merge $current_branch --no-ff

# 检查合并是否有冲突
merge_status=$(git status)
if echo "$merge_status" | grep -qE '(unmerged|both modified)'; then
    echo "${ERROR_ICON}${RED} 合并时发现冲突, 程序停止运行${NC}"
    exit 1
fi

# 提交合并结果
# git add .
# read -p "${CYAN}请输入合并提交的信息: ${NC}" merge_commit_message
# git commit -m "$merge_commit_message"

# 推送合并结果到远程仓库
echo "${INFO_ICON}${BLUE} 正在推送合并结果到远程仓库${target_branch}...${NC}"
if git push 2>&1 | grep -qE '(error|unmerged|both modified)'; then
    echo "${ERROR_ICON}${RED} 执行git push失败,程序停止运行。${NC}"
    exit 1
fi

echo "${SUCCESS_ICON}${GREEN} 合并结果已成功推送至远程仓库${target_branch}。${NC}"