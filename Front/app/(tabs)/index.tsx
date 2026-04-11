import Post from "@/components/post-component/post";
import { colors } from "@/utils/values";
import { StyleSheet, View } from "react-native";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: colors.background,
    padding: 20,
  },
  text: {
    color: colors.white,
  },
  button: {
    marginTop: 20,
    color: colors.primary,
  }
});

const PlaceholderImage = "https://cdn.omlet.com/images/originals/breed_abyssinian_cat.jpg";

export default function Index() {
  return (
    <View style={styles.container}>
      <Post imgSource={PlaceholderImage} likes={0} dislikes={0} comments={0} groupName={undefined} username={"Test User"} />
    </View>
  );
}
