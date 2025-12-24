import os
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

_client = None

def get_db():
    global _client
    if _client is None:
        uri = os.getenv("MONGODB_URI")
        if not uri:
            raise RuntimeError("Missing MONGODB_URI")
        _client = MongoClient(uri)
    return _client[os.getenv("MONGODB_DB_NAME", "gastos_contexto")]
