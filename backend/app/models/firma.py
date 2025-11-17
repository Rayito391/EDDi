from app import Base, db


class Firma(Base):
    __tablename__ = 'firmas'
    id = db.Column('firmaid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    firma = db.Column('firma', db.String(512), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='firmas')