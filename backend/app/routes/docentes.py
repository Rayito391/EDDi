from flask import Blueprint, request
from sqlalchemy import func
from app import db
from app.models.docente import Docente
from app.models.tutoria_docente import TutoriaDocente
from app.models.expediente_docente import ExpedienteDocente
from app.models.documento_generado import DocumentoGenerado
from app.models.tipo_documento import TipoDocumento
from app.routes.documentos import _eligibility_for_docente


docentes_blueprint = Blueprint('docentes', __name__, url_prefix='/docentes')

@docentes_blueprint.get('/')
def get_all():
    puesto_academico = request.args.get('puesto_academico')
    docentes = (
        Docente.query.filter(func.lower(Docente.puesto_academico) == func.lower(puesto_academico)).all()
        if puesto_academico
        else Docente.query.all()
    )

    # Tutorados (solo tipo_registro = 'tutorado')
    tutorados_sub = (
        db.session.query(
            TutoriaDocente.docente_id.label('docente_id'),
            func.coalesce(func.sum(TutoriaDocente.num_estudiantes), 0).label('tutorados'),
        )
        .filter(func.lower(TutoriaDocente.tipo_registro) == 'tutorado')
        .group_by(TutoriaDocente.docente_id)
        .subquery()
    )

    # Asesorados (solo tipo_registro = 'asesorado')
    asesorados_sub = (
        db.session.query(
            TutoriaDocente.docente_id.label('docente_id'),
            func.coalesce(func.sum(TutoriaDocente.num_estudiantes), 0).label('asesorados'),
        )
        .filter(func.lower(TutoriaDocente.tipo_registro) == 'asesorado')
        .group_by(TutoriaDocente.docente_id)
        .subquery()
    )

    tutorados_map = {row.docente_id: row.tutorados for row in db.session.query(tutorados_sub).all()}
    asesorados_map = {row.docente_id: row.asesorados for row in db.session.query(asesorados_sub).all()}

    result = []
    for docente in docentes:
        item = docente.to_dict()
        if item.get("puesto_academico"):
            item["puesto_academico"] = item["puesto_academico"].capitalize()
        item["tutorados"] = int(tutorados_map.get(docente.id, 0))
        item["asesorados"] = int(asesorados_map.get(docente.id, 0))
        # Documentos ya generados
        total_generados = (
            db.session.query(func.count(DocumentoGenerado.id))
            .join(ExpedienteDocente, DocumentoGenerado.expediente_id == ExpedienteDocente.id)
            .filter(ExpedienteDocente.docente_id == docente.id)
            .scalar()
            or 0
        )
        # Documentos que podría generar según elegibilidad actual
        tipos = TipoDocumento.query.all()
        checks = _eligibility_for_docente(docente.id)
        disponibles = [t for t in tipos if checks.get(t.id, True)]
        item["total_documentos"] = int(total_generados)
        item["documentos_inicio"] = f"{len(disponibles)} / {len(tipos)}"
        result.append(item)

    return {"docentes": result}, 200
