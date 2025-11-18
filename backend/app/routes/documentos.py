from flask import Blueprint, jsonify, request
from app.models.tipo_documento import TipoDocumento
from app.utils.auth import docente_from_request


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
@documentos_blueprint.get('/<int:documento_id>')
def get_documento(documento_id):
    try:
        docente = docente_from_request(request)
        tipo_documento: TipoDocumento = TipoDocumento.query.filter_by(id=documento_id).first()

        if not tipo_documento:
            return {"error": "Documento no encontrado"}, 404
        
        match tipo_documento.id:
            case 4: # Carta de exclusividad laboral (formato oficial)
                res = docente.to_dict()
                res["persona"] = docente.personal.to_dict()
                return res
            case 6: # Constancia de CVU-TecNM actualizado
                return docente.to_dict()



        return {"documento_id": tipo_documento.to_dict(), "content": "Este es el contenido del documento."}
    except ValueError as e:
        return {"error": e.args}, 401