from api.db import get_db

db = get_db()
print(db.command("ping"))
print("Mongo OK")
