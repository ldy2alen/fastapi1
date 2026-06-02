from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from models.ai_chat import AiChat


async def save_chat(db: AsyncSession, user_id: int, message: str, response: str):
    chat = AiChat(user_id=user_id, message=message, response=response)
    db.add(chat)
    await db.commit()
    await db.refresh(chat)
    return chat


async def get_chat_history(db: AsyncSession, user_id: int, page: int = 1, page_size: int = 20):
    offset = (page - 1) * page_size

    count_query = select(func.count(AiChat.id)).where(AiChat.user_id == user_id)
    count_result = await db.execute(count_query)
    total = count_result.scalar_one()

    query = (select(AiChat)
             .where(AiChat.user_id == user_id)
             .order_by(AiChat.created_at.desc())
             .offset(offset).limit(page_size))

    result = await db.execute(query)
    rows = result.scalars().all()
    return rows, total
