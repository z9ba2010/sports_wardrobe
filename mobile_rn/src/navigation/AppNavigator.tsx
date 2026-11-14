import React, { useState, useEffect, useCallback } from 'react';
import { View, StyleSheet, StatusBar } from 'react-native';

import { AppBar } from '../components/AppBar';
import { SearchScreen } from '../screens/SearchScreen';
import { WardrobeScreen } from '../screens/WardrobeScreen';
import { wardrobeApi } from '../api/wardrobeApi';

type ScreenName = 'search' | 'wardrobe';

export const AppNavigator: React.FC = () => {
  const [currentScreen, setCurrentScreen] = useState<ScreenName>('search');
  const [wardrobeCount, setWardrobeCount] = useState<number>(0);
  const [savedNames, setSavedNames] = useState<Set<string>>(new Set());

  // Обновление счётчика гардероба для бейджа на иконке профиля в App Bar
  const refreshWardrobeCount = useCallback(async () => {
    try {
      const data = await wardrobeApi.getGroupedWardrobe('user_default');
      setWardrobeCount(data.total_count);

      const names = new Set<string>();
      Object.values(data.sections).forEach((items) => {
        items.forEach((item) => names.add(item.item_name));
      });
      setSavedNames(names);
    } catch {
      // Игнорируем в тихом режиме
    }
  }, []);

  useEffect(() => {
    refreshWardrobeCount();
  }, [refreshWardrobeCount]);

  // Обработчик нажатия на иконку профиля в правом верхнем углу App Bar (ТЗ п. 1)
  const handleProfilePress = () => {
    setCurrentScreen('wardrobe');
  };

  // Переход обратно на экран поиска
  const handleNavigateToSearch = () => {
    setCurrentScreen('search');
    refreshWardrobeCount();
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#0F172A" />

      {/* Главный App Bar с иконкой профиля в верхнем правом углу */}
      <AppBar
        title="MaxFunFit"
        subtitle={currentScreen === 'search' ? 'Каталог и поиск экипировки' : 'Персональный профиль'}
        itemCount={wardrobeCount}
        onProfilePress={handleProfilePress}
        showProfileButton={currentScreen !== 'wardrobe'}
      />

      {/* Экранное переключение */}
      <View style={styles.screenContainer}>
        {currentScreen === 'search' ? (
          <SearchScreen
            onItemAdded={refreshWardrobeCount}
            savedItemNames={savedNames}
          />
        ) : (
          <WardrobeScreen
            userId="user_default"
            onNavigateToSearch={handleNavigateToSearch}
            onGoBack={handleNavigateToSearch}
          />
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0F172A',
  },
  screenContainer: {
    flex: 1,
  },
});
