import { useEffect, useState } from 'react';
import Sidebar, { SidebarRole } from './components/layout/Sidebar/Sidebar';
import './App.css';
import LoginPage from './pages/common/Login/LoginPage';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import ProfilePanel from './components/profile/ProfilePanel';
import DocumentGenerator from './components/documents/DocumentGenerator';
import MyDocuments from './components/documents/MyDocuments';
import CustomButton from './components/global/CustomButton/CustomButton';
import DocentesList from './components/docentes/DocentesList';
import AsignarTutorados from './components/desarrollo/AsignarTutorados';

function AppContent() {
  const { isLoggedIn, user, role, login, logout, loading, error } = useAuth();
  const [activeSection, setActiveSection] = useState<string | undefined>();
  const [canGenerateDocs, setCanGenerateDocs] = useState(true);
  const [quejaTitulo, setQuejaTitulo] = useState('');
  const [quejaDesc, setQuejaDesc] = useState('');
  const [quejaMsg, setQuejaMsg] = useState<string | null>(null);
  const [quejaError, setQuejaError] = useState<string | null>(null);
  const [quejaLoading, setQuejaLoading] = useState(false);
  const [docentesList, setDocentesList] = useState<any[]>([]);
  const [docentesLoading, setDocentesLoading] = useState(false);
  const [docentesError, setDocentesError] = useState<string | null>(null);
  const [selectedDocenteId, setSelectedDocenteId] = useState<number | null>(null);
  const [signatureFile, setSignatureFile] = useState<File | null>(null);
  const [signatureFileName, setSignatureFileName] = useState<string | null>(null);
  const [signaturePreview, setSignaturePreview] = useState<string | null>(null);
  const [signatureMsg, setSignatureMsg] = useState<string | null>(null);
  const [signatureError, setSignatureError] = useState<string | null>(null);
  const [signatureLoading, setSignatureLoading] = useState(false);
  const selectedDocente = selectedDocenteId
    ? docentesList.find((d) => d.id === selectedDocenteId)
    : null;
  const apiBase = process.env.REACT_APP_API_URL || 'http://localhost:5000';

  useEffect(() => {
    const defaultSection = role === 'docente' ? 'generarDocumentos' : 'inicio';
    setActiveSection(defaultSection);
  }, [role]);

  useEffect(() => {
    const fetchDocentes = async () => {
      try {
        setDocentesLoading(true);
        setDocentesError(null);
        const res = await fetch(`${apiBase}/docentes/?puesto_academico=Docente`, { credentials: 'include' });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) {
          throw new Error(data?.error || 'No se pudo cargar la lista de docentes');
        }
        setDocentesList(data?.docentes || []);
      } catch (e) {
        const msg = e instanceof Error ? e.message : 'Error al cargar docentes';
        setDocentesError(msg);
      } finally {
        setDocentesLoading(false);
      }
    };
    if (role === 'subdireccion' && activeSection === 'firmas') {
      fetchDocentes();
    }
  }, [role, activeSection, apiBase]);

  useEffect(() => {
    if (!isLoggedIn) return;
    const fetchPermiso = async () => {
      try {
        const res = await fetch(`${apiBase}/documentos/permiso`, { credentials: 'include' });
        if (!res.ok) {
          setCanGenerateDocs(true);
          return;
        }
        const data = await res.json();
        const allowed = Boolean(data?.puede_generar);
        setCanGenerateDocs(allowed);
      } catch (_e) {
        setCanGenerateDocs(true);
      }
    };
    fetchPermiso();
  }, [isLoggedIn, apiBase]);

  // Autoclear mensajes de quejas y firmas
  useEffect(() => {
    if (quejaMsg || quejaError) {
      const t = setTimeout(() => {
        setQuejaMsg(null);
        setQuejaError(null);
        setQuejaTitulo('');
        setQuejaDesc('');
      }, 3000);
      return () => clearTimeout(t);
    }
  }, [quejaMsg, quejaError]);

  useEffect(() => {
    if (signatureMsg || signatureError) {
      const t = setTimeout(() => {
        setSignatureMsg(null);
        setSignatureError(null);
        setSignatureFile(null);
        setSignatureFileName(null);
        setSignaturePreview(null);
      }, 3000);
      return () => clearTimeout(t);
    }
  }, [signatureMsg, signatureError]);

  // Crear/desechar preview de firma
  useEffect(() => {
    if (!signatureFile) {
      setSignaturePreview(null);
      return;
    }
    const url = URL.createObjectURL(signatureFile);
    setSignaturePreview(url);
    return () => {
      URL.revokeObjectURL(url);
    };
  }, [signatureFile]);

  if (!isLoggedIn) {
    return (
      <div className="app-shell app-shell--login">
        <LoginPage onSubmit={login} isLoading={loading} error={error} />
      </div>
    );
  }

  const fullLastName = [user?.apellido_paterno, user?.apellido_materno]
    .filter(Boolean)
    .join(' ')
    .trim();

  const handleQuejaSubmit = async () => {
    try {
      setQuejaLoading(true);
      setQuejaMsg(null);
      setQuejaError(null);
      if (!quejaTitulo.trim()) {
        setQuejaError('Ingrese un título');
        return;
      }
      if (!quejaDesc.trim()) {
        setQuejaError('Ingrese una descripción');
        return;
      }
      const res = await fetch(`${apiBase}/quejas/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ titulo: quejaTitulo.trim(), descripcion: quejaDesc.trim() }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        throw new Error(data?.error || 'No se pudo enviar la queja');
      }
      setQuejaMsg('Queja enviada correctamente');
      setQuejaTitulo('');
      setQuejaDesc('');
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al enviar la queja';
      setQuejaError(msg);
    } finally {
      setQuejaLoading(false);
    }
  };

  const roleCopy: Record<SidebarRole, { title: string; subtitle: string }> = {
    docente: {
      title: 'Panel de Generación de Documentos EDDi',
      subtitle: 'Bienvenido al sistema. Use el menú lateral para ir a una interfaz',
    },
    subdireccion: {
      title: 'Panel Subdirección',
      subtitle:
        'Resumen del modulo de Subdirección. Vea los docentes registrados o revise su perfil',
    },
    desarrollo: {
      title: 'Panel Desarrollo Académico',
      subtitle:
        'Bienvenido al módulo de Desarrollo Académico. Use las opciones del menú lateral para asignar o consultar el numero de tutorados por docente',
    },
    administrativo: {
      title: 'Panel Área encargada',
      subtitle:
        'Bienvenido al módulo del área encargada. Use las opciones del menú lateral para revisar las quejas de los docentes',
    },
  };

  const roleText = roleCopy[role];

  const handleSignatureUpload = async () => {
    try {
      setSignatureLoading(true);
      setSignatureMsg(null);
      setSignatureError(null);
      if (!selectedDocenteId) {
        setSignatureError('Selecciona un docente.');
        return;
      }
      if (!signatureFile) {
        setSignatureError('Selecciona un archivo de firma (png/jpg).');
        return;
      }
      const res = await fetch(`${apiBase}/firmas/docentes/${selectedDocenteId}`, {
        method: 'PUT',
        credentials: 'include',
        headers: {
          'Content-Type': signatureFile.type || 'application/octet-stream',
        },
        body: signatureFile,
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        throw new Error(data?.error || 'No se pudo subir la firma');
      }
      setSignatureMsg('Firma subida correctamente');
      setSignatureError(null);
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al subir la firma';
      setSignatureError(msg);
    } finally {
      setSignatureLoading(false);
    }
  };

  const handleSelectSection = (key: string | undefined) => {
    setActiveSection(key);
    // Limpia estados de queja al cambiar de pestaña
    setQuejaTitulo('');
    setQuejaDesc('');
    setQuejaMsg(null);
    setQuejaError(null);
    setQuejaLoading(false);
    // Limpia selección de firmas
    setSelectedDocenteId(null);
    setSignatureFile(null);
    setSignatureFileName(null);
    setSignatureMsg(null);
    setSignatureError(null);
    setSignatureLoading(false);
  };

  return (
    <div className="app-shell">
      <Sidebar
        role={role}
        userName={user?.email ?? 'Usuario'}
        activeKey={activeSection}
        onSelect={handleSelectSection}
        onLogout={logout}
      />
      <main className="app-content">
        <header className="app-header">
          <div>
            <h1 className="app-title">{roleText.title}</h1>
            <p className="app-subtitle">{roleText.subtitle}</p>
          </div>
        </header>
        <section className="app-panel">
          {activeSection === 'perfil' ? (
            <ProfilePanel
              role={role}
              email={user?.email}
              firstName={user?.primer_nombre}
              lastName={fullLastName}
              onBack={() => handleSelectSection('inicio')}
            />
          ) : activeSection === 'generarDocumentos' ? (
            <DocumentGenerator canGenerateDocs={canGenerateDocs} />
          ) : activeSection === 'documentos' ? (
            <MyDocuments />
          ) : activeSection === 'docentes' && role === 'subdireccion' ? (
            <DocentesList />
          ) : activeSection === 'asignarTutorados' && role === 'desarrollo' ? (
            <AsignarTutorados />
          ) : activeSection === 'firmas' && role === 'subdireccion' ? (
            <div className="firmas-panel">
              <h2>Firmas</h2>
              <p>Selecciona un docente y adjunta una imagen de firma desde tu equipo.</p>
              <div className="firmas-layout">
                <div className="firmas-list">
                  {docentesLoading && <p>Cargando docentes...</p>}
                  {docentesError && <p className="quejas-status quejas-status--error">{docentesError}</p>}
                  {!docentesLoading && !docentesError && (
                    <ul>
                      {docentesList.map((d) => (
                        <li key={d.id}>
                          <button
                            type="button"
                            className={`sidebar__nav-btn${selectedDocenteId === d.id ? ' is-active' : ''}`}
                            onClick={() => setSelectedDocenteId(d.id)}
                          >
                            <span>{`${[d.primer_nombre, d.segundo_nombre, d.apellido_paterno, d.apellido_materno].filter(Boolean).join(' ') || d.email || 'Docente'}`}</span>
                          </button>
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
                <div className="firmas-upload">
                  {selectedDocente ? (
                    <>
                      <p className="firmas-selected">
                        Docente seleccionado:{' '}
                        {[selectedDocente.primer_nombre, selectedDocente.segundo_nombre, selectedDocente.apellido_paterno, selectedDocente.apellido_materno]
                          .filter(Boolean)
                          .join(' ') || selectedDocente.email}
                      </p>
                      <label className="firmas-dropzone">
                        <input
                          type="file"
                          accept="image/*"
                          onChange={(e) => {
                            const file = e.target.files?.[0] || null;
                            setSignatureFile(file);
                            setSignatureFileName(file?.name || null);
                            setSignatureMsg(null);
                            setSignatureError(null);
                          }}
                          className="firmas-file-input"
                        />
                        <span>{signatureFileName ? `Archivo: ${signatureFileName}` : 'Cargar firma (png/jpg)'}</span>
                      </label>
                      {signaturePreview && (
                        <div className="firmas-preview">
                          <img src={signaturePreview} alt="Vista previa de firma" />
                        </div>
                      )}
                      <CustomButton
                        label={signatureLoading ? 'Subiendo...' : 'Subir firma'}
                        className="custom-button--small"
                        onClick={handleSignatureUpload}
                        disabled={signatureLoading}
                      />
                      {signatureMsg && <p className="quejas-status quejas-status--ok">{signatureMsg}</p>}
                      {signatureError && <p className="quejas-status quejas-status--error">{signatureError}</p>}
                    </>
                  ) : (
                    <p>Selecciona un docente para habilitar la carga de firma.</p>
                  )}
                </div>
              </div>
            </div>
          ) : activeSection === 'quejas' ? (
            <div className="quejas-panel">
              <h2>Quejas</h2>
              <p>Envía un título y una descripción para solicitar revisión o aclaración.</p>
              <input
                className="quejas-input"
                placeholder="Título de la queja"
                value={quejaTitulo}
                onChange={(e) => setQuejaTitulo(e.target.value)}
                autoComplete="off"
              />
              <textarea
                className="quejas-textarea"
                placeholder="Describe tu queja..."
                value={quejaDesc}
                onChange={(e) => setQuejaDesc(e.target.value)}
                rows={5}
              />
              <div className="quejas-actions">
                <CustomButton
                  label={quejaLoading ? 'Enviando...' : 'Enviar queja'}
                  className="custom-button--small"
                  onClick={handleQuejaSubmit}
                  disabled={quejaLoading}
                />
              </div>
              {quejaMsg && <p className="quejas-status quejas-status--ok">{quejaMsg}</p>}
              {quejaError && <p className="quejas-status quejas-status--error">{quejaError}</p>}
            </div>
          ) : (
            <>
              {role === 'docente' ? (
                <div className="quick-actions">
                  <CustomButton
                    variant="outline"
                    label="Ir a Generar Documentos"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('generarDocumentos')}
                  />
                  <CustomButton
                    label="Mis Documentos"
                    variant="outline"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('documentos')}
                  />
                  <CustomButton
                    label="Mi Perfil"
                    variant="outline"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('perfil')}
                  />
                  <CustomButton
                    label="Quejas"
                    variant="outline"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('quejas')}
                  />
                  <div className="docente-info">
                    <p className="docente-info__name">
                      {`${
                        [user?.primer_nombre, user?.segundo_nombre, user?.apellido_paterno, user?.apellido_materno]
                          .filter(Boolean)
                          .join(' ') || 'Docente'
                      }`}
                    </p>
                    <p className="docente-info__email">{user?.email || ''}</p>
                  </div>
                </div>
              ) : role === 'subdireccion' ? (
                <div className="quick-actions">
                  <CustomButton
                    variant="outline"
                    label="Ver docentes"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('docentes')}
                  />
                  <CustomButton
                    label="Mi Perfil"
                    variant="outline"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('perfil')}
                  />
                  <div className="docente-info">
                    <p className="docente-info__name">
                      {`${
                        [user?.primer_nombre, user?.segundo_nombre, user?.apellido_paterno, user?.apellido_materno]
                          .filter(Boolean)
                          .join(' ') || 'Usuario'
                      }`}
                    </p>
                    <p className="docente-info__email">{user?.email || ''}</p>
                  </div>
                </div>
              ) : role === 'desarrollo' ? (
                <div className="quick-actions">
                  <CustomButton
                    variant="outline"
                    label="Ir a Asignar Tutorados"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('asignarTutorados')}
                  />
                  <CustomButton
                    variant="outline"
                    label="Ir a Asignar Asesorados"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('asignarAsesorados')}
                  />
                  <CustomButton
                    variant="outline"
                    label="Mi Perfil"
                    className="custom-button--small"
                    onClick={() => handleSelectSection('perfil')}
                  />
                  <div className="docente-info">
                    <p className="docente-info__name">
                      {`${
                        [user?.primer_nombre, user?.segundo_nombre, user?.apellido_paterno, user?.apellido_materno]
                          .filter(Boolean)
                          .join(' ') || 'Usuario'
                      }`}
                    </p>
                    <p className="docente-info__email">{user?.email || ''}</p>
                  </div>
                </div>
              ) : (
                <>
                  <h2>Seccion activa</h2>
                  <p>{activeSection ?? 'Selecciona una opcion del menu'}</p>
                </>
              )}
            </>
          )}
        </section>
      </main>
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;
