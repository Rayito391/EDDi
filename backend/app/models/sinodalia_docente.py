from app import Base, db


class SinodaliaDocente(Base):
    __tablename__ = 'titulaciones_docentes'
    id = db.Column('titulaciondocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    nivel_grado = db.Column('nivelgrado', db.String(50), nullable=False)
    rol_academico = db.Column('rolacademico', db.String(50), nullable=False)  # Director, Codirector, Sinodal
    tipo_trabajo = db.Column('tipotrabajo', db.String(50), nullable=False)  # Tesis, Tesina, Proyecto integrador, etc.
    folio_acta = db.Column('folioacta', db.String(50), nullable=True)
    fecha_examen = db.Column('fechaexamen', db.Date, nullable=True)
    es_externo = db.Column('esexterno', db.String(2), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='titulaciones')
