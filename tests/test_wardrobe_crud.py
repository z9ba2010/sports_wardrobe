import pytest
import os
import sys

# Ensure project root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from backend.database import Base
from backend.models.wardrobe import WardrobeItem
from backend.schemas.wardrobe import WardrobeItemCreate
from backend.crud.wardrobe import (
    create_wardrobe_item,
    get_wardrobe_items,
    get_wardrobe_item_by_id,
    get_wardrobe_grouped_by_category,
    delete_wardrobe_item,
    check_item_in_wardrobe
)
from backend.services.category_mapper import map_category_to_section

def test_category_mapping():
    assert map_category_to_section("Обувь") == "Обувь"
    assert map_category_to_section("Куртки (Мембраны)") == "Верх"
    assert map_category_to_section("Футболки") == "Верх"
    assert map_category_to_section("Шорты") == "Низ"
    assert map_category_to_section("Тайтсы") == "Низ"
    assert map_category_to_section("Носки") == "Аксессуары"
    assert map_category_to_section("Баффы (Гейтеры)") == "Аксессуары"
    assert map_category_to_section("Кепки / Козырьки") == "Аксессуары"

def test_wardrobe_crud_lifecycle():
    # Use in-memory SQLite for clean test
    engine = create_engine("sqlite:///:memory:", echo=False)
    Base.metadata.create_all(bind=engine)
    TestingSession = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = TestingSession()

    try:
        # 1. Create items in different sections
        item1 = create_wardrobe_item(db, WardrobeItemCreate(
            user_id="user_123",
            item_name="Nike Air Zoom Pegasus 40",
            brand="Nike",
            category="Обувь",
            image_url="https://example.com/pegasus.jpg",
            source_url="https://runlab.ru/pegasus",
            price=14990.0,
            raw_category="Обувь"
        ))
        assert item1.id is not None
        assert item1.category == "Обувь"
        assert item1.brand == "Nike"

        item2 = create_wardrobe_item(db, WardrobeItemCreate(
            user_id="user_123",
            item_name="Salomon Bonatti Pro WP",
            brand="Salomon",
            category="Верх",
            image_url="https://example.com/bonatti.jpg",
            source_url="https://runlab.ru/bonatti",
            price=19990.0,
            raw_category="Куртки (Мембраны)"
        ))
        assert item2.id is not None
        assert item2.category == "Верх"

        # 3. Auto-category mapping test
        item3 = create_wardrobe_item(db, WardrobeItemCreate(
            user_id="user_123",
            item_name="2XU Compression Tights",
            brand="2XU",
            image_url="https://example.com/2xu.jpg",
            source_url="https://runlab.ru/2xu",
            price=8990.0,
            raw_category="Тайтсы" # should auto-map to "Низ"
        ))
        assert item3.category == "Низ"

        # 4. Read by user
        all_items = get_wardrobe_items(db, user_id="user_123")
        assert len(all_items) == 3

        # 5. Read grouped by 4 sections
        grouped = get_wardrobe_grouped_by_category(db, user_id="user_123")
        assert "Обувь" in grouped and len(grouped["Обувь"]) == 1
        assert "Верх" in grouped and len(grouped["Верх"]) == 1
        assert "Низ" in grouped and len(grouped["Низ"]) == 1
        assert "Аксессуары" in grouped and len(grouped["Аксессуары"]) == 0

        # 6. Check duplicates
        found = check_item_in_wardrobe(db, "user_123", "Nike Air Zoom Pegasus 40", "Nike")
        assert found is not None
        assert found.id == item1.id

        # 7. Delete
        deleted = delete_wardrobe_item(db, item1.id, user_id="user_123")
        assert deleted is True

        remaining = get_wardrobe_items(db, user_id="user_123")
        assert len(remaining) == 2

    finally:
        db.close()

if __name__ == "__main__":
    test_category_mapping()
    test_wardrobe_crud_lifecycle()
    print("All Wardrobe CRUD and Category Mapper tests passed successfully!")
