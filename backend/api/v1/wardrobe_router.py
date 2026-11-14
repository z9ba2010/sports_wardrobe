from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, status
from sqlalchemy.orm import Session

from backend.database import get_db
from backend.schemas.wardrobe import (
    WardrobeItemCreate,
    WardrobeItemResponse,
    WardrobeGroupedResponse,
)
from backend.crud import wardrobe as crud_wardrobe
from backend.services.category_mapper import DEFAULT_SECTIONS
from backend.services.parser_client import parser_client

router = APIRouter(prefix="/wardrobe", tags=["Модуль: Спортивный Гардероб (MaxFunFit)"])

@router.get("", response_model=List[WardrobeItemResponse], summary="Список сохраненных вещей пользователя")
def get_user_wardrobe(
    user_id: str = Query("user_default", description="ID профиля пользователя"),
    category: Optional[str] = Query(None, description="Секция (Обувь, Верх, Низ, Аксессуары)"),
    db: Session = Depends(get_db)
):
    """
    Возвращает вещи из гардероба пользователя, опционально фильтруя по одной из 4 категорий.
    """
    return crud_wardrobe.get_wardrobe_items(db=db, user_id=user_id, category=category)

@router.get("/grouped", response_model=WardrobeGroupedResponse, summary="Гардероб, разбитый по 4 секциям")
def get_grouped_wardrobe(
    user_id: str = Query("user_default", description="ID профиля пользователя"),
    db: Session = Depends(get_db)
):
    """
    Возвращает гардероб пользователя, структурированный строго по 4 секциям:
    - Обувь
    - Верх
    - Низ
    - Аксессуары
    """
    grouped = crud_wardrobe.get_wardrobe_grouped_by_category(db=db, user_id=user_id)
    total_count = sum(len(items) for items in grouped.values())
    
    # Преобразуем SQLAlchemy модели в Pydantic
    serialized_sections = {
        sec: [WardrobeItemResponse.model_validate(it) for it in items]
        for sec, items in grouped.items()
    }
    
    return WardrobeGroupedResponse(
        user_id=user_id,
        total_count=total_count,
        sections=serialized_sections
    )

@router.post("", response_model=WardrobeItemResponse, status_code=status.HTTP_201_CREATED, summary="Добавить вещь в гардероб")
def add_item_to_wardrobe(
    item_in: WardrobeItemCreate,
    db: Session = Depends(get_db)
):
    """
    Сохраняет вещь из каталога парсера в персональный гардероб пользователя.
    Автоматически определяет секцию: Обувь, Верх, Низ или Аксессуары.
    """
    # Проверка на дубликаты
    existing = crud_wardrobe.check_item_in_wardrobe(
        db=db, 
        user_id=item_in.user_id or "user_default",
        item_name=item_in.item_name,
        brand=item_in.brand
    )
    if existing:
        return WardrobeItemResponse.model_validate(existing)

    item = crud_wardrobe.create_wardrobe_item(db=db, item_in=item_in)
    return WardrobeItemResponse.model_validate(item)

@router.delete("/{item_id}", summary="Удалить вещь из гардероба")
def remove_item_from_wardrobe(
    item_id: int,
    user_id: str = Query("user_default", description="ID пользователя"),
    db: Session = Depends(get_db)
):
    """Удаляет сохраненную вещь из профиля пользователя."""
    success = crud_wardrobe.delete_wardrobe_item(db=db, item_id=item_id, user_id=user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Элемент гардероба не найден или принадлежит другому пользователю"
        )
    return {"status": "success", "message": "Вещь успешно удалена из гардероба", "deleted_id": item_id}

@router.get("/parser/search", summary="Поиск экипировки через API Парсера")
async def search_parser_catalog(
    search: Optional[str] = Query(None, description="Текстовый запрос (Nike, ветровка, Pegasus...)"),
    category: Optional[str] = Query(None, description="Категория"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100)
):
    """
    Проксирует запрос к API внешнего проекта «Парсер» (/api/v1/apparel).
    """
    return await parser_client.search_apparel(search=search, category=category, page=page, page_size=page_size)

@router.post("/parser/scan", summary="Поиск по фото через AI Vision Парсера")
async def scan_by_photo(
    file: UploadFile = File(..., description="Фотография кроссовка или одежды с камеры смартфона")
):
    """
    Принимает фото с мобильной камеры и отправляет в сервис Vision парсера.
    """
    content = await file.read()
    return await parser_client.recognize_by_photo(
        image_bytes=content,
        filename=file.filename or "scan.jpg",
        mime_type=file.content_type or "image/jpeg"
    )
