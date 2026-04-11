import { navigateTo } from "@/navigation/navigationService";
import { titleCase } from "@/utils/calculations";
import { apiEndpoints, localStorageKeys, routes } from "@/utils/values";
import * as SecureStorage from 'expo-secure-store';
import { get, post } from "./http";

export async function login(username: string, password: string) {
    console.log("INFO: User is not authenticated");

    const res = await post(apiEndpoints.login, { user: username.trim(), password: password.trim() })

    if (res.statusCode === 422) {
        res.detail.forEach((err: any) => {
            alert(`${titleCase(err.loc[1])} is required`);
        })
        return;
    }
    if (res.statusCode === 401) return alert('Invalid credentials');

    updateAuth(res);
    navigateTo(routes.home);
}

export async function signup(username: string, email: string, password: string) {
    const res = await post(apiEndpoints.register, { username: username.trim(), email: email.trim(), password: password.trim() })
          
    if (res.statusCode === 422) {
        res.detail.forEach((err: any) => {
            alert(`${titleCase(err.loc[1])} is required`);
        })
        return;
    }

    if (res.statusCode != 201) return alert(res.detail || 'Failed to sign up');

    login(username, password)
}

export async function checkAuth() {
    const tokenType = await SecureStorage.getItemAsync(localStorageKeys.tokenType);
    const token = await SecureStorage.getItemAsync(localStorageKeys.token);
    const user = await SecureStorage.getItemAsync(localStorageKeys.user);
    
    if (tokenType && token && user) return isTokenActive();
    else return false;
}

export async function isTokenActive() : Promise<boolean> {
    const tokenType = await SecureStorage.getItemAsync(localStorageKeys.tokenType);
    const token = await SecureStorage.getItemAsync(localStorageKeys.token);

    const res = await get(apiEndpoints.currentUser, { 'Authorization': `${tokenType} ${token}` });

    if (res.statusCode === 401) {
        console.log("INFO: Token is invalid or expired, clearing auth details");
        await SecureStorage.deleteItemAsync(localStorageKeys.token);
        await SecureStorage.deleteItemAsync(localStorageKeys.tokenType);
        await SecureStorage.deleteItemAsync(localStorageKeys.user);
        return false;
    }

    console.log("INFO: User is authenticated with token:", token);
    return true;
}

export async function logout() {
    await SecureStorage.deleteItemAsync(localStorageKeys.token);
    await SecureStorage.deleteItemAsync(localStorageKeys.tokenType);
    await SecureStorage.deleteItemAsync(localStorageKeys.user);

    navigateTo(routes.login);
}

export async function updateAuth(details: any) {
    await SecureStorage.setItemAsync(localStorageKeys.token, details.access_token);
    await SecureStorage.setItemAsync(localStorageKeys.tokenType, details.token_type);
    await SecureStorage.setItemAsync(localStorageKeys.user, JSON.stringify(details.user));
    console.log("INFO: Updated auth details in secure storage");
}