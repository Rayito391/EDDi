from flask import Blueprint, request
from datetime import datetime

from app import db
from app.models.tutoria_docente import TutoriaDocente
from app.models.docente import Docente
from app.utils.auth import docente_from_request

tutorias_blueprint = Blueprint('tutorias', __name__, url_prefix='/tutorias')


@tutorias_blueprint.put('/docentes/<int:docente_id>')
def asignar_tutorados(docente_id: int):
    """
    Actualiza o crea un registro de tutorías para un docente con el número de estudiantes.
    Espera JSON: { "num_estudiantes": int, "semestre": "YYYY-X" (opcional) }
    Solo usuarios con puesto 'desarrollo' pueden asignar a otros; el propio docente puede actualizarse a sí mismo.
    """
    try:
        solicitante = docente_from_request(request)
    except ValueError as e:
        return {"error": e.args}, 401

    data = request.get_json(silent=True) or {}
    if "num_estudiantes" not in data:
        return {"error": "Falta num_estudiantes"}, 400

    try:
        num_estudiantes = int(data.get("num_estudiantes", 0))
    except (TypeError, ValueError):
        return {"error": "num_estudiantes debe ser entero"}, 400

    if num_estudiantes < 0:
        return {"error": "num_estudiantes no puede ser negativo"}, 400

    semestre_payload = data.get("semestre")

    # Permisos: el propio docente o alguien de desarrollo puede modificar
    if solicitante.id != docente_id and (solicitante.puesto_academico or "").lower() != "desarrollo":
        return {"error": "No autorizado"}, 403

    docente_target = Docente.query.get(docente_id)
    if not docente_target:
        return {"error": "Docente no encontrado"}, 404

    tutoria = None
    semestre = None

    if semestre_payload:
        semestre = semestre_payload
        tutoria = (
            db.session.query(TutoriaDocente)
            .filter_by(docente_id=docente_target.id, semestre=semestre)
            .first()
        )
    else:
        # Sin semestre explícito, intenta usar el último registro existente
        tutoria = (
            db.session.query(TutoriaDocente)
            .filter_by(docente_id=docente_target.id)
            .order_by(TutoriaDocente.id.desc())
            .first()
        )
        semestre = tutoria.semestre if tutoria else datetime.now().strftime("%Y-%m")

    if tutoria:
        tutoria.num_estudiantes = (tutoria.num_estudiantes or 0) + num_estudiantes
    else:
        tutoria = TutoriaDocente(
            docente_id=docente_target.id,
            semestre=semestre,
            num_estudiantes=num_estudiantes,
            folio_constancia=None,
            impacto_evaluacion=None,
            vobo_sub_academica="SI",
        )
        db.session.add(tutoria)

    db.session.commit()
    return {
        "id": tutoria.id,
        "docente_id": tutoria.docente_id,
        "semestre": tutoria.semestre,
        "num_estudiantes": tutoria.num_estudiantes,
    }, 200
