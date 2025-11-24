import { useEffect, useMemo, useState } from 'react';
import './MyDocuments.css';
import CustomButton from '../global/CustomButton/CustomButton';
import { useAuth } from '../../contexts/AuthContext';
import { jsPDF } from 'jspdf';
import { renderDocumentContent } from '../../utils/documentTemplates';
import logoLeft from '../../assets/images/logo.png';

type DocumentoGenerado = {
  id: number;
  titulo: string;
  folio: string;
  fecha: string;
  tipo_documento_id: number;
};

const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:5000';

const MyDocuments = () => {
  const [docs, setDocs] = useState<DocumentoGenerado[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  const [actionLoading, setActionLoading] = useState<number | null>(null);
  const { user } = useAuth();

  const fetchDocs = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await fetch(`${API_BASE}/documentos/mis`, { credentials: 'include' });
      if (!res.ok) {
        throw new Error('No se pudieron cargar tus documentos');
      }
      const data: DocumentoGenerado[] = await res.json();
      setDocs(data);
    } catch (e) {
      const message = e instanceof Error ? e.message : 'Error desconocido';
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDocs();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const filtered = useMemo(() => {
    if (!query) return docs;
    const q = query.toLowerCase();
    return docs.filter(
      (d) => d.titulo.toLowerCase().includes(q) || d.folio.toLowerCase().includes(q)
    );
  }, [docs, query]);

  const docenteNombreCompleto =
    [user?.primer_nombre, user?.segundo_nombre, user?.apellido_paterno, user?.apellido_materno]
      .filter(Boolean)
      .join(' ')
      .trim() || 'Docente';

  const buildPdf = (doc: DocumentoGenerado) => {
    const pdf = new jsPDF();
    const startX = 20;
    const { titleLines, paragraphs } = renderDocumentContent(doc.tipo_documento_id, {
      docenteNombre: docenteNombreCompleto,
      titulo: doc.titulo,
      folio: doc.folio,
      fecha: new Date(doc.fecha).toLocaleString(),
      logoLeft,
    });

    const imgWidth = 60;
    const imgHeight = 20;
    const topMargin = 12 + imgHeight;
    try {
      pdf.addImage(logoLeft, 'PNG', 20, 10, imgWidth, imgHeight);
    } catch (_e) {}

    pdf.setFont('helvetica', 'bold');
    const dynamicTitleSize = titleLines.join(' ').length > 60 ? 13 : 16;
    pdf.setFontSize(dynamicTitleSize);
    let currentY = 10 + topMargin;
    titleLines.forEach((line) => {
      const wrapped = pdf.splitTextToSize(line, 170);
      wrapped.forEach((w) => {
        pdf.text(w, startX, currentY);
        currentY += 6;
      });
    });

    pdf.setFontSize(12);
    pdf.setFont('helvetica', 'normal');
    const prefix = 'El (La) que suscribe ';
    const startY = currentY + 8;
    pdf.text(prefix, startX, startY);

    const prefixWidth = pdf.getTextWidth(prefix);
    const nameUpper = docenteNombreCompleto.toUpperCase();
    const availableWidth = 170 - prefixWidth;
    const nameLines = pdf.splitTextToSize(nameUpper, availableWidth);

    let y = startY;
    pdf.setFont('helvetica', 'bold');
    pdf.setLineWidth(0.4);
    nameLines.forEach((line, idx) => {
      const x = idx === 0 ? startX + prefixWidth : startX;
      pdf.text(line, x, y);
      const lineWidth = pdf.getTextWidth(line);
      pdf.line(x, y + 1, x + lineWidth, y + 1);
      y += 6;
    });

    pdf.setFont('helvetica', 'normal');
    let py = y + 8;
    paragraphs.forEach((p) => {
      const lines = pdf.splitTextToSize(p, 170);
      lines.forEach((l) => {
        pdf.text(l, startX, py);
        py += 6;
      });
      py += 2;
    });

    // Fecha abajo a la derecha
    const pageWidth = pdf.internal.pageSize.getWidth();
    const pageHeight = pdf.internal.pageSize.getHeight();
    const fechaStr = new Date(doc.fecha).toLocaleDateString();
    pdf.text(fechaStr, pageWidth - 15, pageHeight - 15, { align: 'right' });

    return pdf;
  };

  const handlePreview = async (doc: DocumentoGenerado) => {
    try {
      setActionLoading(doc.id);
      const pdf = buildPdf(doc);
      const blobUrl = pdf.output('bloburl');
      const urlString = typeof blobUrl === 'string' ? blobUrl : blobUrl.toString();
      window.open(urlString, '_blank', 'noopener');
      setTimeout(() => URL.revokeObjectURL(urlString), 5000);
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al mostrar la vista previa';
      setError(msg);
    } finally {
      setActionLoading(null);
    }
  };

  const handleDownload = async (doc: DocumentoGenerado) => {
    try {
      setActionLoading(doc.id);
      const pdf = buildPdf(doc);
      pdf.save(`${doc.titulo || 'documento'}_${doc.id}.pdf`);
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al descargar el documento';
      setError(msg);
    } finally {
      setActionLoading(null);
    }
  };

  return (
    <div className="mydocs">
      <div className="mydocs__header">
        <div>
          <h2 className="mydocs__title">Mis Documentos</h2>
          <p className="mydocs__subtitle">Consulta y descarga los documentos ya generados.</p>
        </div>
        <div className="mydocs__actions">
          <CustomButton
            label="Limpiar"
            variant="outline"
            className="custom-button--small"
            onClick={() => setQuery('')}
          />
          <CustomButton
            label="Refrescar"
            variant="primary"
            className="custom-button--small"
            onClick={fetchDocs}
            disabled={loading}
          />
        </div>
      </div>

      <div className="mydocs__filter">
        <input
          type="text"
          placeholder="Filtrar por título o folio..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
      </div>

      {loading && <div className="mydocs__status">Cargando documentos...</div>}
      {error && <div className="mydocs__status mydocs__status--error">{error}</div>}
      {!loading && !error && filtered.length === 0 && (
        <div className="mydocs__status">No hay documentos generados.</div>
      )}

      <ul className="mydocs__list">
        {filtered.map((doc) => {
          const fecha = new Date(doc.fecha);
          const fechaTexto = isNaN(fecha.getTime())
            ? doc.fecha
            : fecha.toLocaleDateString() + ' ' + fecha.toLocaleTimeString();
          return (
            <li key={doc.id} className="mydocs__item">
              <div>
                <p className="mydocs__item-title">{doc.titulo}</p>
                <p className="mydocs__item-meta">
                  {fechaTexto} · Folio: {doc.folio}
                </p>
              </div>
              <div className="mydocs__item-actions">
                <CustomButton
                  label="Descargar"
                  variant="secondary"
                  className="custom-button--small"
                  onClick={() => handleDownload(doc)}
                  disabled={actionLoading === doc.id}
                />
                <CustomButton
                  label="Vista previa"
                  variant="outline"
                  className="custom-button--small"
                  onClick={() => handlePreview(doc)}
                  disabled={actionLoading === doc.id}
                />
              </div>
            </li>
          );
        })}
      </ul>
    </div>
  );
};

export default MyDocuments;
