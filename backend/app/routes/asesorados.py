from flask import Blueprint, request
from datetime import datetime

from app import db
from app.models.tutoria_docente import TutoriaDocente
from app.models.docente import Docente
from app.utils.auth import docente_from_request

asesorados_blueprint = Blueprint('asesorados', __name__, url_prefix='/asesorados')


@asesorados_blueprint.put('/docentes/<int:docente_id>')
def asignar_asesorados(docente_id: int):
    """
    Actualiza o crea un registro para asesorados (reuse de tutorias_docentes).
    Acepta JSON: { "num_asesorados": int, "semestre": "YYYY-X" (opcional) }
    Si no envías semestre, se usará el último registro del docente o el mes actual.
    Permisos: el propio docente o puesto 'desarrollo'.
    """
    try:
        solicitante = docente_from_request(request)
    except ValueError as e:
        return {"error": e.args}, 401

    data = request.get_json(silent=True) or {}
    if "num_asesorados" not in data and "num_estudiantes" not in data:
        return {"error": "Falta num_asesorados"}, 400

    try:
        num_asesorados = int(data.get("num_asesorados", data.get("num_estudiantes", 0)))
    except (TypeError, ValueError):
        return {"error": "num_asesorados debe ser entero"}, 400

    if num_asesorados < 0:
        return {"error": "num_asesorados no puede ser negativo"}, 400

    semestre_payload = data.get("semestre")

    # Permisos
    if solicitante.id != docente_id and (solicitante.puesto_academico or "").lower() != "desarrollo":
        return {"error": "No autorizado"}, 403

    docente_target = Docente.query.get(docente_id)
    if not docente_target:
        return {"error": "Docente no encontrado"}, 404

    tutoria = None
    semestre = None
    tipo = "asesorado"

    if semestre_payload:
        semestre = semestre_payload
        tutoria = (
            db.session.query(TutoriaDocente)
            .filter_by(docente_id=docente_target.id, semestre=semestre, tipo_registro=tipo)
            .first()
        )
    else:
        tutoria = (
            db.session.query(TutoriaDocente)
            .filter_by(docente_id=docente_target.id, tipo_registro=tipo)
            .order_by(TutoriaDocente.id.desc())
            .first()
        )
        semestre = tutoria.semestre if tutoria else datetime.now().strftime("%Y-%m")

    if tutoria:
        tutoria.num_estudiantes = (tutoria.num_estudiantes or 0) + num_asesorados
    else:
        tutoria = TutoriaDocente(
            docente_id=docente_target.id,
            semestre=semestre,
            tipo_registro=tipo,
            num_estudiantes=num_asesorados,
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
        "num_asesorados": tutoria.num_estudiantes,
    }, 200
