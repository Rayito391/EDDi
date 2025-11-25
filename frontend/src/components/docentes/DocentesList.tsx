import { useEffect, useMemo, useState } from 'react';
import './DocentesList.css';
import CustomButton from '../global/CustomButton/CustomButton';

type DocenteItem = {
  id: number;
  nombre: string;
  email?: string;
  puesto?: string;
  totalDocs?: number;
  docsInicio?: number;
  docsFactor?: number;
  tutorados?: number;
};

const DocentesList = () => {
  const [query, setQuery] = useState('');
  const [docentes, setDocentes] = useState<DocenteItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const apiBase = process.env.REACT_APP_API_URL || 'http://localhost:5000';

  const fetchDocentes = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await fetch(`${apiBase}/docentes/`, { credentials: 'include' });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.error || 'No se pudieron cargar los docentes');
      }
      const mapped: DocenteItem[] = (data?.docentes || []).map((d: any) => ({
        id: d.id,
        nombre:
          [d.primer_nombre, d.segundo_nombre, d.apellido_paterno, d.apellido_materno]
            .filter(Boolean)
            .join(' ') || 'Sin nombre',
        email: d.email,
        puesto: d.puesto_academico,
        totalDocs: d.total_documentos,
        docsInicio: d.documentos_inicio,
        docsFactor: d.documentos_factor,
        tutorados: d.tutorados,
      }));
      const filtered = mapped.filter((d) => (d.puesto || '').toLowerCase() === 'docente');
      setDocentes(filtered);
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error desconocido';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDocentes();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const filtered = useMemo(() => {
    if (!query) return docentes;
    const q = query.toLowerCase();
    return docentes.filter(
      (d) => d.nombre.toLowerCase().includes(q) || (d.email || '').toLowerCase().includes(q)
    );
  }, [docentes, query]);

  return (
    <div className="doc-list">
      <div className="doc-list__header">
        <div>
          <h2 className="doc-list__title">Docentes registrados</h2>
          <p className="doc-list__subtitle">Filtrar por nombre o correo.</p>
        </div>
        <div className="doc-list__actions">
          <CustomButton
            label="Refrescar"
            className="custom-button--small"
            variant="outline"
            onClick={() => {
              setQuery('');
              fetchDocentes();
            }}
            disabled={loading}
          />
        </div>
      </div>

      <div className="doc-list__filter">
        <input
          type="text"
          placeholder="Filtrar por nombre o correo..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
      </div>

      {loading && <div className="doc-list__status">Cargando...</div>}
      {error && <div className="doc-list__status doc-list__status--error">{error}</div>}

      <ul className="doc-list__items">
        {filtered.map((d) => (
          <li key={d.id} className="doc-list__item">
            <div>
              <p className="doc-list__name">{d.nombre}</p>
              <p className="doc-list__email">{d.email || 'Sin correo'}</p>
              {d.puesto && <p className="doc-list__meta">{d.puesto}</p>}
              <p className="doc-list__meta">Total documentos: {d.totalDocs ?? 0}</p>
              <p className="doc-list__meta">Documentos inicio: {d.docsInicio ?? 0} / 14</p>
            </div>
            <div className="doc-list__tutorados">Tutorados: {d.tutorados ?? 0}</div>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default DocentesList;
