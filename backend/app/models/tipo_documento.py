from app import Base, db


class TipoDocumento(Base):
    __tablename__ = 'tipos_documentos'
    id = db.Column('tipodocumentoid', db.Integer, primary_key=True)
    nombre_corto = db.Column('nombrecorto', db.String(50), nullable=False)
    nombre_completo = db.Column('nombrecompleto', db.String(255), nullable=False)
    factor_asociado = db.Column('factorasociado', db.String(20), nullable=True)
    area_responsable = db.Column('arearesponsable', db.String(100), nullable=True)
