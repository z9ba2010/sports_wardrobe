"""
Сервис сопоставления категорий экипировки.

Маппит 20 детальных категорий из бэкенда-парсера в 4 основные секции гардероба:
1. Обувь
2. Верх
3. Низ
4. Аксессуары
"""
from typing import Dict, List, Literal

WardrobeSection = Literal["Обувь", "Верх", "Низ", "Аксессуары"]

# Карта детальных категорий в 4 главные секции
CATEGORY_TO_SECTION_MAP: Dict[str, WardrobeSection] = {
    # Обувь
    "Обувь": "Обувь",
    "Кроссовки": "Обувь",
    "shoes": "Обувь",
    "footwear": "Обувь",

    # Верх
    "Майки": "Верх",
    "Футболки": "Верх",
    "Лонгсливы": "Верх",
    "Термобелье": "Верх",
    "Кофты / Мидлееры": "Верх",
    "Жилеты": "Верх",
    "Ветровки": "Верх",
    "Куртки (Мембраны)": "Верх",
    "Куртки": "Верх",
    "tops": "Верх",
    "clothing": "Верх",

    # Низ
    "Шорты": "Низ",
    "Тайтсы": "Низ",
    "Брюки": "Низ",
    "bottoms": "Низ",

    # Аксессуары
    "Носки": "Аксессуары",
    "Гетры (Компрессия)": "Аксессуары",
    "Нижнее белье / Спортивные бра": "Аксессуары",
    "Перчатки": "Аксессуары",
    "Баффы (Гейтеры)": "Аксессуары",
    "Кепки / Козырьки": "Аксессуары",
    "Повязки": "Аксессуары",
    "Шапки": "Аксессуары",
    "accessories": "Аксессуары",
}

DEFAULT_SECTIONS: List[str] = ["Обувь", "Верх", "Низ", "Аксессуары"]

def map_category_to_section(category: str, item_name: str = "") -> WardrobeSection:
    """
    Определяет секцию гардероба по категории товара или названию.
    """
    if not category:
        category = ""
    
    cat_clean = category.strip()
    if cat_clean in CATEGORY_TO_SECTION_MAP:
        return CATEGORY_TO_SECTION_MAP[cat_clean]

    # Поиск по подстроке категории
    cat_lower = cat_clean.lower()
    if any(k in cat_lower for k in ["обув", "кроссов", "shoe", "sneaker"]):
        return "Обувь"
    if any(k in cat_lower for k in ["майк", "футбол", "лонгслив", "термо", "кофт", "жилет", "ветров", "куртк", "мембран", "top", "jacket"]):
        return "Верх"
    if any(k in cat_lower for k in ["шорт", "тайтс", "брюк", "штаны", "леггинс", "short", "pant", "tight"]):
        return "Низ"
    if any(k in cat_lower for k in ["нос", "гетр", "бра", "бель", "перчат", "бафф", "гейтер", "кепк", "козыр", "повяз", "шапк", "access"]):
        return "Аксессуары"

    # Запасной поиск по названию вещи
    name_lower = (item_name or "").lower()
    if any(k in name_lower for k in ["кроссов", "кед", "shoes", "shoe"]):
        return "Обувь"
    if any(k in name_lower for k in ["куртк", "ветров", "футбол", "майк", "худи", "лонгслив"]):
        return "Верх"
    if any(k in name_lower for k in ["шорт", "тайтс", "штаны", "брюк"]):
        return "Низ"
    if any(k in name_lower for k in ["нос", "шапк", "кепк", "бафф", "перчат"]):
        return "Аксессуары"

    return "Аксессуары"
