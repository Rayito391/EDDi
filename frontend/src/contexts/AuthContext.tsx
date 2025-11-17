import { createContext, useContext, useMemo, useState, ReactNode } from 'react';
import { SidebarRole } from '../components/layout/Sidebar/Sidebar';

type DocentePayload = {
  id: number;
  email: string;
  puesto_academico?: string;
  primer_nombre?: string;
  segundo_nombre?: string;
  apellido_paterno?: string;
  apellido_materno?: string;
};

type AuthContextValue = {
  user: DocentePayload | null;
  role: SidebarRole;
  isLoggedIn: boolean;
  loading: boolean;
  error: string;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
};

const mapRole = (puesto?: string): SidebarRole => {
  const normalized = (puesto || '').toLowerCase();
  if (normalized.includes('sub')) return 'subdireccion';
  if (normalized.includes('admin')) return 'administrativo';
  if (normalized.includes('des')) return 'desarrollo';
  if (normalized.includes('rh')) return 'desarrollo';
  return 'docente';
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<DocentePayload | null>(null);
  const [role, setRole] = useState<SidebarRole>('docente');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const login = async (email: string, password: string) => {
    try {
      setLoading(true);
      setError('');
      const res = await fetch('http://localhost:5000/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ email, password }),
      });

      const data = await res.json();
      if (!res.ok) {
        setError(data?.error || 'Error al iniciar sesión');
        return;
      }

      setUser(data as DocentePayload);
      setRole(mapRole(data?.puesto_academico));
    } catch (err) {
      setError('No se pudo conectar con el servidor');
    } finally {
      setLoading(false);
    }
  };

  const logout = async () => {
    try {
      setLoading(true);
      await fetch('http://localhost:5000/auth/logout', {
        method: 'POST',
        credentials: 'include',
      });
    } finally {
      setUser(null);
      setRole('docente');
      setLoading(false);
      setError('');
    }
  };

  const value = useMemo(
    () => ({ user, role, isLoggedIn: Boolean(user), loading, error, login, logout }),
    [user, role, loading, error]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return ctx;
}

