from typing import List, Optional, Dict
from pydantic import BaseModel, ConfigDict
from datetime import datetime

class WardrobeItemBase(BaseModel):
    user_id: str = "user_default"
    item_name: str
    brand: str
    category: str # "Обувь", "Верх", "Низ", "Аксессуары"
    image_url: Optional[str] = None
    source_url: Optional[str] = None
    price: Optional[float] = 0.0
    raw_category: Optional[str] = None

class WardrobeItemCreate(BaseModel):
    user_id: Optional[str] = "user_default"
    item_name: str
    brand: str
    category: Optional[str] = None # Если не указана, вычислится через category_mapper
    image_url: Optional[str] = None
    source_url: Optional[str] = None
    price: Optional[float] = 0.0
    raw_category: Optional[str] = None

class WardrobeItemResponse(WardrobeItemBase):
    id: int
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class WardrobeGroupedResponse(BaseModel):
    user_id: str
    total_count: int
    sections: Dict[str, List[WardrobeItemResponse]]
