from app import Base, db


class SinodaliaDocente(Base):
    __tablename__ = 'sinodalias_titulaciones_docentes'
    id = db.Column('sinodaliatitulaciondocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    nivel_grado = db.Column('nivelgrado', db.String(50), nullable=False)
    tipo_participacion = db.Column('tipoparticipacion', db.String(50), nullable=False)
    folio_acta = db.Column('folioacta', db.String(50), nullable=True)
    fecha_examen = db.Column('fechaexamen', db.Date, nullable=True)
    es_sinodalia_externa = db.Column('essinodaliaexterna', db.String(2), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='sinodalias')