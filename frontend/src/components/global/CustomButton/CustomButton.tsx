import { ButtonHTMLAttributes, ReactNode } from 'react';
import './CustomButton.css';

interface CustomButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  label: string;
  icon?: ReactNode;
  variant?: 'primary' | 'secondary' | 'outline' | 'danger';
}

function CustomButton({
  label,
  icon,
  variant = 'primary',
  className = '',
  ...buttonProps
}: CustomButtonProps) {
  return (
    <button
      className={['custom-button', `custom-button--${variant}`, className].filter(Boolean).join(' ')}
      {...buttonProps}
    >
      {icon && <span className="custom-button__icon">{icon}</span>}
      <span className="custom-button__label">{label}</span>
    </button>
  );
}
export default CustomButton;
