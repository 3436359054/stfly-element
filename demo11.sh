ERROR_ICON='✗'
RED='\033[0;31m'
NC='\033[0m'

if git push 2>&1 | grep -qE 'error'; then
    echo "${ERROR_ICON}${RED} 推送失败，请检查网络连接或权限。${NC}"
    exit 1
fi
echo "www"