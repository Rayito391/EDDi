from app import Base, db


class ResponsableInformacion(Base):
    __tablename__ = 'responsables_informacion'
    id = db.Column('responsableid', db.Integer, primary_key=True)
    persona_id = db.Column('personaid', db.Integer, db.ForeignKey('personal.personaid'), nullable=False)
    area_responsable = db.Column('arearesponsable', db.String(100), nullable=False)
    email_contacto = db.Column('emailcontacto', db.String(100), nullable=True)
    
    # Relationship
    persona = db.relationship('Personal', backref='responsabilidades')