import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Shirt, Search, Sparkles } from 'lucide-react-native';

interface EmptyStateProps {
  onNavigateToSearch: () => void;
}

export const EmptyState: React.FC<EmptyStateProps> = ({ onNavigateToSearch }) => {
  return (
    <View style={styles.container}>
      <View style={styles.iconCircle}>
        <Shirt size={48} color="#60A5FA" strokeWidth={1.5} />
        <View style={styles.sparkleBadge}>
          <Sparkles size={14} color="#FF6B00" />
        </View>
      </View>

      <Text style={styles.title}>Ваш гардероб пуст</Text>
      <Text style={styles.description}>
        Найдите и добавьте вещи через поиск по каталогу или сканирование кроссовок по фото.
      </Text>

      <TouchableOpacity
        style={styles.actionButton}
        onPress={onNavigateToSearch}
        activeOpacity={0.8}
      >
        <Search size={18} color="#FFFFFF" strokeWidth={2.2} />
        <Text style={styles.buttonText}>Найти экипировку</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 28,
    paddingVertical: 48,
  },
  iconCircle: {
    width: 96,
    height: 96,
    borderRadius: 48,
    backgroundColor: 'rgba(59, 130, 246, 0.12)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 20,
    borderWidth: 1,
    borderColor: 'rgba(59, 130, 246, 0.3)',
    position: 'relative',
  },
  sparkleBadge: {
    position: 'absolute',
    top: 6,
    right: 6,
    backgroundColor: '#1E293B',
    borderRadius: 10,
    padding: 3,
  },
  title: {
    fontSize: 20,
    fontWeight: '800',
    color: '#F8FAFC',
    marginBottom: 8,
    textAlign: 'center',
  },
  description: {
    fontSize: 14,
    color: '#94A3B8',
    textAlign: 'center',
    lineHeight: 20,
    marginBottom: 24,
    maxWidth: 280,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: '#2563EB',
    paddingHorizontal: 22,
    paddingVertical: 13,
    borderRadius: 12,
    shadowColor: '#2563EB',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
    elevation: 4,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '700',
  },
});
