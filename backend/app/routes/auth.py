from flask import Blueprint, jsonify, make_response, request
import jwt
from app.models.docente import Docente
from app.utils.auth import enconde_jwt, docente_from_request
from app import db

auth_blueprint = Blueprint('auth', __name__, url_prefix='/auth')
SECRET_KEY = 'tecnm'

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
    
    token_payload = {
        'docente_id': docente.id,
        'email': docente.email
    }
    
    token = enconde_jwt(token_payload)
    
    response = make_response(jsonify(docente.to_dict()))
    response.status_code = 200
    response.set_cookie('auth_token', token, httponly=True)

    return response

@auth_blueprint.get('/me')
def get_current_user():
    try:
        docente = docente_from_request(request)

        return jsonify(docente.to_dict_with_personal()), 200
    except ValueError as e:
        return {"error": e.args}, 404
    
@auth_blueprint.patch('/change-password')
def change_password():
    try:
        docente = docente_from_request(request)

        if not request.is_json:
            return {"error": "Entradas invalidas"}, 400
        
        current_password = request.json.get('current_password')
        new_password = request.json.get('new_password')

        if not current_password or not new_password:
            return {"error": "Faltan campos obligatorios"}, 400
        
        if docente.password_email != current_password:
            return {"error": "Contraseña actual incorrecta"}, 401
        
        docente.password_email = new_password
        db.session.commit()

        return jsonify({"message": "Contraseña actualizada correctamente"}), 200
    except jwt.ExpiredSignatureError:
        return {"error": "Token expirado"}, 401
    except jwt.InvalidTokenError:
        return {"error": "Token invalido"}, 401