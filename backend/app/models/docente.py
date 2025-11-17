from app import db


class Docente(db.Model):
    __tablename__ = 'docentes'
    id = db.Column('docenteid', db.Integer, primary_key=True)
    personal_id = db.Column('personaid', db.Integer, db.ForeignKey('personal.personaid'), nullable=False)
    puesto_academico = db.Column('puestoacademico', db.String(100), nullable=True)
    email = db.Column('email', db.String(100), nullable=True)
    password_email = db.Column('passwordemail', db.String(50), nullable=True)

    personal = db.relationship('Personal', backref='docentes')

    def to_dict(self):
        return {
            "id": self.id,
            "personal_id": self.personal_id,
            "puesto_academico": self.puesto_academico,
            "email": self.email,
            "primer_nombre": self.personal.primer_nombre if self.personal else None,
            "segundo_nombre": self.personal.segundo_nombre if self.personal else None,
            "apellido_paterno": self.personal.apellido_paterno if self.personal else None,
            "apellido_materno": self.personal.apellido_materno if self.personal else None,
        }
