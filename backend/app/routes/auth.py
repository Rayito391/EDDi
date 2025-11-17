from flask import Blueprint, make_response, request
from app.models.docente import Docente

auth_blueprint = Blueprint('auth', __name__, url_prefix='/auth')

@auth_blueprint.post('/login')
def login():
    if request.cookies.get('docente_id'):
        return {"message": "Ya autenticado"}, 200

    if not request.is_json:
        return {"error": "Entradas invalidas"}, 400
    
    email, password = request.json.get('email'), request.json.get('password')

    if not email or not password:
        return {"error": "Faltan campos obligatorios"}, 400
    
    docente = Docente.query.filter_by(email=email, password_email=password).first()

    if not docente:
        return {"error": "Credenciales invalidas"}, 401
    
    response = make_response()
    response.status_code = 200
    response.set_cookie('docente_id', str(docente.id), httponly=True, samesite='Lax')

    return response

@auth_blueprint.post('/logout')
def logout():
    response = make_response()
    response.status_code = 200
    response.delete_cookie('docente_id')

    return response
