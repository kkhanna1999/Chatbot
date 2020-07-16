from flask import Flask,request,jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow


app = Flask(__name__)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'diro'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgres://postgres:Kh8562808374@localhost/chatbot'
db = SQLAlchemy(app)
ma = Marshmallow(app)

from routes import *

if __name__ == '__main__':
    app.run(debug=True)
    db.create_all()
