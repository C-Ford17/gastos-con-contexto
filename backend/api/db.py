import os
import certifi
from pymongo import MongoClient
from dotenv import load_dotenv
load_dotenv()
_client = None

def get_db():
    global _client
    if _client is None:
        uri = os.getenv("MONGODB_URI")
        if not uri:
            raise RuntimeError("Missing MONGODB_URI")
        _client = MongoClient(uri, tlsCAFile=certifi.where())
    return _client[os.getenv("MONGODB_DB_NAME", "gastos_contexto")]
