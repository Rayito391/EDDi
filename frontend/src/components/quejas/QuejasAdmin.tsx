import { useEffect, useMemo, useState } from 'react';
import './QuejasAdmin.css';

type Queja = {
  id: number;
  docente_id: number;
  expediente_docente_id?: number | null;
  fecha_queja: string;
  titulo: string;
  descripcion: string;
  estado_queja: string;
  fecha_resolucion?: string | null;
  observaciones_resolucion?: string | null;
};

type Docente = {
  id: number;
  email?: string;
  primer_nombre?: string;
  segundo_nombre?: string;
  apellido_paterno?: string;
  apellido_materno?: string;
  puesto_academico?: string;
};

const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:5000';
const STATUS_OPTIONS = ['Pendiente', 'En proceso', 'Resuelta'];

const QuejasAdmin = () => {
  const [quejas, setQuejas] = useState<Queja[]>([]);
  const [docentes, setDocentes] = useState<Docente[]>([]);
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [selectedEstado, setSelectedEstado] = useState<string>('Pendiente');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [updatingId, setUpdatingId] = useState<number | null>(null);
  const [observaciones, setObservaciones] = useState<string>('');

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        const [quejasRes, docentesRes] = await Promise.all([
          fetch(`${API_BASE}/quejas/`, { credentials: 'include' }),
          fetch(`${API_BASE}/docentes/`, { credentials: 'include' }),
        ]);
        const quejasData = await quejasRes.json().catch(() => []);
        const docentesData = await docentesRes.json().catch(() => ({}));

        if (!quejasRes.ok) {
          throw new Error(quejasData?.error || 'No se pudieron cargar las quejas');
        }
        if (!docentesRes.ok) {
          throw new Error(docentesData?.error || 'No se pudieron cargar los docentes');
        }

        setQuejas(Array.isArray(quejasData) ? quejasData : quejasData?.quejas || []);
        setDocentes(docentesData?.docentes || []);
      } catch (e) {
        const msg = e instanceof Error ? e.message : 'Error al cargar información';
        setError(msg);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  useEffect(() => {
    if (!msg && !error) return;
    const t = setTimeout(() => {
      setMsg(null);
      setError(null);
    }, 3000);
    return () => clearTimeout(t);
  }, [msg, error]);

  const docenteMap = useMemo(
    () =>
      docentes.reduce<Record<number, Docente>>((acc, d) => {
        acc[d.id] = d;
        return acc;
      }, {}),
    [docentes]
  );

  const sortedQuejas = useMemo(() => {
    const priority = (estado: string) => {
      if ((estado || '').toLowerCase() === 'pendiente') return 0;
      if ((estado || '').toLowerCase().includes('proceso')) return 1;
      return 2;
    };
    return [...quejas].sort((a, b) => {
      const byEstado = priority(a.estado_queja) - priority(b.estado_queja);
      if (byEstado !== 0) return byEstado;
      return new Date(b.fecha_queja).getTime() - new Date(a.fecha_queja).getTime();
    });
  }, [quejas]);

  const selectedQueja = sortedQuejas.find((q) => q.id === selectedId) || sortedQuejas[0] || null;

  useEffect(() => {
    if (!selectedId && sortedQuejas.length) {
      setSelectedId(sortedQuejas[0].id);
    }
  }, [sortedQuejas, selectedId]);

  useEffect(() => {
    if (selectedQueja) {
      setSelectedEstado(selectedQueja.estado_queja);
      setObservaciones(selectedQueja.observaciones_resolucion || '');
    } else {
      setSelectedEstado('Pendiente');
      setObservaciones('');
    }
  }, [selectedQueja]);

  const fullName = (docente?: Docente) =>
    docente
      ? [
          docente.primer_nombre,
          docente.segundo_nombre,
          docente.apellido_paterno,
          docente.apellido_materno,
        ]
          .filter(Boolean)
          .join(' ') ||
        docente.email ||
        `Docente ${docente.id}`
      : 'Docente';

  const formatDate = (iso: string | null | undefined) => {
    if (!iso) return '';
    const d = new Date(iso);
    return d.toLocaleDateString('es-MX', { day: '2-digit', month: 'short', year: 'numeric' });
  };

  const handleStatusChange = async (quejaId: number, estado: string) => {
    try {
      setUpdatingId(quejaId);
      setMsg(null);
      setError(null);

      const res = await fetch(`${API_BASE}/quejas/${quejaId}/estado`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ estado_queja: estado, observaciones_resolucion: observaciones }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        throw new Error(data?.error || 'No se pudo actualizar el estado');
      }

      setQuejas((prev) =>
        prev.map((q) =>
          q.id === quejaId
            ? {
                ...q,
                estado_queja: data?.estado_queja || estado,
                observaciones_resolucion:
                  data?.observaciones_resolucion !== undefined
                    ? data.observaciones_resolucion
                    : observaciones,
                fecha_resolucion: data?.fecha_resolucion ?? q.fecha_resolucion,
              }
            : q
        )
      );
      setMsg('Actualizado correctamente');
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al actualizar estado';
      setError(msg);
    } finally {
      setUpdatingId(null);
    }
  };

  return (
    <div className="quejas-admin">
      <div className="quejas-admin__list">
        <div className="quejas-admin__list-header">
          <div>
            <h3>Quejas registradas</h3>
          </div>
          {loading && <span className="quejas-admin__pill">Cargando...</span>}
        </div>

        {error && <p className="quejas-status quejas-status--error">{error}</p>}
        {msg && <p className="quejas-status quejas-status--ok">{msg}</p>}

        <ul className="quejas-admin__items">
          {sortedQuejas.map((q) => {
            const docente = docenteMap[q.docente_id];
            const isActive = selectedQueja?.id === q.id;
            return (
              <li key={q.id}>
                <button
                  type="button"
                  className={`quejas-admin__item${isActive ? ' is-active' : ''}`}
                  onClick={() => setSelectedId(q.id)}
                >
                  <div className="quejas-admin__item-row">
                    <div>
                      <p className="quejas-admin__item-title">{q.titulo}</p>
                      <p className="quejas-admin__item-author">{fullName(docente)}</p>
                    </div>
                    <div className="quejas-admin__item-meta">
                      <span
                        className={`quejas-admin__status quejas-admin__status--${(
                          q.estado_queja || ''
                        )
                          .toLowerCase()
                          .replace(/\s+/g, '-')}`}
                      >
                        {q.estado_queja}
                      </span>
                      <span className="quejas-admin__date">{formatDate(q.fecha_queja)}</span>
                    </div>
                  </div>
                  <p className="quejas-admin__item-desc">{q.descripcion}</p>
                </button>
              </li>
            );
          })}
          {!sortedQuejas.length && !loading && (
            <li className="quejas-admin__empty">No hay quejas registradas.</li>
          )}
        </ul>
      </div>

      <div className="quejas-admin__detail">
        {selectedQueja ? (
          <>
              <div className="quejas-admin__detail-head">
                <div>
                  <p className="quejas-admin__detail-label">Título</p>
                  <h3 className="quejas-admin__detail-title">{selectedQueja.titulo}</h3>
                  <p className="quejas-admin__detail-date">
                    Registrada el {formatDate(selectedQueja.fecha_queja)}
                  </p>
                </div>
                <div className="quejas-admin__detail-status">
                  <label htmlFor="estado-select">Estatus</label>
                  <select
                    id="estado-select"
                    value={selectedEstado}
                    onChange={(e) => setSelectedEstado(e.target.value)}
                    disabled={updatingId === selectedQueja.id}
                  >
                    {STATUS_OPTIONS.map((s) => (
                      <option key={s} value={s}>
                        {s}
                      </option>
                    ))}
                  </select>
                  <label htmlFor="observaciones">Observaciones</label>
                  <textarea
                    id="observaciones"
                    value={observaciones}
                    onChange={(e) => setObservaciones(e.target.value)}
                    rows={3}
                  />
                  <button
                    type="button"
                    className="quejas-admin__save"
                    onClick={() => handleStatusChange(selectedQueja.id, selectedEstado)}
                    disabled={updatingId === selectedQueja.id}
                  >
                    {updatingId === selectedQueja.id ? 'Guardando...' : 'Guardar cambios'}
                  </button>
                </div>
              </div>

            <div className="quejas-admin__detail-section">
              <p className="quejas-admin__detail-label">Descripción</p>
              <p className="quejas-admin__detail-text">{selectedQueja.descripcion}</p>
            </div>

            <div className="quejas-admin__detail-section">
              <p className="quejas-admin__detail-label">Persona que reporta</p>
              <div className="quejas-admin__person">
                <div className="quejas-admin__avatar">
                  {fullName(docenteMap[selectedQueja.docente_id]).substring(0, 1).toUpperCase()}
                </div>
                <div>
                  <p className="quejas-admin__person-name">
                    {fullName(docenteMap[selectedQueja.docente_id])}
                  </p>
                  <p className="quejas-admin__person-email">
                    {docenteMap[selectedQueja.docente_id]?.email || 'Sin correo registrado'}
                  </p>
                </div>
              </div>
            </div>

            {selectedQueja.observaciones_resolucion && (
              <div className="quejas-admin__detail-section">
                <p className="quejas-admin__detail-label">Observaciones</p>
                <p className="quejas-admin__detail-text">
                  {selectedQueja.observaciones_resolucion}
                </p>
              </div>
            )}

            {selectedQueja.fecha_resolucion && (
              <div className="quejas-admin__detail-section">
                <p className="quejas-admin__detail-label">Resuelta</p>
                <p className="quejas-admin__detail-text">
                  {formatDate(selectedQueja.fecha_resolucion)}
                </p>
              </div>
            )}
          </>
        ) : (
          <div className="quejas-admin__placeholder">
            <p>Selecciona una queja para ver los detalles.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default QuejasAdmin;
