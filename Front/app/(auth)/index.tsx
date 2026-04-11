import { navigateTo } from "@/navigation/navigationService";
import { login } from "@/services/server-requests";
import { colors, routes } from "@/utils/values";
import { usePreventRemove } from "@react-navigation/native";
import React from "react";
import { Image, Pressable, StyleSheet, Text, TextInput, View } from "react-native";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: colors.background,
    padding: 50,
    gap: 10,
  },
  text: {
    color: colors.white,
    fontSize: 16,
    fontWeight: "bold",
  },
  textInput: {
    backgroundColor: colors.darkGray,
    color: colors.white,
    padding: 10,
    borderRadius: 5,
    width: "100%",
  },
  button: {
    color: colors.primary,
    backgroundColor: colors.primary,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 7,
  },
  buttonsGroup: {
    flexDirection: "column",
    gap: 10,
    marginTop: 20,
  },
  logo: {
    width: 200,
    height: 200,
    marginBottom: 20
  }
});

export default function Index() {
  usePreventRemove(true, () => {});

  const [username, onChangeUsername] = React.useState('');
  const [password, onChangePassword] = React.useState('');

  return (
    <View style={styles.container}>
        <Image source={require('@/assets/images/carisma_logo_foreground.webp')} style={styles.logo} />
        <TextInput placeholder="Username/Email" style={styles.textInput} value={username} onChangeText={onChangeUsername} placeholderTextColor={colors.white} />
        <TextInput placeholder="Password" style={styles.textInput} value={password} onChangeText={onChangePassword} placeholderTextColor={colors.white} />
        <View style={styles.buttonsGroup}>
          <Pressable onPress={() => login(username, password)} style={styles.button}>
            <Text style={styles.text}>Login</Text>
          </Pressable>
          <Pressable onPress={() => navigateTo(routes.signup)} style={styles.button}>
              <Text style={styles.text}>Sign Up</Text>
          </Pressable>
          <Pressable onPress={() => navigateTo(routes.recoverPassword)} style={styles.button}>
              <Text style={styles.text}>Reset Password</Text>
          </Pressable>
        </View>
    </View>
  );
}