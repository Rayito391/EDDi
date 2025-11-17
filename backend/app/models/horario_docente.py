from app import Base, db


class HorarioDocente(Base):
    __tablename__ = 'horarios_docentes'
    id = db.Column('horariodocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(50), nullable=False)
    horario_inicio = db.Column('horarioinicio', db.Time, nullable=False)
    horario_fin = db.Column('horariofin', db.Time, nullable=False)
    carga_reglamentaria = db.Column('cargareglamentaria', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='horarios')
