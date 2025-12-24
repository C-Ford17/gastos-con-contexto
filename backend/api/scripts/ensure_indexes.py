from pymongo import ASCENDING, DESCENDING
from api.db import get_db

def run():
    db = get_db()

    # users: email único (si no lo hiciste ya)
    db["users"].create_index([("email", ASCENDING)], unique=True)

    # categories: unique por usuario+nombre+tipo (evita duplicados)
    db["categories"].create_index([("userId", ASCENDING), ("type", ASCENDING), ("name", ASCENDING)], unique=True)
    db["categories"].create_index([("userId", ASCENDING), ("type", ASCENDING), ("order", ASCENDING)])

    # expenses (las dejaremos listas desde ya, aunque el CRUD venga después)
    db["expenses"].create_index([("userId", ASCENDING), ("date", DESCENDING)])
    db["expenses"].create_index([("userId", ASCENDING), ("categoryId", ASCENDING)])
    db["expenses"].create_index([("userId", ASCENDING), ("type", ASCENDING)])
    db["expenses"].create_index([("userId", ASCENDING), ("reason", ASCENDING)])
    db["expenses"].create_index([("userId", ASCENDING), ("tags", ASCENDING)])  # tags array => multikey automático
    db["expenses"].create_index([("userId", ASCENDING), ("mood", ASCENDING)])
    db["expenses"].create_index([("userId", ASCENDING), ("date", DESCENDING), ("type", ASCENDING), ("categoryId", ASCENDING)])

if __name__ == "__main__":
    run()
    print("Indexes ensured.")
