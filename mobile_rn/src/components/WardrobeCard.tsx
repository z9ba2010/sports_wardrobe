import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, Linking } from 'react-native';
import { Trash2, ExternalLink } from 'lucide-react-native';
import { WardrobeItem } from '../types';

interface WardrobeCardProps {
  item: WardrobeItem;
  onRemove: (itemId: number) => void;
}

export const WardrobeCard: React.FC<WardrobeCardProps> = ({ item, onRemove }) => {
  const formattedPrice = item.price ? new Intl.NumberFormat('ru-RU').format(item.price) + ' ₽' : '';

  const handleOpenSource = () => {
    if (item.source_url) {
      Linking.openURL(item.source_url).catch((err) => console.log('Could not open URL:', err));
    }
  };

  return (
    <View style={styles.card}>
      <View style={styles.imageContainer}>
        {item.image_url ? (
          <Image source={{ uri: item.image_url }} style={styles.image} resizeMode="cover" />
        ) : (
          <View style={styles.placeholder}>
            <Text style={styles.placeholderText}>Без фото</Text>
          </View>
        )}
        <View style={styles.brandTag}>
          <Text style={styles.brandText}>{item.brand}</Text>
        </View>
      </View>

      <View style={styles.content}>
        <View style={styles.headerRow}>
          <Text style={styles.title} numberOfLines={2}>
            {item.item_name}
          </Text>
        </View>

        {formattedPrice ? <Text style={styles.price}>{formattedPrice}</Text> : null}

        <View style={styles.footerRow}>
          {item.source_url ? (
            <TouchableOpacity style={styles.storeLink} onPress={handleOpenSource}>
              <ExternalLink size={12} color="#38BDF8" />
              <Text style={styles.storeText}>В магазин</Text>
            </TouchableOpacity>
          ) : <View />}

          <TouchableOpacity
            style={styles.deleteBtn}
            onPress={() => onRemove(item.id)}
            hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
          >
            <Trash2 size={16} color="#EF4444" />
          </TouchableOpacity>
        </View>
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
    borderWidth: 1,
    borderColor: '#334155',
    overflow: 'hidden',
  },
  imageContainer: {
    width: '100%',
    height: 135,
    backgroundColor: '#0F172A',
    position: 'relative',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  placeholder: {
    width: '100%',
    height: '100%',
    alignItems: 'center',
    justifyContent: 'center',
  },
  placeholderText: {
    color: '#64748B',
    fontSize: 12,
  },
  brandTag: {
    position: 'absolute',
    top: 6,
    left: 6,
    backgroundColor: 'rgba(15, 23, 42, 0.85)',
    paddingHorizontal: 7,
    paddingVertical: 2,
    borderRadius: 5,
  },
  brandText: {
    color: '#38BDF8',
    fontSize: 10,
    fontWeight: '700',
  },
  content: {
    padding: 10,
  },
  headerRow: {
    minHeight: 34,
  },
  title: {
    color: '#F1F5F9',
    fontSize: 12,
    fontWeight: '600',
    lineHeight: 16,
  },
  price: {
    color: '#F97316',
    fontSize: 13,
    fontWeight: '700',
    marginTop: 4,
  },
  footerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 8,
    paddingTop: 6,
    borderTopWidth: 1,
    borderTopColor: '#334155',
  },
  storeLink: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  storeText: {
    color: '#38BDF8',
    fontSize: 11,
    fontWeight: '600',
  },
  deleteBtn: {
    padding: 4,
  },
});
