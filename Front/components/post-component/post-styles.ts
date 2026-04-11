import { colors } from '@/utils/values';
import { StyleSheet } from 'react-native';

export const styles = StyleSheet.create({
    buttons: {
        flexDirection: 'row',
        minWidth: 40,
        minHeight: 30,
        alignItems: 'center',
    },
    joinButton: {
        backgroundColor: colors.primary,
        borderWidth: 1,
        paddingVertical: 5,
        paddingHorizontal: 10,
        paddingRight: 15,
        borderRadius: 10,
    },
    text: {
        color: colors.white,
        marginLeft: 5,
    },
    group: {
        flexDirection: 'row',
        gap: 10,
        borderColor: colors.primary,
        borderWidth: 1,
        paddingVertical: 5,
        paddingHorizontal: 10,
        borderRadius: 20
    },
    topInfo: {
        height: 10,
        marginBottom: 30,
        flexDirection: 'row',
        justifyContent: 'space-between',
    },   
    image: {
        width: '100%',
        aspectRatio: 3/4,
        borderRadius: 10,
    },
    bottomInfo: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginTop: 10,
        gap: 10,
    },
})