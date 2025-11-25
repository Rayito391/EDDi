-- Convocatoria base
INSERT INTO Convocatorias (NombreConvocatoria, Periodo, FechaInicio, FechaFin)
VALUES ('Convocatoria 2025-A', '2025-A', '2025-01-01', '2025-06-30');

-- Personal + Docentes (docente, subdirección, desarrollo, administrativo)
WITH p_doc AS (
  INSERT INTO Personal (PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES ('Ana', 'María', 'López', 'Gómez', 'LOPA850101MDF00100', 'LOGA850101ABC', '2024-08-01')
  RETURNING PersonaId
), p_sub AS (
  INSERT INTO Personal (PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES ('Bruno', NULL, 'Pérez', 'Ramírez', 'PERB850202HDF00200', 'PERR850202DEF', '2024-08-01')
  RETURNING PersonaId
), p_des AS (
  INSERT INTO Personal (PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES ('Carla', 'Sofía', 'Ruiz', 'Nava', 'RUIC850303MDF00300', 'RUIN850303GHI', '2024-08-01')
  RETURNING PersonaId
), p_adm AS (
  INSERT INTO Personal (PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES ('Diego', NULL, 'Martínez', 'Flores', 'MARD850404HDF00400', 'MARF850404JKL', '2024-08-01')
  RETURNING PersonaId
)
INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
SELECT PersonaId, 'Docente',               'docente1@ejemplo.edu',    'pass_docente'       FROM p_doc
UNION ALL
SELECT PersonaId, 'Subdirector_Academico', 'subdireccion@ejemplo.edu','pass_subdireccion'  FROM p_sub
UNION ALL
SELECT PersonaId, 'Desarrollo_Academico',  'desarrollo@ejemplo.edu',  'pass_desarrollo'    FROM p_des
UNION ALL
SELECT PersonaId, 'Administrativo',        'administrativo@ejemplo.edu','pass_admin'       FROM p_adm;

-- Segundo docente (para el caso de 0 asesorados)
WITH p_doc2 AS (
  INSERT INTO Personal (PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES ('Elena', NULL, 'García', 'Luna', 'GALE850505MDF00500', 'GALE850505MNO', '2024-08-01')
  RETURNING PersonaId
)
INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
SELECT PersonaId, 'Docente', 'docente2@ejemplo.edu', 'pass_docente2' FROM p_doc2;

-- Expedientes para ambos docentes
WITH conv AS (
  SELECT ConvocatoriaId FROM Convocatorias WHERE Periodo = '2025-A' LIMIT 1
), d1 AS (
  SELECT DocenteId FROM Docentes WHERE Email = 'docente1@ejemplo.edu'
), d2 AS (
  SELECT DocenteId FROM Docentes WHERE Email = 'docente2@ejemplo.edu'
)
INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
SELECT conv.ConvocatoriaId, d1.DocenteId, '2025-A', CURRENT_DATE FROM conv, d1
UNION ALL
SELECT conv.ConvocatoriaId, d2.DocenteId, '2025-A', CURRENT_DATE FROM conv, d2;

-- Tutorías (asesorados) solo para el primer docente: 10 asesorados
WITH d1 AS (SELECT DocenteId FROM Docentes WHERE Email = 'docente1@ejemplo.edu')
INSERT INTO Tutorias_Docentes (DocenteId, Semestre, NumEstudiantes, FolioConstancia, ImpactoEvaluacion, VoBo_SubAcademica)
SELECT d1.DocenteId, '2025-1', 10, 'FOL-TUT-2025-001', 'Seguimiento regular', 'SI' FROM d1;
-- El segundo docente queda con 0 asesorados (no insertamos tutorías)

-- 14 tipos de documentos
INSERT INTO Tipos_Documentos (TipoDocumentoID, NombreCorto, NombreCompleto, FactorAsociado, AreaResponsable) VALUES
(nextval('tipos_doc_seq'), '01', 'Constancia de Recursos Humanos sobre nombramiento, asistencia y sanciones', 'F1', 'Recursos Humanos'),
(nextval('tipos_doc_seq'), '02', 'Talón de pago (quincena 07 del 2025, sin DT o I8)', 'F1', 'Recursos Humanos'),
(nextval('tipos_doc_seq'), '03', 'Horarios de labores 2024 y 2025', 'F1', 'Académica'),
(nextval('tipos_doc_seq'), '04', 'Carta de exclusividad laboral (formato oficial)', 'F1', 'Recursos Humanos'),
(nextval('tipos_doc_seq'), '05', 'Proyecto de investigación vigente con dictamen y recomendación institucional', 'F1', 'Académica'),
(nextval('tipos_doc_seq'), '06', 'Constancia de CVU-TecNM actualizado', 'F1', 'Académica'),
(nextval('tipos_doc_seq'), '07', 'Constancia de asignaturas impartidas y estudiantes atendidos', 'F1', 'Académica'),
(nextval('tipos_doc_seq'), '08', 'Oficio de autorización de período sabático o beca comisión', 'F1', 'Recursos Humanos'),
(nextval('tipos_doc_seq'), '09', 'Licencia por gravidez (si aplica)', 'F1', 'Recursos Humanos'),
(nextval('tipos_doc_seq'), '10', 'Cédula profesional o acta de examen de grado', 'F1', 'Recursos Humanos'),
(nextval('tipos_doc_seq'), '11', 'Formato de liberación de actividades docentes (dos semestres)', 'F1', 'Académica'),
(nextval('tipos_doc_seq'), '12', 'Carta de liberación de actividades académicas (Anexo XXXVII)', 'F1', 'Académica'),
(nextval('tipos_doc_seq'), '13', 'Evaluaciones departamentales y autoevaluación (licenciatura o posgrado)', 'F1', 'Académica'),
(nextval('tipos_doc_seq'), '14', 'Evaluaciones del desempeño frente a grupo (mínimo 60% del estudiantado)', 'F1', 'Académica');