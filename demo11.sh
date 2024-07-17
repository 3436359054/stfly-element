if echo "$(git push)" | grep -qE 'error'; then 
    echo "${ERROR_ICON}${RED} 推送失败，请检查网络连接或权限。${NC}"
    exit 1
fi