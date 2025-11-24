from flask import Blueprint, request

from app.models.docente import Docente


docentes_blueprint = Blueprint('docentes', __name__, url_prefix='/docentes')

@docentes_blueprint.get('/')
def get_all():
    puesto_academico = request.args.get()
    if puesto_academico:
        docentes = Docente.query.filter_by(puesto_academico=puesto_academico).all()
    else:
        docentes = Docente.query.all()
    return {"docentes": [docente.to_dict() for docente in docentes]}, 200