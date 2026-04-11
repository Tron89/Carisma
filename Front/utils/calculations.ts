export const parseNumber = (num: number) => {
    if (num > 1_000_000_000) return `${Math.floor(num / 1_000_000_000)}B`;
    if (num > 1_000_000) return `${Math.floor(num / 1_000_000)}M`;
    if (num > 1_000) return `${Math.floor(num / 1_000)}k`;
    return num.toString();
}

export const selectUserOrGroup = (groupName?: string, username?: string) => {
    if (groupName) return `g/${groupName}`;
    if (username) return `u/${username}`;
    return 'Unknown';
}

export const titleCase = (str: string) => {
    return str.replace(/\w\S*/g, (txt) => txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase());
}

export const colorVariant = (color: string, variant: number) => {
    const num = parseInt(color.replace("#", ""), 16);

    variant = Math.max(-10, Math.min(10, variant));

    const r = clamp(((num >> 16) & 0x00FF) + variant * 6, 0, 255);
    const g = clamp(((num >> 8) & 0x00FF) + variant * 6, 0, 255);
    const b = clamp((num & 0x0000FF) + variant * 6, 0, 255);
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
}

export const clamp = (num: number, min: number, max: number) => {
    return Math.max(min, Math.min(max, num));
}