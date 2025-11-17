from app import db


class Docente(db.Model):
    __tablename__ = 'docentes'
    id = db.Column('docenteid', db.Integer, primary_key=True)
    personal_id = db.Column('personaid', db.Integer, db.ForeignKey('personal.personaid'), nullable=False)
    puesto_academico = db.Column('puestoacademico', db.String(100), nullable=True)
    email = db.Column('email', db.String(100), nullable=True)
    password_email = db.Column('passwordemail', db.String(50), nullable=True)
