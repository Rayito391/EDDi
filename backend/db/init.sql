-- ==========================
-- Seed consolidado sin duplicados
-- ==========================

-- 1) Cat�logos base
INSERT INTO Materias (MateriaId, NombreMateria, Nivel, EsDiferenteBase)
VALUES (1, 'Ingenieria de Software', 'Licenciatura', 'NO')
ON CONFLICT (MateriaId) DO NOTHING;

INSERT INTO Convocatorias (ConvocatoriaId, NombreConvocatoria, Periodo, FechaInicio, FechaFin)
VALUES (1, 'Estimulo al Desempeno Docente 2025', 'Enero-Diciembre 2025', '2025-01-15', '2025-02-15')
ON CONFLICT (ConvocatoriaId) DO NOTHING;

INSERT INTO Programas_Academicos (ProgramaId, NombrePrograma, NivelPrograma, Acreditado, SNP_Vigente, OrganoAcreditador, FolioRegistroDDIE_DPII)
VALUES (1, 'Ing. En Sistemas Computacionales', 'Licenciatura', 'SI', 'SI', 'CACEI', 'DDIE-2024-001')
ON CONFLICT (ProgramaId) DO NOTHING;

-- 14 tipos de documentos
INSERT INTO Tipos_Documentos (TipoDocumentoID, NombreCorto, NombreCompleto, FactorAsociado, AreaResponsable) VALUES
(1,  '01', 'Constancia de Recursos Humanos sobre nombramiento, asistencia y sanciones', 'F1', 'Recursos Humanos'),
(2,  '02', 'Talon de pago (quincena 07 del 2025, sin DT o I8)', 'F1', 'Recursos Humanos'),
(3,  '03', 'Horarios de labores 2024 y 2025', 'F1', 'Academica'),
(4,  '04', 'Carta de exclusividad laboral (formato oficial)', 'F1', 'Recursos Humanos'),
(5,  '05', 'Proyecto de investigacion vigente con dictamen y recomendacion institucional', 'F1', 'Academica'),
(6,  '06', 'Constancia de CVU-TecNM actualizado', 'F1', 'Academica'),
(7,  '07', 'Constancia de asignaturas impartidas y estudiantes atendidos', 'F1', 'Academica'),
(8,  '08', 'Oficio de autorizacion de periodo sabatico o beca comision', 'F1', 'Recursos Humanos'),
(9,  '09', 'Licencia por gravidez (si aplica)', 'F1', 'Recursos Humanos'),
(10, '10', 'Cedula profesional o acta de examen de grado', 'F1', 'Recursos Humanos'),
(11, '11', 'Formato de liberacion de actividades docentes (dos semestres)', 'F1', 'Academica'),
(12, '12', 'Carta de liberacion de actividades academicas (Anexo XXXVII)', 'F1', 'Academica'),
(13, '13', 'Evaluaciones departamentales y autoevaluacion (licenciatura o posgrado)', 'F1', 'Academica'),
(14, '14', 'Evaluaciones del desempeno frente a grupo (minimo 60% del estudiantado)', 'F1', 'Academica')
ON CONFLICT (TipoDocumentoID) DO NOTHING;

-- 2) Personal y Docentes base (demo)
WITH p_doc AS (
  INSERT INTO Personal (PersonaId, PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES (10, 'Ana', 'Maria', 'Lopez', 'Gomez', 'LOPA850101MDF00100', 'LOGA850101ABC', '2024-08-01')
  ON CONFLICT (PersonaId) DO NOTHING
  RETURNING PersonaId
), p_sub AS (
  INSERT INTO Personal (PersonaId, PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES (11, 'Bruno', NULL, 'Perez', 'Ramirez', 'PERB850202HDF00200', 'PERR850202DEF', '2024-08-01')
  ON CONFLICT (PersonaId) DO NOTHING
  RETURNING PersonaId
), p_des AS (
  INSERT INTO Personal (PersonaId, PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES (12, 'Carla', 'Sofia', 'Ruiz', 'Nava', 'RUIC850303MDF00300', 'RUIN850303GHI', '2024-08-01')
  ON CONFLICT (PersonaId) DO NOTHING
  RETURNING PersonaId
), p_adm AS (
  INSERT INTO Personal (PersonaId, PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES (13, 'Diego', NULL, 'Martinez', 'Flores', 'MARD850404HDF00400', 'MARF850404JKL', '2024-08-01')
  ON CONFLICT (PersonaId) DO NOTHING
  RETURNING PersonaId
)
INSERT INTO Docentes (DocenteId, PersonaId, PuestoAcademico, Email, PasswordEmail)
SELECT 10, PersonaId, 'docente', 'docente1@ejemplo.edu', 'pass_docente' FROM p_doc
UNION ALL SELECT 11, PersonaId, 'subdireccion', 'subdireccion@ejemplo.edu', 'pass_subdireccion' FROM p_sub
UNION ALL SELECT 12, PersonaId, 'desarrollo', 'desarrollo@ejemplo.edu', 'pass_desarrollo' FROM p_des
UNION ALL SELECT 13, PersonaId, 'administrativo', 'administrativo@ejemplo.edu', 'pass_admin' FROM p_adm
ON CONFLICT (DocenteId) DO NOTHING;

-- Segundo docente (0 asesorados)
WITH p_doc2 AS (
  INSERT INTO Personal (PersonaId, PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES (14, 'Elena', NULL, 'Garcia', 'Luna', 'GALE850505MDF00500', 'GALE850505MNO', '2024-08-01')
  ON CONFLICT (PersonaId) DO NOTHING
  RETURNING PersonaId
)
INSERT INTO Docentes (DocenteId, PersonaId, PuestoAcademico, Email, PasswordEmail)
SELECT 14, PersonaId, 'Docente', 'docente2@ejemplo.edu', 'pass_docente2' FROM p_doc2
ON CONFLICT (DocenteId) DO NOTHING;

-- Expedientes para ambos docentes
WITH conv AS (
  SELECT ConvocatoriaId FROM Convocatorias WHERE Periodo = '2025-A' LIMIT 1
), d1 AS (
  SELECT DocenteId FROM Docentes WHERE Email = 'docente1@ejemplo.edu'
), d2 AS (
  SELECT DocenteId FROM Docentes WHERE Email = 'docente2@ejemplo.edu'
)
INSERT INTO Expediente_Docente (ExpedienteDocenteId, ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
SELECT 10, conv.ConvocatoriaId, d1.DocenteId, '2025-A', CURRENT_DATE FROM conv, d1
UNION ALL
SELECT 11, conv.ConvocatoriaId, d2.DocenteId, '2025-A', CURRENT_DATE FROM conv, d2
ON CONFLICT (ExpedienteDocenteId) DO NOTHING;

WITH d1 AS (SELECT DocenteId FROM Docentes WHERE Email = 'docente1@ejemplo.edu')
INSERT INTO Tutorias_Docentes (TutoriaDocenteId, DocenteId, Semestre, TipoRegistro, NumEstudiantes, FolioConstancia, ImpactoEvaluacion, VoBo_SubAcademica)
SELECT 10, d1.DocenteId, '2025-1', 'tutorado', 10, 'FOL-TUT-2025-001', 'Seguimiento regular', 'SI' FROM d1
ON CONFLICT (TutoriaDocenteId) DO NOTHING;
-- Titulaciones (ejemplo actividad 1.3)
WITH d1 AS (SELECT DocenteId FROM Docentes WHERE Email = 'docente1@ejemplo.edu')
INSERT INTO Titulaciones_Docentes (TitulacionDocenteId, DocenteID, NivelGrado, RolAcademico, TipoTrabajo, FolioActa, FechaExamen, EsExterno)
SELECT 1, d1.DocenteId, 'Licenciatura', 'Director', 'Tesis', 'ACT-2024-001', '2024-11-30', 'NO' FROM d1
ON CONFLICT (TitulacionDocenteId) DO NOTHING;

-- Asesorías de proyectos (Residencia)
WITH d1 AS (SELECT DocenteId FROM Docentes WHERE Email = 'docente1@ejemplo.edu')
INSERT INTO Asesorias_Proyectos_Estudiantes (AsesoriaProyectoId, DocenteId, TipoAsesoria, NombreProyecto, EmpresaInstitucion, RolAcademico, AlumnoNombre, Periodo, FechaInicio, FechaFin, FolioConstancia)
SELECT 1, d1.DocenteId, 'Residencia', 'Sistema de Gestión Académica', 'Empresa ABC', 'Asesor', 'Luis Perez', '2025-1', '2025-01-15', '2025-06-30', 'RES-2025-001' FROM d1
ON CONFLICT (AsesoriaProyectoId) DO NOTHING;

-- 3) Seed Fausto + admin Norma
INSERT INTO Personal (PersonaId, PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
VALUES (1, 'Fausto', 'Gabriel', 'Espinoza', 'Felix', 'EIFG990101HSR01', 'EIFG990101000', '2018-08-15')
ON CONFLICT (PersonaId) DO NOTHING;

INSERT INTO Docentes (DocenteId, PersonaId, PuestoAcademico, Email, PasswordEmail)
VALUES (1, 1, 'Docente', 'fausto.ef@culiacan.tecnm.mx', 'PasswordSeguro123')
ON CONFLICT (DocenteId) DO NOTHING;

INSERT INTO Personal (PersonaId, PrimerNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
VALUES (2, 'Norma', 'Godoy', 'Castro', 'GOCN800101MSR01', 'GOCN800101000', '2010-01-01')
ON CONFLICT (PersonaId) DO NOTHING;

INSERT INTO Expediente_Docente (ExpedienteDocenteId, ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
VALUES (1, 1, 1, 'Enero-Diciembre 2025', '2025-01-20')
ON CONFLICT (ExpedienteDocenteId) DO NOTHING;

INSERT INTO Grados_Estudios_Docentes (GradoEstudioDocenteId, DocenteId, GradoObtenido, FolioCedula, FechaObtencion, InstitucionEmisora)
VALUES (1, 1, 'Maestria en Ciencias de la Computacion', '12345678', '2020-06-30', 'Tecnologico Nacional de Mexico')
ON CONFLICT (GradoEstudioDocenteId) DO NOTHING;

INSERT INTO Estatus_Laboral_Periodo (EstatusPeriodoId, DocenteId, EstatusPlaza, EstatusPlazaInicio, TipoNombramiento, PercepcionQ07_2025, PeriodoEvaluado, DiasLaboralesTotales, TotalFaltas, TipoSancion)
VALUES (1, 1, 'E3817', '2018-08-15', 'Base', 15000.00, '2024', 200, 0, 'Ninguna')
ON CONFLICT (EstatusPeriodoId) DO NOTHING;

INSERT INTO CVU_Control_Docente (CVUControlDocenteId, DocenteId, FechaUltimaActualizacion, EstadoCVU, FolioConstancia)
VALUES (1, 1, '2025-01-10', 'Actualizado', 'CVU-TEC-2025-001')
ON CONFLICT (CVUControlDocenteId) DO NOTHING;

INSERT INTO Materias_Docentes (AsignaturaDocenteId, DocenteId, MateriaId, TotalAlumnos, Semestre, EsComplementaria)
VALUES (1, 1, 1, 35, '2024-2', 'NO')
ON CONFLICT (AsignaturaDocenteId) DO NOTHING;

INSERT INTO Horarios_Docentes (HorarioDocenteId, DocenteId, Semestre, HorarioInicio, HorarioFin, CargaReglamentaria)
VALUES (1, 1, '2025-1', '14:00:00', '15:00:00', 'SI')
ON CONFLICT (HorarioDocenteId) DO NOTHING;

INSERT INTO Proyectos_Investigacion (ProyectoId, NombreProyecto, TipoProyecto, VigenciaInicio, VigenciaFin, FuenteFinanciamiento)
VALUES (1, 'Sistema EDDi v1.0', 'Investigacion Aplicada', '2024-01-01', '2025-12-31', 'TecNM')
ON CONFLICT (ProyectoId) DO NOTHING;

INSERT INTO Proyectos_Docentes (ProyectosDocentesId, DocenteId, ProyectoId, Rol)
VALUES (1, 1, 1, 'Responsable Tecnico')
ON CONFLICT (ProyectosDocentesId) DO NOTHING;

INSERT INTO Tutorias_Docentes (TutoriaDocenteId, DocenteId, Semestre, TipoRegistro, NumEstudiantes, FolioConstancia, VoBo_SubAcademica)
VALUES (2, 1, '2024-2', 'tutorado', 5, 'TUT-2024-001', 'SI')
ON CONFLICT (TutoriaDocenteId) DO NOTHING;

INSERT INTO Titulaciones_Docentes (TitulacionDocenteId, DocenteID, NivelGrado, RolAcademico, TipoTrabajo, FolioActa, FechaExamen, EsExterno)
VALUES (2, 1, 'Maestria', 'Sinodal', 'Tesis', 'ACT-2025-002', '2025-03-15', 'NO')
ON CONFLICT (TitulacionDocenteId) DO NOTHING;

INSERT INTO Asesorias_Proyectos_Estudiantes (AsesoriaProyectoId, DocenteId, TipoAsesoria, NombreProyecto, EmpresaInstitucion, RolAcademico, AlumnoNombre, Periodo, FechaInicio, FechaFin, FolioConstancia)
VALUES (2, 1, 'Concurso', 'Robotica Nacional', 'TecNM', 'Jurado', 'Equipo Halcones', '2024-2', '2024-09-01', '2024-11-30', 'CON-2024-009')
ON CONFLICT (AsesoriaProyectoId) DO NOTHING;

INSERT INTO Responsables_Informacion (ResponsableId, PersonaId, AreaResponsable, EmailContacto)
VALUES (1, 2, 'Recursos Humanos', 'rh@culiacan.tecnm.mx')
ON CONFLICT (ResponsableId) DO NOTHING;

INSERT INTO Responsables_Tipo_Documento (ResponsableTipoDocId, ResponsableId, TipoDocumentoID)
VALUES (1, 1, 1)
ON CONFLICT (ResponsableTipoDocId) DO NOTHING;

INSERT INTO Documentos_Generados (DocumentoId, ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
VALUES (1, 1, 1, 'EDDI-DOC-001-2025', CURRENT_TIMESTAMP)
ON CONFLICT (DocumentoId) DO NOTHING;

INSERT INTO Quejas (QuejaId, DocenteId, ExpedienteDocenteId, FechaQueja, Titulo, Descripcion, EstadoQueja)
VALUES (1, 1, 1, CURRENT_TIMESTAMP, 'Error en constancia', 'Error en el calculo de antiguedad en la constancia', 'Pendiente')
ON CONFLICT (QuejaId) DO NOTHING;

-- Casos de prueba de elegibilidad de documentos (Docentes 20, 21, 22)
-- Docente 20: debería ver TODOS los documentos (1-14) al cumplir todas las condiciones.
INSERT INTO Personal (PersonaId, PrimerNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
VALUES (20, 'Prueba', 'Completo', 'Elegible', 'COMC900101HDF02020', 'COMC900101000', '2020-01-01')
ON CONFLICT (PersonaId) DO NOTHING;
INSERT INTO Docentes (DocenteId, PersonaId, PuestoAcademico, Email, PasswordEmail)
VALUES (20, 20, 'Docente', 'doc_full@ejemplo.edu', 'pass_full')
ON CONFLICT (DocenteId) DO NOTHING;
INSERT INTO Expediente_Docente (ExpedienteDocenteId, ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
VALUES (20, 1, 20, 'Enero-Diciembre 2025', CURRENT_DATE)
ON CONFLICT (ExpedienteDocenteId) DO NOTHING;
INSERT INTO Estatus_Laboral_Periodo (EstatusPeriodoId, DocenteId, EstatusPlaza, EstatusPlazaInicio, TipoNombramiento, PercepcionQ07_2025, PeriodoEvaluado, DiasLaboralesTotales, TotalFaltas, TipoSancion)
VALUES (20, 20, 'E3817', '2023-12-15', 'Tiempo Completo', 15000, '2024', 200, 5, NULL)
ON CONFLICT (EstatusPeriodoId) DO NOTHING;
INSERT INTO Horarios_Docentes (HorarioDocenteId, DocenteId, Semestre, HorarioInicio, HorarioFin, CargaReglamentaria)
VALUES (20, 20, '2025-1', '08:00:00', '10:00:00', 'SI')
ON CONFLICT (HorarioDocenteId) DO NOTHING;
INSERT INTO Materias_Docentes (AsignaturaDocenteId, DocenteId, MateriaId, TotalAlumnos, Semestre, EsComplementaria)
VALUES (20, 20, 1, 30, '2024-2', 'NO'),
       (21, 20, 1, 25, '2025-1', 'NO')
ON CONFLICT (AsignaturaDocenteId) DO NOTHING;
INSERT INTO Proyectos_Investigacion (ProyectoId, NombreProyecto, TipoProyecto, VigenciaInicio, VigenciaFin, FuenteFinanciamiento)
VALUES (2, 'IA aplicada a EDDi', 'Investigacion Aplicada', '2024-01-01', '2025-12-31', 'TecNM')
ON CONFLICT (ProyectoId) DO NOTHING;
INSERT INTO Proyectos_Docentes (ProyectosDocentesId, DocenteId, ProyectoId, Rol)
VALUES (2, 20, 2, 'Responsable Tecnico')
ON CONFLICT (ProyectosDocentesId) DO NOTHING;
INSERT INTO CVU_Control_Docente (CVUControlDocenteId, DocenteId, FechaUltimaActualizacion, EstadoCVU, FolioConstancia)
VALUES (2, 20, '2025-01-05', 'Actualizado', 'CVU-TEC-2025-020')
ON CONFLICT (CVUControlDocenteId) DO NOTHING;
INSERT INTO Licencias_Docentes (LicenciaDocenteId, DocenteId, TipoLicencia, FolioAutorizacion, FechaInicio, FechaFin, EsOficioAutorizado)
VALUES (20, 20, 'Sabatico', 'LIC-2025-020', '2025-01-10', '2025-06-30', 'SI')
ON CONFLICT (LicenciaDocenteId) DO NOTHING;
INSERT INTO Grados_Estudios_Docentes (GradoEstudioDocenteId, DocenteId, GradoObtenido, FolioCedula, FechaObtencion, InstitucionEmisora)
VALUES (20, 20, 'Doctorado', 'CED-2025-020', '2020-07-01', 'TecNM')
ON CONFLICT (GradoEstudioDocenteId) DO NOTHING;
INSERT INTO Liberaciones_Docentes (LiberacionDocenteId, DocenteId, Semestre, TipoLiberacion, FolioLiberacion, CumplimientoPorcentaje, EstaLiberado)
VALUES (20, 20, '2024-1', 'Academica', 'LIB-2024-020', 100.00, 'SI')
ON CONFLICT (LiberacionDocenteId) DO NOTHING;
INSERT INTO Evaluaciones_Docentes (EvaluacionDocenteId, DocenteId, Semestre, TipoEvaluacion, Calificacion, CoberturaEstudiantes, VoBo_SubAcademica)
VALUES (20, 20, '2024-2', 'Desempeno', 90, 100, 'SI'),
       (21, 20, '2024-2', 'Estudiantes', 90, 80, 'SI')
ON CONFLICT (EvaluacionDocenteId) DO NOTHING;

-- Docente 21: debería ver 02 (talón), 04 (formato libre), 06 (CVU), 10 (grado), 13/14 no; 01/03/07/08/09/11/12 no cumplen.
INSERT INTO Personal (PersonaId, PrimerNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
VALUES (21, 'Prueba', 'Parcial', 'Talones', 'PART900101HDF02121', 'PART900101000', '2024-02-01')
ON CONFLICT (PersonaId) DO NOTHING;
INSERT INTO Docentes (DocenteId, PersonaId, PuestoAcademico, Email, PasswordEmail)
VALUES (21, 21, 'Docente', 'doc_parcial@ejemplo.edu', 'pass_parcial')
ON CONFLICT (DocenteId) DO NOTHING;
INSERT INTO Expediente_Docente (ExpedienteDocenteId, ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
VALUES (21, 1, 21, 'Enero-Diciembre 2025', CURRENT_DATE)
ON CONFLICT (ExpedienteDocenteId) DO NOTHING;
INSERT INTO Estatus_Laboral_Periodo (EstatusPeriodoId, DocenteId, EstatusPlaza, EstatusPlazaInicio, TipoNombramiento, PercepcionQ07_2025, PeriodoEvaluado, DiasLaboralesTotales, TotalFaltas, TipoSancion)
VALUES (21, 21, 'E3817', '2024-05-01', 'Medio Tiempo', 12000, '2024', 200, 30, 'Amonestacion')
ON CONFLICT (EstatusPeriodoId) DO NOTHING;
INSERT INTO CVU_Control_Docente (CVUControlDocenteId, DocenteId, FechaUltimaActualizacion, EstadoCVU, FolioConstancia)
VALUES (3, 21, '2025-02-01', 'Actualizado', 'CVU-TEC-2025-021')
ON CONFLICT (CVUControlDocenteId) DO NOTHING;
INSERT INTO Grados_Estudios_Docentes (GradoEstudioDocenteId, DocenteId, GradoObtenido, FolioCedula, FechaObtencion, InstitucionEmisora)
VALUES (21, 21, 'Maestria', 'CED-2025-021', '2021-05-10', 'TecNM')
ON CONFLICT (GradoEstudioDocenteId) DO NOTHING;

-- Docente 22: debería ver 01, 03, 07, 08, 09, 10; no verá 11/12 (sin liberación), 13/14 (sin evaluaciones).
INSERT INTO Personal (PersonaId, PrimerNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
VALUES (22, 'Prueba', 'Licencia', 'Evaluacion', 'LICE900101HDF02222', 'LICE900101000', '2022-01-01')
ON CONFLICT (PersonaId) DO NOTHING;
INSERT INTO Docentes (DocenteId, PersonaId, PuestoAcademico, Email, PasswordEmail)
VALUES (22, 22, 'Docente', 'doc_licencia@ejemplo.edu', 'pass_licencia')
ON CONFLICT (DocenteId) DO NOTHING;
INSERT INTO Expediente_Docente (ExpedienteDocenteId, ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
VALUES (22, 1, 22, 'Enero-Diciembre 2025', CURRENT_DATE)
ON CONFLICT (ExpedienteDocenteId) DO NOTHING;
INSERT INTO Estatus_Laboral_Periodo (EstatusPeriodoId, DocenteId, EstatusPlaza, EstatusPlazaInicio, TipoNombramiento, PercepcionQ07_2025, PeriodoEvaluado, DiasLaboralesTotales, TotalFaltas, TipoSancion)
VALUES (22, 22, 'E3817', '2023-12-01', 'Tiempo Completo', 14000, '2024', 200, 10, NULL)
ON CONFLICT (EstatusPeriodoId) DO NOTHING;
INSERT INTO Horarios_Docentes (HorarioDocenteId, DocenteId, Semestre, HorarioInicio, HorarioFin, CargaReglamentaria)
VALUES (22, 22, '2025-1', '09:00:00', '11:00:00', 'SI')
ON CONFLICT (HorarioDocenteId) DO NOTHING;
INSERT INTO Materias_Docentes (AsignaturaDocenteId, DocenteId, MateriaId, TotalAlumnos, Semestre, EsComplementaria)
VALUES (22, 22, 1, 32, '2024-2', 'NO'),
       (23, 22, 1, 28, '2025-1', 'NO')
ON CONFLICT (AsignaturaDocenteId) DO NOTHING;
INSERT INTO Licencias_Docentes (LicenciaDocenteId, DocenteId, TipoLicencia, FolioAutorizacion, FechaInicio, FechaFin, EsOficioAutorizado)
VALUES (22, 22, 'Sabatico', 'LIC-2025-022', '2025-02-01', '2025-07-31', 'SI')
ON CONFLICT (LicenciaDocenteId) DO NOTHING;
INSERT INTO Grados_Estudios_Docentes (GradoEstudioDocenteId, DocenteId, GradoObtenido, FolioCedula, FechaObtencion, InstitucionEmisora)
VALUES (22, 22, 'Licenciatura', 'CED-2025-022', '2019-03-20', 'TecNM')
ON CONFLICT (GradoEstudioDocenteId) DO NOTHING;

-- Ajustar secuencias despues de inserts manuales (para que nextval no colisione)
SELECT setval('materias_seq',             (SELECT coalesce(max(MateriaId), 1)            FROM Materias),              true);
SELECT setval('convocatorias_seq',        (SELECT coalesce(max(ConvocatoriaId), 1)       FROM Convocatorias),         true);
SELECT setval('programas_seq',            (SELECT coalesce(max(ProgramaId), 1)           FROM Programas_Academicos),  true);
SELECT setval('tipos_doc_seq',            (SELECT coalesce(max(TipoDocumentoID), 1)      FROM Tipos_Documentos),      true);
SELECT setval('personal_seq',             (SELECT coalesce(max(PersonaId), 1)            FROM Personal),              true);
SELECT setval('docentes_seq',             (SELECT coalesce(max(DocenteId), 1)            FROM Docentes),              true);
SELECT setval('expediente_seq',           (SELECT coalesce(max(ExpedienteDocenteId), 1)  FROM Expediente_Docente),    true);
SELECT setval('grados_seq',               (SELECT coalesce(max(GradoEstudioDocenteId), 1)FROM Grados_Estudios_Docentes), true);
SELECT setval('estatus_lab_seq',          (SELECT coalesce(max(EstatusPeriodoId), 1)     FROM Estatus_Laboral_Periodo), true);
SELECT setval('cvu_control_seq',          (SELECT coalesce(max(CVUControlDocenteId), 1)  FROM CVU_Control_Docente),   true);
SELECT setval('materias_doc_seq',         (SELECT coalesce(max(AsignaturaDocenteId), 1)  FROM Materias_Docentes),     true);
SELECT setval('horarios_seq',             (SELECT coalesce(max(HorarioDocenteId), 1)     FROM Horarios_Docentes),     true);
SELECT setval('proyectos_seq',            (SELECT coalesce(max(ProyectoId), 1)           FROM Proyectos_Investigacion),true);
SELECT setval('proyectos_doc_seq',        (SELECT coalesce(max(ProyectosDocentesId), 1)  FROM Proyectos_Docentes),    true);
SELECT setval('tutorias_seq',             (SELECT coalesce(max(TutoriaDocenteId), 1)     FROM Tutorias_Docentes),     true);
SELECT setval('titulaciones_seq',         (SELECT coalesce(max(TitulacionDocenteId), 1)  FROM Titulaciones_Docentes), true);
SELECT setval('asesorias_proj_seq',       (SELECT coalesce(max(AsesoriaProyectoId), 1)   FROM Asesorias_Proyectos_Estudiantes), true);
SELECT setval('responsables_seq',         (SELECT coalesce(max(ResponsableId), 1)        FROM Responsables_Informacion), true);
SELECT setval('resp_tipo_doc_seq',        (SELECT coalesce(max(ResponsableTipoDocId), 1) FROM Responsables_Tipo_Documento), true);
SELECT setval('documentos_gen_seq',       (SELECT coalesce(max(DocumentoId), 1)          FROM Documentos_Generados), true);
SELECT setval('quejas_seq',               (SELECT coalesce(max(QuejaId), 1)              FROM Quejas),               true);

