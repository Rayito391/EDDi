from app import Base, db


class CVUControlDocente(Base):
    __tablename__ = 'cvu_control_docente'
    id = db.Column('cvucontroldocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    fecha_ultima_actualizacion = db.Column('fechaultimaactualizacion', db.Date, nullable=False)
    estado_cvu = db.Column('estadocvu', db.String(50), nullable=False)
    folio_constancia = db.Column('folioconstancia', db.String(50), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='cvu_control', uselist=False)
