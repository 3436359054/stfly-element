#!/bin/bash
# 脚本说明
# 功能:
# 把当前分支提交到今日上线分支(master-YYYYMMDD)

# 注意事项:
# 1. 如果今日上线分支不存在,那么会自动创建上线分支,分支名以master- 加上 当日日期
# 2. 当前分支存在未提交的更改,脚本会停止
# 3. 遇到冲突,网络中断等其他报错,脚本会给出提示并停止运行

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
target_branch="master-$current_date" # 目标分支
current_branch=$(git rev-parse --abbrev-ref HEAD) # 当前分支

echo "${SUCCESS_ICON}${GREEN} 程序开始运行"
echo "${SUCCESS_ICON}${GREEN} 当前分支为: ${current_branch}。${NC}"
echo "${SUCCESS_ICON}${GREEN} 今日上线分支为: ${target_branch}。${NC}"

# 检查是否有未提交的更改
if git status --porcelain | grep -q .; then
    echo "${INFO_ICON}${BLUE} 发现未提交的更改在当前分支 ${current_branch}。${NC}"
    echo "${ERROR_ICON}${RED} 程序停止运行${NC}"
    exit 1
fi

# 检查当前分支是否未提交到远程仓库
if [[ $(git status --porcelain -b) =~ ahead\ [0-9]+ ]]; then
    echo "${WARNING_ICON}${YELLOW} 发现当前分支未提交到远程。${NC}"
    echo "${ERROR_ICON}${RED} 程序停止运行${NC}"
    exit 1
fi

# 拉取最新代码
if git pull 2>&1 | grep -qE '(error|unmerged|both modified)'; then
    echo "${ERROR_ICON}${RED} 执行git pull失败,程序停止运行。${NC}"
    exit 1
fi

# 检查目标分支是否已经存在
if git show-ref --verify --quiet "refs/heads/$target_branch"; then
    echo "${INFO_ICON}${BLUE} 正在切换到今日上线分支 ${target_branch}...${NC}"
    if git checkout $target_branch 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 切换到 ${target_branch} 分支失败,程序停止运行。${NC}"
        exit 1
    fi

    echo "${INFO_ICON}${BLUE} 正在拉取今日上线分支 ${target_branch} 最新代码...${NC}"
    if git pull 2>&1 | grep -qE '(error|unmerged|both modified)'; then
        echo "${ERROR_ICON}${RED} 执行git pull失败,程序停止运行。${NC}"
        exit 1
    fi
else
    echo "${INFO_ICON}${BLUE} 今日上线分支 ${target_branch} 不存在，正在切换到develop分支...${NC}"
    if git show-ref --verify --quiet "refs/heads/develop"; then

        if git checkout develop 2>&1 | grep -qE '(error|unmerged|both modified)'; then
            echo "${ERROR_ICON}${RED} 切换到develop分支失败,程序停止运行。${NC}"
            exit 1
        fi
    
        echo "${INFO_ICON}${BLUE} 正在拉取develop分支最新代码...${NC}"
        if git pull 2>&1 | grep -qE '(error|unmerged|both modified)'; then
            echo "${ERROR_ICON}${RED} 执行git pull失败,程序停止运行。${NC}"
            exit 1
        fi
        
        echo "${INFO_ICON}${BLUE} 正在创建 ${target_branch} 分支...${NC}"
        if git checkout -b $target_branch 2>&1 | grep -qE '(error|unmerged|both modified)'; then
            echo "${ERROR_ICON}${RED} 创建分支失败,程序停止运行。${NC}"
            exit 1
        fi

        echo "${INFO_ICON}${BLUE} 正在将新分支 ${target_branch} 推送到远程仓库...${NC}"
        if git push --set-upstream origin $target_branch 2>&1 | grep -qE '(error|unmerged|both modified)'; then
            echo "${ERROR_ICON}${RED} 推送到远程仓库失败,程序停止运行。${NC}"
            exit 1
        fi

    else
        echo "${ERROR_ICON}${RED} develop不存在,程序停止运行。${NC}"
        exit 1
    fi
fi

# 合并当前分支到目标分支
echo "${INFO_ICON}${BLUE} 正在将 ${current_branch} 分支合并到今日上线分支 ${target_branch}...${NC}"
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
echo "${INFO_ICON}${BLUE} 正在推送合并结果到远程仓库 ${target_branch}...${NC}"
if git push 2>&1 | grep -qE 'error'; then
    echo "${ERROR_ICON}${RED} 执行git push失败,程序停止运行。${NC}"
    exit 1
fi

echo "${SUCCESS_ICON}${GREEN} 合并结果已成功推送至远程仓库 ${target_branch}。${NC}"