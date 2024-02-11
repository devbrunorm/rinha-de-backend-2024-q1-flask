import psycopg2
import os

class DataBaseConnection(object):
    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, 'instance'):
            cls.instance = super(DataBaseConnection, cls).__new__(cls)
        return cls.instance

    def __init__(self):
        self._database=os.getenv("POSTGRES_DB")
        self._host="0.0.0.0"
        self._user=os.getenv("POSTGRES_USER")
        self._password=os.getenv("POSTGRES_PASSWORD")
        self._port=os.getenv("5432")
        self._connection = psycopg2.connect(
            database=self._host,
            host=self._host,
            user=self._user,
            password=self._password,
            port=self._port
        )
        self._cursor = self._connection.cursor()

    def get_cursor(self):
        return self._cursor