from typing import List, Optional, Dict
from sqlalchemy.orm import Session
from sqlalchemy import and_

from backend.models.wardrobe import WardrobeItem
from backend.schemas.wardrobe import WardrobeItemCreate
from backend.services.category_mapper import map_category_to_section, DEFAULT_SECTIONS

def create_wardrobe_item(db: Session, item_in: WardrobeItemCreate) -> WardrobeItem:
    """
    Добавляет элемент в гардероб пользователя.
    Автоматически сопоставляет категорию в одну из 4 секций:
    'Обувь', 'Верх', 'Низ', 'Аксессуары'.
    """
    raw_cat = item_in.raw_category or item_in.category or ""
    canonical_section = item_in.category
    
    # Если переданная категория не одна из 4 секций, нормализуем через маппер
    if canonical_section not in DEFAULT_SECTIONS:
        canonical_section = map_category_to_section(raw_cat, item_in.item_name)

    db_item = WardrobeItem(
        user_id=item_in.user_id or "user_default",
        item_name=item_in.item_name.strip(),
        brand=item_in.brand.strip(),
        category=canonical_section,
        image_url=item_in.image_url,
        source_url=item_in.source_url,
        price=item_in.price or 0.0,
        raw_category=raw_cat
    )
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

def get_wardrobe_items(
    db: Session, 
    user_id: str, 
    category: Optional[str] = None
) -> List[WardrobeItem]:
    """
    Получает список всех вещей пользователя или с фильтром по секции.
    """
    query = db.query(WardrobeItem).filter(WardrobeItem.user_id == user_id)
    if category and category.strip():
        query = query.filter(WardrobeItem.category == category.strip())
    return query.order_by(WardrobeItem.id.desc()).all()

def get_wardrobe_item_by_id(
    db: Session, 
    item_id: int, 
    user_id: Optional[str] = None
) -> Optional[WardrobeItem]:
    """Получает элемент гардероба по id."""
    query = db.query(WardrobeItem).filter(WardrobeItem.id == item_id)
    if user_id:
        query = query.filter(WardrobeItem.user_id == user_id)
    return query.first()

def get_wardrobe_grouped_by_category(
    db: Session, 
    user_id: str
) -> Dict[str, List[WardrobeItem]]:
    """
    Возвращает гардероб пользователя, структурированный по 4 секциям:
    - Обувь
    - Верх
    - Низ
    - Аксессуары
    """
    items = db.query(WardrobeItem).filter(WardrobeItem.user_id == user_id).order_by(WardrobeItem.id.desc()).all()
    grouped: Dict[str, List[WardrobeItem]] = {sec: [] for sec in DEFAULT_SECTIONS}
    
    for item in items:
        sec = item.category if item.category in grouped else map_category_to_section(item.category, item.item_name)
        if sec not in grouped:
            grouped[sec] = []
        grouped[sec].append(item)
        
    return grouped

def check_item_in_wardrobe(
    db: Session, 
    user_id: str, 
    item_name: str, 
    brand: str
) -> Optional[WardrobeItem]:
    """Проверяет, сохранена ли вещь с данным названием и брендом в гардеробе."""
    return db.query(WardrobeItem).filter(
        and_(
            WardrobeItem.user_id == user_id,
            WardrobeItem.item_name == item_name.strip(),
            WardrobeItem.brand == brand.strip()
        )
    ).first()

def delete_wardrobe_item(
    db: Session, 
    item_id: int, 
    user_id: Optional[str] = None
) -> bool:
    """Удаляет вещь из гардероба по id."""
    item = get_wardrobe_item_by_id(db, item_id, user_id)
    if not item:
        return False
    db.delete(item)
    db.commit()
    return True
