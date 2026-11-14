/**
 * Типы и интерфейсы модуля «Спортивный Гардероб» (MaxFunFit).
 */

export type WardrobeSection = 'Обувь' | 'Верх' | 'Низ' | 'Аксессуары';

export interface WardrobeItem {
  id: number;
  user_id: string;
  item_name: string;
  brand: string;
  category: WardrobeSection;
  image_url: string;
  source_url: string;
  price?: number;
  raw_category?: string;
  created_at?: string;
}

export interface AddWardrobeItemPayload {
  user_id?: string;
  item_name: string;
  brand: string;
  category?: string;
  image_url?: string;
  source_url?: string;
  price?: number;
  raw_category?: string;
}

export interface ApparelItem {
  id: number;
  sku_id?: string;
  title: string;
  product_name: string;
  brand: string;
  category: string;
  gender: string;
  price_current: number;
  price?: number;
  image_urls: string[];
  image_url?: string;
  source_url: string;
  source: string;
  rating?: number;
}

export interface ApparelSearchResponse {
  total: number;
  page: number;
  page_size: number;
  items: ApparelItem[];
}

export interface VisionDetected {
  brand?: string;
  model_name?: string;
  category?: string;
  subcategory?: string;
  confidence_score?: number;
  description?: string;
}

export interface VisionResponse {
  detected: VisionDetected;
  matched_product?: ApparelItem;
  similar_products: ApparelItem[];
  search_query_used: string;
  recognition_engine: string;
  note?: string;
}

export type GroupedWardrobe = Record<WardrobeSection, WardrobeItem[]>;

export interface GroupedWardrobeResponse {
  user_id: string;
  total_count: number;
  sections: GroupedWardrobe;
}
