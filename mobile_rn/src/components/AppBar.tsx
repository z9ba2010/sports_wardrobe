import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, Platform } from 'react-native';
import { User, Sparkles } from 'lucide-react-native';

interface AppBarProps {
  title?: string;
  subtitle?: string;
  itemCount?: number;
  onProfilePress: () => void;
  showProfileButton?: boolean;
}

export const AppBar: React.FC<AppBarProps> = ({
  title = 'MaxFunFit',
  subtitle = 'Спортивный Гардероб',
  itemCount = 0,
  onProfilePress,
  showProfileButton = true,
}) => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        {/* Логотип и заголовок */}
        <View style={styles.titleContainer}>
          <View style={styles.badgeRow}>
            <Text style={styles.brandTitle}>{title}</Text>
            <View style={styles.proTag}>
              <Sparkles size={11} color="#FF6B00" />
              <Text style={styles.proText}>AI</Text>
            </View>
          </View>
          <Text style={styles.subtitle}>{subtitle}</Text>
        </View>

        {/* Иконка профиля пользователя в верхнем правом углу (ТЗ п.1) */}
        {showProfileButton && (
          <TouchableOpacity
            style={styles.profileButton}
            onPress={onProfilePress}
            activeOpacity={0.7}
            accessibilityLabel="Профиль пользователя и Мой гардероб"
            accessibilityRole="button"
          >
            <View style={styles.avatarCircle}>
              <User size={20} color="#FFFFFF" strokeWidth={2.2} />
            </View>

            {itemCount > 0 && (
              <View style={styles.counterBadge}>
                <Text style={styles.counterText}>
                  {itemCount > 99 ? '99+' : itemCount}
                </Text>
              </View>
            )}
          </TouchableOpacity>
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    backgroundColor: '#0F172A',
  },
  container: {
    height: Platform.OS === 'android' ? 64 : 58,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    backgroundColor: '#0F172A',
    borderBottomWidth: 1,
    borderBottomColor: '#1E293B',
  },
  titleContainer: {
    flex: 1,
  },
  badgeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  brandTitle: {
    fontSize: 20,
    fontWeight: '800',
    color: '#FFFFFF',
    letterSpacing: -0.5,
  },
  proTag: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 107, 0, 0.15)',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: 'rgba(255, 107, 0, 0.4)',
    gap: 3,
  },
  proText: {
    fontSize: 10,
    fontWeight: '700',
    color: '#FF6B00',
  },
  subtitle: {
    fontSize: 12,
    color: '#94A3B8',
    marginTop: 1,
  },
  profileButton: {
    position: 'relative',
    padding: 4,
  },
  avatarCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#3B82F6',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: '#60A5FA',
    shadowColor: '#3B82F6',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.35,
    shadowRadius: 4,
    elevation: 4,
  },
  counterBadge: {
    position: 'absolute',
    top: 0,
    right: 0,
    backgroundColor: '#FF6B00',
    minWidth: 18,
    height: 18,
    borderRadius: 9,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 4,
    borderWidth: 2,
    borderColor: '#0F172A',
  },
  counterText: {
    color: '#FFFFFF',
    fontSize: 10,
    fontWeight: '800',
  },
});
