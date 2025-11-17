from app import Base, db


class Personal(Base):
    __tablename__ = 'personal'
    id = db.Column('personaid', db.Integer, primary_key=True)
    primer_nombre = db.Column('primernombre', db.String(100), nullable=False)
    segundo_nombre = db.Column('segundonombre', db.String(100), nullable=True)
    apellido_paterno = db.Column('apellidopaterno', db.String(100), nullable=True)
    apellido_materno = db.Column('apellidomaterno', db.String(100), nullable=True)
    curp = db.Column('curp', db.String(18), nullable=False)
    rfc = db.Column('rfc', db.String(13), nullable=False)
    fecha_ingreso = db.Column('fechaingreso', db.Date, nullable=False)