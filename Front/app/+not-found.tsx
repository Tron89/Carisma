import { colors, routes } from "@/utils/values";
import { Link } from "expo-router";
import { StyleSheet, Text, View } from "react-native";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: colors.background,
  },
  text: {
    color: colors.white,
  },
  button: {
    marginTop: 20,
    color: colors.primary,
  }
});

export default function Index() {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>404. Page not found.</Text>
      <Link href={routes.home} style={styles.button}>
        Go to home
      </Link>
    </View>
  );
}
