
from app import Base, db


class ExpedienteDocente(Base):
    __tablename__ = 'expediente_docente'
    id = db.Column('expedientedocenteid', db.Integer, primary_key=True)
    convocatoria_id = db.Column('convocatoriaid', db.Integer, db.ForeignKey('convocatorias.convocatoriaid'), nullable=False)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    periodo = db.Column('periodo', db.String(100), nullable=False)
    fecha_creacion = db.Column('fechacreacion', db.Date, nullable=False)

    convocatoria = db.relationship('Convocatoria', backref='expedientes_docentes')
    docente = db.relationship('Docente', backref='expedientes')