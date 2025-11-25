from app import db
from sqlalchemy.dialects.postgresql import BYTEA


class Firma(db.Model):
    __tablename__ = 'firmas'
    id = db.Column('firmaid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    firma = db.Column('firma', BYTEA, nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='firmas') 