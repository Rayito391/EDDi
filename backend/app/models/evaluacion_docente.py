from app import Base, db


class EvaluacionDocente(Base):
    __tablename__ = 'evaluaciones_docentes'
    id = db.Column('evaluaciondocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    tipo_evaluacion = db.Column('tipoevaluacion', db.String(50), nullable=False)
    calificacion = db.Column('calificacion', db.Numeric(5, 2), nullable=False)
    nombre_dpto_academico = db.Column('nombredptoacademico', db.String(100), nullable=True)
    cobertura_estudiantes = db.Column('coberturaestudiantes', db.Numeric(5, 2), nullable=True)
    vobo_sub_academica = db.Column('vobo_subacademica', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='evaluaciones')