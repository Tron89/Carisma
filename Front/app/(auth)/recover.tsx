import { navigateTo } from "@/navigation/navigationService";
import { Image, Pressable, StyleSheet, Text, TextInput, View } from "react-native";
import { colors, routes } from "../../utils/values";

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
    return (
    <View style={styles.container}>
        <Image source={require('@/assets/images/carisma_logo_foreground.webp')} style={styles.logo} />
        <TextInput placeholder="Username/Email" style={styles.textInput} placeholderTextColor={colors.white}/>
        <View style={styles.buttonsGroup}>
          <Pressable onPress={() => alert('Reset Password!')} style={styles.button}>
              <Text style={styles.text}>Reset Password</Text>
          </Pressable>
          <Pressable onPress={() => navigateTo(routes.login)} style={styles.button}>
            <Text style={styles.text}>Back</Text>
          </Pressable>
        </View>
    </View>
  );
}