import AsyncStorage from '@react-native-async-storage/async-storage';
import { 
  WardrobeItem, 
  AddWardrobeItemPayload, 
  GroupedWardrobeResponse,
  GroupedWardrobe,
  WardrobeSection 
} from '../types';
import { mapCategoryToSection, WARDROBE_SECTIONS } from '../services/categoryMapper';

export const WARDROBE_API_BASE_URL = 'http://10.0.2.2:8001';
const LOCAL_STORAGE_KEY = '@maxfunfit_wardrobe_items';

class WardrobeApiClient {
  private baseUrl: string;

  constructor(baseUrl: string = WARDROBE_API_BASE_URL) {
    this.baseUrl = baseUrl.replace(/\/+$/, '');
  }

  public setBaseUrl(url: string) {
    this.baseUrl = url.replace(/\/+$/, '');
  }

  /**
   * Получает гардероб пользователя, структурированный по 4 секциям.
   * Пытается загрузить с сервера, при оффлайне — из локального хранилища.
   */
  async getGroupedWardrobe(userId: string = 'user_default'): Promise<GroupedWardrobeResponse> {
    try {
      const response = await fetch(`${this.baseUrl}/api/v1/wardrobe/grouped?user_id=${encodeURIComponent(userId)}`);
      if (response.ok) {
        const data: GroupedWardrobeResponse = await response.json();
        // Сохраняем свежий снимок в локальный кэш
        await this._saveToLocalStorage(data);
        return data;
      }
    } catch (err) {
      console.log('Backend offline, loading wardrobe from local storage:', err);
    }

    // Офлайн режим: читаем из локального кэша
    return await this._loadFromLocalStorage(userId);
  }

  /**
   * Добавляет найденный товар в гардероб пользователя.
   */
  async addToWardrobe(payload: AddWardrobeItemPayload): Promise<WardrobeItem> {
    const section = (payload.category as WardrobeSection) || mapCategoryToSection(payload.raw_category, payload.item_name);

    try {
      const response = await fetch(`${this.baseUrl}/api/v1/wardrobe`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_id: payload.user_id || 'user_default',
          item_name: payload.item_name,
          brand: payload.brand,
          category: section,
          image_url: payload.image_url,
          source_url: payload.source_url,
          price: payload.price || 0,
          raw_category: payload.raw_category,
        }),
      });

      if (response.ok) {
        const savedItem: WardrobeItem = await response.json();
        await this._appendToLocalStorage(savedItem);
        return savedItem;
      }
    } catch (e) {
      console.log('Saving item locally due to server offline');
    }

    // Сохранение локально (Offline-First)
    const localItem: WardrobeItem = {
      id: Date.now(),
      user_id: payload.user_id || 'user_default',
      item_name: payload.item_name,
      brand: payload.brand,
      category: section,
      image_url: payload.image_url || '',
      source_url: payload.source_url || '',
      price: payload.price || 0,
      raw_category: payload.raw_category,
      created_at: new Date().toISOString(),
    };

    await this._appendToLocalStorage(localItem);
    return localItem;
  }

  /**
   * Удаляет вещь из гардероба.
   */
  async removeFromWardrobe(itemId: number, userId: string = 'user_default'): Promise<boolean> {
    try {
      await fetch(`${this.baseUrl}/api/v1/wardrobe/${itemId}?user_id=${encodeURIComponent(userId)}`, {
        method: 'DELETE',
      });
    } catch (e) {
      console.log('Deleted locally:', e);
    }

    // Обновляем локальное хранилище
    const all = await this._loadRawLocalItems();
    const filtered = all.filter((it) => it.id !== itemId);
    await AsyncStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(filtered));
    return true;
  }

  // --- Хелперы локального хранилища ---

  private async _loadRawLocalItems(): Promise<WardrobeItem[]> {
    try {
      const raw = await AsyncStorage.getItem(LOCAL_STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  private async _appendToLocalStorage(item: WardrobeItem) {
    const list = await this._loadRawLocalItems();
    // Избегаем дубликатов по имени и бренду
    if (!list.some((i) => i.item_name === item.item_name && i.brand === item.brand)) {
      list.unshift(item);
      await AsyncStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(list));
    }
  }

  private async _saveToLocalStorage(data: GroupedWardrobeResponse) {
    const flat: WardrobeItem[] = [];
    Object.values(data.sections).forEach((arr) => flat.push(...arr));
    await AsyncStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(flat));
  }

  private async _loadFromLocalStorage(userId: string): Promise<GroupedWardrobeResponse> {
    const flat = await this._loadRawLocalItems();
    const sections: GroupedWardrobe = {
      'Обувь': [],
      'Верх': [],
      'Низ': [],
      'Аксессуары': [],
    };

    flat.forEach((item) => {
      const sec = WARDROBE_SECTIONS.includes(item.category) 
        ? item.category 
        : mapCategoryToSection(item.category, item.item_name);
      sections[sec].push(item);
    });

    return {
      user_id: userId,
      total_count: flat.length,
      sections,
    };
  }
}

export const wardrobeApi = new WardrobeApiClient();
