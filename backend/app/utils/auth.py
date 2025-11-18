from flask import Request
import jwt

from app.models.docente import Docente


SECRET_KEY = 'tecnm'

def enconde_jwt(payload):
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    return token

def docente_from_request(request: Request) -> Docente:
    try:
        token = request.cookies.get('auth_token')
        
        if not token:
            raise ValueError("No autenticado")
        
        docente_id = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])["docente_id"]
        return Docente.query.filter_by(id = docente_id).first()
    except jwt.ExpiredSignatureError:
        raise ValueError("Token expirado")
    except jwt.InvalidTokenError:
        raise ValueError("Token invalido")