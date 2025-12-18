#!/bin/bash

echo "=========================================="
echo "New API 构建环境检查"
echo "=========================================="
echo ""

# 检查 Go
echo -n "检查 Go: "
if command -v go >/dev/null 2>&1; then
    GO_VERSION=$(go version | awk '{print $3}')
    echo "✓ 已安装 ($GO_VERSION)"
    
    # 检查 Go 版本是否符合要求 (>= 1.25.1)
    GO_MAJOR=$(echo $GO_VERSION | sed 's/go//' | cut -d. -f1)
    GO_MINOR=$(echo $GO_VERSION | sed 's/go//' | cut -d. -f2)
    GO_PATCH=$(echo $GO_VERSION | sed 's/go//' | cut -d. -f3 | cut -d- -f1)
    
    if [ "$GO_MAJOR" -gt 1 ] || ([ "$GO_MAJOR" -eq 1 ] && [ "$GO_MINOR" -gt 25 ]) || ([ "$GO_MAJOR" -eq 1 ] && [ "$GO_MINOR" -eq 25 ] && [ "$GO_PATCH" -ge 1 ]); then
        echo "  ✓ 版本符合要求 (>= 1.25.1)"
    else
        echo "  ✗ 版本不符合要求，需要 >= 1.25.1"
    fi
else
    echo "✗ 未安装"
    echo "  请访问 https://go.dev/dl/ 安装 Go"
fi

# 检查 bun
echo -n "检查 Bun: "
if command -v bun >/dev/null 2>&1; then
    BUN_VERSION=$(bun --version)
    echo "✓ 已安装 ($BUN_VERSION)"
else
    echo "✗ 未安装"
    echo "  安装命令: curl -fsSL https://bun.sh/install | bash"
fi

# 检查 Node.js (可选，但推荐)
echo -n "检查 Node.js: "
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo "✓ 已安装 ($NODE_VERSION)"
else
    echo "⚠ 未安装 (可选，但推荐)"
fi

# 检查 VERSION 文件
echo -n "检查 VERSION 文件: "
if [ -f "VERSION" ]; then
    VERSION=$(cat VERSION | tr -d '[:space:]')
    if [ -n "$VERSION" ]; then
        echo "✓ 存在 ($VERSION)"
    else
        echo "⚠ 存在但为空"
        echo "  建议设置版本号，例如: echo 'v0.4.0' > VERSION"
    fi
else
    echo "⚠ 不存在"
    echo "  建议创建: echo 'v0.4.0' > VERSION"
fi

# 检查 Go 模块
echo -n "检查 Go 模块: "
if [ -f "go.mod" ]; then
    echo "✓ go.mod 存在"
    MODULE_NAME=$(grep "^module" go.mod | awk '{print $2}')
    echo "  模块名: $MODULE_NAME"
else
    echo "✗ go.mod 不存在"
fi

# 检查前端配置
echo -n "检查前端配置: "
if [ -f "web/package.json" ]; then
    echo "✓ package.json 存在"
    if [ -f "web/bun.lock" ]; then
        echo "  ✓ bun.lock 存在"
    else
        echo "  ⚠ bun.lock 不存在，需要运行 bun install"
    fi
else
    echo "✗ package.json 不存在"
fi

# 检查构建产物目录
echo -n "检查构建产物: "
if [ -d "web/dist" ]; then
    echo "✓ web/dist 存在"
    DIST_SIZE=$(du -sh web/dist 2>/dev/null | awk '{print $1}')
    echo "  大小: $DIST_SIZE"
else
    echo "⚠ web/dist 不存在，需要先构建前端"
fi

if [ -f "new-api" ]; then
    echo "✓ new-api 可执行文件存在"
    BINARY_SIZE=$(ls -lh new-api 2>/dev/null | awk '{print $5}')
    echo "  大小: $BINARY_SIZE"
else
    echo "⚠ new-api 可执行文件不存在，需要构建后端"
fi

echo ""
echo "=========================================="
echo "检查完成"
echo "=========================================="

