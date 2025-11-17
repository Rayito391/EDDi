from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import DeclarativeBase

from main import app

class Base(DeclarativeBase):
  pass

db = SQLAlchemy(model_class=Base)

# create the app
# configure the SQLite database, relative to the app instance folder
app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://postgres:postgres@localhost:5432/TecDeCuliacann"
# initialize the app with the extension
db.init_app(app)

class Usuario(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)

    def __repr__(self):
        return f"<Usuario {self.nombre}>"
    


with app.app_context():
    db.create_all()

