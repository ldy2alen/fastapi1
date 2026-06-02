import uuid
import pytest
from httpx import AsyncClient


@pytest.mark.integration
@pytest.mark.asyncio
async def test_register_success(client: AsyncClient):
    """测试用户注册成功"""
    username = f"reg_{uuid.uuid4().hex[:8]}"
    response = await client.post("/api/user/register", json={
        "username": username,
        "password": "test123456"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["code"] == 200
    assert "token" in data["data"]
    assert data["data"]["userInfo"]["username"] == username


@pytest.mark.integration
@pytest.mark.asyncio
async def test_login_wrong_password(client: AsyncClient):
    """测试密码错误登录失败"""
    username = f"wpwd_{uuid.uuid4().hex[:8]}"

    # 注册
    await client.post("/api/user/register", json={
        "username": username,
        "password": "correct123"
    })

    # 用错误密码登录
    response = await client.post("/api/user/login", json={
        "username": username,
        "password": "wrong123"
    })
    data = response.json()
    assert data["code"] != 200
