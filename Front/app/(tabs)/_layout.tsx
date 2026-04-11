import { logout } from '@/services/server-requests';
import { colorVariant } from '@/utils/calculations';
import { colors } from '@/utils/values';
import { Feather, FontAwesome, Ionicons } from '@expo/vector-icons';
import { usePreventRemove } from '@react-navigation/native';
import { Tabs } from "expo-router";
import { Image, Pressable, View } from 'react-native';

export default function TabsLayout() {
  usePreventRemove(true, () => {});

  return <Tabs
  
    screenOptions={{
      headerStyle: {
        backgroundColor: colors.background,
      },
      headerShadowVisible: true,
      headerTitleStyle: {
        color: colors.white,
      },
      headerTitle: '',
      headerLeft: () => (
        <Pressable onPress={() => alert("Menu pressed")} style={{ marginLeft: 15 }}>
          <Image
            source={require('@/assets/images/carisma_logo_text_left.webp')}
            style={{ width: 120, height: 40, objectFit: 'contain' }} />
        </Pressable>
      ),
      headerRight: () => (
        <View style={{ flexDirection: 'row', gap: 20, marginRight: 15 }}>
          <Pressable onPress={() => alert("Notifications pressed")}>
            <Ionicons name='notifications-outline' color={colors.primary} size={30}/>
          </Pressable>
          <Pressable onPress={() => logout()}>
            <Ionicons name='settings-outline' color={colors.primary} size={30}/>
          </Pressable>
        </View>
      ),

      tabBarActiveTintColor: colors.primary,
      tabBarInactiveTintColor: colors.white,
      tabBarStyle: {
        backgroundColor: colors.background,
        paddingTop: 5
      },
      tabBarLabel: () => null,

      animation: "shift",
      sceneStyle: {backgroundColor: colors.background},
    }}
    >
    <Tabs.Screen name="index" options={{
      title: "Home",
        tabBarIcon: ({ focused, color, size }) => (
          <Ionicons name={focused ? "home" : "home-outline"} color={color} size={size} />
        ),
    }} />
    <Tabs.Screen name="search" options={{
      title: "Search",
        tabBarIcon: ({ focused, color, size }) => (
          <Ionicons name={focused ? "search" : "search-outline"} color={color} size={size} />
        ),
    }} />
    <Tabs.Screen name="new-post" options={{
      title: "New Post",
        tabBarIcon: ({ focused, color, size }) => (
          <View style={{
            width: 60,
            height: 60,
            justifyContent: "center",
            alignItems: "center",
            backgroundColor: colors.primary,
            borderRadius: 100,
            marginBottom: 5,
            borderColor: colorVariant(colors.gray, 5),
            borderWidth: 1,
          }}>
            <Ionicons name={focused ? "add" : "add-outline"} color={color} size={size} />
          </View>
        ),
    }} />
    <Tabs.Screen name="messages" options={{
      title: "Messages",
        tabBarIcon: ({ focused, color, size }) => (
          <Feather name={focused ? "message-square" : "message-circle"} color={color} size={size} />
        ),
    }} />
    <Tabs.Screen name="account" options={{
      title: "Account",
        tabBarIcon: ({ focused, color, size }) => (
          <FontAwesome name={focused ? "user-circle" : "user-circle-o"} color={color} size={size} />
        ),
    }} />
  </Tabs>;
}
