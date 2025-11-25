from flask import Blueprint, request

from app import db
from app.models.docente import Docente
from app.models.firma import Firma
from app.utils.auth import docente_from_request


firmas_blueprint = Blueprint('firmas', __name__, url_prefix='/firmas')

@firmas_blueprint.put("/docentes/<int:docente_id>")
def upload_firma(docente_id):
    try:
        docente = docente_from_request(request)

        if docente.puesto_academico != 'subdireccion':
            return {"error": "No autorizado para subir firmas de otros docentes."}, 403
        
        docente_target = Docente.query.get(docente_id)

        if not docente_target:
            return {"error": "Docente no encontrado."}, 404
        
        firma = Firma.query.filter_by(docente_id=docente_target.id).first()

        if not firma:
            firma = Firma(docente_id=docente_target.id)

        firma.firma = request.get_data()
        db.session.add(firma)
        db.session.commit()
        return {"message": "Firma subida exitosamente."}, 200
    except ValueError as e:
        return {"error": e.args}, 401
    except KeyError:
        return {"error": "Falta el archivo de firma."}, 400