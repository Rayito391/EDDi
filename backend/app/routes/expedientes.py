from datetime import datetime
from flask import Blueprint, request
from app.models.queja import Queja
from app.utils.auth import docente_from_request
from app import db


expediente_blueprint = Blueprint('expedientes', __name__, url_prefix='/expedientes')

@expediente_blueprint.get('/<int:expediente_id>/quejas')
def get_quejas_by_expediente(expediente_id):
    try:
        docente = docente_from_request(request)
        quejas: list[Queja] = Queja.query.filter_by(docente_id = docente.id, expediente_docente_id=expediente_id).order_by(Queja.fecha_queja).all()
        return [queja.to_dict() for queja in quejas], 200
    except ValueError as e:
        return {"error": e.args}, 401
    
    
@expediente_blueprint.post('/<int:expediente_id>/quejas')
def create_queja(expediente_id):
    try:
        docente = docente_from_request(request)
        data = request.get_json()
        nueva_queja = Queja(
            docente_id = docente.id,
            expediente_docente_id = expediente_id,
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
    
    
@expediente_blueprint.get('/<int:expediente_id>/quejas/<int:queja_id>')
def get_queja_by_id(expediente_id, queja_id):
    try:
        docente = docente_from_request(request)
        queja: Queja = Queja.query.filter_by(docente_id = docente.id, expediente_docente_id=expediente_id, id=queja_id).first()
        if not queja:
            return {"error": "Queja no encontrada"}, 404
        return queja.to_dict(), 200
    except ValueError as e:
        return {"error": e.args}, 401
    

@expediente_blueprint.put('/<int:expediente_id>/quejas/<int:queja_id>/estado')
def update_status(expediente_id, queja_id):
    try:
        docente = docente_from_request(request)
        data = request.get_json()
        queja: Queja = Queja.query.filter_by(docente_id = docente.id, expediente_docente_id=expediente_id, id=queja_id).first()
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
