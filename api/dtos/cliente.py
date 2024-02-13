from api.adapters.database import DataBaseConnection

class Cliente:
    def __init__(self):
        self._cursor = DataBaseConnection().get_cursor()

    def get_col_names(self):
        return [desc[0]for desc in self._cursor.description]
    
    def format_to_dict(self, cols, values):
        row_dict = {}
        for col, value in zip(cols, values):
            row_dict[col] = value
        return row_dict

    def get_values(self):
        col_names = self.get_col_names()
        results = self._cursor.fetchall()
        return [self.format_to_dict(col_names, result) for result in results]

    def get_table(self):
        self._cursor.execute("SELECT * FROM clientes;")
        return self.get_values()

    def get(self, id:int):
        self._cursor.execute(f"SELECT * FROM clientes WHERE id = {id};")
        return self.get_values()[0]