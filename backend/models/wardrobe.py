from sqlalchemy import Column, Integer, String, Float, DateTime, Text
from datetime import datetime, timezone
from backend.database import Base

class WardrobeItem(Base):
    """
    Модель элемента гардероба пользователя.
    
    Соответствует требованиям ТЗ:
    - id: уникальный идентификатор записи
    - user_id: идентификатор владельца (профиль пользователя)
    - item_name: наименование вещи (модель/название)
    - brand: бренд (Nike, Adidas, Salomon, CEP и т.д.)
    - category: секция гардероба ('Обувь', 'Верх', 'Низ', 'Аксессуары')
    - image_url: ссылка на фото вещи
    - source_url: ссылка на страницу магазина / источника
    """
    __tablename__ = "wardrobe_items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(String(100), nullable=False, index=True)
    item_name = Column(String(255), nullable=False, index=True)
    brand = Column(String(100), nullable=False, index=True)
    category = Column(String(100), nullable=False, index=True) # Обувь | Верх | Низ | Аксессуары
    image_url = Column(Text, nullable=True)
    source_url = Column(Text, nullable=True)
    
    # Дополнительные полезные поля для аналитики гардероба
    raw_category = Column(String(100), nullable=True) # Исходная детальная категория из парсера
    price = Column(Float, nullable=True, default=0.0)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f"<WardrobeItem(id={self.id}, user_id='{self.user_id}', item_name='{self.item_name}', category='{self.category}')>"
