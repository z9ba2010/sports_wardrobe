class CategoryMapper {
  static const List<String> sections = ['Обувь', 'Верх', 'Низ', 'Аксессуары'];

  static String mapToSection(String? category, {String title = ''}) {
    if (category == null || category.isEmpty) {
      return _mapFromTitle(title);
    }

    final cat = category.trim();

    // Прямое соответствие
    if (cat == 'Обувь' || cat.toLowerCase().contains('кроссов')) return 'Обувь';
    if (['Майки', 'Футболки', 'Лонгсливы', 'Термобелье', 'Кофты / Мидлееры', 'Жилеты', 'Ветровки', 'Куртки (Мембраны)', 'Куртки'].contains(cat)) {
      return 'Верх';
    }
    if (['Шорты', 'Тайтсы', 'Брюки'].contains(cat)) {
      return 'Низ';
    }
    if (['Носки', 'Гетры (Компрессия)', 'Нижнее белье / Спортивные бра', 'Перчатки', 'Баффы (Гейтеры)', 'Кепки / Козырьки', 'Повязки', 'Шапки'].contains(cat)) {
      return 'Аксессуары';
    }

    // Подстрочный поиск
    final l = cat.toLowerCase();
    if (l.contains('обув') || l.contains('shoes') || l.contains('кроссов')) return 'Обувь';
    if (l.contains('курт') || l.contains('ветров') || l.contains('футбол') || l.contains('майк') || l.contains('лонгслив') || l.contains('термо')) return 'Верх';
    if (l.contains('шорт') || l.contains('тайтс') || l.contains('брюк') || l.contains('штаны')) return 'Низ';
    if (l.contains('нос') || l.contains('гетр') || l.contains('бра') || l.contains('шапк') || l.contains('бафф') || l.contains('кепк')) return 'Аксессуары';

    return _mapFromTitle(title);
  }

  static String _mapFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('кроссов') || t.contains('shoes')) return 'Обувь';
    if (t.contains('куртк') || t.contains('ветров') || t.contains('футбол') || t.contains('майк') || t.contains('худи')) return 'Верх';
    if (t.contains('шорт') || t.contains('тайтс') || t.contains('брюк')) return 'Низ';
    return 'Аксессуары';
  }
}
