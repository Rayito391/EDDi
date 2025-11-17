import './ProfilePanel.css';
import ProfileIcon from '../../assets/icons/ProfileIcon';
import PeopleIcon from '../../assets/icons/PeopleIcon';
import DocumentIcon from '../../assets/icons/DocumentIcon';
import HomeIcon from '../../assets/icons/HomeIcon';
import CustomButton from '../global/CustomButton/CustomButton';

import { SidebarRole } from '../layout/Sidebar/Sidebar';

interface ProfilePanelProps {
  role: SidebarRole;
  email?: string;
  firstName?: string;
  lastName?: string;
  onBack?: () => void;
}

const ProfilePanel = ({ role, email, firstName, lastName, onBack }: ProfilePanelProps) => {
  const isDocente = role === 'docente';
  const displayName =
    [firstName, lastName].filter(Boolean).join(' ').trim() || 'Nombre no disponible';

  if (isDocente) {
    return (
      <div className="profile-panel">
        <div className="profile-panel__header">
          <ProfileIcon size={80} />
          <div className="profile-panel__info">
            <div>
              <p className="profile-panel__kicker">Correo</p>
              <p className="profile-panel__data">{email ?? 'sin correo'}</p>
            </div>
            <div>
              <p className="profile-panel__kicker">Nombre(s)</p>
              <p className="profile-panel__data">{firstName}</p>
            </div>
            <div>
              <p className="profile-panel__kicker">Apellido</p>
              <p className="profile-panel__data">{lastName}</p>
            </div>
          </div>
        </div>

        <div className="profile-panel__actions">
          <CustomButton label="Volver" variant="outline" onClick={onBack} />
        </div>
      </div>
    );
  }

  return (
    <div className="profile-panel">
      <div className="profile-panel__header">
        <ProfileIcon size={80} />
        <div className="profile-panel__info">
          <div>
            <p className="profile-panel__kicker">Correo</p>
            <p className="profile-panel__data">{email ?? 'sin correo'}</p>
          </div>
          <div>
            <p className="profile-panel__kicker">Nombre(s)</p>
            <p className="profile-panel__data">{firstName}</p>
          </div>
          <div>
            <p className="profile-panel__kicker">Apellido</p>
            <p className="profile-panel__data">{lastName}</p>
          </div>
        </div>
      </div>

      <div className="profile-panel__actions">
        <CustomButton label="Volver" variant="outline" onClick={onBack} />
      </div>
    </div>
  );
};

export default ProfilePanel;
