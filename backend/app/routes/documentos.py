from flask import Blueprint, jsonify, request, send_file
from sqlalchemy import func
from datetime import datetime
import uuid
import base64
import io
from app import db
from app.models.tipo_documento import TipoDocumento
from app.models.tutoria_docente import TutoriaDocente
from app.models.documento_generado import DocumentoGenerado
from app.models.expediente_docente import ExpedienteDocente
from app.models.estatus_laboral_periodo import EstatusLaboralPeriodo
from app.models.horario_docente import HorarioDocente
from app.models.materia_docente import MateriaDocente
from app.models.proyecto_docente import ProyectoDocente
from app.models.cvu_control_docente import CVUControlDocente
from app.models.licencia_docente import LicenciaDocente
from app.models.grado_estudio_docente import GradoEstudioDocente
from app.models.liberacion_docente import LiberacionDocente
from app.models.evaluacion_docente import EvaluacionDocente
from app.utils.auth import docente_from_request

# PDF base de ejemplo para preview/descarga
SAMPLE_PDF_B64 = (
    "JVBERi0xLjQKJcKlwrHDqwoKMSAwIG9iago8PC9UeXBlIC9DYXRhbG9nL1BhZ2VzIDIgMCBSCj4+CmVuZG9iagoK"
    "MiAwIG9iago8PC9UeXBlIC9QYWdlcy9LaWRzIFszIDAgUl0vQ291bnQgMQo+PgplbmRvYmoKCjMgMCBvYmoKPDwv"
    "VHlwZSAvUGFnZS9QYXJlbnQgMiAwIFIvTWVkaWFCb3ggWzAgMCA2MTIgNzkyXS9Db250ZW50cyA0IDAgUi9SZXNv"
    "dXJjZXMgPDwvRm9udCA8PC9GMSA1IDAgUj4+Pj4+CmVuZG9iagoKNCAwIG9iago8PC9MZW5ndGggNDQ+PgpzdHJl"
    "YW0KQlQKL0YxIDI0IFRmCjEwMCA3MDAgVGQKKEV4YW1wbGUgUEZGKSBUCkVUCmdyZWFcblZpc3RhIHByZXZpYSBk"
    "ZSBkb2N1bWVudG8KZW5kc3RyZWFtCmVuZG9iagoKNSAwIG9iago8PC9UeXBlIC9Gb250L1N1YnR5cGUgL1R5cGUx"
    "L0Jhc2VGb250IC9IZWx2ZXRpY2E+PgplbmRvYmoKCnhyZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAw"
    "MDA5OSAwMDAwMCBuIAowMDAwMDAwMTczIDAwMDAwIG4gCjAwMDAwMDAzMjYgMDAwMDAgbiAKMDAwMDAwMDQzNyAw"
    "MDAwMCBuIAowMDAwMDAwNjIzIDAwMDAwIG4gCnRyYWlsZXIKPDwvU2l6ZSA2L1Jvb3QgMSAwIFIvSW5mbyA2IDAg"
    "Ugo+PgpzdGFydHhyZWYKNzQ3CiUlRU9GCg=="
)


documentos_blueprint = Blueprint('documentos', __name__, url_prefix='/documentos')

"""
('Documento 01', 'Constancia de Recursos Humanos sobre nombramiento, asistencia y sanciones', NULL, NULL),
('Documento 02', 'Talón de pago (quincena 07 del 2025, sin DT o I8)', NULL, NULL),
('Documento 03', 'Horarios de labores 2024 y 2025', NULL, NULL),
('Documento 04', 'Carta de exclusividad laboral (formato oficial)', NULL, NULL),
('Documento 05', 'Proyecto de investigación vigente con dictamen y recomendación institucional', NULL, NULL),
('Documento 06', 'Constancia de CVU-TecNM actualizado', NULL, NULL),
('Documento 07', 'Constancia de asignaturas impartidas y estudiantes atendidos', NULL, NULL),
('Documento 08', 'Oficio de autorización de período sabático o beca comisión', NULL, NULL),
('Documento 09', 'Licencia por gravidez (si aplica)', NULL, NULL),
('Documento 10', 'Cédula profesional o acta de examen de grado', NULL, NULL),
('Documento 11', 'Formato de liberación de actividades docentes (dos semestres)', NULL, NULL),
('Documento 12', 'Carta de liberación de actividades académicas (Anexo XXXVII)', NULL, NULL),
('Documento 13', 'Evaluaciones departamentales y autoevaluación (licenciatura o posgrado)', NULL, NULL),
('Documento 14', 'Evaluaciones del desempeño frente a grupo (mínimo 60% del estudiantado)', NULL, NULL)
"""
def _get_latest(model, docente_id):
    return db.session.query(model).filter_by(docente_id=docente_id).order_by(model.id.desc()).first()


def _eligibility_for_docente(docente_id: int):
    estatus = _get_latest(EstatusLaboralPeriodo, docente_id)
    horario = _get_latest(HorarioDocente, docente_id)
    materias_2024 = (
        db.session.query(MateriaDocente)
        .filter(
            MateriaDocente.docente_id == docente_id,
            MateriaDocente.semestre.like('2024%'),
        )
        .count()
    )
    materias_2025 = (
        db.session.query(MateriaDocente)
        .filter(
            MateriaDocente.docente_id == docente_id,
            MateriaDocente.semestre.like('2025%'),
        )
        .count()
    )
    proyecto_vigente = db.session.query(ProyectoDocente).filter_by(docente_id=docente_id).count() > 0
    cvu = _get_latest(CVUControlDocente, docente_id)
    licencia = _get_latest(LicenciaDocente, docente_id)
    grado = _get_latest(GradoEstudioDocente, docente_id)
    liberacion = _get_latest(LiberacionDocente, docente_id)
    eval_departamental = (
        db.session.query(EvaluacionDocente)
        .filter_by(docente_id=docente_id, tipo_evaluacion='Desempeno')
        .order_by(EvaluacionDocente.id.desc())
        .first()
    )
    eval_estudiantes = (
        db.session.query(EvaluacionDocente)
        .filter_by(docente_id=docente_id, tipo_evaluacion='Estudiantes')
        .order_by(EvaluacionDocente.id.desc())
        .first()
    )

    def asistencia_ok():
        if not estatus or not estatus.dias_laborales_totales:
            return False
        if estatus.total_faltas is None:
            return False
        asistencia = 100 * (estatus.dias_laborales_totales - estatus.total_faltas) / estatus.dias_laborales_totales
        return asistencia >= 90

    checks = {
        1: bool(
            estatus
            and (estatus.tipo_nombramiento or '').lower().find('completo') != -1
            and (estatus.estatus_plaza_inicio is None or estatus.estatus_plaza_inicio <= datetime(2024, 1, 1).date())
            and not estatus.tipo_sancion
            and asistencia_ok()
        ),
        2: bool(estatus and estatus.percepcion_q07_2025 is not None),
        3: bool(horario and horario.carga_reglamentaria and materias_2024 > 0 and materias_2025 > 0),
        4: True,  # depende de descarga de formato, se permite mostrar
        6: bool(cvu),
        7: bool(materias_2024 > 0),
        8: bool(licencia and licencia.tipo_licencia and licencia.es_oficio_autorizado == 'SI'),
        9: bool(licencia and licencia.tipo_licencia),
        10: bool(grado and (grado.folio_cedula or grado.grado_obtenido)),
        11: bool(liberacion and liberacion.esta_liberado == 'SI'),
        12: bool(liberacion and liberacion.esta_liberado == 'SI'),
        13: bool(eval_departamental and eval_departamental.calificacion >= 70),
        14: bool(
            eval_estudiantes
            and eval_estudiantes.calificacion >= 70
            and (eval_estudiantes.cobertura_estudiantes or 0) >= 60
        ),
        18: bool(
            eval_estudiantes
            and eval_estudiantes.calificacion >= 70
            and (eval_estudiantes.cobertura_estudiantes or 0) >= 60
        ),
    }
    return checks


@documentos_blueprint.get('/')
def list_documentos():
    """Devuelve los tipos de documento que el docente puede levantar."""
    try:
        docente = docente_from_request(request)  # valida autenticación
        tipos = TipoDocumento.query.all()
        checks = _eligibility_for_docente(docente.id)
        disponibles = []
        for t in tipos:
            allowed = checks.get(t.id, True)
            if allowed:
                disponibles.append(t.to_dict())
        return jsonify(disponibles), 200
    except ValueError as e:
        return {"error": e.args}, 401


@documentos_blueprint.get('/permiso')
def puede_generar_documentos():
    """Indica si el docente puede generar al menos un documento, basado en elegibilidad."""
    try:
        docente = docente_from_request(request)
        checks = _eligibility_for_docente(docente.id)
        tipos = TipoDocumento.query.all()
        disponibles = [t for t in tipos if checks.get(t.id, True)]
        return {
            "puede_generar": len(disponibles) > 0,
            "total_documentos_disponibles": len(disponibles),
        }
    except ValueError as e:
        return {"error": e.args}, 401


@documentos_blueprint.get('/mis')
def documentos_generados():
    """Lista de documentos generados para el docente autenticado."""
    try:
        docente = docente_from_request(request)
        registros = (
            db.session.query(DocumentoGenerado, TipoDocumento)
            .join(TipoDocumento, DocumentoGenerado.tipo_documento_id == TipoDocumento.id)
            .join(ExpedienteDocente, DocumentoGenerado.expediente_id == ExpedienteDocente.id)
            .filter(ExpedienteDocente.docente_id == docente.id)
            .order_by(DocumentoGenerado.fecha_generacion.desc())
            .all()
        )
        data = []
        for generado, tipo in registros:
            data.append(
                {
                    "id": generado.id,
                    "titulo": tipo.nombre_completo,
                    "folio": generado.folio_interno,
                    "fecha": generado.fecha_generacion.isoformat(),
                    "tipo_documento_id": tipo.id,
                }
            )
        return jsonify(data)
    except ValueError as e:
        return {"error": e.args}, 401


def _doc_generado_para_docente(docente_id: int, doc_id: int):
    return (
        db.session.query(DocumentoGenerado, TipoDocumento, ExpedienteDocente)
        .join(TipoDocumento, DocumentoGenerado.tipo_documento_id == TipoDocumento.id)
        .join(ExpedienteDocente, DocumentoGenerado.expediente_id == ExpedienteDocente.id)
        .filter(DocumentoGenerado.id == doc_id, ExpedienteDocente.docente_id == docente_id)
        .first()
    )


@documentos_blueprint.get('/mis/<int:doc_id>/preview')
def preview_documento(doc_id):
    """Devuelve un PDF de ejemplo para el documento generado (preview inline)."""
    try:
        docente = docente_from_request(request)
        registro = _doc_generado_para_docente(docente.id, doc_id)
        if not registro:
            return {"error": "Documento no encontrado"}, 404
        pdf_bytes = base64.b64decode(SAMPLE_PDF_B64)
        return send_file(
            io.BytesIO(pdf_bytes),
            mimetype='application/pdf',
            download_name=f'documento_{doc_id}.pdf',
            as_attachment=False,
        )
    except ValueError as e:
        return {"error": e.args}, 401


@documentos_blueprint.get('/mis/<int:doc_id>/download')
def download_documento(doc_id):
    """Descarga PDF de ejemplo para el documento generado."""
    try:
        docente = docente_from_request(request)
        result = _doc_generado_para_docente(docente.id, doc_id)
        if not result:
            return {"error": "Documento no encontrado"}, 404
        generado, tipo, _exp = result  # type: ignore
        pdf_bytes = base64.b64decode(SAMPLE_PDF_B64)
        filename = f"{tipo.nombre_corto or 'documento'}_{doc_id}.pdf"
        return send_file(
            io.BytesIO(pdf_bytes),
            mimetype='application/pdf',
            download_name=filename,
            as_attachment=True,
        )
    except ValueError as e:
        return {"error": e.args}, 401


@documentos_blueprint.post('/generar')
def generar_documento():
    """Crea un registro de DocumentoGenerado para el docente autenticado."""
    try:
        docente = docente_from_request(request)
        body = request.get_json(silent=True) or {}
        tipo_id = body.get('tipo_documento_id')

        if not tipo_id:
            return {"error": "tipo_documento_id requerido"}, 400

        tipo = TipoDocumento.query.filter_by(id=tipo_id).first()
        if not tipo:
            return {"error": "Tipo de documento no encontrado"}, 404

        expediente = (
            db.session.query(ExpedienteDocente)
            .filter_by(docente_id=docente.id)
            .order_by(ExpedienteDocente.fecha_creacion.desc())
            .first()
        )
        if not expediente:
            return {"error": "No hay expediente asociado al docente"}, 400

        folio = f"GEN-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}-{uuid.uuid4().hex[:6].upper()}"
        generado = DocumentoGenerado(
            expediente_id=expediente.id,
            tipo_documento_id=tipo.id,
            folio_interno=folio,
            fecha_generacion=datetime.utcnow(),
        )
        db.session.add(generado)
        db.session.commit()

        return {
            "id": generado.id,
            "folio": generado.folio_interno,
            "fecha": generado.fecha_generacion.isoformat(),
            "tipo_documento_id": tipo.id,
            "titulo": tipo.nombre_completo,
        }, 201
    except ValueError as e:
        return {"error": e.args}, 401


@documentos_blueprint.get('/<int:documento_id>')
def get_documento(documento_id):
    try:
        docente = docente_from_request(request)
        tipo_documento: TipoDocumento = TipoDocumento.query.filter_by(id=documento_id).first()

        if not tipo_documento:
            return {"error": "Documento no encontrado"}, 404
        
        match tipo_documento.id:
            case 4: 
                res = docente.to_dict()
                res["persona"] = docente.personal.to_dict()
                return res
            case 6: 
                return docente.to_dict()



        return {"documento_id": tipo_documento.to_dict(), "content": "Este es el contenido del documento."}
    except ValueError as e:
        return {"error": e.args}, 401
