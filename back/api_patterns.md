# API Request/Response Patterns (Example)

Base URL: /v1

This file shows a scalable request pattern using a "posts" resource. The same
conventions apply to users, communities, comments, votes, etc.

## Conventions

- Resources use standard REST paths.
- Lists use cursor pagination (no offset).
- Sorting and filtering use the same query keys on every list.
- Errors return a single consistent shape.
- Write requests are idempotent where possible.

## Resource Paths

- GET    /v1/posts
- POST   /v1/posts
- GET    /v1/posts/{id}
- PATCH  /v1/posts/{id}
- DELETE /v1/posts/{id}
- PUT    /v1/posts/{id}/vote
- DELETE /v1/posts/{id}/vote
- GET    /v1/posts/{id}/comments
- POST   /v1/posts/batch

## List Query Parameters (applies to all list endpoints)

- limit: number (max 100)
- cursor: opaque string
- sort: new | top | hot
- order: asc | desc
- filter[community_id]=...
- filter[author_id]=...
- q: full-text search string
- include: comma-separated related resources (e.g. author,community)
- fields[posts]=id,title,author_id

## Standard Success Response (list)

{
  "data": [
    {
      "id": 123,
      "community_id": 1,
      "author_id": 9,
      "title": "Hello world",
      "body": "First post",
      "created_at": "2024-01-01T00:00:00Z",
      "score": 42
    }
  ],
  "meta": {
    "next_cursor": "123",
    "has_more": true
  }
}

## Standard Success Response (single resource)

{
  "data": {
    "id": 123,
    "community_id": 1,
    "author_id": 9,
    "title": "Hello world",
    "body": "First post",
    "created_at": "2024-01-01T00:00:00Z",
    "score": 42
  }
}

## Standard Error Response

{
  "error": {
    "code": "not_found",
    "message": "post not found",
    "details": {
      "resource": "post",
      "id": 123
    }
  }
}

## Create Post (POST /v1/posts)

Request headers:
- Content-Type: application/json
- Idempotency-Key: <optional for safe retries>

Request body:
{
  "community_name": "community_1",
  "title": "Hello world",
  "body": "First post",
  "image_url": null,
  "author_username": "demo_user"
}

Response:
{
  "data": {
    "id": 123,
    "created_at": "2024-01-01T00:00:00Z"
  }
}

## Vote (PUT /v1/posts/{id}/vote)

Request body:
{
  "value": 1
}

Response:
{
  "data": {
    "post_id": 123,
    "user_id": 9,
    "value": 1
  }
}

## Batch Read (POST /v1/posts/batch)

Request body:
{
  "ids": [123, 456]
}

Response:
{
  "data": [
    { "id": 123, "title": "Hello world" },
    { "id": 456, "title": "Another post" }
  ]
}
