import { colors } from "@/utils/values";
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
  }
});

export default function About() {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>This is the about screen.</Text>
    </View>
  );
}
