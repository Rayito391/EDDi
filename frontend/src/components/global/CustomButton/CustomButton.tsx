import './CustomButton.css';

interface CustomButtonProps {
  label: string;
  onClick?: (value) => void;
}

function CustomButton({ label, onClick }: CustomButtonProps) {
  return (
    <button onClick={onClick} className="custom-button">
      {label}
    </button>
  );
}
export default CustomButton;
