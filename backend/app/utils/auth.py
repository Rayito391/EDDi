import jwt

from app.models.docente import Docente


SECRET_KEY = 'tecnm'

def enconde_jwt(payload):
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    return token

def docente_from_jwt(token) -> Docente:
    try:
        docente_id = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])["docente_id"]
        return Docente.query.filter_by(id = docente_id).first()
    except jwt.ExpiredSignatureError:
        raise ValueError("Token expirado")
    except jwt.InvalidTokenError:
        raise ValueError("Token invalido")