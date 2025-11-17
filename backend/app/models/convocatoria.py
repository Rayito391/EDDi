from app import Base, db


class Convocatoria(Base):
    __tablename__ = 'convocatorias'
    id = db.Column('convocatoriaid', db.Integer, primary_key=True)
    nombre_convocatoria = db.Column('nombreconvocatoria', db.String(100), nullable=False)
    periodo = db.Column('periodo', db.String(100), nullable=False)
    fecha_inicio = db.Column('fechainicio', db.Date, nullable=False)
    fecha_fin = db.Column('fechafin', db.Date, nullable=False)