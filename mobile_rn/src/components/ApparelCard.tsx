import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, ActivityIndicator } from 'react-native';
import { Check, Plus, ExternalLink } from 'lucide-react-native';
import { ApparelItem } from '../types';

interface ApparelCardProps {
  item: ApparelItem;
  isSaved?: boolean;
  isLoading?: boolean;
  onAddToWardrobe: (item: ApparelItem) => void;
  onOpenSource?: (url: string) => void;
}

export const ApparelCard: React.FC<ApparelCardProps> = ({
  item,
  isSaved = false,
  isLoading = false,
  onAddToWardrobe,
  onOpenSource,
}) => {
  const imageUrl = item.image_url || (item.image_urls && item.image_urls[0]) || '';
  const price = item.price_current || item.price || 0;
  const formattedPrice = new Intl.NumberFormat('ru-RU').format(price) + ' ₽';
  const name = item.product_name || item.title;

  return (
    <View style={styles.card}>
      {/* Контейнер изображения */}
      <View style={styles.imageContainer}>
        {imageUrl ? (
          <Image
            source={{ uri: imageUrl }}
            style={styles.image}
            resizeMode="cover"
          />
        ) : (
          <View style={styles.imagePlaceholder}>
            <Text style={styles.placeholderText}>Нет фото</Text>
          </View>
        )}

        {/* Бейдж бренда */}
        <View style={styles.brandBadge}>
          <Text style={styles.brandText}>{item.brand}</Text>
        </View>

        {/* Ссылка на магазин */}
        {item.source_url && onOpenSource && (
          <TouchableOpacity
            style={styles.sourceBtn}
            onPress={() => onOpenSource(item.source_url)}
            hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
          >
            <ExternalLink size={13} color="#CBD5E1" />
          </TouchableOpacity>
        )}
      </View>

      {/* Информация о товаре */}
      <View style={styles.info}>
        <Text style={styles.category}>{item.category}</Text>
        <Text style={styles.title} numberOfLines={2} ellipsizeMode="tail">
          {name}
        </Text>
        
        <View style={styles.priceRow}>
          <Text style={styles.price}>{formattedPrice}</Text>
        </View>

        {/* Кнопка «Добавить в гардероб» (ТЗ п. 2) */}
        <TouchableOpacity
          style={[
            styles.addButton,
            isSaved ? styles.addButtonSaved : styles.addButtonActive,
          ]}
          onPress={() => onAddToWardrobe(item)}
          disabled={isSaved || isLoading}
          activeOpacity={0.8}
        >
          {isLoading ? (
            <ActivityIndicator size="small" color="#FFFFFF" />
          ) : isSaved ? (
            <View style={styles.btnContent}>
              <Check size={16} color="#10B981" strokeWidth={2.5} />
              <Text style={styles.savedBtnText}>В гардеробе</Text>
            </View>
          ) : (
            <View style={styles.btnContent}>
              <Plus size={16} color="#FFFFFF" strokeWidth={2.5} />
              <Text style={styles.activeBtnText}>В гардероб</Text>
            </View>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    flex: 1,
    margin: 6,
    backgroundColor: '#1E293B',
    borderRadius: 14,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#334155',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  imageContainer: {
    width: '100%',
    height: 145,
    backgroundColor: '#0F172A',
    position: 'relative',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  imagePlaceholder: {
    width: '100%',
    height: '100%',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#1E293B',
  },
  placeholderText: {
    color: '#64748B',
    fontSize: 12,
  },
  brandBadge: {
    position: 'absolute',
    top: 8,
    left: 8,
    backgroundColor: 'rgba(15, 23, 42, 0.85)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
    borderWidth: 0.5,
    borderColor: '#475569',
  },
  brandText: {
    color: '#38BDF8',
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.2,
  },
  sourceBtn: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: 'rgba(15, 23, 42, 0.85)',
    padding: 6,
    borderRadius: 6,
  },
  info: {
    padding: 10,
    flex: 1,
    justifyContent: 'space-between',
  },
  category: {
    color: '#94A3B8',
    fontSize: 11,
    fontWeight: '500',
    marginBottom: 2,
  },
  title: {
    color: '#F8FAFC',
    fontSize: 13,
    fontWeight: '600',
    lineHeight: 17,
    minHeight: 34,
  },
  priceRow: {
    marginTop: 6,
    marginBottom: 8,
  },
  price: {
    color: '#F97316',
    fontSize: 15,
    fontWeight: '800',
  },
  addButton: {
    height: 36,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 2,
  },
  addButtonActive: {
    backgroundColor: '#2563EB',
  },
  addButtonSaved: {
    backgroundColor: 'rgba(16, 185, 129, 0.15)',
    borderWidth: 1,
    borderColor: '#10B981',
  },
  btnContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
  },
  activeBtnText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '700',
  },
  savedBtnText: {
    color: '#10B981',
    fontSize: 12,
    fontWeight: '700',
  },
});
