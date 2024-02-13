from flask import Flask
from api.dtos.cliente import Cliente

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.route("/cliente")
def table_clientes():
    return Cliente().get_table()

@app.route("/cliente/<id>")
def get_client(id:int):
    return Cliente().get(id)

app.run(debug=True, host='0.0.0.0')