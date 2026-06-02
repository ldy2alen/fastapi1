# ========== 阶段1: 构建 ==========
FROM node:20-alpine AS builder

WORKDIR /app

# 先复制依赖文件，利用 Docker 缓存层
COPY package.json package-lock.json ./

# 使用国内 npm 镜像安装依赖
RUN npm config set registry https://registry.npmmirror.com && npm ci

# 复制源码
COPY . .

# 构建生产版本
RUN npm run build

# ========== 阶段2: 运行 ==========
FROM nginx:alpine

# 复制构建产物到 nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
