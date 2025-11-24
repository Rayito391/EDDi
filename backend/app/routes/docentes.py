from flask import Blueprint, request
from sqlalchemy import func
from app import db
from app.models.docente import Docente
from app.models.tutoria_docente import TutoriaDocente
from app.models.expediente_docente import ExpedienteDocente
from app.models.documento_generado import DocumentoGenerado
from app.models.tipo_documento import TipoDocumento


docentes_blueprint = Blueprint('docentes', __name__, url_prefix='/docentes')

@docentes_blueprint.get('/')
def get_all():
    puesto_academico = request.args.get('puesto_academico')
    docentes = (
        Docente.query.filter_by(puesto_academico=puesto_academico).all()
        if puesto_academico
        else Docente.query.all()
    )

    # Tutorados sum
    tutorados_sub = (
        db.session.query(
            TutoriaDocente.docente_id.label('docente_id'),
            func.coalesce(func.sum(TutoriaDocente.num_estudiantes), 0).label('tutorados'),
        )
        .group_by(TutoriaDocente.docente_id)
        .subquery()
    )

    # Documentos generados total
    docs_total_sub = (
        db.session.query(
            ExpedienteDocente.docente_id.label('docente_id'),
            func.count(DocumentoGenerado.id).label('total_docs'),
        )
        .join(DocumentoGenerado, DocumentoGenerado.expediente_id == ExpedienteDocente.id)
        .group_by(ExpedienteDocente.docente_id)
        .subquery()
    )

    # Documentos inicio (sin factor asociado)
    docs_inicio_sub = (
        db.session.query(
            ExpedienteDocente.docente_id.label('docente_id'),
            func.count(DocumentoGenerado.id).label('docs_inicio'),
        )
        .join(DocumentoGenerado, DocumentoGenerado.expediente_id == ExpedienteDocente.id)
        .join(TipoDocumento, TipoDocumento.id == DocumentoGenerado.tipo_documento_id)
        .filter(func.coalesce(TipoDocumento.factor_asociado, '') == '')
        .group_by(ExpedienteDocente.docente_id)
        .subquery()
    )

    # Documentos factor (con factor asociado)
    docs_factor_sub = (
        db.session.query(
            ExpedienteDocente.docente_id.label('docente_id'),
            func.count(DocumentoGenerado.id).label('docs_factor'),
        )
        .join(DocumentoGenerado, DocumentoGenerado.expediente_id == ExpedienteDocente.id)
        .join(TipoDocumento, TipoDocumento.id == DocumentoGenerado.tipo_documento_id)
        .filter(func.coalesce(TipoDocumento.factor_asociado, '') != '')
        .group_by(ExpedienteDocente.docente_id)
        .subquery()
    )

    tutorados_map = {row.docente_id: row.tutorados for row in db.session.query(tutorados_sub).all()}
    total_map = {row.docente_id: row.total_docs for row in db.session.query(docs_total_sub).all()}
    inicio_map = {row.docente_id: row.docs_inicio for row in db.session.query(docs_inicio_sub).all()}
    factor_map = {row.docente_id: row.docs_factor for row in db.session.query(docs_factor_sub).all()}

    result = []
    for docente in docentes:
        item = docente.to_dict()
        item["tutorados"] = int(tutorados_map.get(docente.id, 0))
        item["total_documentos"] = int(total_map.get(docente.id, 0))
        item["documentos_inicio"] = int(inicio_map.get(docente.id, 0))
        item["documentos_factor"] = int(factor_map.get(docente.id, 0))
        result.append(item)

    return {"docentes": result}, 200
