import { colors } from '@/utils/values';
import { Entypo, Feather, Ionicons } from '@expo/vector-icons';
import { Image, Pressable, Text, View } from 'react-native';
import { parseNumber, selectUserOrGroup } from '../../utils/calculations';
import { styles } from './post-styles';

type Props = {
    imgSource?: string;
    likes: number;
    dislikes: number;
    comments: number;
    groupName?: string;
    username?: string;
}

export default function Post({ imgSource, likes, dislikes, comments, groupName, username }: Props) {
    return <View style={{ width: '100%' }}>
        <View style={styles.topInfo}>
            <Pressable style={[styles.buttons, styles.group]} onPress={() => alert('Looking at user!')}>
                <Text style={styles.text}>{selectUserOrGroup(groupName, username)}</Text>
            </Pressable>
            <Pressable style={[styles.buttons, styles.joinButton]} onPress={() => alert('Joined!')}>
                <Text style={styles.text}>JOIN</Text>
            </Pressable>
        </View>
        <Pressable onPress={() => alert('Looking at post!')}>
            <Image style={styles.image} source={{ uri: imgSource }} />
        </Pressable>
        <View style={styles.bottomInfo}>
            <View style={styles.group}>
                <Pressable onPress={() => alert('Like!')} style={styles.buttons}>
                    <Ionicons name="heart" size={24} color={ colors.primary } />
                    <Text style={styles.text}>{parseNumber(likes)}</Text>
                </Pressable>
                <Pressable onPress={() => alert('Dislike!')} style={styles.buttons}>
                    <Entypo name="cross" size={24} color={ colors.primary } />
                    <Text style={styles.text}>{parseNumber(dislikes)}</Text>
                </Pressable>
                <Pressable onPress={() => alert('Comment!')} style={styles.buttons}>
                    <Feather name="message-square" size={24} color={ colors.primary } />
                    <Text style={styles.text}>{parseNumber(comments)}</Text>
                </Pressable>
            </View>
            <Pressable onPress={() => alert('Sent!')} style={[styles.buttons ,{flex: 1, justifyContent: 'flex-end'}]}>
                <Feather style={styles.group} name="send" size={24} color={ colors.primary } />
            </Pressable>
        </View>
    </View>;
}

