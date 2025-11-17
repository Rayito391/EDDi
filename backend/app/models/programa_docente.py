from app import Base, db


class ProgramaDocente(Base):
    __tablename__ = 'programas_docentes'
    id = db.Column('programadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    programa_id = db.Column('programaid', db.Integer, db.ForeignKey('programas_academicos.programaid'), nullable=False)
    rol = db.Column('rol', db.String(50), nullable=False)
    
    # Relationships
    docente = db.relationship('Docente', backref='programas_participacion')
    programa = db.relationship('ProgramaAcademico', backref='participantes')
