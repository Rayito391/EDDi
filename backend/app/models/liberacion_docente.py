from app import Base, db


class LiberacionDocente(Base):
    __tablename__ = 'liberaciones_docentes'
    id = db.Column('liberaciondocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    tipo_liberacion = db.Column('tipoliberacion', db.String(50), nullable=False)
    folio_liberacion = db.Column('folioliberacion', db.String(50), nullable=True)
    cumplimiento_porcentaje = db.Column('cumplimientoporcentaje', db.Numeric(5, 2), nullable=False)
    esta_liberado = db.Column('estaliberado', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='liberaciones')