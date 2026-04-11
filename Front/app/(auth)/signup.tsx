import { navigateTo } from "@/navigation/navigationService";
import { signup } from "@/services/server-requests";
import { colors, routes } from "@/utils/values";
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

export default function Recover() {
    const [username, onUsernameChange] = React.useState("");
    const [email, onEmailChange] = React.useState("");
    const [password, onPasswordChange] = React.useState("");

    return (
        <View style={styles.container}>
            <Image source={require('@/assets/images/carisma_logo_foreground.webp')} style={styles.logo} />
            <TextInput placeholder="Username" style={styles.textInput} value={username} onChangeText={onUsernameChange}  placeholderTextColor={colors.white}/>
            <TextInput placeholder="Email" style={styles.textInput} value={email} onChangeText={onEmailChange} placeholderTextColor={colors.white} />
            <TextInput placeholder="Password" style={styles.textInput} value={password} onChangeText={onPasswordChange} secureTextEntry placeholderTextColor={colors.white} />
            <View style={styles.buttonsGroup}>
                <Pressable onPress={() => signup(username, email, password)} style={styles.button}>
                    <Text style={styles.text}>Sign Up</Text>
                </Pressable>
                <Pressable onPress={() => navigateTo(routes.login)} style={styles.button}>
                    <Text style={styles.text}>Login</Text>
                </Pressable>
            </View>
        </View>
    );
}