from fastapi import FastAPI, Depends, HTTPException
import uvicorn
from sqlmodel import SQLModel, Field, Session, create_engine, select
from authlib.jose import jwt
from datetime import datetime, timedelta
from typing import Optional

app = FastAPI()

SECRET = "secretkey"
engine = create_engine("noope")


# ---------- MODELOS ----------
class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str
    password: str  # normalmente la guardarías hasheada


# ---------- DB INIT ----------
@app.on_event("startup")
def on_startup():
    SQLModel.metadata.create_all(engine)


# ---------- JWT ----------
def create_token(data: dict):
    exp = datetime.utcnow() + timedelta(hours=1)
    payload = {**data, "exp": exp}
    return jwt.encode({"alg": "HS256"}, payload, SECRET)


def verify_token(token: str):
    try:
        return jwt.decode(token, SECRET)
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")


# ---------- ROUTES ----------
@app.post("/register")
def register(username: str, password: str):
    with Session(engine) as session:
        user = User(username=username, password=password)
        session.add(user)
        session.commit()
        return {"msg": "ok"}


@app.post("/login")
def login(username: str, password: str):
    with Session(engine) as session:
        user = session.exec(select(User).where(User.username == username)).first()
        if not user or user.password != password:
            raise HTTPException(status_code=401, detail="Bad credentials")
        token = create_token({"sub": user.username})
        return {"access_token": token}


@app.get("/me")
def me(token: str):
    data = verify_token(token)
    return {"you_are": data["sub"]}


if __name__ == '__main__':
    uvicorn.run(app=app)