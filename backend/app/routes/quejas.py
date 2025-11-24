import datetime
from flask import Blueprint, request

from app.models.queja import Queja
from app.utils.auth import docente_from_request
from app import db


quejas_blueprint = Blueprint('quejas', __name__, url_prefix='/quejas')

@quejas_blueprint.get('/')
def get_quejas():
    quejas = Queja.query.all()
    return [queja.to_dict() for queja in quejas], 200

@quejas_blueprint.post('/')
def create_queja():
    try:
        docente = docente_from_request(request)
        data = request.get_json()
        nueva_queja = Queja(
            docente_id = docente.id,
            fecha_queja = datetime.now(),
            descripcion = data['descripcion'],
            estado_queja = 'Pendiente',
        )
        db.session.add(nueva_queja)
        db.session.commit()
        return nueva_queja.to_dict(), 201
    except ValueError as e:
        return {"error": e.args}, 401
    except KeyError as e:
        return {"error": f"Faltan parametros {e.args}"}, 400
    

@quejas_blueprint.get('/<int:queja_id>')
def get_queja_by_id(queja_id):
    try:
        docente = docente_from_request(request)
        queja: Queja = Queja.query.filter_by(docente_id = docente.id, id=queja_id).first()
        if not queja:
            return {"error": "Queja no encontrada"}, 404
        return queja.to_dict(), 200
    except ValueError as e:
        return {"error": e.args}, 401
    

@quejas_blueprint.put('/<int:queja_id>/estado')
def update_status(queja_id):
    try:
        docente = docente_from_request(request)
        data = request.get_json()
        queja: Queja = Queja.query.filter_by(docente_id = docente.id, id=queja_id).first()
        if not queja:
            return {"error": "Queja no encontrada"}, 404
        estado_queja = data['estado_queja']
        queja.estado_queja = estado_queja

        if estado_queja == 'Resuelta':
            queja.fecha_resolucion = datetime.now()

        db.session.commit()
        return queja.to_dict(), 200
    except ValueError as e:
        return {"error": e.args}, 401
    except KeyError as e:
        return {"error": f"Faltan parametros {e.args}"}, 400