from api.adapters.database import DataBaseConnection

class Cliente:
    def __init__(self):
        self._cursor = DataBaseConnection().cursor()

    def get_table(self):
        return self._cursor.execute("SELECT * FROM clientes;")

    def get(self, id:int):
        return self._cursor.execute(f"SELECT * FROM clientes FROM id = {id};")