from app import Base, db


class ProyectoDocente(Base):
    __tablename__ = 'proyectos_docentes'
    id = db.Column('proyectosdocentesid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    proyecto_id = db.Column('proyectoid', db.Integer, db.ForeignKey('proyectos_investigacion.proyectoid'), nullable=False)
    rol = db.Column('rol', db.String(50), nullable=False)
    
    # Relationships
    docente = db.relationship('Docente', backref='proyectos_participacion')
    proyecto = db.relationship('ProyectoInvestigacion', backref='participantes')
