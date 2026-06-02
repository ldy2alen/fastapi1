import os
import json

import httpx
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.responses import StreamingResponse

from config.db_confing import get_db
from crud import ai_chat as ai_chat_crud
from models.users import User
from schemas.ai_chat import ChatRequest, ChatHistoryResponse, ChatHistoryItem
from utils.auth import get_current_user
from utils.response import success_response

router = APIRouter(prefix="/api/ai", tags=["ai"])

AI_API_ENDPOINT = os.environ.get("DASHSCOPE_API_ENDPOINT", "https://www.dreamfield.top/v1/chat/completions")
AI_API_KEY = os.environ.get("DASHSCOPE_API_KEY", "")
AI_MODEL = os.environ.get("DASHSCOPE_MODEL", "DeepSeek-V4-Flash")


@router.post("/chat")
async def chat(data: ChatRequest,
               user: User = Depends(get_current_user),
               db: AsyncSession = Depends(get_db)):
    """
    AI聊天 - SSE流式响应
    """
    if not AI_API_KEY:
        return {"code": 500, "message": "AI API Key 未配置"}

    # 构建消息列表
    messages = []
    # 添加历史对话上下文
    for msg in data.history:
        messages.append({"role": msg.role, "content": msg.content})
    # 添加当前用户消息
    messages.append({"role": "user", "content": data.message})

    async def generate():
        ai_response = ""

        async with httpx.AsyncClient(timeout=120.0) as client:
            async with client.stream(
                "POST",
                AI_API_ENDPOINT,
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {AI_API_KEY}",
                },
                json={
                    "model": AI_MODEL,
                    "messages": messages,
                    "stream": True,
                },
            ) as response:
                if response.status_code != 200:
                    error_body = await response.aread()
                    error_msg = json.dumps({"error": f"AI API 错误: {response.status_code}"})
                    yield f"data: {error_msg}\n\n"
                    return

                buffer = ""
                async for chunk in response.aiter_text():
                    buffer += chunk
                    while "\n" in buffer:
                        line, buffer = buffer.split("\n", 1)
                        line = line.strip()
                        if not line or not line.startswith("data: "):
                            continue
                        data_str = line[6:]
                        if data_str == "[DONE]":
                            yield "data: [DONE]\n\n"
                            continue
                        try:
                            json_data = json.loads(data_str)
                            content = (
                                json_data.get("choices", [{}])[0].get("delta", {}).get("content")
                                or json_data.get("output", {}).get("text")
                                or json_data.get("choices", [{}])[0].get("message", {}).get("content")
                                or ""
                            )
                            if content:
                                ai_response += content
                                yield f"data: {json.dumps({'content': content})}\n\n"
                        except json.JSONDecodeError:
                            continue

        # 流结束后保存到数据库
        if ai_response:
            try:
                await ai_chat_crud.save_chat(db, user.id, data.message, ai_response)
            except Exception:
                pass  # 保存失败不影响响应

    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/history")
async def get_chat_history(page: int = Query(1, ge=1),
                           page_size: int = Query(20, ge=1, le=100, alias="pageSize"),
                           user: User = Depends(get_current_user),
                           db: AsyncSession = Depends(get_db)):
    """
    获取聊天历史记录
    """
    rows, total = await ai_chat_crud.get_chat_history(db, user.id, page, page_size)
    has_more = total > page * page_size

    history_list = [ChatHistoryItem.model_validate(chat) for chat in rows]
    data = ChatHistoryResponse(list=history_list, total=total, hasMore=has_more)

    return success_response(data=data)
