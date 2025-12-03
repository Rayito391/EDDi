 INSERT INTO Personal (PersonaId, PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso)
  VALUES ( 'Maria', NULL, 'Garcia', 'Sosa', 'MGAS850505MDF00500', 'MGAS850505MNO', '2024-09-01')
  ON CONFLICT (PersonaId) DO NOTHING
  RETURNING PersonaId
)
INSERT INTO Docentes (DocenteId, PersonaId, PuestoAcademico, Email, PasswordEmail)
SELECT 14, PersonaId, 'Docente', 'docente2@ejemplo.edu', 'pass_docente2' FROM p_doc2
ON CONFLICT (DocenteId) DO NOTHING;








--Documento 01:
BEGIN;
-- 1) Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso
  ) VALUES (
    'Laura', NULL, 'García', 'López', 'GALP000101HDFRLR01', 'GALP000101ABC', DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- 2) Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'laura.garcia@ejemplo.edu', 'clave-segura' FROM p
  RETURNING DocenteId
),
-- 3) Materias base (si no existen)
m AS (
  INSERT INTO Materias (NombreMateria, Nivel, EsDiferenteBase)
  VALUES ('Calculo Integral', 'Licenciatura', 'NO')
  ON CONFLICT (NombreMateria, Nivel) DO UPDATE SET NombreMateria=excluded.NombreMateria
  RETURNING MateriaId
),
mpos AS (
  INSERT INTO Materias (NombreMateria, Nivel, EsDiferenteBase)
  VALUES ('Investigacion Aplicada', 'Posgrado', 'NO')
  ON CONFLICT (NombreMateria, Nivel) DO UPDATE SET NombreMateria=excluded.NombreMateria
  RETURNING MateriaId
),
-- 4) Expediente ligado a convocatoria 1 (ajusta si usas otro ID)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, '2025-A', CURRENT_DATE FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- 5) Estatus laboral con reglas: plaza 10/95, activo antes 2024-01-01, sin sanción, ≥90% asistencia
elp AS (
  INSERT INTO Estatus_Laboral_Periodo (
    DocenteId, EstatusPlaza, EstatusPlazaInicio, TipoNombramiento,
    PercepcionQ07_2025, PeriodoEvaluado, DiasLaboralesTotales, TotalFaltas, TipoSancion
  )
  SELECT DocenteId, '10', DATE '2023-12-15', 'Tiempo Completo',
         15000, '2024', 200, 10, NULL
  FROM d
  RETURNING EstatusPeriodoId, DocenteId
),
-- 6) Clases impartidas 2024 y 2025-1
md AS (
  INSERT INTO Materias_Docentes (DocenteId, MateriaId, TotalAlumnos, Semestre, EsComplementaria)
  SELECT DocenteId, (SELECT MateriaId FROM m),    35, '2024',  'NO' FROM d
  UNION ALL
  SELECT DocenteId, (SELECT MateriaId FROM mpos), 18, '2025-1','NO' FROM d
  RETURNING AsignaturaDocenteId
),
-- 7) Carga reglamentaria cumplida (marca 'SI')
hor AS (
  INSERT INTO Horarios_Docentes (DocenteId, Semestre, HorarioInicio, HorarioFin, CargaReglamentaria)
  SELECT DocenteId, '2025-1', TIME '07:00', TIME '13:00', 'SI' FROM d
  RETURNING HorarioDocenteId
),
-- 8) (Opcional) Evidencia de lineamientos TecNM 2023 posgrado
posg AS (
  INSERT INTO Comisiones_Oficios_Docentes (
    DocenteID, TipoComision, ClaveActividad, FolioOficioComision,
    FolioConstanciaCumplimiento, VoBo_SubAcademica, NivelParticipacion
  )
  SELECT DocenteId,
         'Cumplimiento lineamientos TecNM 2023 posgrado', 'POSG2023',
         'OF-12345', 'CONST-12345', 'SI', 'Titular'
  FROM d
  RETURNING ComisionOficioDocenteId
)
-- 9) Registrar el documento generado (TipoDocumentoID = 1)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 1, 'RH-01-2025-LGL', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 02
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno, Curp, Rfc, FechaIngreso
  ) VALUES (
    'Pedro', NULL, 'Ramirez', 'Luna',
    'RALP850101HDF00111', 'RALP850101ABC',
    DATE '2020-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'pedro.ramirez@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (usa ConvocatoriaId=1 ya sembrada en init.sql)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Estatus laboral con percepción Q07 2025 y sin sanción (sin DT/I8)
elp AS (
  INSERT INTO Estatus_Laboral_Periodo (
    DocenteId,
    EstatusPlaza, EstatusPlazaInicio, TipoNombramiento,
    PercepcionQ07_2025, PeriodoEvaluado,
    DiasLaboralesTotales, TotalFaltas, TipoSancion
  )
  SELECT DocenteId,
         '10', DATE '2023-12-15', 'Tiempo Completo',
         15000.00, '2025-Q07',
         10, 0, NULL
  FROM d
  RETURNING EstatusPeriodoId
)
-- Documento generado (TipoDocumentoID = 2)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 2, 'RH-02-2025-PRL', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 03
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Sofia', NULL, 'Hernandez', 'Mora',
    'HESM900101MDF00333', 'HESM900101ABC',
    DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'sofia.hernandez@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1 ya sembrada en init.sql)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Horarios 2024 y 2025-1 con carga reglamentaria cumplida
hor AS (
  INSERT INTO Horarios_Docentes (
    DocenteId, Semestre, HorarioInicio, HorarioFin, CargaReglamentaria
  )
  SELECT DocenteId, '2024',   TIME '07:00', TIME '13:00', 'SI' FROM d
  UNION ALL
  SELECT DocenteId, '2025-1', TIME '08:00', TIME '14:00', 'SI' FROM d
  RETURNING HorarioDocenteId
)
-- Documento generado (TipoDocumentoID = 3)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 3, 'ACAD-03-2025-SHM', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 04
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Miguel', NULL, 'Torres', 'Salinas',
    'TOSM900101HDF00444', 'TOSM900101ABC',
    DATE '2018-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'miguel.torres@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1 ya sembrada en init.sql)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Evidencia de dedicación exclusiva: horario con carga reglamentaria “SI” en el periodo actual
hor AS (
  INSERT INTO Horarios_Docentes (
    DocenteId, Semestre, HorarioInicio, HorarioFin, CargaReglamentaria
  )
  SELECT DocenteId, '2025-1', TIME '08:00', TIME '14:00', 'SI' FROM d
  RETURNING HorarioDocenteId
)
-- Registrar el documento generado (TipoDocumentoID = 4)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 4, 'RH-04-2025-MTS', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 05
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Daniel', NULL, 'Cortes', 'Ibarra',
    'COID900101HDF00555', 'COID900101ABC',
    DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'daniel.cortes@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1 ya sembrada)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Proyecto de investigacion vigente con dictamen y recomendacion
proj AS (
  INSERT INTO Proyectos_Investigacion (
    NombreProyecto, FolioRegistro, VigenciaInicio, VigenciaFin,
    FuenteFinanciamiento, DictamenDirector, RecomendacionComite, TipoProyecto
  )
  VALUES (
    'Analisis de Datos Educativos 2025',
    'REG-PI-2025-005',
    DATE '2024-07-01',
    DATE '2025-12-31',
    'TecNM',
    'SI',  -- dictamen positivo
    'SI',  -- recomendacion institucional
    'Investigacion Aplicada'
  )
  RETURNING ProyectoId
),
-- Asociar docente al proyecto
pd AS (
  INSERT INTO Proyectos_Docentes (DocenteId, ProyectoId, Rol)
  SELECT d.DocenteId, proj.ProyectoId, 'Responsable Tecnico'
  FROM d, proj
  RETURNING ProyectosDocentesId
)
-- Registrar el documento generado (TipoDocumentoID = 5)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 5, 'ACAD-05-2025-DCI', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 06
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Camila', NULL, 'Navarro', 'Reyes',
    'NARC900101MDF00666', 'NARC900101ABC',
    DATE '2020-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'camila.navarro@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1 ya sembrada)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- CVU actualizado
cvu AS (
  INSERT INTO CVU_Control_Docente (
    DocenteId, FechaUltimaActualizacion, EstadoCVU, FolioConstancia
  )
  SELECT DocenteId, DATE '2025-02-05', 'Actualizado', 'CVU-TEC-2025-066'
  FROM d
  RETURNING CVUControlDocenteId
)
-- Registrar el documento generado (TipoDocumentoID = 6)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 6, 'ACAD-06-2025-CNR', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 07 
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Lucia', NULL, 'Vega', 'Sandoval',
    'VESL900101MDF00777', 'VESL900101ABC',
    DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'lucia.vega@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1 ya sembrada)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Materias (dos ejemplos)
m1 AS (
  INSERT INTO Materias (NombreMateria, Nivel, EsDiferenteBase)
  VALUES ('Bases de Datos Avanzadas', 'Licenciatura', 'NO')
  RETURNING MateriaId
),
m2 AS (
  INSERT INTO Materias (NombreMateria, Nivel, EsDiferenteBase)
  VALUES ('Metodologia de la Investigacion', 'Posgrado', 'NO')
  RETURNING MateriaId
),
-- Asignaturas impartidas con conteo de alumnos
md AS (
  INSERT INTO Materias_Docentes (DocenteId, MateriaId, TotalAlumnos, Semestre, EsComplementaria)
  SELECT d.DocenteId, m1.MateriaId, 32, '2024-2', 'NO' FROM d, m1
  UNION ALL
  SELECT d.DocenteId, m2.MateriaId, 28, '2025-1', 'NO' FROM d, m2
  RETURNING AsignaturaDocenteId
)
-- Documento generado (TipoDocumentoID = 7)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 7, 'ACAD-07-2025-LVS', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 08
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Andrea', NULL, 'Silva', 'Morales',
    'SIM A900101MDF00888', 'SIMA900101ABC',
    DATE '2018-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'andrea.silva@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Licencia sabático/beca comisión con oficio autorizado
lic AS (
  INSERT INTO Licencias_Docentes (
    DocenteId, TipoLicencia, FolioAutorizacion, FechaInicio, FechaFin, EsOficioAutorizado
  )
  SELECT DocenteId, 'Sabatico', 'LIC-2025-008', DATE '2025-02-01', DATE '2025-07-31', 'SI'
  FROM d
  RETURNING LicenciaDocenteId
)
-- Documento generado (TipoDocumentoID = 8)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 8, 'RH-08-2025-ASM', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--documento 09
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Paola', NULL, 'Mendez', 'Rios',
    'MERP900101MDF00999', 'MERP900101ABC',
    DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'paola.mendez@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Licencia por gravidez con oficio autorizado
lic AS (
  INSERT INTO Licencias_Docentes (
    DocenteId, TipoLicencia, FolioAutorizacion, FechaInicio, FechaFin, EsOficioAutorizado
  )
  SELECT DocenteId, 'Gravidez', 'LIC-2025-009', DATE '2025-03-01', DATE '2025-08-31', 'SI'
  FROM d
  RETURNING LicenciaDocenteId
)
-- Documento generado (TipoDocumentoID = 9)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 9, 'RH-09-2025-PMR', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 10
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Karina', NULL, 'Ortega', 'Santos',
    'ORKA900101MDF01010', 'ORKA900101ABC',
    DATE '2020-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'karina.ortega@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Grado y cédula / acta
grado AS (
  INSERT INTO Grados_Estudios_Docentes (
    DocenteId, GradoObtenido, FolioCedula, FechaObtencion, FechaExpedicionCedula, InstitucionEmisora
  )
  SELECT DocenteId, 'Maestria', 'CED-2025-010', DATE '2020-06-30', DATE '2020-07-15', 'TecNM'
  FROM d
  RETURNING GradoEstudioDocenteId
)
-- Documento generado (TipoDocumentoID = 10)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 10, 'RH-10-2025-KOS', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 11
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Hugo', NULL, 'Benitez', 'Lozano',
    'BEZH900101HDF01111', 'BEZH900101ABC',
    DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'hugo.benitez@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Liberaciones en dos semestres
lib AS (
  INSERT INTO Liberaciones_Docentes (
    DocenteId, Semestre, TipoLiberacion, FolioLiberacion, CumplimientoPorcentaje, EstaLiberado
  )
  SELECT DocenteId, '2024-2', 'Academica', 'LIB-2024-011A', 100.00, 'SI' FROM d
  UNION ALL
  SELECT DocenteId, '2025-1', 'Academica', 'LIB-2025-011B', 100.00, 'SI' FROM d
  RETURNING LiberacionDocenteId
)
-- Documento generado (TipoDocumentoID = 11)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 11, 'ACAD-11-2025-HBL', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 12
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Irene', NULL, 'Quintero', 'Ruiz',
    'QUIR900101MDF01212', 'QUIR900101ABC',
    DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'irene.quintero@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Liberación académica (Anexo XXXVII)
lib AS (
  INSERT INTO Liberaciones_Docentes (
    DocenteId, Semestre, TipoLiberacion, FolioLiberacion, CumplimientoPorcentaje, EstaLiberado
  )
  SELECT DocenteId, '2025-1', 'Academica', 'ANEXO-XXXVII-2025-012', 100.00, 'SI'
  FROM d
  RETURNING LiberacionDocenteId
)
-- Documento generado (TipoDocumentoID = 12)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 12, 'ACAD-12-2025-IQR', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 13
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Brenda', NULL, 'Salazar', 'Nieto',
    'SANB900101MDF01313', 'SANB900101ABC',
    DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'brenda.salazar@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Evaluaciones: desempeño y autoevaluación (licenciatura o posgrado)
evals AS (
  INSERT INTO Evaluaciones_Docentes (
    DocenteId, Semestre, TipoEvaluacion, Calificacion, NombreDptoAcademico,
    CoberturaEstudiantes, VoBo_SubAcademica
  )
  SELECT DocenteId, '2024-2', 'Desempeno',      90.00, 'Sistemas y Computacion', 80.00, 'SI' FROM d
  UNION ALL
  SELECT DocenteId, '2024-2', 'Autoevaluacion', 88.00, 'Sistemas y Computacion', 80.00, 'SI' FROM d
  RETURNING EvaluacionDocenteId
)
-- Documento generado (TipoDocumentoID = 13)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 13, 'ACAD-13-2025-BSN', CURRENT_TIMESTAMP
FROM exp;

COMMIT;


--Documento 14
BEGIN;
-- Persona
WITH p AS (
  INSERT INTO Personal (
    PrimerNombre, SegundoNombre, ApellidoPaterno, ApellidoMaterno,
    Curp, Rfc, FechaIngreso
  ) VALUES (
    'Sergio', NULL, 'Lopez', 'Camacho',
    'LOCS900101HDF01414', 'LOCS900101ABC',
    DATE '2019-08-15'
  )
  RETURNING PersonaId
),
-- Docente
d AS (
  INSERT INTO Docentes (PersonaId, PuestoAcademico, Email, PasswordEmail)
  SELECT PersonaId, 'Docente', 'sergio.lopez@ejemplo.edu', 'ClaveSegura#2025'
  FROM p
  RETURNING DocenteId
),
-- Expediente (ConvocatoriaId = 1)
exp AS (
  INSERT INTO Expediente_Docente (ConvocatoriaId, DocenteId, Periodo, FechaCreacion)
  SELECT 1, DocenteId, 'Enero-Diciembre 2025', CURRENT_DATE
  FROM d
  RETURNING ExpedienteDocenteId, DocenteId
),
-- Evaluación de desempeño frente a grupo (cobertura >= 60%)
evals AS (
  INSERT INTO Evaluaciones_Docentes (
    DocenteId, Semestre, TipoEvaluacion, Calificacion, NombreDptoAcademico,
    CoberturaEstudiantes, VoBo_SubAcademica
  )
  SELECT DocenteId, '2024-2', 'Desempeno', 92.00, 'Sistemas y Computacion', 85.00, 'SI'
  FROM d
  RETURNING EvaluacionDocenteId
)
-- Documento generado (TipoDocumentoID = 14)
INSERT INTO Documentos_Generados (ExpedienteId, TipoDocumentoID, FolioInterno, FechaGeneracion)
SELECT exp.ExpedienteDocenteId, 14, 'ACAD-14-2025-SLC', CURRENT_TIMESTAMP
FROM exp;

COMMIT;