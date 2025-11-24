from app import Base, db


class Queja(db.Model):
    __tablename__ = 'quejas'
    id = db.Column('quejaid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    expediente_docente_id = db.Column('expedientedocenteid', db.Integer, db.ForeignKey('expediente_docente.expedientedocenteid'), nullable=True)
    fecha_queja = db.Column('fechaqueja', db.DateTime, nullable=False)
    descripcion = db.Column('descripcion', db.String(500), nullable=False)
    estado_queja = db.Column('estadoqueja', db.String(50), nullable=False)
    fecha_resolucion = db.Column('fecharesolucion', db.DateTime, nullable=True)
    observaciones_resolucion = db.Column('observacionesresolucion', db.String(500), nullable=True)
    
    # Relationships
    docente = db.relationship('Docente', backref='quejas')
    expediente = db.relationship('ExpedienteDocente', backref='quejas')

    def to_dict(self):
        return {
            'id': self.id,
            'docente_id': self.docente_id,
            'expediente_docente_id': self.expediente_docente_id,
            'fecha_queja': self.fecha_queja.isoformat(),
            'descripcion': self.descripcion,
            'estado_queja': self.estado_queja,
            'fecha_resolucion': self.fecha_resolucion.isoformat() if self.fecha_resolucion else None,
            'observaciones_resolucion': self.observaciones_resolucion
        }