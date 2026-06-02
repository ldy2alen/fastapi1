import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_root(client: AsyncClient):
    """测试根路由返回 200"""
    response = await client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Hello World"


@pytest.mark.asyncio
async def test_docs(client: AsyncClient):
    """测试 API 文档可访问"""
    response = await client.get("/docs")
    assert response.status_code == 200
