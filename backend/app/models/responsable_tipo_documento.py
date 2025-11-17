from app import Base, db


class ResponsableTipoDocumento(Base):
    __tablename__ = 'responsables_tipo_documento'
    id = db.Column('responsabletipodocid', db.Integer, primary_key=True)
    responsable_id = db.Column('responsableid', db.Integer, db.ForeignKey('responsables_informacion.responsableid'), nullable=False)
    tipo_documento_id = db.Column('tipodocumentoid', db.Integer, db.ForeignKey('tipos_documentos.tipodocumentoid'), nullable=False)
    
    # Relationships
    responsable = db.relationship('ResponsableInformacion', backref='tipos_documento_asignados')
    tipo_documento = db.relationship('TipoDocumento', backref='responsables_asignados')
