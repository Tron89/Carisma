import { Href } from "expo-router";

export const colors = {
    primary: "#6200ff",
    background: "#1f1f1f",

    white: "#ffffff",
    black: "#000000",

    gray: "#7f7f7f",
    darkGray: "#3f3f3f",
    lightGray: "#bfbfbf",

    red: "#ff0000",
    yellow: "#ffff00",
    green: "#00ff00",
    cyan: "#00ffff",
    blue: "#0000ff",
    magenta: "#ff00ff",
}

export const localStorageKeys = {
    tokenType: 'token_type',
    token: 'access_token',
    user: 'user',
}

export const routes = {
    home: '/(tabs)' as Href,
    account: '/(tabs)/account' as Href,
    messages: '/(tabs)/messages' as Href,
    newPost: '/(tabs)/new-post' as Href,
    search: '/(tabs)/search' as Href,

    login: '/(auth)' as Href,
    signup: '/(auth)/signup' as Href,
    recoverPassword: '/(auth)/recover' as Href,

    notFound: '/+not-found' as Href,
}

export const apiBaseUrl = 'https://survival-spiral-praying.ngrok-free.dev/v1/';

export const apiEndpoints = {
    login: 'login',
    register: 'register',
    currentUser: 'users/me',
    user: (id: number) => `users/${id}`,
    communities: 'communities',
    community: (id: number) => `communities/${id}`,
    posts: 'posts',
    post: (id: number) => `posts/${id}`,
}