FROM python:3.11-slim

WORKDIR /app

# 换阿里云 Debian 镜像源（国内加速）
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources

# 安装系统依赖（asyncpg 编译需要）
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv 包管理器
RUN pip install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/ uv

# 复制依赖文件（从根目录）
COPY pyproject.toml uv.lock ./

# 使用阿里云 PyPI 镜像安装 Python 依赖
ENV UV_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/
RUN uv sync --no-dev --no-install-project

# 复制后端源码
COPY news-headline-backend/ ./

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
