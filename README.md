# MaxFunFit — Модуль «Спортивный Гардероб» 👟🎽

Полнофункциональный модуль **«Спортивный Гардероб»** для мобильного приложения **MaxFunFit**, интегрированный по API с существующим бэкенд-проектом **«Парсер»** (каталог беговой экипировки, нормализатор брендов и AI Vision распознавание).

---

## 📱 Архитектура и реализованные требования ТЗ

### 1. Глобальная навигация (UI/UX)
- **Главный App Bar:** В верхнем правом углу размещена интерактивная иконка **«Профиль пользователя»** с бейджем количества сохраненных вещей.
- **Интерактив:** Нажатие на иконку открывает экран **«Мой гардероб»**.

### 2. Вкладка «Поиск одежды» (Интеграция с готовым Парсером)
- **Строка текстового поиска:** Поиск экипировки по названию модели, бренду или артикулу SKU с автозапросом к бэкенду парсера (`GET /api/v1/apparel`).
- **Кнопка «Сканер / Поиск по фото»:** Запуск камеры устройства для съемки кроссовка или экипировки. Фото отправляется в модуль компьютерного зрения парсера (`POST /api/v1/vision/recognize`).
- **Сетка карточек товаров:** Отображение результатов парсера (фото высокого разрешения, нормализованный бренд, наименование, цена в рублях).
- **Интерактивная кнопка «Добавить в гардероб»:** Сохраняет выбранную вещь в профиль пользователя, мгновенно меняя состояние кнопки на «В гардеробе ✓».

### 3. Экран «Мой гардероб» (Профиль)
- **Секционная структура:** Разделение экипировки строго по 4 обязательным секциям:
  1. 👟 **Обувь** (Кроссовки, шиповки, трейловая обувь)
  2. 👕 **Верх** (Майки, футболки, лонгсливы, термобелье, мидлееры, жилеты, ветровки, мембранные куртки)
  3. 🩳 **Низ** (Шорты, беговые тайтсы, брюки)
  4. 🧢 **Аксессуары** (Носки, компрессионные гетры, спортивные бра, перчатки, баффы/гейтеры, кепки, шапки)
- **Сетка карточек сохраненных вещей:** Просмотр, переход в магазин по ссылке `source_url` и удаление вещей.
- **Empty State:** При отсутствии вещей отображается заглушка *«Ваш гардероб пуст. Найдите и добавьте вещи»* с кнопкой перехода обратно в поиск.

---

## 🗄 Структура базы данных и модель `WardrobeItem`

Модель таблицы `wardrobe_items` реализована в соответствии с ТЗ:

```python
class WardrobeItem(Base):
    __tablename__ = "wardrobe_items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(String(100), nullable=False, index=True)
    item_name = Column(String(255), nullable=False, index=True)
    brand = Column(String(100), nullable=False, index=True)
    category = Column(String(100), nullable=False, index=True) # Обувь | Верх | Низ | Аксессуары
    image_url = Column(Text, nullable=True)
    source_url = Column(Text, nullable=True)
    
    # Дополнительные поля
    raw_category = Column(String(100), nullable=True) # Исходная категория парсера (напр. "Куртки (Мембраны)")
    price = Column(Float, default=0.0)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
```

---

## 🗺 Маппинг категорий (20 категорий парсера → 4 секции гардероба)

Сервис `backend/services/category_mapper.py` автоматически распределяет поступающие от парсера товары:

| Секция гардероба | Входящие категории из Парсера (20 категорий ТЗ) |
|---|---|
| 👟 **Обувь** | `Обувь`, `Кроссовки` |
| 👕 **Верх** | `Майки`, `Футболки`, `Лонгсливы`, `Термобелье`, `Кофты / Мидлееры`, `Жилеты`, `Ветровки`, `Куртки (Мембраны)` |
| 🩳 **Низ** | `Шорты`, `Тайтсы`, `Брюки` |
| 🧢 **Аксессуары** | `Носки`, `Гетры (Компрессия)`, `Нижнее белье / Спортивные бра`, `Перчатки`, `Баффы (Гейтеры)`, `Кепки / Козырьки`, `Повязки`, `Шапки` |

---

## 📂 Структура проекта

```
02. Спортивный Гардероб/
├── backend/                              # Бэкенд-сервис и CRUD модели (FastAPI + SQLAlchemy)
│   ├── database.py                       # Подключение к БД (SQLite / PostgreSQL)
│   ├── models/
│   │   └── wardrobe.py                   # Модель WardrobeItem
│   ├── schemas/
│   │   └── wardrobe.py                   # Pydantic схемы (Base, Create, Response, Grouped)
│   ├── crud/
│   │   └── wardrobe.py                   # CRUD операции (Create, Read, Group, Delete)
│   ├── services/
│   │   ├── category_mapper.py            # Маппинг 20 категорий -> 4 секции
│   │   └── parser_client.py              # Сетевой клиент к API парсера (search + vision)
│   ├── api/v1/
│   │   └── wardrobe_router.py            # REST эндпоинты гардероба
│   └── main.py                           # Главное FastAPI приложение
│
├── mobile_rn/                            # React Native / Expo (TypeScript) код приложения
│   ├── src/
│   │   ├── types/index.ts                # Интерфейсы WardrobeItem, ApparelItem, VisionResponse
│   │   ├── api/parserApi.ts              # Сетевой слой интеграции с Парсером
│   │   ├── api/wardrobeApi.ts            # Сетевой слой CRUD гардероба + оффлайн-кэш
│   │   ├── services/categoryMapper.ts    # Клиентский маппер категорий
│   │   ├── components/
│   │   │   ├── AppBar.tsx                # App Bar с иконкой профиля в верхнем правом углу
│   │   │   ├── ApparelCard.tsx           # Карточка товара с кнопкой "Добавить в гардероб"
│   │   │   ├── WardrobeCard.tsx          # Карточка сохраненной вещи
│   │   │   └── EmptyState.tsx            # Заглушка "Ваш гардероб пуст..."
│   │   ├── screens/
│   │   │   ├── SearchScreen.tsx          # Экран поиска (текст + камера + сетка товаров)
│   │   │   └── WardrobeScreen.tsx        # Экран гардероба по 4 секциям
│   │   └── navigation/AppNavigator.tsx   # Глобальная навигация между экранами
│   └── package.json
│
├── mobile_flutter/                       # Flutter (Dart) реализация мобильного модуля
│   ├── lib/
│   │   ├── models/                       # WardrobeItem, ApparelProduct
│   │   ├── services/                     # ParserApiService, WardrobeRepository, CategoryMapper
│   │   ├── widgets/                      # CustomAppBar, ProductCard, EmptyWardrobeView
│   │   └── screens/                      # SearchScreen, WardrobeScreen
│   └── pubspec.yaml
│
├── web_preview/                          # Интерактивный веб-симулятор мобильного интерфейса
│   ├── index.html                        # Мобильный фрейм (App Bar, Камера, Поиск, Гардероб)
│   └── server.py                         # Сервер для запуска интерактивного стенда
│
├── tests/
│   ├── test_wardrobe_crud.py             # Тесты CRUD модели WardrobeItem
│   └── test_parser_client.py             # Тесты клиента интеграции с парсером
│
└── README.md
```

---

## ⚡ Интеграция сетевого слоя (API методы)

### 1. Текстовый поиск (`parserApi.searchApparel` / `ParserApiService.searchApparel`):
- **Эндпоинт:** `GET http://127.0.0.1:8000/api/v1/apparel`
- **Параметры:** `search`, `category`, `page`, `page_size`
- **Ответ:** `ApparelListResponse` со списком `items`, содержащих `brand`, `title`, `price_current`, `image_urls`, `source_url`.

### 2. Визуальный поиск по фото (`parserApi.recognizeByPhoto` / `ParserApiService.recognizeByPhoto`):
- **Эндпоинт:** `POST http://127.0.0.1:8000/api/v1/vision/recognize`
- **Тело запроса:** `multipart/form-data` с полем `file` (снимок камеры смартфона).
- **Ответ:** `VisionRecognitionResponse` с распознанными признаками (`brand`, `model_name`), точным совпадением `matched_product` и массивом похожих товаров `similar_products`.

### 3. CRUD операции с гардеробом:
- `GET /api/v1/wardrobe/grouped?user_id=...` — получение вещей, сгруппированных по 4 секциям.
- `POST /api/v1/wardrobe` — сохранение найденного товара в базу данных.
- `DELETE /api/v1/wardrobe/{id}` — удаление вещи из профиля.

---

## 🚀 Запуск и проверка

### 1. Запуск интерактивного стенда мобильного интерфейса:
```bash
python "c:\AG\02. Спортивный Гардероб\web_preview\server.py"
```
После запуска откройте в браузере: **http://127.0.0.1:8080**
На экране появится мобильный симулятор MaxFunFit, в котором можно:
- Искать товары по тексту (обращается к базе парсера).
- Загрузить фото обуви для AI-сканирования.
- Нажимать «В гардероб» на любой карточке.
- Нажимать на иконку профиля в правом верхнем углу App Bar для перехода в «Мой гардероб».
- Переключаться между 4 секциями (Обувь, Верх, Низ, Аксессуары).
- Проверять состояние Empty State.

### 2. Запуск тестов CRUD и интеграции:
```bash
python "c:\AG\02. Спортивный Гардероб\tests\test_wardrobe_crud.py"
python "c:\AG\02. Спортивный Гардероб\tests\test_parser_client.py"
```
