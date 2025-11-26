from app import Base, db


class MateriaDocente(Base):
    __tablename__ = 'materias_docentes'
    id = db.Column('asignaturadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    materia_id = db.Column('materiaid', db.Integer, db.ForeignKey('materias.materiaid'), nullable=False)
    total_alumnos = db.Column('totalalumnos', db.Integer, nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    es_complementaria = db.Column('escomplementaria', db.String(2), nullable=False)
    
    # Relationships
    docente = db.relationship('Docente', backref='materias_impartidas')
    materia = db.relationship('Materia', backref='docentes_asignados')
