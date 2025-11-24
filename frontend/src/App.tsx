import { useEffect, useState } from 'react';
import Sidebar, { SidebarRole } from './components/layout/Sidebar/Sidebar';
import './App.css';
import LoginPage from './pages/common/Login/LoginPage';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import ProfilePanel from './components/profile/ProfilePanel';
import DocumentGenerator from './components/documents/DocumentGenerator';

function AppContent() {
  const { isLoggedIn, user, role, login, logout, loading, error } = useAuth();
  const [activeSection, setActiveSection] = useState<string | undefined>();

  useEffect(() => {
    setActiveSection(undefined);
  }, [role]);

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

  return (
    <div className="app-shell">
      <Sidebar
        role={role}
        userName={user?.email ?? 'Usuario'}
        activeKey={activeSection}
        onSelect={setActiveSection}
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
              onBack={() => setActiveSection('inicio')}
            />
          ) : activeSection === 'generarDocumentos' ? (
            <DocumentGenerator />
          ) : (
            <>
              <h2>Seccion activa</h2>
              <p>{activeSection ?? 'Selecciona una opcion del menu'}</p>
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
