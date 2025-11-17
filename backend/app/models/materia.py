from app import Base, db


class Materia(Base):
    __tablename__ = 'materias'
    id = db.Column('materiaid', db.Integer, primary_key=True)
    nombre_materia = db.Column('nombremateria', db.String(50), nullable=False)
    nivel = db.Column('nivel', db.String(30), nullable=False)
    es_diferente_base = db.Column('esdiferentebase', db.String(2), nullable=False)
