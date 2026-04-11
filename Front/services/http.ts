import { apiBaseUrl } from "@/utils/values";

export async function get(dir: string = '', headers: any = {}) {
    const res = await fetch(`${apiBaseUrl}${dir}`, { headers });
    const data = await res.json();
    return { statusCode: res.status, ...data };
}

export async function post(dir: string = '', body: any) {
    const res = await fetch(`${apiBaseUrl}${dir}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
    })

    const data = await res.json();
    return { statusCode: res.status, ...data }
}