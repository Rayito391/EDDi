from app import Base, db


class EstatusLaboralPeriodo(Base):
    __tablename__ = 'estatus_laboral_periodo'
    id = db.Column('estatusperiodoid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    estatus_plaza = db.Column('estatusplaza', db.String(10), nullable=False)
    estatus_plaza_inicio = db.Column('estatusplazainicio', db.Date, nullable=True)
    tipo_nombramiento = db.Column('tiponombramiento', db.String(50), nullable=False)
    percepcion_q07_2025 = db.Column('percepcionq07_2025', db.Numeric(10, 2), nullable=True)
    periodo_evaluado = db.Column('periodoevaluado', db.String(50), nullable=False)
    dias_laborales_totales = db.Column('diaslaboralestotales', db.Integer, nullable=False)
    total_faltas = db.Column('totalfaltas', db.Integer, nullable=True)
    tipo_sancion = db.Column('tiposancion', db.String(100), nullable=True)

    docente = db.relationship('Docente', backref='estatus_laboral_periodos')
