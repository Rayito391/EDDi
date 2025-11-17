from app import Base, db


class CursoDocente(Base):
    __tablename__ = 'cursos_docentes'
    id = db.Column('cursodocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    tipo_curso = db.Column('tipocurso', db.String(100), nullable=True)
    nombre_institucion = db.Column('nombreinstitucion', db.String(100), nullable=False)
    folio_oficio_comision = db.Column('foliooficiocomision', db.String(50), nullable=False)
    num_horas = db.Column('numhoras', db.Integer, nullable=True)
    num_registro_constancia = db.Column('numregistroconstancia', db.String(50), nullable=True)
    institucion_constancia = db.Column('institucionconstancia', db.String(100), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='cursos_impartidos')
