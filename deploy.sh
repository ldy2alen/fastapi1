#!/bin/bash
# ============================================
# 服务器部署脚本 - 在 ECS 服务器上执行
# 使用方式: bash deploy.sh
# ============================================

set -e

echo "===== 开始部署新闻头条项目 ====="

# 1. 拉取最新代码
echo "[1/4] 拉取最新代码..."
git pull origin main

# 2. 构建 Docker 镜像
echo "[2/4] 构建 Docker 镜像..."
docker compose build --no-cache

# 3. 停止旧容器
echo "[3/4] 停止旧容器..."
docker compose down

# 4. 启动新容器
echo "[4/4] 启动新容器..."
docker compose up -d

echo ""
echo "===== 部署完成 ====="
echo "前端访问: http://你的服务器IP"
echo "后端API:  http://你的服务器IP:8000"
echo "API文档:  http://你的服务器IP:8000/docs"
echo ""
echo "查看日志: docker compose logs -f"
echo "停止服务: docker compose down"
