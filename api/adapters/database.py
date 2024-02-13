import psycopg2
import os

class DataBaseConnection(object):
    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, 'instance'):
            cls.instance = super(DataBaseConnection, cls).__new__(cls, *args, **kwargs)
        return cls.instance

    def __init__(self):
        self._database=os.getenv("POSTGRES_DB")
        self._host="db"
        self._user=os.getenv("POSTGRES_USER")
        self._password=os.getenv("POSTGRES_PASSWORD")
        self._connection = psycopg2.connect(
            database=self._database,
            host=self._host,
            user=self._user,
            password=self._password
        )
        self._cursor = self._connection.cursor()

    def get_cursor(self):
        return self._cursor