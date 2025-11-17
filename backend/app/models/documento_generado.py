from app import Base, db


class DocumentoGenerado(Base):
    __tablename__ = 'documentos_generados'
    id = db.Column('documentoid', db.Integer, primary_key=True)
    expediente_id = db.Column('expedienteid', db.Integer, db.ForeignKey('expediente_docente.expedientedocenteid'), nullable=False)
    tipo_documento_id = db.Column('tipodocumentoid', db.Integer, db.ForeignKey('tipos_documentos.tipodocumentoid'), nullable=False)
    folio_interno = db.Column('foliointerno', db.String(50), nullable=False)
    fecha_generacion = db.Column('fechageneracion', db.DateTime, nullable=False)
    
    # Relationships
    expediente = db.relationship('ExpedienteDocente', backref='documentos_generados')
    tipo_documento = db.relationship('TipoDocumento', backref='documentos')
