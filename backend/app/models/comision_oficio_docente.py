from app import Base, db


class ComisionOficioDocente(Base):
    __tablename__ = 'comisiones_oficios_docentes'
    id = db.Column('comisionoficiodocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    tipo_comision = db.Column('tipocomision', db.String(100), nullable=False)
    clave_actividad = db.Column('claveactividad', db.String(10), nullable=False)
    folio_oficio_comision = db.Column('foliooficiocomision', db.String(50), nullable=True)
    folio_constancia_cumplimiento = db.Column('folioconstanciacumplimiento', db.String(50), nullable=True)
    vobo_sub_academica = db.Column('vobo_subacademica', db.String(2), nullable=True)
    nivel_participacion = db.Column('nivelparticipacion', db.String(50), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='comisiones_oficios')