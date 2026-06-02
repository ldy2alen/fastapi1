from datetime import datetime

from sqlalchemy import Integer, DateTime, ForeignKey, Text, Index
from sqlalchemy.orm import Mapped, mapped_column

from models.users import User
from models.favorite import Base


class AiChat(Base):
    """
    AI聊天记录表ORM模型
    """
    __tablename__ = 'ai_chat'

    __table_args__ = (
        Index('idx_ai_chat_created_at', 'created_at'),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="记录ID")
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey(User.id), nullable=False, comment="用户ID")
    message: Mapped[str] = mapped_column(Text, nullable=False, comment="用户消息")
    response: Mapped[str] = mapped_column(Text, nullable=False, comment="AI回复")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False, comment="创建时间")

    def __repr__(self):
        return f"<AiChat(id={self.id}, user_id={self.user_id}, created_at={self.created_at})>"
