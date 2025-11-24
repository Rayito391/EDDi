from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from sqlalchemy.orm import DeclarativeBase
import os

class Base(DeclarativeBase):
    pass

db = SQLAlchemy(model_class=Base)

def create_app():
    app = Flask(__name__)
    
    default_uri = "postgresql://postgres:postgres@localhost:5432/TecDeCuliacann"
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("SQLALCHEMY_DATABASE_URI", default_uri)
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # Habilitar CORS para el front en localhost
    CORS(app, supports_credentials=True, origins=["http://localhost:3000", "http://127.0.0.1:3000"])
    
    db.init_app(app)

    # Import models to register mappings before create_all
    from app.models.personal import Personal
    from app.models.docente import Docente
    from app.models.convocatoria import Convocatoria
    from app.models.expediente_docente import ExpedienteDocente
    from app.models.tutoria_docente import TutoriaDocente
    from app.models.documento_generado import DocumentoGenerado
    from app.models.tipo_documento import TipoDocumento
        
    from app.routes.auth import auth_blueprint
    from app.routes.documentos import documentos_blueprint
    app.register_blueprint(auth_blueprint)
    app.register_blueprint(documentos_blueprint)
    
    with app.app_context():
        db.create_all()
    
    return app
