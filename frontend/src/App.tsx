import { useEffect, useState } from 'react';
import Sidebar from './components/layout/Sidebar/Sidebar';
import './App.css';
import LoginPage from './pages/common/Login/LoginPage';
import { AuthProvider, useAuth } from './contexts/AuthContext';

function AppContent() {
  const { isLoggedIn, user, role, login, logout, loading, error } = useAuth();
  const [activeSection, setActiveSection] = useState<string | undefined>();

  useEffect(() => {
    setActiveSection(undefined);
  }, [role]);

  if (!isLoggedIn) {
    return (
      <div>
        <LoginPage onSubmit={login} isLoading={loading} error={error} />
      </div>
    );
  }

  return (
    <div className="app-shell">
      <Sidebar
        role={role}
        userName={user?.email ?? 'Usuario'}
        activeKey={activeSection}
        onSelect={setActiveSection}
        onLogout={logout}
      />
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
