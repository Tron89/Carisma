import { Href, router } from "expo-router";

export function navigateTo(path: Href) {
    router.navigate(path);
}