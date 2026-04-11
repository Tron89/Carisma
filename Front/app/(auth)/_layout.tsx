import { colors } from "@/utils/values";
import { usePreventRemove } from "@react-navigation/native";
import { Stack } from "expo-router";
import { KeyboardAvoidingView } from "react-native";

export default function TabsLayout() {
  usePreventRemove(true, () => {});

  return <KeyboardAvoidingView style={{ flex: 1 }} behavior="padding">
    <Stack  
      screenOptions={{
        headerStyle: {
          backgroundColor: colors.background,
        },
        headerShadowVisible: false,
        headerTitleStyle: {
          color: colors.white,
        },
        animation: "fade_from_bottom",
        contentStyle: {backgroundColor: colors.background},
      }}
      >
      <Stack.Screen name="index" options={{title: "Login"}} />
      <Stack.Screen name="signup" options={{title: "Sign Up"}} />
      <Stack.Screen name="recover" options={{title: "Recover Password"}} />
    </Stack>
  </KeyboardAvoidingView>;
}
