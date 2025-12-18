# 检查所有必需工具
echo "Go 版本: $(go version 2>/dev/null || echo '未安装')"
echo "Bun 版本: $(bun --version 2>/dev/null || echo '未安装')"
echo "Node 版本: $(node --version 2>/dev/null || echo '未安装')"
echo "VERSION 文件: $(cat VERSION 2>/dev/null || echo '不存在或为空')"
