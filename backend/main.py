from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
  pass

db = SQLAlchemy(model_class=Base)

app = Flask(__name__)

# create the app
# configure the SQLite database, relative to the app instance folder
app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://postgres:postgres@localhost:5432/TecDeCuliacann"
# initialize the app with the extension
db.init_app(app)

class Personal(Base):
    __tablename__ = 'personal'
    id = db.Column('personaid', db.Integer, primary_key=True)
    primer_nombre = db.Column('primernombre', db.String(100), nullable=False)
    segundo_nombre = db.Column('segundonombre', db.String(100), nullable=True)
    apellido_paterno = db.Column('apellidopaterno', db.String(100), nullable=True)
    apellido_materno = db.Column('apellidomaterno', db.String(100), nullable=True)
    curp = db.Column('curp', db.String(18), nullable=False)
    rfc = db.Column('rfc', db.String(13), nullable=False)
    fecha_ingreso = db.Column('fechaingreso', db.Date, nullable=False)

class Docente(Base):
    __tablename__ = 'docentes'
    id = db.Column('docenteid', db.Integer, primary_key=True)
    personal_id = db.Column('personaid', db.Integer, db.ForeignKey('personal.personaid'), nullable=False)
    puesto_academico = db.Column('puestoacademico', db.String(100), nullable=True)
    email = db.Column('email', db.String(100), nullable=True)
    password_email = db.Column('passwordemail', db.String(50), nullable=True)

    personal = db.relationship('Personal', backref='docente_info')

class Materia(Base):
    __tablename__ = 'materias'
    id = db.Column('materiaid', db.Integer, primary_key=True)
    nombre_materia = db.Column('nombremateria', db.String(50), nullable=False)
    nivel = db.Column('nivel', db.String(30), nullable=False)
    es_diferente_base = db.Column('esdiferentebase', db.String(2), nullable=False)

class Convocatoria(Base):
    __tablename__ = 'convocatorias'
    id = db.Column('convocatoriaid', db.Integer, primary_key=True)
    nombre_convocatoria = db.Column('nombreconvocatoria', db.String(100), nullable=False)
    periodo = db.Column('periodo', db.String(100), nullable=False)
    fecha_inicio = db.Column('fechainicio', db.Date, nullable=False)
    fecha_fin = db.Column('fechafin', db.Date, nullable=False)

class ExpedienteDocente(Base):
    __tablename__ = 'expediente_docente'
    id = db.Column('expedientedocenteid', db.Integer, primary_key=True)
    convocatoria_id = db.Column('convocatoriaid', db.Integer, db.ForeignKey('convocatorias.convocatoriaid'), nullable=False)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    periodo = db.Column('periodo', db.String(100), nullable=False)
    fecha_creacion = db.Column('fechacreacion', db.Date, nullable=False)

    convocatoria = db.relationship('Convocatoria', backref='expedientes_docentes')
    docente = db.relationship('Docente', backref='expedientes')

class GradoEstudioDocente(Base):
    __tablename__ = 'grados_estudios_docentes'
    id = db.Column('gradoestudiodocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    grado_obtenido = db.Column('gradoobtenido', db.String(50), nullable=True)
    folio_cedula = db.Column('foliocedula', db.String(50), nullable=True)
    fecha_obtencion = db.Column('fechaobtencion', db.Date, nullable=True)
    fecha_expedicion_cedula = db.Column('fechaexpedicioncedula', db.Date, nullable=True)
    institucion_emisora = db.Column('institucionemisora', db.String(255), nullable=True)

    docente = db.relationship('Docente', backref='grados_estudios')

class EstatusLaboralPeriodo(Base):
    __tablename__ = 'estatus_laboral_periodo'
    id = db.Column('estatusperiodoid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    estatus_plaza = db.Column('estatusplaza', db.String(10), nullable=False)
    estatus_plaza_inicio = db.Column('estatusplazainicio', db.Date, nullable=True)
    tipo_nombramiento = db.Column('tiponombramiento', db.String(50), nullable=False)
    percepcion_q07_2025 = db.Column('percepcionq07_2025', db.Numeric(10, 2), nullable=True)
    periodo_evaluado = db.Column('periodoevaluado', db.String(50), nullable=False)
    dias_laborales_totales = db.Column('diaslaboralestotales', db.Integer, nullable=False)
    total_faltas = db.Column('totalfaltas', db.Integer, nullable=True)
    tipo_sancion = db.Column('tiposancion', db.String(100), nullable=True)

    docente = db.relationship('Docente', backref='estatus_laboral_periodos')

# ...existing code...

class Firma(Base):
    __tablename__ = 'firmas'
    id = db.Column('firmaid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    firma = db.Column('firma', db.String(512), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='firmas')

class LicenciaDocente(Base):
    __tablename__ = 'licencias_docentes'
    id = db.Column('licenciadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    tipo_licencia = db.Column('tipolicencia', db.String(50), nullable=False)
    folio_autorizacion = db.Column('folioautorizacion', db.String(50), nullable=True)
    fecha_inicio = db.Column('fechainicio', db.Date, nullable=False)
    fecha_fin = db.Column('fechafin', db.Date, nullable=False)
    es_oficio_autorizado = db.Column('esoficioautorizado', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='licencias')

class ProyectoInvestigacion(Base):
    __tablename__ = 'proyectos_investigacion'
    id = db.Column('proyectoid', db.Integer, primary_key=True)
    nombre_proyecto = db.Column('nombreproyecto', db.String(255), nullable=False)
    folio_registro = db.Column('folioregistro', db.String(50), nullable=True)
    vigencia_inicio = db.Column('vigenciainicio', db.Date, nullable=True)
    vigencia_fin = db.Column('vigenciafin', db.Date, nullable=True)
    fuente_financiamiento = db.Column('fuentefinanciamiento', db.String(50), nullable=True)
    dictamen_director = db.Column('dictamendirector', db.String(2), nullable=True)
    recomendacion_comite = db.Column('recomendacioncomite', db.String(2), nullable=True)
    tipo_proyecto = db.Column('tipoproyecto', db.String(50), nullable=False)

class ProyectoDocente(Base):
    __tablename__ = 'proyectos_docentes'
    id = db.Column('proyectosdocentesid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    proyecto_id = db.Column('proyectoid', db.Integer, db.ForeignKey('proyectos_investigacion.proyectoid'), nullable=False)
    rol = db.Column('rol', db.String(50), nullable=False)
    
    # Relationships
    docente = db.relationship('Docente', backref='proyectos_participacion')
    proyecto = db.relationship('ProyectoInvestigacion', backref='participantes')

class HorarioDocente(Base):
    __tablename__ = 'horarios_docentes'
    id = db.Column('horariodocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(50), nullable=False)
    horario_inicio = db.Column('horarioinicio', db.Time, nullable=False)
    horario_fin = db.Column('horariofin', db.Time, nullable=False)
    carga_reglamentaria = db.Column('cargareglamentaria', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='horarios')

class MateriaDocente(Base):
    __tablename__ = 'materias_docentes'
    id = db.Column('asignaturdocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    materia_id = db.Column('materiaid', db.Integer, db.ForeignKey('materias.materiaid'), nullable=False)
    total_alumnos = db.Column('totalalumnos', db.Integer, nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    es_complementaria = db.Column('escomplementaria', db.String(2), nullable=False)
    
    # Relationships
    docente = db.relationship('Docente', backref='materias_impartidas')
    materia = db.relationship('Materia', backref='docentes_asignados')

class LiberacionDocente(Base):
    __tablename__ = 'liberaciones_docentes'
    id = db.Column('liberaciondocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    tipo_liberacion = db.Column('tipoliberacion', db.String(50), nullable=False)
    folio_liberacion = db.Column('folioliberacion', db.String(50), nullable=True)
    cumplimiento_porcentaje = db.Column('cumplimientoporcentaje', db.Numeric(5, 2), nullable=False)
    esta_liberado = db.Column('estaliberado', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='liberaciones')

class EvaluacionDocente(Base):
    __tablename__ = 'evaluaciones_docentes'
    id = db.Column('evaluaciondocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    tipo_evaluacion = db.Column('tipoevaluacion', db.String(50), nullable=False)
    calificacion = db.Column('calificacion', db.Numeric(5, 2), nullable=False)
    nombre_dpto_academico = db.Column('nombredptoacademico', db.String(100), nullable=True)
    cobertura_estudiantes = db.Column('coberturaestudiantes', db.Numeric(5, 2), nullable=True)
    vobo_sub_academica = db.Column('vobo_subacademica', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='evaluaciones')

class CVUControlDocente(Base):
    __tablename__ = 'cvu_control_docente'
    id = db.Column('cvucontroldocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    fecha_ultima_actualizacion = db.Column('fechaultimaactualizacion', db.Date, nullable=False)
    estado_cvu = db.Column('estadocvu', db.String(50), nullable=False)
    folio_constancia = db.Column('folioconstancia', db.String(50), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='cvu_control', uselist=False)

class ActividadDedicacionDocente(Base):
    __tablename__ = 'actividades_dedicacion_docente'
    id = db.Column('actividaddedicativadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    clave_actividad = db.Column('claveactividad', db.String(20), nullable=False)
    descripcion_actividad = db.Column('descripcionactividad', db.String(255), nullable=False)
    folio_constancia = db.Column('folioconstancia', db.String(50), nullable=True)
    num_estudiantes = db.Column('numestudiantes', db.Integer, nullable=True)
    resultado = db.Column('resultado', db.String(50), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='actividades_dedicacion')

class TutoriaDocente(Base):
    __tablename__ = 'tutorias_docentes'
    id = db.Column('tutoriadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    semestre = db.Column('semestre', db.String(20), nullable=False)
    num_estudiantes = db.Column('numestudiantes', db.Integer, nullable=False)
    folio_constancia = db.Column('folioconstancia', db.String(50), nullable=True)
    impacto_evaluacion = db.Column('impactoevaluacion', db.String(255), nullable=True)
    vobo_sub_academica = db.Column('vobo_subacademica', db.String(2), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='tutorias')

class MaterialDidacticoDocente(Base):
    __tablename__ = 'material_didactico_docente'
    id = db.Column('materialdidacticodenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    tipo_producto = db.Column('tipoproducto', db.String(100), nullable=False)
    tiene_rubrica = db.Column('tienerubrica', db.String(2), nullable=True)
    firma_presidente_academia = db.Column('firmapresidenteacademia', db.String(2), nullable=True)
    firma_dpto_academico = db.Column('firmadptoacademico', db.String(2), nullable=True)
    vobo_sub_academica = db.Column('vobo_subacademica', db.String(2), nullable=True)
    folio_constancia = db.Column('folioconstancia', db.String(50), nullable=True)
    impacto_experiencia_aprendizaje = db.Column('impactoexperienciaaprendizaje', db.String(255), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='materiales_didacticos')

class CursoDocente(Base):
    __tablename__ = 'cursos_docentes'
    id = db.Column('cursodocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    tipo_curso = db.Column('tipocurso', db.String(100), nullable=True)
    nombre_institucion = db.Column('nombreinstitucion', db.String(100), nullable=False)
    folio_oficio_comision = db.Column('foliooficiocomision', db.String(50), nullable=False)
    num_horas = db.Column('numhoras', db.Integer, nullable=True)
    num_registro_constancia = db.Column('numregistroconstancia', db.String(50), nullable=True)
    institucion_constancia = db.Column('institucionconstancia', db.String(100), nullable=False)
    
    # Relationship
    docente = db.relationship('Docente', backref='cursos_impartidos')

class SinodaliaDocente(Base):
    __tablename__ = 'sinodalias_titulaciones_docentes'
    id = db.Column('sinodaliatitulaciondocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    nivel_grado = db.Column('nivelgrado', db.String(50), nullable=False)
    tipo_participacion = db.Column('tipoparticipacion', db.String(50), nullable=False)
    folio_acta = db.Column('folioacta', db.String(50), nullable=True)
    fecha_examen = db.Column('fechaexamen', db.Date, nullable=True)
    es_sinodalia_externa = db.Column('essinodaliaexterna', db.String(2), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='sinodalias')

class ComisionOficioDocente(Base):
    __tablename__ = 'comisiones_oficios_docentes'
    id = db.Column('comisionoficiodocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    tipo_comision = db.Column('tipocomision', db.String(100), nullable=False)
    clave_actividad = db.Column('claveactividad', db.String(10), nullable=False)
    folio_oficio_comision = db.Column('foliooficiocomision', db.String(50), nullable=True)
    folio_constancia_cumplimiento = db.Column('folioconstanciacumplimiento', db.String(50), nullable=True)
    vobo_sub_academica = db.Column('vobo_subacademica', db.String(2), nullable=True)
    nivel_participacion = db.Column('nivelparticipacion', db.String(50), nullable=True)
    
    # Relationship
    docente = db.relationship('Docente', backref='comisiones_oficios')

class ProgramaAcademico(Base):
    __tablename__ = 'programas_academicos'
    id = db.Column('programaid', db.Integer, primary_key=True)
    nombre_programa = db.Column('nombreprograma', db.String(255), nullable=False)
    nivel_programa = db.Column('nivelprograma', db.String(50), nullable=False)
    acreditado = db.Column('acreditado', db.String(2), nullable=True)
    snp_vigente = db.Column('snp_vigente', db.String(2), nullable=True)
    organo_acreditador = db.Column('organoacreditador', db.String(100), nullable=True)
    folio_registro_ddie_dpii = db.Column('folioregistroddie_dpii', db.String(50), nullable=True)

class ProgramaDocente(Base):
    __tablename__ = 'programas_docentes'
    id = db.Column('programadocenteid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    programa_id = db.Column('programaid', db.Integer, db.ForeignKey('programas_academicos.programaid'), nullable=False)
    rol = db.Column('rol', db.String(50), nullable=False)
    
    # Relationships
    docente = db.relationship('Docente', backref='programas_participacion')
    programa = db.relationship('ProgramaAcademico', backref='participantes')

class TipoDocumento(Base):
    __tablename__ = 'tipos_documentos'
    id = db.Column('tipodocumentoid', db.Integer, primary_key=True)
    nombre_corto = db.Column('nombrecorto', db.String(50), nullable=False)
    nombre_completo = db.Column('nombrecompleto', db.String(255), nullable=False)
    factor_asociado = db.Column('factorasociado', db.String(20), nullable=True)
    area_responsable = db.Column('arearesponsable', db.String(100), nullable=True)

class DocumentoGenerado(Base):
    __tablename__ = 'documentos_generados'
    id = db.Column('documentoid', db.Integer, primary_key=True)
    expediente_id = db.Column('expedienteid', db.Integer, db.ForeignKey('expediente_docente.expedientedocenteid'), nullable=False)
    tipo_documento_id = db.Column('tipodocumentoid', db.Integer, db.ForeignKey('tipos_documentos.tipodocumentoid'), nullable=False)
    folio_interno = db.Column('foliointerno', db.String(50), nullable=False)
    fecha_generacion = db.Column('fechageneracion', db.DateTime, nullable=False)
    
    # Relationships
    expediente = db.relationship('ExpedienteDocente', backref='documentos_generados')
    tipo_documento = db.relationship('TipoDocumento', backref='documentos')

class Queja(Base):
    __tablename__ = 'quejas'
    id = db.Column('quejaid', db.Integer, primary_key=True)
    docente_id = db.Column('docenteid', db.Integer, db.ForeignKey('docentes.docenteid'), nullable=False)
    expediente_docente_id = db.Column('expedientedocenteid', db.Integer, db.ForeignKey('expediente_docente.expedientedocenteid'), nullable=True)
    fecha_queja = db.Column('fechaqueja', db.DateTime, nullable=False)
    descripcion = db.Column('descripcion', db.String(500), nullable=False)
    estado_queja = db.Column('estadoqueja', db.String(50), nullable=False)
    fecha_resolucion = db.Column('fecharesolucion', db.DateTime, nullable=True)
    observaciones_resolucion = db.Column('observacionesresolucion', db.String(500), nullable=True)
    
    # Relationships
    docente = db.relationship('Docente', backref='quejas')
    expediente = db.relationship('ExpedienteDocente', backref='quejas')

class ResponsableInformacion(Base):
    __tablename__ = 'responsables_informacion'
    id = db.Column('responsableid', db.Integer, primary_key=True)
    persona_id = db.Column('personaid', db.Integer, db.ForeignKey('personal.personaid'), nullable=False)
    area_responsable = db.Column('arearesponsable', db.String(100), nullable=False)
    email_contacto = db.Column('emailcontacto', db.String(100), nullable=True)
    
    # Relationship
    persona = db.relationship('Personal', backref='responsabilidades')

class ResponsableTipoDocumento(Base):
    __tablename__ = 'responsables_tipo_documento'
    id = db.Column('responsabletipodocid', db.Integer, primary_key=True)
    responsable_id = db.Column('responsableid', db.Integer, db.ForeignKey('responsables_informacion.responsableid'), nullable=False)
    tipo_documento_id = db.Column('tipodocumentoid', db.Integer, db.ForeignKey('tipos_documentos.tipodocumentoid'), nullable=False)
    
    # Relationships
    responsable = db.relationship('ResponsableInformacion', backref='tipos_documento_asignados')
    tipo_documento = db.relationship('TipoDocumento', backref='responsables_asignados')


with app.app_context():
    db.create_all()

@app.route('/')
def home():
    personal = Personal(
        primer_nombre='Juan',
        segundo_nombre='Carlos',
        apellido_paterno='Pérez',
        apellido_materno='López',
        curp='JUCP850101HDFRRL09',
        rfc='JUCP850101XXX',
        fecha_ingreso='2020-01-15'
    )
    db.session.add(personal)
    db.session.commit()
    return "Hello, WWorld!" + str(personal.id)

@app.route('/personal')
def get_personal():
    personal = db.session.query(Personal).all()
    db.session.commit()

    result = []

    for p in personal:
        result.append({
            'id': p.id,
            'primer_nombre': p.primer_nombre,
            'segundo_nombre': p.segundo_nombre,
            'apellido_paterno': p.apellido_paterno,
            'apellido_materno': p.apellido_materno,
            'curp': p.curp,
            'rfc': p.rfc,
            'fecha_ingreso': p.fecha_ingreso.isoformat()
        })
    
    return result
