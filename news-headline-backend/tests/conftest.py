import sys
import asyncio
from pathlib import Path

# Windows 下使用 SelectorEventLoop 避免 ProactorEventLoop 的已知问题
if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# 将 backend 目录加入 Python 路径
backend_dir = str(Path(__file__).resolve().parent.parent)
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

import pytest_asyncio
from httpx import AsyncClient, ASGITransport

from main import app


@pytest_asyncio.fixture
async def client():
    """创建异步测试客户端 - 每个测试独立的客户端"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
