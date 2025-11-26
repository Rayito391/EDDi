import { useEffect, useMemo, useState } from 'react';
import './DocumentGenerator.css';
import CustomButton from '../global/CustomButton/CustomButton';
import { useAuth } from '../../contexts/AuthContext';
import { jsPDF } from 'jspdf';
import { renderDocumentContent } from '../../utils/documentTemplates';
import logoLeft from '../../assets/images/logo.png';

type ApiDocument = {
  id: number;
  nombre_corto: string;
  nombre_completo: string;
  factor_asociado?: string | null;
  area_responsable?: string | null;
};

type DocumentTemplate = {
  id: number;
  category: string;
  title: string;
  description: string;
  previewUrl: string;
};

const SAMPLE_PDF_DATA_URL =
  'data:application/pdf;base64,JVBERi0xLjQKJcKlwrHDqwoKMSAwIG9iago8PC9UeXBlIC9DYXRhbG9nL1BhZ2VzIDIgMCBSCj4+CmVuZG9iagoKMiAwIG9iago8PC9UeXBlIC9QYWdlcy9LaWRzIFszIDAgUl0vQ291bnQgMQo+PgplbmRvYmoKCjMgMCBvYmoKPDwvVHlwZSAvUGFnZS9QYXJlbnQgMiAwIFIvTWVkaWFCb3ggWzAgMCA2MTIgNzkyXS9Db250ZW50cyA0IDAgUi9SZXNvdXJjZXMgPDwvRm9udCA8PC9GMSA1IDAgUj4+Pj4+CmVuZG9iagoKNCAwIG9iago8PC9MZW5ndGggNDQ+PgpzdHJlYW0KQlQKL0YxIDI0IFRmCjEwMCA3MDAgVGQKKEV4YW1wbGUgUEZGKSBUCkVUCmdyZWFcblZpc3RhIHByZXZpYSBkZSBkb2N1bWVudG8KZW5kc3RyZWFtCmVuZG9iagoKNSAwIG9iago8PC9UeXBlIC9Gb250L1N1YnR5cGUgL1R5cGUxL0Jhc2VGb250IC9IZWx2ZXRpY2E+PgplbmRvYmoKCnhyZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDA5OSAwMDAwMCBuIAowMDAwMDAwMTczIDAwMDAwIG4gCjAwMDAwMDAzMjYgMDAwMDAgbiAKMDAwMDAwMDQzNyAwMDAwMCBuIAowMDAwMDAwNjIzIDAwMDAwIG4gCnRyYWlsZXIKPDwvU2l6ZSA2L1Jvb3QgMSAwIFIvSW5mbyA2IDAgUgo+PgpzdGFydHhyZWYKNzQ3CiUlRU9GCg==';

type DocumentGeneratorProps = {
  canGenerateDocs?: boolean;
};

const DocumentGenerator = ({ canGenerateDocs = true }: DocumentGeneratorProps) => {
  const [templates, setTemplates] = useState<DocumentTemplate[]>([]);
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [signatureUrl, setSignatureUrl] = useState<string | null>(null);
  const [signatureFormat, setSignatureFormat] = useState<'PNG' | 'JPEG' | null>(null);
  const apiBase = 'http://localhost:5000';
  const { user } = useAuth();

  useEffect(() => {
    const fetchDocuments = async () => {
      try {
        setLoading(true);
        setError(null);
        const resp = await fetch(`${apiBase}/documentos/`, { credentials: 'include' });
        if (!resp.ok) {
          throw new Error(`No se pudieron obtener documentos (${resp.status})`);
        }
        const data: ApiDocument[] = await resp.json();
        const mapped: DocumentTemplate[] = data.map((doc) => ({
          id: doc.id,
          category: doc.factor_asociado || 'Documentos disponibles',
          title: doc.nombre_corto,
          description: doc.nombre_completo,
          previewUrl: SAMPLE_PDF_DATA_URL,
        }));
        setTemplates(mapped);
        setSelectedId(mapped[0]?.id ?? null);
      } catch (err) {
        const message =
          err instanceof Error ? err.message : 'Error desconocido al cargar documentos';
        setError(message);
      } finally {
        setLoading(false);
      }
    };

    fetchDocuments();
  }, [apiBase]);

  useEffect(() => {
    if (successMsg) {
      const t = setTimeout(() => setSuccessMsg(null), 3000);
      return () => clearTimeout(t);
    }
  }, [successMsg]);

  useEffect(() => {
    const fetchSignature = async () => {
      if (!user?.id) return;
      try {
        const resp = await fetch(`${apiBase}/firmas/docentes/${user.id}`, {
          credentials: 'include',
        });
        if (!resp.ok) {
          setSignatureUrl(null);
          setSignatureFormat(null);
          return;
        }
        const blob = await resp.blob();
        if (!blob || blob.size === 0) {
          setSignatureUrl(null);
          setSignatureFormat(null);
          return;
        }
        const reader = new FileReader();
        reader.onloadend = () => {
          if (typeof reader.result === 'string') {
            const mime = blob.type?.toLowerCase() || '';
            const fmt = mime.includes('jpeg') || mime.includes('jpg') ? 'JPEG' : 'PNG';
            setSignatureFormat(fmt);
            setSignatureUrl(reader.result);
          }
        };
        reader.readAsDataURL(blob);
      } catch (_e) {
        setSignatureUrl(null);
        setSignatureFormat(null);
      }
    };
    fetchSignature();
  }, [apiBase, user?.id]);

  const groupedTemplates = useMemo(() => {
    return templates.reduce<Record<string, DocumentTemplate[]>>((acc, template) => {
      acc[template.category] = acc[template.category] || [];
      acc[template.category].push(template);
      return acc;
    }, {});
  }, [templates]);

  const selectedTemplate = templates.find((t) => t.id === selectedId) ?? null;
  const docenteNombre =
    [user?.primer_nombre, user?.segundo_nombre, user?.apellido_paterno, user?.apellido_materno]
      .filter(Boolean)
      .join(' ')
      .trim() || 'Docente';

  const [previewUrl, setPreviewUrl] = useState<string | null>(null);

  const buildPdf = () => {
    if (!selectedTemplate) return null;
    const doc = new jsPDF();
    const startX = 20;

    const { titleLines, paragraphs } = renderDocumentContent(selectedTemplate.id, {
      docenteNombre,
      titulo: selectedTemplate.description,
      logoLeft,
    });

    const imgWidth = 60;
    const imgHeight = 20;
    const topMargin = 12 + imgHeight;
    try {
      doc.addImage(logoLeft, 'PNG', 20, 10, imgWidth, imgHeight);
    } catch (_e) {}

    doc.setFont('helvetica', 'bold');
    const dynamicTitleSize = titleLines.join(' ').length > 60 ? 13 : 16;
    doc.setFontSize(dynamicTitleSize);
    let currentY = 10 + topMargin;
    titleLines.forEach((line) => {
      const wrapped = doc.splitTextToSize(line, 170);
      wrapped.forEach((w) => {
        doc.text(w, startX, currentY);
        currentY += 6;
      });
    });

    doc.setFontSize(12);
    doc.setFont('helvetica', 'normal');
    const prefix = 'El (La) que suscribe ';
    const startY = currentY + 8;
    doc.text(prefix, startX, startY);

    const prefixWidth = doc.getTextWidth(prefix);
    const nameUpper = (docenteNombre || 'Docente').toUpperCase();
    const availableWidth = 170 - prefixWidth;
    const nameLines = doc.splitTextToSize(nameUpper, availableWidth);

    currentY = startY;
    doc.setFont('helvetica', 'bold');
    doc.setLineWidth(0.4);
    nameLines.forEach((line, idx) => {
      const x = idx === 0 ? startX + prefixWidth : startX;
      doc.text(line, x, currentY);
      const lineWidth = doc.getTextWidth(line);
      doc.line(x, currentY + 1, x + lineWidth, currentY + 1);
      currentY += 6;
    });

    doc.setFont('helvetica', 'normal');
    const paragraphStartY = currentY + 8;
    let py = paragraphStartY;
    paragraphs.forEach((p) => {
      const lines = doc.splitTextToSize(p, 170);
      lines.forEach((l) => {
        doc.text(l, startX, py);
        py += 6;
      });
      py += 2;
    });

    // Firma centrada en la parte inferior si existe
    if (signatureUrl) {
      const pageWidth = doc.internal.pageSize.getWidth();
      const pageHeight = doc.internal.pageSize.getHeight();
      const sigWidth = 60;
      const sigHeight = 24;
      const x = (pageWidth - sigWidth) / 2;
      const y = pageHeight - sigHeight - 12;
      try {
        doc.addImage(signatureUrl, signatureFormat || 'PNG', x, y, sigWidth, sigHeight);
      } catch (_e) {
        // Ignorar errores de dibujo de imagen
      }
    }

    return doc;
  };

  useEffect(() => {
    if (!canGenerateDocs) {
      setPreviewUrl(null);
      return;
    }

    const doc = buildPdf();
    if (!doc) {
      setPreviewUrl(null);
      return;
    }

    const blobUrl = doc.output('bloburl');
    const urlString = typeof blobUrl === 'string' ? blobUrl : blobUrl.toString();
    setPreviewUrl(urlString);

    return () => {
      if (urlString) URL.revokeObjectURL(urlString);
    };
  }, [selectedTemplate, docenteNombre, canGenerateDocs]);

  const handleDownload = () => {
    const doc = buildPdf();
    if (!doc || !selectedTemplate) return;
    doc.save(`${selectedTemplate.title}.pdf`);
  };

  const handlePreviewPopup = () => {
    if (previewUrl) window.open(previewUrl, '_blank', 'noopener');
  };

  const handleGenerate = async () => {
    if (!selectedTemplate) return;
    try {
      setSaving(true);
      setError(null);
      setSuccessMsg(null);
      const res = await fetch(`${apiBase}/documentos/generar`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ tipo_documento_id: selectedTemplate.id }),
      });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data?.error || 'No se pudo generar el documento');
      }
      setSuccessMsg('Documento generado correctamente');
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error desconocido al generar';
      setError(msg);
    } finally {
      setSaving(false);
    }
  };

  const showWarning = !canGenerateDocs && templates.length === 0;

  return (
    <div className="docgen">
      {showWarning ? (
        <div className="docgen__alert">
          <div className="docgen__alert-icon">!</div>
          <div>
            <p className="docgen__alert-title">No es posible generar documentos</p>
            <p className="docgen__alert-text">
              Actualmente no cumples los requisitos obligatorios para generar documentos. Si tienes dudas,
              envía una queja al área responsable.
            </p>
          </div>
        </div>
      ) : (
        <>
          <div className="docgen__sidebar">
            {loading && <div className="docgen__status">Cargando documentos...</div>}
            {error && <div className="docgen__status docgen__status--error">{error}</div>}
            {successMsg && <div className="docgen__status docgen__status--ok">{successMsg}</div>}
            {!loading && !error && templates.length === 0 && (
              <div className="docgen__status">No hay documentos disponibles.</div>
            )}
            {Object.entries(groupedTemplates).map(([category, group]) => (
              <div key={category} className="docgen__group">
                <h3 className="docgen__group-title">{category}</h3>
                <ul className="docgen__list">
                  {group.map((template) => {
                    const isActive = template.id === selectedId;
                    return (
                      <li key={template.id}>
                        <button
                          type="button"
                          className={`docgen__item${isActive ? ' is-active' : ''}`}
                          onClick={() => setSelectedId(template.id)}
                          disabled={loading}
                        >
                          <span className="docgen__item-title">{template.title}</span>
                          <span className="docgen__item-desc">{template.description}</span>
                        </button>
                      </li>
                    );
                  })}
                </ul>
              </div>
            ))}
          </div>

          <div className="docgen__preview">
            {selectedTemplate ? (
              <>
                <div className="docgen__preview-header">
                  <div>
                    <h2 className="docgen__preview-title">{selectedTemplate.title}</h2>
                    <p className="docgen__preview-desc">{selectedTemplate.description}</p>
                  </div>
                  <div className="docgen__preview-actions">
                    <CustomButton
                      label="Vista previa"
                      variant="outline"
                      className="custom-button--small"
                      onClick={handlePreviewPopup}
                    />
                    <CustomButton
                      label={saving ? 'Generando...' : 'Generar documento'}
                      className="custom-button--small"
                      onClick={handleGenerate}
                      disabled={saving}
                    />
                  </div>
                </div>
                <div className="docgen__preview-frame">
                  <iframe
                    title={`Vista previa ${selectedTemplate.title}`}
                    src={previewUrl || undefined}
                    frameBorder="0"
                  />
                </div>
              </>
            ) : (
              <div className="docgen__placeholder">Selecciona un documento de la lista.</div>
            )}
          </div>
        </>
      )}
    </div>
  );
};

export default DocumentGenerator;
