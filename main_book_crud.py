import datetime
from contextlib import asynccontextmanager

from sqlalchemy import func
from sqlalchemy.types import DateTime, Numeric, String
from sqlalchemy.ext.asyncio import create_async_engine,async_sessionmaker,AsyncSession
from sqlalchemy.orm import DeclarativeBase, Mapped, MappedColumn
from fastapi import FastAPI,Depends,HTTPException
from sqlalchemy import select
from pydantic import BaseModel
ASYNC_DATABASE_URL = "postgresql+asyncpg://postgres:zxc123456@localhost:5432/fastapi1"

async_engine = create_async_engine(
    ASYNC_DATABASE_URL,
    echo=True,
    pool_size=10,
    max_overflow=20
)


class Base(DeclarativeBase):
    create_time: Mapped[datetime.datetime] = MappedColumn(
        DateTime, default=func.now(), comment='创建时间'
    )
    update_time: Mapped[datetime.datetime] = MappedColumn(
        DateTime, default=func.now(), onupdate=func.now(), comment='更新时间'
    )


class Book(Base):
    __tablename__ = 'books'
    id: Mapped[int] = MappedColumn(primary_key=True)
    bookname: Mapped[str] = MappedColumn(String(100))
    author: Mapped[str] = MappedColumn(String(100))
    price: Mapped[float] = MappedColumn(Numeric(10, 2))
    publisher:Mapped[str]=MappedColumn(String(100))

async def create_table():
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

@asynccontextmanager
async def lifespan(_app: FastAPI):
    await create_table()
    yield

app = FastAPI(lifespan=lifespan)

Session_local=async_sessionmaker(
    bind=async_engine,   #数据库引擎
    class_=AsyncSession, #指定会话类
    expire_on_commit=False 
)

#依赖项目
async def get_database():
    async with Session_local() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

# @app.get("/book/books")
# async def get_book_list(db:AsyncSession=Depends(get_database)):
#     # result=await db.execute(select(Book))
#     # book=result.scalars().all()
#     # book=result.scalars().first()
#     book =await db.get(Book,2)
#     return book

# @app.get("/book/{id}")
# async def get_book_id(id:int,db:AsyncSession=Depends(get_database)):
#     result=await db.execute(select(Book).where(Book.id==id))
#     book=result.scalar_one_or_none()
#     return book

# @app.get("/book/get/serach")
# async def get_serach(db:AsyncSession=Depends(get_database)):
#     result=await db.execute(select(Book).where(Book.price>=50))
#     book=result.scalars().all()
#     return book

# @app.get("/book/serach_book")
# async def get_serach(db:AsyncSession=Depends(get_database)):
#     # result=await db.execute(select(Book).where(Book.author.like('张%')))
#     result=await db.execute(select(Book).where((Book.author.like('张%'))&(Book.price>50)))
#     book=result.scalars().all()
#     return book

# @app.get("/book/serach_book")
# async def get_serach(db:AsyncSession=Depends(get_database)):
#     #聚合查询
#     # result=await db.execute(select(func.count(Book.id)))
#     # result=await db.execute(select(func.avg(Book.price)))
#     # result=await db.execute(select(func.max(Book.price)))
#     result=await db.execute(select(func.sum(Book.price)))
#     book=result.scalar()  #提取标量值
#     return book


class BookBase(BaseModel):
    id: int
    bookname: str
    author: str
    price: float
    publisher: str

#增加
@app.post("/book/add_book")
async def get_serach(book:BookBase,db:AsyncSession=Depends(get_database)):
    book_obj=Book(**book.__dict__)
    db.add(book_obj)
    await db.commit()
    return book


class Book_update(BaseModel):
    bookname: str
    author: str
    price: float
    publisher: str

#更新
@app.put('/book/update/{book_id}')
async def update_book(book_id:int,book_update:Book_update,db:AsyncSession=Depends(get_database)):
    db_book=await db.get(Book,book_id)
    if not db_book:
        raise HTTPException(
            status_code=404,
            detail="查无此书"
        )
    
    #做赋值
    db_book.bookname = book_update.bookname
    db_book.author = book_update.author
    db_book.price = book_update.price
    db_book.publisher = book_update.publisher
    await db.commit()
    return db_book


@app.delete('/book/delete/{book_id}')
async def delete_book(book_id:int,db:AsyncSession=Depends(get_database)):
    db_book=await db.get(Book,book_id)
    if not db_book:
        raise HTTPException(
            status_code=404,
            detail="查无此书"
        )
    await db.delete(db_book)
    await db.commit()
    return {"message":"del 成功！"}