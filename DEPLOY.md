# ECS 服务器部署指南

## 一、服务器环境准备

### 1. 安装 Docker
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Docker
curl -fsSL https://get.docker.com | sh

# 将当前用户加入 docker 组（免 sudo）
sudo usermod -aG docker $USER

# 重新登录后生效，或执行：
newgrp docker

# 验证安装
docker --version
```

### 2. 安装 Docker Compose
```bash
# 安装 docker compose 插件
sudo apt install docker-compose-plugin -y

# 验证
docker compose version
```

### 3. 安装 Git
```bash
sudo apt install git -y
```

---

## 二、部署项目

### 1. 克隆代码
```bash
git clone https://github.com/你的用户名/你的仓库名.git
cd 你的仓库名
```

### 2. 配置环境变量（可选）
```bash
# 如果需要修改默认密码等配置，创建 .env 文件
cat > .env << 'EOF'
POSTGRES_USER=postgres
POSTGRES_PASSWORD=你的安全密码
POSTGRES_DB=news_app
REDIS_PORT=6379
POSTGRES_PORT=5432
EOF
```

### 3. 一键启动
```bash
docker compose up -d
```

### 4. 导入数据库（首次部署）
```bash
# 等待 PostgreSQL 启动完成
sleep 10

# 导入初始数据
docker exec -i news-postgres psql -U postgres -d news_app < news-headline-backend/database_pg.sql
```

### 5. 验证服务
```bash
# 查看所有容器状态
docker compose ps

# 测试后端
curl http://localhost:8000/

# 测试前端
curl http://localhost/
```

---

## 三、常用运维命令

```bash
# 查看日志
docker compose logs -f              # 所有服务
docker compose logs -f backend      # 只看后端
docker compose logs -f frontend     # 只看前端

# 重启服务
docker compose restart              # 重启所有
docker compose restart backend      # 重启后端

# 更新部署
bash deploy.sh                      # 拉代码 + 重建 + 重启

# 停止服务
docker compose down

# 停止并删除数据（慎用）
docker compose down -v
```

---

## 四、安全组/防火墙配置

在云服务器控制台开放以下端口：

| 端口 | 用途 | 协议 |
|------|------|------|
| 22 | SSH 远程登录 | TCP |
| 80 | 前端网页访问 | TCP |
| 8000 | 后端 API（可选，调试用） | TCP |

> 生产环境建议：关闭 8000 端口的公网访问，前端通过 Nginx 反向代理访问后端 API。

---

## 五、常见问题

### Q: 数据库连接失败
```bash
# 检查 PostgreSQL 是否启动
docker compose ps postgres
docker compose logs postgres
```

### Q: 端口被占用
```bash
# 查看占用端口的进程
sudo lsof -i :80
sudo lsof -i :8000

# 修改 docker-compose.yml 中的端口映射
# 例如: "8080:80" 改用 8080 端口
```

### Q: 如何备份数据库
```bash
docker exec news-postgres pg_dump -U postgres news_app > backup_$(date +%Y%m%d).sql
```
