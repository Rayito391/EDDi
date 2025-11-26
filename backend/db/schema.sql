
CREATE SEQUENCE personal_seq START 1;
CREATE SEQUENCE docentes_seq START 1;
CREATE SEQUENCE firmas_seq START 1;
CREATE SEQUENCE materias_seq START 1;
CREATE SEQUENCE convocatorias_seq START 1;
CREATE SEQUENCE grados_seq START 1;
CREATE SEQUENCE estatus_lab_seq START 1;
CREATE SEQUENCE licencias_seq START 1;
CREATE SEQUENCE proyectos_seq START 1;
CREATE SEQUENCE proyectos_doc_seq START 1;
CREATE SEQUENCE horarios_seq START 1;
CREATE SEQUENCE materias_doc_seq START 1;
CREATE SEQUENCE liberaciones_seq START 1;
CREATE SEQUENCE evaluaciones_seq START 1;
CREATE SEQUENCE cvu_control_seq START 1;
CREATE SEQUENCE actividades_ded_seq START 1;
CREATE SEQUENCE tutorias_seq START 1;
CREATE SEQUENCE material_did_seq START 1;
CREATE SEQUENCE cursos_doc_seq START 1;
CREATE SEQUENCE titulaciones_seq START 1;
CREATE SEQUENCE asesorias_proj_seq START 1;
CREATE SEQUENCE comisiones_seq START 1;
CREATE SEQUENCE programas_seq START 1;
CREATE SEQUENCE programas_doc_seq START 1;
CREATE SEQUENCE expediente_seq START 1;
CREATE SEQUENCE tipos_doc_seq START 1;
CREATE SEQUENCE documentos_gen_seq START 1;
CREATE SEQUENCE quejas_seq START 1;
CREATE SEQUENCE responsables_seq START 1;
CREATE SEQUENCE resp_tipo_doc_seq START 1;


-- *** TABLAS PRINCIPALES Y ESTRUCTURA ***

-- Tabla Principal de Personal (Datos Comunes)
Create Table Personal(
    PersonaId Int Not Null DEFAULT nextval('personal_seq'),
    PrimerNombre Varchar(100) Not Null,
    SegundoNombre Varchar(100) Null,
    ApellidoPaterno Varchar(100) Null,
    ApellidoMaterno Varchar(100) Null,
    Curp Varchar(18) Not Null,
    Rfc Varchar(13) Not Null,
    FechaIngreso Date Not Null
);

-- Tabla de Personal Docente.
Create Table Docentes(
    DocenteId Int Not Null DEFAULT nextval('docentes_seq'),
    PersonaId Int Not Null,
    PuestoAcademico Varchar(100), -- Ej: 'Docente', 'Subdirector_Academico', 'RRHH'
    Email Varchar(100),
    PasswordEmail Varchar(50)
);

-- Tabla de Materias.
Create Table Materias(
    MateriaId Int Not Null DEFAULT nextval('materias_seq'),
    NombreMateria Varchar(50) Not Null,
    Nivel Varchar(30) Not Null,
    EsDiferenteBase Varchar(2) Not Null
);

-- Tabla para las convocatorias.
Create Table Convocatorias(
    ConvocatoriaId Int Not Null DEFAULT nextval('convocatorias_seq'),
    NombreConvocatoria Varchar(100) Not Null,
    Periodo Varchar(100) Not Null,
    FechaInicio Date Not Null,
    FechaFin Date Not Null
);

-- Tabla para los expedientes de los docentes.
Create Table Expediente_Docente(
    ExpedienteDocenteId Int Not Null DEFAULT nextval('expediente_seq'),
    ConvocatoriaId Int Not Null,
    DocenteId Int Not Null,
    Periodo Varchar(100) Not Null,
    FechaCreacion Date Not Null
);


-- *** TABLAS DE SPD (Sistema de Promoción Docente) ***

-- Tabla de Grados de Estudio de los Docentes.
Create Table Grados_Estudios_Docentes (
    GradoEstudioDocenteId Int Not Null DEFAULT nextval('grados_seq'),
    DocenteId Int Not Null,
    GradoObtenido Varchar(50) Null,
    FolioCedula Varchar(50) Null,
    FechaObtencion Date Null,
    FechaExpedicionCedula Date Null,
    InstitucionEmisora Varchar(255) Null
);

Create Table Estatus_Laboral_Periodo (
    EstatusPeriodoId Int Not Null DEFAULT nextval('estatus_lab_seq'),
    DocenteId Int Not Null,
    -- Datos de Plazas/Nómina
    EstatusPlaza Varchar(10) Not Null,
    EstatusPlazaInicio Date,
    TipoNombramiento Varchar(50) Not Null,
    PercepcionQ07_2025 DECIMAL(10, 2),
    
    -- Datos de Incidencias/Asistencia
    PeriodoEvaluado Varchar(50) Not Null,
    DiasLaboralesTotales Int Not Null,
    TotalFaltas Int Null,
    TipoSancion Varchar(100) Null
);

-- Tabla para almacenar las firmas.
Create Table Firmas (
    FirmaId Int Not Null DEFAULT nextval('firmas_seq'),
    DocenteId Int Not Null,
    Firma bytea Not Null -- Almacena el binario/base64 de la firma.
);

-- Tabla de Licencias de los Docentes.
Create Table Licencias_Docentes (
    LicenciaDocenteId Int Not Null DEFAULT nextval('licencias_seq'),
    DocenteId Int Not Null,
    TipoLicencia Varchar(50) Not Null, -- Sabatico, Beca Comision Gravidez
    FolioAutorizacion Varchar(50),
    FechaInicio Date Not Null,
    FechaFin Date Not Null,
    EsOficioAutorizado Varchar(2) Not Null
);

-- Tabla de Proyectos de Investigación.
Create Table Proyectos_Investigacion (
    ProyectoId Int Not Null DEFAULT nextval('proyectos_seq'),
    NombreProyecto Varchar(255) Not Null,
    FolioRegistro Varchar(50),
    VigenciaInicio Date,
    VigenciaFin Date,
    FuenteFinanciamiento Varchar(50),
    DictamenDirector Varchar(2),
    RecomendacionComite Varchar(2),
    TipoProyecto Varchar(50) Not Null
);

-- Tabla de Participantes en Proyectos de Investigación.
Create Table Proyectos_Docentes (
    ProyectosDocentesId Int Not Null DEFAULT nextval('proyectos_doc_seq'),
    DocenteId Int Not Null,
    ProyectoId Int Not Null,
    Rol Varchar(50) Not Null
);

-- Tabla de Horarios de los Docentes.
Create Table Horarios_Docentes (
    HorarioDocenteId Int Not Null DEFAULT nextval('horarios_seq'),
    DocenteId Int Not Null,
    Semestre Varchar(50) Not Null,
    HorarioInicio Time Not Null,
    HorarioFin Time Not Null,
    CargaReglamentaria Varchar(2) Not Null
);

-- Tabla de Materias Impartidas por los Docentes.
Create Table Materias_Docentes (
    AsignaturaDocenteId Int Not Null DEFAULT nextval('materias_doc_seq'),
    DocenteId Int Not Null,
    MateriaId Int Not Null,
    TotalAlumnos Int Not Null,
    Semestre Varchar(20) Not Null,    
    EsComplementaria Varchar(2) Not Null
);

-- Tabla de Liberaciones de los Docentes.
Create Table Liberaciones_Docentes (
    LiberacionDocenteId Int Not Null DEFAULT nextval('liberaciones_seq'),
    DocenteId Int Not Null,
    Semestre Varchar(20) Not Null,
    TipoLiberacion Varchar(50) Not Null,
    FolioLiberacion Varchar(50),
    CumplimientoPorcentaje Decimal(5, 2) Not Null,
    EstaLiberado Varchar(2) Not Null
);

-- Tabla de Evaluaciones de los Docentes.
Create Table Evaluaciones_Docentes (
    EvaluacionDocenteId Int Not Null DEFAULT nextval('evaluaciones_seq'),
    DocenteId Int Not Null,
    Semestre Varchar(20) Not Null,
    TipoEvaluacion Varchar(50) Not Null, -- Autoevaluacion, Desempeno
    Calificacion Decimal(5,2) Not Null,
    NombreDptoAcademico Varchar(100),
    CoberturaEstudiantes Decimal(5, 2),
    VoBo_SubAcademica Varchar(2) Not Null
);

-- Tabla de CVU Control de los Docentes.
Create Table CVU_Control_Docente (
    CVUControlDocenteId Int Not Null DEFAULT nextval('cvu_control_seq'),
    DocenteId Int Not Null,
    FechaUltimaActualizacion Date Not Null,
    EstadoCVU Varchar(50) Not Null,
    FolioConstancia Varchar(50) Not Null
);


-- *** TABLAS ESPECÍFICAS DE ACTIVIDADES (FACTOR 1) ***

-- Tabla de Actividades de Dedicación (Factor 1.1.7 y 1.4 genéricas)
Create Table Actividades_Dedicacion_Docente (
    ActividadDedicativaDocenteId Int Not Null DEFAULT nextval('actividades_ded_seq'),
    DocenteId Int Not Null,
    Semestre Varchar(20) Not Null,
    ClaveActividad Varchar(20) Not Null,
    DescripcionActividad Varchar(255) Not Null,
    FolioConstancia Varchar(50),
    NumEstudiantes Int,
    Resultado Varchar(50)
);

-- Tabla de Acciones Tutoriales. (Factor 1.1.5)
-- Uso exclusivo para PIT con conteo de estudiantes y folio de constancia de cumplimiento.
Create Table Tutorias_Docentes (
    TutoriaDocenteId Int Not Null DEFAULT nextval('tutorias_seq'),
    DocenteId Int Not Null,
    Semestre Varchar(20) Not Null,
    TipoRegistro Varchar(20) Not Null DEFAULT 'tutorado', -- tutorado / asesorado
    NumEstudiantes Int Not Null,
    FolioConstancia Varchar(50),
    ImpactoEvaluacion Varchar(255),
    VoBo_SubAcademica Varchar(2) Not Null
);

-- Tabla de Producción Didáctica. (Factor 1.2.1)
Create Table Material_Didactico_Docente (
    MaterialDidacticoDocenteId Int Not Null DEFAULT nextval('material_did_seq'),
    DocenteID Int Not Null,
    TipoProducto Varchar(100) Not Null,
    TieneRubrica Varchar(2),
    FirmaPresidenteAcademia Varchar(2),
    FirmaDptoAcademico Varchar(2),
    VoBo_SubAcademica Varchar(2),
    FolioConstancia Varchar(50),
    ImpactoExperienciaAprendizaje Varchar(255)
);

-- Tabla de Cursos Impartidos a otros Docentes. (Factor 1.2.2)
Create Table Cursos_Docentes (
    CursoDocenteId Int Not Null DEFAULT nextval('cursos_doc_seq'),
    DocenteID Int Not Null,
    TipoCurso Varchar(100),
    NombreInstitucion Varchar(100) Not Null,
    FolioOficioComision Varchar(50) Not Null,
    NumHoras Int Null,
    NumRegistroConstancia Varchar(50) Null,
    InstitucionConstancia Varchar(100) Not Null
);

-- Tabla de Titulaciones (Actividad 1.3) con roles académicos explícitos.
Create Table Titulaciones_Docentes (
    TitulacionDocenteId Int Not Null DEFAULT nextval('titulaciones_seq'),
    DocenteID Int Not Null,
    NivelGrado Varchar(50) Not Null, -- Licenciatura, Maestría, Doctorado
    RolAcademico Varchar(50) Not Null, -- Director, Codirector, Sinodal
    TipoTrabajo Varchar(50) Not Null, -- Tesis, Tesina, Proyecto Integrador, etc.
    FolioActa Varchar(50),
    FechaExamen Date,
    EsExterno Varchar(2) -- Si la participación fue externa
);

-- Tabla de Comisiones y Oficios. (Factor 1.4)
Create Table Comisiones_Oficios_Docentes (
    ComisionOficioDocenteId Int Not Null DEFAULT nextval('comisiones_seq'),
    DocenteID Int Not Null,
    TipoComision Varchar(100) Not Null,
    ClaveActividad Varchar(10) Not Null,
    FolioOficioComision Varchar(50),
    FolioConstanciaCumplimiento Varchar(50),
    VoBo_SubAcademica Varchar(2),
    NivelParticipacion Varchar(50)
);

-- Tabla para Asesorías de Proyectos de Estudiantes (Residencias, Educación Dual, Concursos).
Create Table Asesorias_Proyectos_Estudiantes (
    AsesoriaProyectoId Int Not Null DEFAULT nextval('asesorias_proj_seq'),
    DocenteId Int Not Null,
    TipoAsesoria Varchar(50) Not Null, -- Residencia, Concurso, Educacion_Dual, etc.
    NombreProyecto Varchar(255) Not Null,
    EmpresaInstitucion Varchar(255),
    RolAcademico Varchar(50) Not Null, -- Asesor, Coasesor, Director, Jurado
    AlumnoNombre Varchar(255),
    Periodo Varchar(20),
    FechaInicio Date,
    FechaFin Date,
    FolioConstancia Varchar(50)
);

-- Tabla de Programas Académicos. (Factor 1.1.6 y 1.4.8)
Create Table Programas_Academicos (
    ProgramaId Int Not Null DEFAULT nextval('programas_seq'),
    NombrePrograma Varchar(255) Not Null,
    NivelPrograma Varchar(50) Not Null,
    Acreditado Varchar(2),
    SNP_Vigente Varchar(2),
    OrganoAcreditador Varchar(100),
    FolioRegistroDDIE_DPII Varchar(50)
);

-- Tabla de Participación de Docentes en Programas Académicos.
Create Table Programas_Docentes (
    ProgramaDocenteId Int Not Null DEFAULT nextval('programas_doc_seq'),
    DocenteID Int Not Null,
    ProgramaID Int Not Null,
    Rol Varchar(50) Not Null
);


-- *** TABLAS DE CONTROL DE SISTEMA Y DOCUMENTACIÓN ***

-- Tabla de Tipos de Documentos Generados.
Create Table Tipos_Documentos (
    TipoDocumentoID Int Not Null DEFAULT nextval('tipos_doc_seq'),
    NombreCorto Varchar(50) Not Null,
    NombreCompleto Varchar(255) Not Null,
    FactorAsociado Varchar(20) Null,
    AreaResponsable Varchar(100)
);

-- Tabla de Documentos Generados para el Personal. (Almacenamiento y Auditoría)
Create Table Documentos_Generados (
    DocumentoId Int Not Null DEFAULT nextval('documentos_gen_seq'),
    ExpedienteId Int Not Null,
    TipoDocumentoID Int Not Null,
    FolioInterno Varchar(50) Not Null,
    FechaGeneracion Timestamp Not Null -- Usando TIMESTAMP para mayor precisión si se necesita.
);


-- *** TABLAS AGREGADAS DE QUEJAS Y RESPONSABLES ***

-- TABLA PARA GESTIONAR LAS QUEJAS (SOLICITUD DE REVISIÓN/ACLARACIÓN)
Create Table Quejas (
    QuejaId Int Not Null DEFAULT nextval('quejas_seq'),
    DocenteId Int Not Null, -- Docente que levanta la queja
    ExpedienteDocenteId Int Null, -- Expediente asociado a la queja
    FechaQueja Timestamp Not Null,
    Titulo Varchar(100) Not Null,
    Descripcion Varchar(500) Not Null,
    EstadoQueja Varchar(50) Not Null, -- Ej: 'Pendiente', 'En Revisión', 'Resuelta', 'Improcedente'
    FechaResolucion Timestamp Null,
    ObservacionesResolucion Varchar(500) Null
);

-- TABLA PARA ASIGNAR RESPONSABLES DE DOCUMENTOS/INFORMACIÓN (GESTORES)
Create Table Responsables_Informacion (
    ResponsableId Int Not Null DEFAULT nextval('responsables_seq'),
    PersonaId Int Not Null, -- El responsable es una persona del Personal
    AreaResponsable Varchar(100) Not Null, -- Ej: 'Subdirección Académica', 'Recursos Humanos'
    EmailContacto Varchar(100)
);

-- TABLA PARA RELACIONAR QUÉ RESPONSABLE ESTÁ ASIGNADO A QUÉ TIPO DE DOCUMENTO
Create Table Responsables_Tipo_Documento (
    ResponsableTipoDocId Int Not Null DEFAULT nextval('resp_tipo_doc_seq'),
    ResponsableId Int Not Null,
    TipoDocumentoID Int Not Null -- Tipo de documento o factor asociado
);


-- *** CLAVES PRIMARIAS ***

ALTER TABLE Personal ADD CONSTRAINT PK_Personal PRIMARY KEY (PersonaId);
ALTER TABLE Docentes ADD CONSTRAINT PK_Docentes PRIMARY KEY (DocenteId);
ALTER TABLE Firmas ADD CONSTRAINT PK_Firmas PRIMARY KEY (FirmaId);
ALTER TABLE Materias ADD CONSTRAINT PK_Materias PRIMARY KEY (MateriaId);
ALTER TABLE Convocatorias ADD CONSTRAINT PK_Convocatorias PRIMARY KEY (ConvocatoriaId);
ALTER TABLE Grados_Estudios_Docentes ADD CONSTRAINT PK_Grados_Estudios_Docentes PRIMARY KEY (GradoEstudioDocenteId);
ALTER TABLE Estatus_Laboral_Periodo ADD CONSTRAINT PK_Estatus_Laboral_Periodo PRIMARY KEY (EstatusPeriodoId);
ALTER TABLE Licencias_Docentes ADD CONSTRAINT PK_Licencias_Docentes PRIMARY KEY (LicenciaDocenteId);
ALTER TABLE Proyectos_Investigacion ADD CONSTRAINT PK_Proyectos_Investigacion PRIMARY KEY (ProyectoId);
ALTER TABLE Proyectos_Docentes ADD CONSTRAINT PK_Proyectos_Docentes PRIMARY KEY (ProyectosDocentesId);
ALTER TABLE Horarios_Docentes ADD CONSTRAINT PK_Horarios_Docentes PRIMARY KEY (HorarioDocenteId);
ALTER TABLE Materias_Docentes ADD CONSTRAINT PK_Materias_Docentes PRIMARY KEY (AsignaturaDocenteId);
ALTER TABLE Liberaciones_Docentes ADD CONSTRAINT PK_Liberaciones_Docentes PRIMARY KEY (LiberacionDocenteId);
ALTER TABLE Evaluaciones_Docentes ADD CONSTRAINT PK_Evaluaciones_Docentes PRIMARY KEY (EvaluacionDocenteId);
ALTER TABLE CVU_Control_Docente ADD CONSTRAINT PK_CVU_Control_Docente PRIMARY KEY (CVUControlDocenteId);
ALTER TABLE Actividades_Dedicacion_Docente ADD CONSTRAINT PK_Actividades_Dedicacion_Docente PRIMARY KEY (ActividadDedicativaDocenteId);
ALTER TABLE Tutorias_Docentes ADD CONSTRAINT PK_Tutorias_Docentes PRIMARY KEY (TutoriaDocenteId);
ALTER TABLE Material_Didactico_Docente ADD CONSTRAINT PK_Material_Didactico_Docente PRIMARY KEY (MaterialDidacticoDocenteId);
ALTER TABLE Cursos_Docentes ADD CONSTRAINT PK_Cursos_Docentes PRIMARY KEY (CursoDocenteId);
ALTER TABLE Titulaciones_Docentes ADD CONSTRAINT PK_Titulaciones_Docentes PRIMARY KEY (TitulacionDocenteId);
ALTER TABLE Comisiones_Oficios_Docentes ADD CONSTRAINT PK_Comisiones_Oficios_Docentes PRIMARY KEY (ComisionOficioDocenteId);
ALTER TABLE Asesorias_Proyectos_Estudiantes ADD CONSTRAINT PK_Asesorias_Proyectos_Estudiantes PRIMARY KEY (AsesoriaProyectoId);
ALTER TABLE Programas_Academicos ADD CONSTRAINT PK_Programas_Academicos PRIMARY KEY (ProgramaId);
ALTER TABLE Programas_Docentes ADD CONSTRAINT PK_Programas_Docentes PRIMARY KEY (ProgramaDocenteId);
ALTER TABLE Expediente_Docente ADD CONSTRAINT PK_Expediente_Docente PRIMARY KEY (ExpedienteDocenteId);
ALTER TABLE Tipos_Documentos ADD CONSTRAINT PK_Tipos_Documentos PRIMARY KEY (TipoDocumentoID);
ALTER TABLE Documentos_Generados ADD CONSTRAINT PK_Documentos_Generados PRIMARY KEY (DocumentoId);
ALTER TABLE Quejas ADD CONSTRAINT PK_Quejas PRIMARY KEY (QuejaId);
ALTER TABLE Responsables_Informacion ADD CONSTRAINT PK_Responsables_Informacion PRIMARY KEY (ResponsableId);
ALTER TABLE Responsables_Tipo_Documento ADD CONSTRAINT PK_Responsables_Tipo_Documento PRIMARY KEY (ResponsableTipoDocId);


-- *** CLAVES FORÁNEAS (RELACIONES) ***

-- Relaciones de Estructura
ALTER TABLE Docentes ADD CONSTRAINT FK_Docentes_PersonaId FOREIGN KEY (PersonaId) REFERENCES Personal(PersonaId);
ALTER TABLE Firmas ADD CONSTRAINT FK_Firmas_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Expediente_Docente ADD CONSTRAINT FK_Expediente_Docente_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Expediente_Docente ADD CONSTRAINT FK_Expediente_Docente_ConvocatoriaId FOREIGN KEY (ConvocatoriaId) REFERENCES Convocatorias(ConvocatoriaId);

-- Relaciones de SPD
ALTER TABLE Grados_Estudios_Docentes ADD CONSTRAINT FK_Grados_Estudios_Docentes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Estatus_Laboral_Periodo ADD CONSTRAINT FK_Estatus_Laboral_Periodo_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Licencias_Docentes ADD CONSTRAINT FK_Licencias_Docentes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Proyectos_Docentes ADD CONSTRAINT FK_Proyectos_Docentes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Horarios_Docentes ADD CONSTRAINT FK_Horarios_Docentes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Materias_Docentes ADD CONSTRAINT FK_Materias_Docentes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Liberaciones_Docentes ADD CONSTRAINT FK_Liberaciones_Docentes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Evaluaciones_Docentes ADD CONSTRAINT FK_Evaluaciones_Docentes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE CVU_Control_Docente ADD CONSTRAINT FK_CVU_Control_Docente_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Actividades_Dedicacion_Docente ADD CONSTRAINT FK_Actividades_Dedicacion_Docente_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Tutorias_Docentes ADD CONSTRAINT FK_Tutorias_Docentes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Material_Didactico_Docente ADD CONSTRAINT FK_Material_Didactico_Docente_DocenteId FOREIGN KEY (DocenteID) REFERENCES Docentes(DocenteId);
ALTER TABLE Cursos_Docentes ADD CONSTRAINT FK_Cursos_Docentes_DocenteId FOREIGN KEY (DocenteID) REFERENCES Docentes(DocenteId);
ALTER TABLE Titulaciones_Docentes ADD CONSTRAINT FK_Titulaciones_Docentes_DocenteID FOREIGN KEY (DocenteID) REFERENCES Docentes(DocenteId);
ALTER TABLE Comisiones_Oficios_Docentes ADD CONSTRAINT FK_Comisiones_Oficios_Docentes_DocenteID FOREIGN KEY (DocenteID) REFERENCES Docentes(DocenteId);
ALTER TABLE Asesorias_Proyectos_Estudiantes ADD CONSTRAINT FK_Asesorias_Proyectos_Estudiantes_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Programas_Docentes ADD CONSTRAINT FK_Programas_Docentes_DocenteID FOREIGN KEY (DocenteID) REFERENCES Docentes(DocenteId);

-- Relaciones Inter-tablas
ALTER TABLE Proyectos_Docentes ADD CONSTRAINT FK_Proyectos_Docentes_ProyectoId FOREIGN KEY (ProyectoId) REFERENCES Proyectos_Investigacion(ProyectoId);
ALTER TABLE Materias_Docentes ADD CONSTRAINT FK_Materias_Docentes_MateriaId FOREIGN KEY (MateriaId) REFERENCES Materias(MateriaId);
ALTER TABLE Programas_Docentes ADD CONSTRAINT FK_Programas_Docentes_ProgramaId FOREIGN KEY (ProgramaID) REFERENCES Programas_Academicos(ProgramaId);

-- Relaciones de Documentación
ALTER TABLE Documentos_Generados ADD CONSTRAINT FK_Documentos_Generados_ExpedienteId FOREIGN KEY (ExpedienteId) REFERENCES Expediente_Docente(ExpedienteDocenteId);
ALTER TABLE Documentos_Generados ADD CONSTRAINT FK_Documentos_Generados_TipoDocumentoID FOREIGN KEY (TipoDocumentoID) REFERENCES Tipos_Documentos(TipoDocumentoID);

-- Relaciones de Quejas y Responsables
ALTER TABLE Quejas ADD CONSTRAINT FK_Quejas_DocenteId FOREIGN KEY (DocenteId) REFERENCES Docentes(DocenteId);
ALTER TABLE Quejas ADD CONSTRAINT FK_Quejas_ExpedienteDocenteId FOREIGN KEY (ExpedienteDocenteId) REFERENCES Expediente_Docente(ExpedienteDocenteId);
ALTER TABLE Responsables_Informacion ADD CONSTRAINT FK_Responsables_Informacion_PersonaId FOREIGN KEY (PersonaId) REFERENCES Personal(PersonaId);
ALTER TABLE Responsables_Tipo_Documento ADD CONSTRAINT FK_Responsables_Tipo_Doc_ResponsableId FOREIGN KEY (ResponsableId) REFERENCES Responsables_Informacion(ResponsableId);
ALTER TABLE Responsables_Tipo_Documento ADD CONSTRAINT FK_Responsables_Tipo_Doc_TipoDocumentoID FOREIGN KEY (TipoDocumentoID) REFERENCES Tipos_Documentos(TipoDocumentoID);
