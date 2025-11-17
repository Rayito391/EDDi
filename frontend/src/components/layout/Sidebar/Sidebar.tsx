import { ComponentType } from 'react';
import ProfileIcon from '../../../assets/icons/ProfileIcon';
import HomeIcon from '../../../assets/icons/HomeIcon';
import DocumentIcon from '../../../assets/icons/DocumentIcon';
import RecordIcon from '../../../assets/icons/RecordIcon';
import './Sidebar.css';
import CustomButton from '../../global/CustomButton/CustomButton';
import GroupIcon from '../../../assets/icons/GroupIcon';
import AddUserIcon from '../../../assets/icons/AddUserIcon';
import PeopleIcon from '../../../assets/icons/PeopleIcon';
import SearchIcon from '../../../assets/icons/SearchIcon';

export type SidebarRole = 'docente' | 'subdireccion' | 'desarrollo' | 'administrativo';

type IconComponent = ComponentType<{ color?: string; size?: number; className?: string }>;

interface NavItem {
  key: string;
  label: string;
  icon: IconComponent;
  helperText?: string;
  badge?: string;
}

const NAV_ITEMS: Record<SidebarRole, NavItem[]> = {
  docente: [
    { key: 'inicio', label: 'Inicio', icon: HomeIcon },
    { key: 'generarDocumentos', label: 'Generar Documentos', icon: DocumentIcon },
    { key: 'documentos', label: 'Mis Documentos', icon: RecordIcon },
    { key: 'perfil', label: 'Mi Perfil', icon: ProfileIcon },
  ],
  subdireccion: [
    { key: 'inicio', label: 'Inicio', icon: HomeIcon },
    { key: 'docentes', label: 'Docentes registrados', icon: GroupIcon },
    { key: 'perfil', label: 'Mi Perfil', icon: ProfileIcon },
  ],
  desarrollo: [
    { key: 'inicio', label: 'Inicio', icon: HomeIcon },
    { key: 'asignarTutorados', label: 'Asignar tutorados', icon: AddUserIcon },
    { key: 'asignarAsesorados', label: 'Asignar asesorados', icon: PeopleIcon },
    { key: 'quejas', label: 'Revisar quejas', icon: SearchIcon },
    { key: 'perfil', label: 'Mi perfil', icon: ProfileIcon },
  ],
  administrativo: [
    { key: 'inicio', label: 'Inicio', icon: HomeIcon },
    { key: 'quejas', label: 'Revisar quejas', icon: SearchIcon },
    { key: 'perfil', label: 'Mi perfil', icon: ProfileIcon },
  ],
};

interface SidebarProps {
  role?: SidebarRole;
  userName?: string;
  activeKey?: string;
  onSelect?: (key: string) => void;
  onLogout?: () => void;
}

const Sidebar = ({ role = 'docente', userName, activeKey, onSelect, onLogout }: SidebarProps) => {
  const navItems = NAV_ITEMS[role];
  const currentActive = activeKey ?? navItems[0]?.key;

  return (
    <aside className="sidebar">
      <div className="sidebar__brand">
        <div className="sidebar__brand-mark">EDDi</div>
        <div>
          <p className="sidebar__brand-title">{userName || 'Usuario'}</p>
          <p className="sidebar__brand-subtitle">{role}</p>
        </div>
      </div>

      <nav className="sidebar__nav" aria-label="Navegación principal">
        <ul className="sidebar__nav-list">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = currentActive === item.key;
            return (
              <li key={item.key}>
                <button
                  type="button"
                  className={`sidebar__nav-btn${isActive ? ' is-active' : ''}`}
                  aria-current={isActive ? 'page' : undefined}
                  onClick={() => onSelect?.(item.key)}
                >
                  <Icon size={18} className="sidebar__nav-icon" />
                  <span>{item.label}</span>
                  {item.badge && <span className="sidebar__nav-badge">{item.badge}</span>}
                </button>
                {item.helperText && <p className="sidebar__nav-helper">{item.helperText}</p>}
              </li>
            );
          })}
        </ul>
      </nav>

      <div className="sidebar__footer">
        <CustomButton label="Cerrar sesion" variant="secondary" onClick={onLogout} />
      </div>
    </aside>
  );
};

export default Sidebar;
