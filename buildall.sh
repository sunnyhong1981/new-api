#!/bin/bash

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 >/dev/null 2>&1; then
        print_error "$1 未安装，请先安装 $1"
        exit 1
    fi
}

print_step "开始构建 New API"

# 检查必需工具
print_info "检查构建工具..."
check_command go
check_command bun

# 检查 Go 版本
GO_VERSION=$(go version | awk '{print $3}')
print_info "Go 版本: $GO_VERSION"

# 处理 VERSION 文件
print_info "检查 VERSION 文件..."
if [ ! -f "VERSION" ] || [ ! -s "VERSION" ]; then
    print_warn "VERSION 文件为空或不存在，使用默认版本 v0.0.0"
    echo "v0.0.0" > VERSION
fi

VERSION=$(cat VERSION | tr -d '[:space:]')
print_info "构建版本: $VERSION"

# 步骤 1: 安装 Go 依赖
print_step "步骤 1: 安装 Go 依赖"
if [ ! -f "go.mod" ]; then
    print_error "go.mod 文件不存在"
    exit 1
fi

print_info "运行 go mod download..."
go mod download
if [ $? -eq 0 ]; then
    print_info "Go 依赖安装成功"
else
    print_error "Go 依赖安装失败"
    exit 1
fi

# 步骤 2: 构建前端
print_step "步骤 2: 构建前端"

if [ ! -f "web/package.json" ]; then
    print_error "web/package.json 文件不存在"
    exit 1
fi

cd web

# 安装前端依赖
print_info "安装前端依赖 (bun install)..."
bun install
if [ $? -ne 0 ]; then
    print_error "前端依赖安装失败"
    exit 1
fi

# 构建前端
print_info "构建前端 (bun run build)..."
print_info "环境变量: DISABLE_ESLINT_PLUGIN=true, VITE_REACT_APP_VERSION=$VERSION"
DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$VERSION bun run build

if [ $? -ne 0 ]; then
    print_error "前端构建失败"
    exit 1
fi

# 检查构建产物
if [ ! -d "dist" ]; then
    print_error "前端构建失败，dist 目录不存在"
    exit 1
fi

DIST_SIZE=$(du -sh dist 2>/dev/null | awk '{print $1}')
print_info "前端构建成功，产物大小: $DIST_SIZE"

cd ..

# 步骤 3: 构建后端
print_step "步骤 3: 构建后端"

# 检查前端构建产物是否存在
if [ ! -d "web/dist" ]; then
    print_error "前端构建产物 web/dist 不存在，无法继续构建后端"
    exit 1
fi

print_info "编译 Go 程序..."
print_info "构建参数: -ldflags \"-s -w -X 'github.com/QuantumNous/new-api/common.Version=$VERSION'\""

go build -ldflags "-s -w -X 'github.com/QuantumNous/new-api/common.Version=$VERSION'" -o new-api main.go

if [ $? -ne 0 ]; then
    print_error "后端构建失败"
    exit 1
fi

# 检查构建产物
if [ ! -f "new-api" ]; then
    print_error "后端构建失败，new-api 可执行文件不存在"
    exit 1
fi

BINARY_SIZE=$(ls -lh new-api 2>/dev/null | awk '{print $5}')
print_info "后端构建成功，可执行文件大小: $BINARY_SIZE"

# 显示构建信息
print_step "构建完成"
echo ""
print_info "构建产物:"
echo "  - 可执行文件: ./new-api"
echo "  - 前端资源: ./web/dist"
echo ""
print_info "版本信息: $VERSION"
print_info "文件大小: $BINARY_SIZE"
echo ""
print_info "运行方式: ./new-api"
print_info "或指定端口: ./new-api --port 3000"
