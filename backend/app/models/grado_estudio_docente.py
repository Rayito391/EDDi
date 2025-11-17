from app import Base, db


class GradoEstudioDocente(Base):
    __tablename__ = 'grados_estudios_docentes'
    id = db.Column('gradoestudiodocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    grado_obtenido = db.Column('gradoobtenido', db.String(50), nullable=True)
    folio_cedula = db.Column('foliocedula', db.String(50), nullable=True)
    fecha_obtencion = db.Column('fechaobtencion', db.Date, nullable=True)
    fecha_expedicion_cedula = db.Column('fechaexpedicioncedula', db.Date, nullable=True)
    institucion_emisora = db.Column('institucionemisora', db.String(255), nullable=True)

    docente = db.relationship('Docente', backref='grados_estudios')
