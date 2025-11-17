import { FormEvent, useState } from 'react';
import './ProfilePanel.css';
import ProfileIcon from '../../assets/icons/ProfileIcon';
import PeopleIcon from '../../assets/icons/PeopleIcon';
import DocumentIcon from '../../assets/icons/DocumentIcon';
import HomeIcon from '../../assets/icons/HomeIcon';
import CustomButton from '../global/CustomButton/CustomButton';
import CustomInput from '../global/CustomInput/CustomInput';
import { SidebarRole } from '../layout/Sidebar/Sidebar';
import { useAuth } from '../../contexts/AuthContext';

interface ProfilePanelProps {
  role: SidebarRole;
  email?: string;
  firstName?: string;
  lastName?: string;
  onBack?: () => void;
}

const ProfilePanel = ({ role, email, firstName, lastName, onBack }: ProfilePanelProps) => {
  const displayName =
    [firstName, lastName].filter(Boolean).join(' ').trim() || 'Nombre no disponible';
  const { changePassword } = useAuth();
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(
    null
  );

  const handlePasswordSubmit = async (event: FormEvent) => {
    event.preventDefault();
    if (!currentPassword || !newPassword || !confirmPassword) {
      setFeedback({ type: 'error', message: 'Completa todos los campos.' });
      return;
    }

    if (newPassword !== confirmPassword) {
      setFeedback({
        type: 'error',
        message: 'La nueva contraseña y la confirmación no coinciden.',
      });
      return;
    }

    setSubmitting(true);
    setFeedback(null);
    const result = await changePassword(currentPassword, newPassword);

    if (!result.ok) {
      setFeedback({ type: 'error', message: result.message });
      setSubmitting(false);
      return;
    }

    setFeedback({ type: 'success', message: result.message });
    setCurrentPassword('');
    setNewPassword('');
    setConfirmPassword('');
    setSubmitting(false);
  };

  return (
    <div className="profile-panel">
      <div className="profile-panel__layout">
        <div className="profile-panel__col profile-panel__col--info">
          <div className="profile-panel__header">
            <ProfileIcon size={120} color={'white'} />
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
        </div>

        <div className="profile-panel__col profile-panel__col--password">
          <div className="profile-panel__card">
            <h3 className="profile-panel__card-title">Cambiar contraseña</h3>
            <form className="profile-panel__form" onSubmit={handlePasswordSubmit}>
              <CustomInput
                type="password"
                placeholder="Contraseña actual"
                value={currentPassword}
                onChange={setCurrentPassword}
              />
              <CustomInput
                type="password"
                placeholder="Nueva contraseña"
                value={newPassword}
                onChange={setNewPassword}
              />
              <CustomInput
                type="password"
                placeholder="Confirmar contraseña"
                value={confirmPassword}
                onChange={setConfirmPassword}
              />
              {feedback && (
                <p className={`profile-panel__feedback profile-panel__feedback--${feedback.type}`}>
                  {feedback.message}
                </p>
              )}
              <div className="profile-panel__actions profile-panel__actions--end">
                <CustomButton
                  type="submit"
                  label={submitting ? 'Actualizando...' : 'Actualizar contraseña'}
                  disabled={submitting}
                />
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePanel;
