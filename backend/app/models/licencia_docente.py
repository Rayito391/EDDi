from app import Base, db


class LicenciaDocente(Base):
    __tablename__ = 'licencias_docentes'
    id = db.Column('licenciadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    tipo_licencia = db.Column('tipolicencia', db.String(50), nullable=False)
    folio_autorizacion = db.Column('folioautorizacion', db.String(50), nullable=True)
    fecha_inicio = db.Column('fechainicio', db.Date, nullable=False)
    fecha_fin = db.Column('fechafin', db.Date, nullable=False)
    es_oficio_autorizado = db.Column('esoficioautorizado', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='licencias')