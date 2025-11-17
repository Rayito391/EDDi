from app import Base, db


class ProgramaAcademico(Base):
    __tablename__ = 'programas_academicos'
    id = db.Column('programaid', db.Integer, primary_key=True)
    nombre_programa = db.Column('nombreprograma', db.String(255), nullable=False)
    nivel_programa = db.Column('nivelprograma', db.String(50), nullable=False)
    acreditado = db.Column('acreditado', db.String(2), nullable=True)
    snp_vigente = db.Column('snp_vigente', db.String(2), nullable=True)
    organo_acreditador = db.Column('organoacreditador', db.String(100), nullable=True)
    folio_registro_ddie_dpii = db.Column('folioregistroddie_dpii', db.String(50), nullable=True)
