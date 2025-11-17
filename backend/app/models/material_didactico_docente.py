from app import Base, db


class MaterialDidacticoDocente(Base):
    __tablename__ = 'material_didactico_docente'
    id = db.Column('materialdidacticodenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    tipo_producto = db.Column('tipoproducto', db.String(100), nullable=False)
    tiene_rubrica = db.Column('tienerubrica', db.String(2), nullable=True)
    firma_presidente_academia = db.Column('firmapresidenteacademia', db.String(2), nullable=True)
    firma_dpto_academico = db.Column('firmadptoacademico', db.String(2), nullable=True)
    vobo_sub_academica = db.Column('vobo_subacademica', db.String(2), nullable=True)
    folio_constancia = db.Column('folioconstancia', db.String(50), nullable=True)
    impacto_experiencia_aprendizaje = db.Column('impactoexperienciaaprendizaje', db.String(255), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='materiales_didacticos')
