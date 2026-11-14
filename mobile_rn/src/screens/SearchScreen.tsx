import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  Platform,
  RefreshControl,
  Linking,
} from 'react-native';
import { Search, Camera, X, Sparkles, Filter } from 'lucide-react-native';
import * as ImagePicker from 'expo-image-picker';

import { ApparelItem, WardrobeItem } from '../types';
import { parserApi } from '../api/parserApi';
import { wardrobeApi } from '../api/wardrobeApi';
import { ApparelCard } from '../components/ApparelCard';

interface SearchScreenProps {
  onItemAdded?: () => void;
  savedItemNames?: Set<string>;
}

const QUICK_FILTERS = ['Все', 'Обувь', 'Футболки', 'Куртки', 'Шорты', 'Тайтсы', 'Носки'];

export const SearchScreen: React.FC<SearchScreenProps> = ({
  onItemAdded,
  savedItemNames = new Set(),
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState('Все');
  const [items, setItems] = useState<ApparelItem[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isScanning, setIsScanning] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [addingId, setAddingId] = useState<number | null>(null);
  const [totalCount, setTotalCount] = useState<number>(0);
  const [scanResultNote, setScanResultNote] = useState<string | null>(null);

  // Выполнение поиска через API парсера
  const performSearch = useCallback(
    async (text: string, categoryFilter: string = selectedFilter) => {
      setIsLoading(true);
      try {
        const cat = categoryFilter === 'Все' ? undefined : categoryFilter;
        const response = await parserApi.searchApparel(text, cat, 1, 30);
        setItems(response.items || []);
        setTotalCount(response.total || 0);
      } catch (error) {
        Alert.alert(
          'Связь с парсером',
          'Не удалось получить данные от сервера парсера. Проверьте, запущен ли бэкенд на порту 8000.'
        );
      } finally {
        setIsLoading(false);
        setIsRefreshing(false);
      }
    },
    [selectedFilter]
  );

  // Первоначальная загрузка каталога
  useEffect(() => {
    performSearch('');
  }, []);

  // Переключение быстрых фильтров
  const handleSelectFilter = (filter: string) => {
    setSelectedFilter(filter);
    performSearch(searchQuery, filter);
  };

  // Очистка поиска
  const handleClearSearch = () => {
    setSearchQuery('');
    setScanResultNote(null);
    performSearch('', selectedFilter);
  };

  // Вызов камеры / сканера для визуального поиска по фото (ТЗ п. 2)
  const handleScanPhoto = async () => {
    try {
      // Запрос разрешений на камеру
      const permission = await ImagePicker.requestCameraPermissionsAsync();
      if (!permission.granted) {
        Alert.alert('Доступ к камере', 'Для сканирования экипировки необходим доступ к камере устройства.');
        return;
      }

      // Запуск камеры смартфона
      const result = await ImagePicker.launchCameraAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (result.canceled || !result.assets || result.assets.length === 0) {
        return;
      }

      const asset = result.assets[0];
      setIsScanning(true);
      setScanResultNote('ИИ анализирует снимок экипировки...');

      // Отправка в модуль AI Vision парсера
      const visionRes = await parserApi.recognizeByPhoto(
        asset.uri,
        'camera_photo.jpg',
        'image/jpeg'
      );

      const detected = visionRes.detected;
      const detectedName = detected.model_name || detected.brand || 'Найденная экипировка';
      setScanResultNote(`Распознано: ${detectedName} (${detected.brand || ''})`);

      // Объединяем сопоставленный товар и похожие товары
      const combinedResults: ApparelItem[] = [];
      if (visionRes.matched_product) {
        combinedResults.push(visionRes.matched_product);
      }
      if (visionRes.similar_products && visionRes.similar_products.length > 0) {
        combinedResults.push(...visionRes.similar_products);
      }

      if (combinedResults.length > 0) {
        setItems(combinedResults);
        setTotalCount(combinedResults.length);
      } else {
        // Если прямого совпадения нет, ищем по распознанному бренду/модели
        const query = detected.model_name || detected.brand || '';
        if (query) {
          setSearchQuery(query);
          await performSearch(query);
        }
      }
    } catch (err: any) {
      Alert.alert('Сканер экипировки', 'Ошибка при обработке фотографии: ' + (err.message || 'Сбой сети'));
      setScanResultNote(null);
    } finally {
      setIsScanning(false);
    }
  };

  // Добавление товара в гардероб (ТЗ п. 2)
  const handleAddToWardrobe = async (item: ApparelItem) => {
    setAddingId(item.id);
    try {
      await wardrobeApi.addToWardrobe({
        item_name: item.product_name || item.title,
        brand: item.brand,
        raw_category: item.category,
        image_url: item.image_url || (item.image_urls && item.image_urls[0]) || '',
        source_url: item.source_url,
        price: item.price_current || item.price || 0,
      });

      if (onItemAdded) {
        onItemAdded();
      }

      Alert.alert('Успешно', `«${item.product_name || item.title}» добавлено в ваш гардероб!`);
    } catch (err) {
      Alert.alert('Ошибка', 'Не удалось сохранить вещь в гардероб.');
    } finally {
      setAddingId(null);
    }
  };

  const handleOpenSource = (url: string) => {
    Linking.openURL(url).catch(() => {});
  };

  return (
    <View style={styles.container}>
      {/* Поисковая панель (Текстовый ввод + кнопка Сканера/Камеры) */}
      <View style={styles.searchBarContainer}>
        <View style={styles.inputWrapper}>
          <Search size={18} color="#94A3B8" />
          <TextInput
            style={styles.input}
            placeholder="Поиск по названию, бренду, SKU..."
            placeholderTextColor="#64748B"
            value={searchQuery}
            onChangeText={setSearchQuery}
            onSubmitEditing={() => performSearch(searchQuery)}
            returnKeyType="search"
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={handleClearSearch} style={styles.clearBtn}>
              <X size={16} color="#94A3B8" />
            </TouchableOpacity>
          )}
        </View>

        {/* Кнопка «Сканер / Поиск по фото» (ТЗ п. 2) */}
        <TouchableOpacity
          style={styles.scannerButton}
          onPress={handleScanPhoto}
          activeOpacity={0.8}
          accessibilityLabel="Сканер / Поиск экипировки по фото"
        >
          <Camera size={19} color="#FFFFFF" strokeWidth={2.2} />
          <Text style={styles.scannerBtnText}>Фото</Text>
        </TouchableOpacity>
      </View>

      {/* Горизонтальные чипы быстрой фильтрации */}
      <View style={styles.filterBar}>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={QUICK_FILTERS}
          keyExtractor={(item) => item}
          contentContainerStyle={styles.filterList}
          renderItem={({ item }) => {
            const isSelected = selectedFilter === item;
            return (
              <TouchableOpacity
                style={[styles.filterChip, isSelected && styles.filterChipActive]}
                onPress={() => handleSelectFilter(item)}
              >
                <Text style={[styles.filterChipText, isSelected && styles.filterChipTextActive]}>
                  {item}
                </Text>
              </TouchableOpacity>
            );
          }}
        />
      </View>

      {/* Оповещение об AI-сканировании */}
      {isScanning && (
        <View style={styles.scanningBanner}>
          <ActivityIndicator size="small" color="#FF6B00" />
          <Text style={styles.scanningText}>AI Vision распознает экипировку по фото...</Text>
        </View>
      )}

      {scanResultNote && !isScanning && (
        <View style={styles.noteBanner}>
          <Sparkles size={14} color="#38BDF8" />
          <Text style={styles.noteText}>{scanResultNote}</Text>
          <TouchableOpacity onPress={() => setScanResultNote(null)}>
            <X size={14} color="#94A3B8" />
          </TouchableOpacity>
        </View>
      )}

      {/* Счётчик результатов */}
      <View style={styles.metaRow}>
        <Text style={styles.resultsCount}>
          Найдено в каталоге: <Text style={styles.resultsCountBold}>{totalCount}</Text> товаров
        </Text>
      </View>

      {/* Сетка карточек товаров (ТЗ п. 2) */}
      {isLoading && !isRefreshing ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#3B82F6" />
          <Text style={styles.loadingText}>Запрос к бэкенду парсера...</Text>
        </View>
      ) : (
        <FlatList
          data={items}
          keyExtractor={(item) => String(item.id)}
          numColumns={2}
          contentContainerStyle={styles.gridContainer}
          refreshControl={
            <RefreshControl
              refreshing={isRefreshing}
              onRefresh={() => {
                setIsRefreshing(true);
                performSearch(searchQuery);
              }}
              tintColor="#3B82F6"
            />
          }
          renderItem={({ item }) => {
            const isSaved = savedItemNames.has(item.product_name || item.title);
            return (
              <ApparelCard
                item={item}
                isSaved={isSaved}
                isLoading={addingId === item.id}
                onAddToWardrobe={handleAddToWardrobe}
                onOpenSource={handleOpenSource}
              />
            );
          }}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyTitle}>Товары не найдены</Text>
              <Text style={styles.emptySub}>
                Попробуйте изменить поисковый запрос или сбросить фильтры
              </Text>
            </View>
          }
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0F172A',
  },
  searchBarContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 8,
    gap: 8,
  },
  inputWrapper: {
    flex: 1,
    height: 44,
    backgroundColor: '#1E293B',
    borderRadius: 12,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    borderWidth: 1,
    borderColor: '#334155',
  },
  input: {
    flex: 1,
    height: '100%',
    color: '#F8FAFC',
    fontSize: 14,
    marginLeft: 8,
  },
  clearBtn: {
    padding: 4,
  },
  scannerButton: {
    height: 44,
    paddingHorizontal: 14,
    backgroundColor: '#FF6B00',
    borderRadius: 12,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    shadowColor: '#FF6B00',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.35,
    shadowRadius: 5,
    elevation: 3,
  },
  scannerBtnText: {
    color: '#FFFFFF',
    fontSize: 13,
    fontWeight: '700',
  },
  filterBar: {
    paddingVertical: 6,
  },
  filterList: {
    paddingHorizontal: 16,
    gap: 8,
  },
  filterChip: {
    paddingHorizontal: 14,
    paddingVertical: 6,
    backgroundColor: '#1E293B',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#334155',
  },
  filterChipActive: {
    backgroundColor: '#3B82F6',
    borderColor: '#60A5FA',
  },
  filterChipText: {
    color: '#94A3B8',
    fontSize: 12,
    fontWeight: '600',
  },
  filterChipTextActive: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  scanningBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 107, 0, 0.15)',
    paddingHorizontal: 16,
    paddingVertical: 8,
    marginHorizontal: 16,
    borderRadius: 8,
    gap: 8,
    borderWidth: 1,
    borderColor: 'rgba(255, 107, 0, 0.4)',
    marginBottom: 6,
  },
  scanningText: {
    color: '#FDBA74',
    fontSize: 12,
    fontWeight: '600',
  },
  noteBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: 'rgba(56, 189, 248, 0.12)',
    paddingHorizontal: 14,
    paddingVertical: 8,
    marginHorizontal: 16,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: 'rgba(56, 189, 248, 0.3)',
    marginBottom: 6,
  },
  noteText: {
    color: '#BAE6FD',
    fontSize: 12,
    fontWeight: '600',
    flex: 1,
    marginHorizontal: 8,
  },
  metaRow: {
    paddingHorizontal: 16,
    paddingVertical: 4,
  },
  resultsCount: {
    color: '#64748B',
    fontSize: 12,
  },
  resultsCountBold: {
    color: '#E2E8F0',
    fontWeight: '700',
  },
  loadingContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 40,
  },
  loadingText: {
    color: '#94A3B8',
    fontSize: 13,
    marginTop: 10,
  },
  gridContainer: {
    paddingHorizontal: 10,
    paddingBottom: 24,
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 60,
    paddingHorizontal: 20,
  },
  emptyTitle: {
    color: '#F8FAFC',
    fontSize: 16,
    fontWeight: '700',
    marginBottom: 6,
  },
  emptySub: {
    color: '#64748B',
    fontSize: 13,
    textAlign: 'center',
  },
});
