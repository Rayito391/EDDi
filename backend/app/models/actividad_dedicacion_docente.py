from app import Base, db


class ActividadDedicacionDocente(Base):
    __tablename__ = 'actividades_dedicacion_docente'
    id = db.Column('actividaddedicativadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    clave_actividad = db.Column('claveactividad', db.String(20), nullable=False)
    descripcion_actividad = db.Column('descripcionactividad', db.String(255), nullable=False)
    folio_constancia = db.Column('folioconstancia', db.String(50), nullable=True)
    num_estudiantes = db.Column('numestudiantes', db.Integer, nullable=True)
    resultado = db.Column('resultado', db.String(50), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='actividades_dedicacion')
