from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
    pass

db = SQLAlchemy(model_class=Base)

def create_app():
    app = Flask(__name__)
    
    app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://postgres:postgres@localhost:5432/TecDeCuliacann"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    
    db.init_app(app)

    from app.models.personal import Personal
    from app.models.docente import Docente
        
    from app.routes.auth import auth_blueprint
    app.register_blueprint(auth_blueprint)
    
    with app.app_context():
        db.create_all()
    
    return app