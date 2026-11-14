import asyncio
import os
import sys

# Ensure project root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from backend.services.parser_client import parser_client

async def main():
    print("Testing Parser Client...")
    
    # 1. Test search with text
    result = await parser_client.search_apparel(search="Nike", page_size=5)
    print(f"Text search results for 'Nike': total={result.get('total')}, items returned={len(result.get('items', []))}")
    assert len(result.get("items", [])) > 0
    first_item = result["items"][0]
    print(f"Sample item: {first_item.get('title')} ({first_item.get('brand')}) - {first_item.get('price_current')} RUB")

    # 2. Test search with category
    result_cat = await parser_client.search_apparel(category="Обувь", page_size=5)
    print(f"Category search 'Обувь': total={result_cat.get('total')}")
    assert len(result_cat.get("items", [])) > 0

    # 3. Test photo scan
    scan_res = await parser_client.recognize_by_photo(b"mock_jpeg_bytes", filename="shoe.jpg")
    print("Scan result detected:", scan_res.get("detected", {}).get("model_name"))
    assert "detected" in scan_res

    print("All Parser Client tests passed successfully!")

if __name__ == "__main__":
    asyncio.run(main())
