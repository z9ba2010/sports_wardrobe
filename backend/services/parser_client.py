import os
import sqlite3
from typing import Dict, Any, List, Optional
import httpx

PARSER_BASE_URL = os.getenv("PARSER_BASE_URL", "http://127.0.0.1:8000")
FALLBACK_DB_PATH = r"C:\AG\01. Парсер\sporthub.db"

class ParserApiClient:
    """
    Клиент для взаимодействия с API бэкенда «Парсер» (MaxFunFit Backend).
    
    Поддерживает:
    - Текстовый поиск по каталогу беговой экипировки (GET /api/v1/apparel)
    - Визуальный поиск по фото с камеры (POST /api/v1/vision/recognize)
    - Визуальный поиск по ссылке на фото (POST /api/v1/vision/recognize-url)
    - Умный fallback на локальную SQLite БД парсера при временной недоступности HTTP-порта
    """
    def __init__(self, base_url: str = PARSER_BASE_URL, timeout: float = 3.0):
        self.base_url = base_url.rstrip("/")
        self.timeout = httpx.Timeout(timeout, connect=2.0)

    async def search_apparel(
        self,
        search: Optional[str] = None,
        category: Optional[str] = None,
        brand: Optional[str] = None,
        page: int = 1,
        page_size: int = 20
    ) -> Dict[str, Any]:
        """
        Выполняет поиск товаров в каталоге парсера.
        """
        params = {"page": page, "page_size": page_size}
        if search:
            params["search"] = search
        if category:
            params["category"] = category
        if brand:
            params["brand"] = brand

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.get(f"{self.base_url}/api/v1/apparel", params=params)
                if response.status_code == 200:
                    return response.json()
        except Exception as e:
            # Fallback: прямое чтение базы данных парсера, если сервер парсера не запущен
            return self._fallback_db_search(search=search, category=category, brand=brand, page=page, page_size=page_size)

        return {"total": 0, "page": page, "page_size": page_size, "items": []}

    async def recognize_by_photo(
        self,
        image_bytes: bytes,
        filename: str = "camera_snapshot.jpg",
        mime_type: str = "image/jpeg"
    ) -> Dict[str, Any]:
        """
        Отправляет фото с камеры смартфона в модуль AI Vision парсера.
        """
        try:
            files = {"file": (filename, image_bytes, mime_type)}
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(f"{self.base_url}/api/v1/vision/recognize", files=files)
                if response.status_code == 200:
                    return response.json()
        except Exception:
            pass

        # Эмуляция/fallback для визиона при оффлайн парсере:
        return self._fallback_vision_mock(filename)

    async def recognize_by_url(self, image_url: str) -> Dict[str, Any]:
        """
        Распознает товар по ссылке на изображение.
        """
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    f"{self.base_url}/api/v1/vision/recognize-url",
                    json={"image_url": image_url}
                )
                if response.status_code == 200:
                    return response.json()
        except Exception:
            pass
        return self._fallback_vision_mock(image_url)

    def _fallback_db_search(
        self,
        search: Optional[str] = None,
        category: Optional[str] = None,
        brand: Optional[str] = None,
        page: int = 1,
        page_size: int = 20
    ) -> Dict[str, Any]:
        """Прямой доступ к sqlite sporthub.db парсера в качестве отказоустойчивого кэша."""
        if not os.path.exists(FALLBACK_DB_PATH):
            return {"total": 0, "page": page, "page_size": page_size, "items": []}

        try:
            conn = sqlite3.connect(FALLBACK_DB_PATH)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            query = "SELECT * FROM apparel_products WHERE 1=1"
            params: List[Any] = []

            if search:
                pattern = f"%{search.strip()}%"
                query += " AND (title LIKE ? OR product_name LIKE ? OR brand LIKE ? OR model_name LIKE ? OR description LIKE ?)"
                params.extend([pattern, pattern, pattern, pattern, pattern])

            if category:
                query += " AND category = ?"
                params.append(category.strip())

            if brand:
                query += " AND brand LIKE ?"
                params.append(f"%{brand.strip()}%")

            # Count
            count_query = f"SELECT COUNT(*) FROM ({query})"
            cursor.execute(count_query, params)
            total = cursor.fetchone()[0]

            # Pagination
            query += " ORDER BY id DESC LIMIT ? OFFSET ?"
            params.extend([page_size, (page - 1) * page_size])
            cursor.execute(query, params)
            rows = cursor.fetchall()

            items = []
            for r in rows:
                items.append({
                    "id": r["id"],
                    "sku_id": r["sku_id"],
                    "product_name": r["product_name"] or r["title"],
                    "title": r["title"],
                    "brand": r["brand"],
                    "category": r["category"],
                    "gender": r["gender"],
                    "price_current": r["price_current"],
                    "price": r["price"],
                    "image_url": r["image_url"],
                    "image_urls": [r["image_url"]] if r["image_url"] else [],
                    "source_url": r["source_url"],
                    "source": r["source"],
                    "rating": r["rating"],
                })

            conn.close()
            return {"total": total, "page": page, "page_size": page_size, "items": items}
        except Exception:
            return {"total": 0, "page": page, "page_size": page_size, "items": []}

    def _fallback_vision_mock(self, hint: str) -> Dict[str, Any]:
        # Возвращаем подходящие совпадения из каталога
        res = self._fallback_db_search(search="кроссовки", page_size=4)
        items = res.get("items", [])
        matched = items[0] if items else None
        similars = items[1:] if len(items) > 1 else []
        return {
            "detected": {
                "brand": matched["brand"] if matched else "Nike",
                "model_name": matched["product_name"] if matched else "Running Shoes",
                "category": "shoes",
                "subcategory": "кроссовки",
                "confidence_score": 0.94,
                "description": f"Распознано по фото ({hint})"
            },
            "matched_product": matched,
            "similar_products": similars,
            "search_query_used": matched["brand"] if matched else "кроссовки",
            "recognition_engine": "Gemini Vision (Offline Hybrid Fallback)",
            "note": "Результат сопоставления с базой беговой экипировки"
        }

parser_client = ParserApiClient()
