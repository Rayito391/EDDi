from app import Base, db


class ProyectoInvestigacion(Base):
    __tablename__ = 'proyectos_investigacion'
    id = db.Column('proyectoid', db.Integer, primary_key=True)
    nombre_proyecto = db.Column('nombreproyecto', db.String(255), nullable=False)
    folio_registro = db.Column('folioregistro', db.String(50), nullable=True)
    vigencia_inicio = db.Column('vigenciainicio', db.Date, nullable=True)
    vigencia_fin = db.Column('vigenciafin', db.Date, nullable=True)
    fuente_financiamiento = db.Column('fuentefinanciamiento', db.String(50), nullable=True)
    dictamen_director = db.Column('dictamendirector', db.String(2), nullable=True)
    recomendacion_comite = db.Column('recomendacioncomite', db.String(2), nullable=True)
    tipo_proyecto = db.Column('tipoproyecto', db.String(50), nullable=False)
