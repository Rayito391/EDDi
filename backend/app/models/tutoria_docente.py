from app import Base, db


class TutoriaDocente(Base):
    __tablename__ = 'tutorias_docentes'
    id = db.Column('tutoriadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    tipo_registro = db.Column('tiporegistro', db.String(20), nullable=False, default='tutorado')  # tutorado/asesorado
    num_estudiantes = db.Column('numestudiantes', db.Integer, nullable=False)
    folio_constancia = db.Column('folioconstancia', db.String(50), nullable=True)
    impacto_evaluacion = db.Column('impactoevaluacion', db.String(255), nullable=True)
    vobo_sub_academica = db.Column('vobo_subacademica', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='tutorias')
