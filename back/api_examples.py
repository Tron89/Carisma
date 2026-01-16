import uuid
import requests


BASE_URL = "http://localhost:8000/v1"


def _url(path: str) -> str:
    return f"{BASE_URL}{path}"


def list_posts(limit: int = 20, cursor: int | None = None) -> dict:
    params = {
        "limit": limit,
        "sort": "new",
        "order": "desc",
        "include": "author,community",
        "fields[posts]": "id,title,author_id,community_id,created_at,score",
    }
    if cursor:
        params["cursor"] = cursor
    resp = requests.get(_url("/posts"), params=params, timeout=10)
    resp.raise_for_status()
    return resp.json()


def create_post(
    community_name: str,
    title: str,
    body: str | None = None,
    author_username: str | None = None,
) -> dict:
    headers = {"Idempotency-Key": str(uuid.uuid4())}
    payload = {
        "community_name": community_name,
        "title": title,
        "body": body,
        "image_url": None,
        "author_username": author_username,
    }
    resp = requests.post(_url("/posts"), json=payload, headers=headers, timeout=10)
    resp.raise_for_status()
    return resp.json()


def get_post(post_id: int) -> dict:
    params = {"include": "author,community"}
    resp = requests.get(_url(f"/posts/{post_id}"), params=params, timeout=10)
    resp.raise_for_status()
    return resp.json()


def update_post(post_id: int, title: str | None = None, body: str | None = None) -> dict:
    payload = {}
    if title is not None:
        payload["title"] = title
    if body is not None:
        payload["body"] = body
    resp = requests.patch(_url(f"/posts/{post_id}"), json=payload, timeout=10)
    resp.raise_for_status()
    return resp.json()


def delete_post(post_id: int) -> None:
    resp = requests.delete(_url(f"/posts/{post_id}"), timeout=10)
    resp.raise_for_status()


def vote_post(post_id: int, value: int) -> dict:
    resp = requests.put(_url(f"/posts/{post_id}/vote"), json={"value": value}, timeout=10)
    resp.raise_for_status()
    return resp.json()


def clear_vote(post_id: int) -> None:
    resp = requests.delete(_url(f"/posts/{post_id}/vote"), timeout=10)
    resp.raise_for_status()


def list_comments(post_id: int, limit: int = 50) -> dict:
    params = {"limit": limit, "sort": "new", "order": "asc"}
    resp = requests.get(_url(f"/posts/{post_id}/comments"), params=params, timeout=10)
    resp.raise_for_status()
    return resp.json()


def batch_get_posts(ids: list[int]) -> dict:
    resp = requests.post(_url("/posts/batch"), json={"ids": ids}, timeout=10)
    resp.raise_for_status()
    return resp.json()


if __name__ == "__main__":
    # Requires: pip install requests
    created = create_post("community_1", "Hello world", "First post", "demo_user")
    post_id = created["data"]["id"]
    print("Created:", created)
    print("Get:", get_post(post_id))
    print("List:", list_posts())
    print("Vote:", vote_post(post_id, 1))
    print("Comments:", list_comments(post_id))
    delete_post(post_id)
    print("Deleted:", post_id)
