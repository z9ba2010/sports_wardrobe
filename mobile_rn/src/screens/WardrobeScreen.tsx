import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  RefreshControl,
  ScrollView,
} from 'react-native';
import { ArrowLeft, Sparkles, Layers } from 'lucide-react-native';

import { WardrobeItem, WardrobeSection, GroupedWardrobe } from '../types';
import { wardrobeApi } from '../api/wardrobeApi';
import { WardrobeCard } from '../components/WardrobeCard';
import { EmptyState } from '../components/EmptyState';

interface WardrobeScreenProps {
  userId?: string;
  onNavigateToSearch: () => void;
  onGoBack?: () => void;
}

const SECTIONS_CONFIG: { key: WardrobeSection; title: string; icon: string }[] = [
  { key: 'Обувь', title: 'Обувь', icon: '👟' },
  { key: 'Верх', title: 'Верх', icon: '👕' },
  { key: 'Низ', title: 'Низ', icon: '🩳' },
  { key: 'Аксессуары', title: 'Аксессуары', icon: '🧢' },
];

export const WardrobeScreen: React.FC<WardrobeScreenProps> = ({
  userId = 'user_default',
  onNavigateToSearch,
  onGoBack,
}) => {
  const [activeSection, setActiveSection] = useState<WardrobeSection>('Обувь');
  const [groupedWardrobe, setGroupedWardrobe] = useState<GroupedWardrobe>({
    'Обувь': [],
    'Верх': [],
    'Низ': [],
    'Аксессуары': [],
  });
  const [totalItems, setTotalItems] = useState<number>(0);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isRefreshing, setIsRefreshing] = useState<boolean>(false);

  // Загрузка гардероба пользователя
  const loadWardrobe = useCallback(async () => {
    try {
      const data = await wardrobeApi.getGroupedWardrobe(userId);
      setGroupedWardrobe(data.sections);
      setTotalItems(data.total_count);

      // Если в текущей секции 0 вещей, но есть вещи в других — переключаем на первую непустую
      if (
        data.sections[activeSection]?.length === 0 &&
        data.total_count > 0
      ) {
        const firstNonEmpty = SECTIONS_CONFIG.find(
          (sec) => (data.sections[sec.key]?.length || 0) > 0
        );
        if (firstNonEmpty) {
          setActiveSection(firstNonEmpty.key);
        }
      }
    } catch (err) {
      console.warn('Error loading wardrobe:', err);
    } finally {
      setIsLoading(false);
      setIsRefreshing(false);
    }
  }, [userId, activeSection]);

  useEffect(() => {
    loadWardrobe();
  }, [loadWardrobe]);

  // Удаление вещи из гардероба
  const handleRemoveItem = (itemId: number) => {
    Alert.alert(
      'Удалить из гардероба?',
      'Вы действительно хотите убрать эту вещь из вашего профиля?',
      [
        { text: 'Отмена', style: 'cancel' },
        {
          text: 'Удалить',
          style: 'destructive',
          onPress: async () => {
            // Оптимистичное обновление UI
            setGroupedWardrobe((prev) => {
              const updated = { ...prev };
              for (const key of Object.keys(updated) as WardrobeSection[]) {
                updated[key] = updated[key].filter((i) => i.id !== itemId);
              }
              return updated;
            });
            setTotalItems((prev) => Math.max(0, prev - 1));

            try {
              await wardrobeApi.removeFromWardrobe(itemId, userId);
            } catch {
              loadWardrobe();
            }
          },
        },
      ]
    );
  };

  const currentSectionItems = groupedWardrobe[activeSection] || [];

  return (
    <View style={styles.container}>
      {/* Верхний заголовок экрана профиля */}
      <View style={styles.header}>
        {onGoBack && (
          <TouchableOpacity onPress={onGoBack} style={styles.backButton}>
            <ArrowLeft size={22} color="#FFFFFF" />
          </TouchableOpacity>
        )}
        <View style={styles.headerTitleWrap}>
          <Text style={styles.headerTitle}>Мой гардероб</Text>
          <Text style={styles.headerSubtitle}>
            Всего сохранено: <Text style={styles.highlightText}>{totalItems}</Text> вещей
          </Text>
        </View>
      </View>

      {/* Проверка на пустой гардероб (Empty State п. 3 ТЗ) */}
      {isLoading && !isRefreshing ? (
        <View style={styles.centerContainer}>
          <ActivityIndicator size="large" color="#3B82F6" />
          <Text style={styles.loadingText}>Загрузка гардероба...</Text>
        </View>
      ) : totalItems === 0 ? (
        <EmptyState onNavigateToSearch={onNavigateToSearch} />
      ) : (
        <>
          {/* Секционная навигация по 4 категориям (Обувь, Верх, Низ, Аксессуары) */}
          <View style={styles.sectionTabsWrapper}>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.sectionTabs}
            >
              {SECTIONS_CONFIG.map((sec) => {
                const count = groupedWardrobe[sec.key]?.length || 0;
                const isActive = activeSection === sec.key;
                return (
                  <TouchableOpacity
                    key={sec.key}
                    style={[styles.sectionTab, isActive && styles.sectionTabActive]}
                    onPress={() => setActiveSection(sec.key)}
                    activeOpacity={0.7}
                  >
                    <Text style={styles.tabIcon}>{sec.icon}</Text>
                    <Text style={[styles.tabTitle, isActive && styles.tabTitleActive]}>
                      {sec.title}
                    </Text>
                    <View style={[styles.badge, isActive && styles.badgeActive]}>
                      <Text style={[styles.badgeText, isActive && styles.badgeTextActive]}>
                        {count}
                      </Text>
                    </View>
                  </TouchableOpacity>
                );
              })}
            </ScrollView>
          </View>

          {/* Сетка сохраненных вещей в выбранной секции (ТЗ п. 3) */}
          {currentSectionItems.length === 0 ? (
            <View style={styles.emptySectionContainer}>
              <Text style={styles.emptySectionIcon}>
                {SECTIONS_CONFIG.find((s) => s.key === activeSection)?.icon}
              </Text>
              <Text style={styles.emptySectionTitle}>
                В секции «{activeSection}» пока ничего нет
              </Text>
              <TouchableOpacity
                style={styles.findMoreBtn}
                onPress={onNavigateToSearch}
              >
                <Text style={styles.findMoreText}>Найти в поиске</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <FlatList
              data={currentSectionItems}
              keyExtractor={(item) => String(item.id)}
              numColumns={2}
              contentContainerStyle={styles.gridContainer}
              refreshControl={
                <RefreshControl
                  refreshing={isRefreshing}
                  onRefresh={() => {
                    setIsRefreshing(true);
                    loadWardrobe();
                  }}
                  tintColor="#3B82F6"
                />
              }
              renderItem={({ item }) => (
                <WardrobeCard item={item} onRemove={handleRemoveItem} />
              )}
            />
          )}
        </>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0F172A',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: '#1E293B',
  },
  backButton: {
    marginRight: 12,
    padding: 4,
  },
  headerTitleWrap: {
    flex: 1,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '800',
    color: '#F8FAFC',
    letterSpacing: -0.3,
  },
  headerSubtitle: {
    fontSize: 12,
    color: '#94A3B8',
    marginTop: 2,
  },
  highlightText: {
    color: '#38BDF8',
    fontWeight: '700',
  },
  sectionTabsWrapper: {
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#1E293B',
    backgroundColor: '#0F172A',
  },
  sectionTabs: {
    paddingHorizontal: 14,
    gap: 8,
  },
  sectionTab: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 22,
    borderWidth: 1,
    borderColor: '#334155',
    gap: 6,
  },
  sectionTabActive: {
    backgroundColor: '#2563EB',
    borderColor: '#60A5FA',
  },
  tabIcon: {
    fontSize: 14,
  },
  tabTitle: {
    color: '#94A3B8',
    fontSize: 13,
    fontWeight: '600',
  },
  tabTitleActive: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  badge: {
    backgroundColor: '#334155',
    minWidth: 20,
    height: 20,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 6,
  },
  badgeActive: {
    backgroundColor: 'rgba(255, 255, 255, 0.25)',
  },
  badgeText: {
    color: '#94A3B8',
    fontSize: 11,
    fontWeight: '700',
  },
  badgeTextActive: {
    color: '#FFFFFF',
  },
  gridContainer: {
    paddingHorizontal: 10,
    paddingTop: 12,
    paddingBottom: 24,
  },
  centerContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  loadingText: {
    color: '#94A3B8',
    fontSize: 14,
    marginTop: 10,
  },
  emptySectionContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 30,
    paddingVertical: 60,
  },
  emptySectionIcon: {
    fontSize: 48,
    marginBottom: 12,
  },
  emptySectionTitle: {
    color: '#94A3B8',
    fontSize: 15,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 16,
  },
  findMoreBtn: {
    backgroundColor: '#1E293B',
    paddingHorizontal: 18,
    paddingVertical: 10,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#3B82F6',
  },
  findMoreText: {
    color: '#38BDF8',
    fontSize: 13,
    fontWeight: '600',
  },
});
