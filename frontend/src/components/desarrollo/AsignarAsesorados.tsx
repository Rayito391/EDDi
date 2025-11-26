import { useEffect, useMemo, useState } from 'react';
import CustomButton from '../global/CustomButton/CustomButton';
import './AsignarTutorados.css'; // reutilizamos estilos

type Docente = {
  id: number;
  email: string;
  puesto_academico?: string;
  primer_nombre?: string;
  segundo_nombre?: string;
  apellido_paterno?: string;
  apellido_materno?: string;
  asesorados?: number;
};

const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:5000';

const AsignarAsesorados = () => {
  const [docentes, setDocentes] = useState<Docente[]>([]);
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [numAsesorados, setNumAsesorados] = useState<number>(0);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);

  useEffect(() => {
    const fetchDocentes = async () => {
      try {
        setLoading(true);
        setError(null);
        const res = await fetch(`${API_BASE}/docentes/?puesto_academico=Docente`, {
          credentials: 'include',
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) {
          throw new Error(data?.error || 'No se pudieron cargar los docentes');
        }
        setDocentes(data?.docentes || []);
      } catch (e) {
        const msg = e instanceof Error ? e.message : 'Error al cargar docentes';
        setError(msg);
      } finally {
        setLoading(false);
      }
    };
    fetchDocentes();
  }, []);

  useEffect(() => {
    const t = setTimeout(() => {
      setMsg(null);
      setError(null);
    }, 3000);
    return () => clearTimeout(t);
  }, [msg, error]);

  const selectedDocente = useMemo(
    () => (selectedId ? docentes.find((d) => d.id === selectedId) || null : null),
    [selectedId, docentes]
  );

  const fullName = (d: Docente | null) =>
    d
      ? [d.primer_nombre, d.segundo_nombre, d.apellido_paterno, d.apellido_materno]
          .filter(Boolean)
          .join(' ') || d.email || 'Docente'
      : '';

  const handleSave = async () => {
    if (!selectedId) {
      setError('Selecciona un docente.');
      return;
    }
    if (numAsesorados < 0) {
      setError('El número de asesorados no puede ser negativo.');
      return;
    }
    try {
      setSaving(true);
      setError(null);
      setMsg(null);

      // Endpoint de asesorados
      const res = await fetch(`${API_BASE}/asesorados/docentes/${selectedId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ num_asesorados: numAsesorados }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        throw new Error(data?.error || 'No se pudo guardar los asesorados');
      }

      if (data?.num_asesorados !== undefined) {
        setDocentes((prev) =>
          prev.map((d) =>
            d.id === selectedId ? { ...d, asesorados: data.num_asesorados } : d
          )
        );
      }
      setMsg('Asesorados guardados correctamente.');
      setNumAsesorados(0);
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al guardar';
      setError(msg);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="asignar-panel">
      <div className="asignar-card">
        <h2>Asignar asesorados</h2>
        <p className="asignar-subtitle">Selecciona el docente y captura el número de estudiantes que asesora.</p>
        {error && <p className="asignar-status asignar-status--error">{error}</p>}
        {msg && <p className="asignar-status asignar-status--ok">{msg}</p>}

        <label className="asignar-label">Docente</label>
        <select
          className="asignar-select"
          value={selectedId ?? ''}
          onChange={(e) => setSelectedId(Number(e.target.value) || null)}
          disabled={loading}
        >
          <option value="">-- Selecciona --</option>
          {docentes.map((d) => (
            <option key={d.id} value={d.id}>
              {fullName(d)}
            </option>
          ))}
        </select>

        <label className="asignar-label">Número de asesorados</label>
        <input
          type="number"
          min={0}
          className="asignar-input"
          value={numAsesorados}
          onChange={(e) => setNumAsesorados(Number(e.target.value) || 0)}
        />

        <div className="asignar-actions">
          <CustomButton
            label={saving ? 'Guardando...' : 'Guardar'}
            className="custom-button--small"
            onClick={handleSave}
            disabled={saving}
          />
        </div>
      </div>

      <div className="asignar-detail">
        <h3>Datos del docente seleccionado</h3>
        {selectedDocente ? (
          <ul className="asignar-detail-list">
            <li>
              <strong>Nombre:</strong> {fullName(selectedDocente)}
            </li>
            <li>
              <strong>Email:</strong> {selectedDocente.email}
            </li>
            <li>
              <strong>Puesto:</strong> {selectedDocente.puesto_academico || 'Docente'}
            </li>
            <li>
              <strong>Asesorados actuales:</strong> {selectedDocente.asesorados ?? 0}
            </li>
            <li>
              <strong>Cantidad de asesorados:</strong> {numAsesorados}
            </li>
          </ul>
        ) : (
          <p className="asignar-placeholder">Selecciona un docente para ver sus datos.</p>
        )}
      </div>
    </div>
  );
};

export default AsignarAsesorados;
