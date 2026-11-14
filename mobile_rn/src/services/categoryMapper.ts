import { WardrobeSection } from '../types';

/**
 * Словарь сопоставления 20 категорий беговой экипировки в 4 секции гардероба.
 */
const SECTION_MAP: Record<string, WardrobeSection> = {
  // 1. Обувь
  'Обувь': 'Обувь',
  'Кроссовки': 'Обувь',
  'shoes': 'Обувь',
  'footwear': 'Обувь',

  // 2. Верх
  'Майки': 'Верх',
  'Футболки': 'Верх',
  'Лонгсливы': 'Верх',
  'Термобелье': 'Верх',
  'Кофты / Мидлееры': 'Верх',
  'Жилеты': 'Верх',
  'Ветровки': 'Верх',
  'Куртки (Мембраны)': 'Верх',
  'Куртки': 'Верх',
  'tops': 'Верх',

  // 3. Низ
  'Шорты': 'Низ',
  'Тайтсы': 'Низ',
  'Брюки': 'Низ',
  'bottoms': 'Низ',

  // 4. Аксессуары
  'Носки': 'Аксессуары',
  'Гетры (Компрессия)': 'Аксессуары',
  'Нижнее белье / Спортивные бра': 'Аксессуары',
  'Перчатки': 'Аксессуары',
  'Баффы (Гейтеры)': 'Аксессуары',
  'Кепки / Козырьки': 'Аксессуары',
  'Повязки': 'Аксессуары',
  'Шапки': 'Аксессуары',
  'accessories': 'Аксессуары',
};

export const WARDROBE_SECTIONS: WardrobeSection[] = ['Обувь', 'Верх', 'Низ', 'Аксессуары'];

export function mapCategoryToSection(category?: string, title: string = ''): WardrobeSection {
  if (category && SECTION_MAP[category]) {
    return SECTION_MAP[category];
  }

  const catLower = (category || '').toLowerCase();
  if (catLower.includes('обув') || catLower.includes('кроссов') || catLower.includes('shoe')) {
    return 'Обувь';
  }
  if (
    catLower.includes('майк') ||
    catLower.includes('футбол') ||
    catLower.includes('лонгслив') ||
    catLower.includes('термо') ||
    catLower.includes('кофт') ||
    catLower.includes('жилет') ||
    catLower.includes('ветров') ||
    catLower.includes('куртк')
  ) {
    return 'Верх';
  }
  if (catLower.includes('шорт') || catLower.includes('тайтс') || catLower.includes('брюк') || catLower.includes('штаны')) {
    return 'Низ';
  }
  if (
    catLower.includes('нос') ||
    catLower.includes('гетр') ||
    catLower.includes('бра') ||
    catLower.includes('перчат') ||
    catLower.includes('бафф') ||
    catLower.includes('кепк') ||
    catLower.includes('повяз') ||
    catLower.includes('шапк')
  ) {
    return 'Аксессуары';
  }

  // Fallback to title keywords
  const titleLower = title.toLowerCase();
  if (titleLower.includes('кроссов') || titleLower.includes('shoes')) return 'Обувь';
  if (titleLower.includes('куртк') || titleLower.includes('ветров') || titleLower.includes('футбол') || titleLower.includes('майк')) return 'Верх';
  if (titleLower.includes('шорт') || titleLower.includes('тайтс') || titleLower.includes('штаны')) return 'Низ';

  return 'Аксессуары';
}
