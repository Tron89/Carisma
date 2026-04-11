import { navigateTo } from "@/navigation/navigationService";
import { checkAuth } from "@/services/server-requests";
import { colors, routes } from "@/utils/values";
import { Stack } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { useEffect } from "react";

export default function RootLayout() {  
  useEffect(() => { 
    const init = async () => {
      if (await checkAuth()) navigateTo(routes.home);
      else navigateTo(routes.login);
    };
    init();
  }, []);

  return (
  <>
    <StatusBar style="dark" />
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: colors.background },
      }}
      />
  </>);
}
