from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field, ConfigDict


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    history: list[ChatMessage] = Field(default_factory=list)


class ChatHistoryItem(BaseModel):
    id: int
    message: str
    response: str
    created_at: datetime = Field(alias="createdAt")

    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True
    )


class ChatHistoryResponse(BaseModel):
    list: list[ChatHistoryItem]
    total: int
    has_more: bool = Field(alias="hasMore")

    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True
    )
