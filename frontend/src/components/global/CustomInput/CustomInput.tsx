import { ChangeEvent, useId } from 'react';
import './CustomInput.css';

interface CustomInputProps {
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  type?: string;
  error?: string;
  id?: string;
}

function CustomInput({
  value = '',
  onChange,
  placeholder = '',
  type = 'text',
  error = '',
  id,
}: CustomInputProps) {
  const autoId = useId();
  const inputId = id ?? autoId;

  const handleChange = (event: ChangeEvent<HTMLInputElement>) => {
    onChange?.(event.target.value);
  };

  return (
    <div className="input-container">
      <input
        className="custom-input__field"
        id={inputId}
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={handleChange}
      />
      {error && <span>{error}</span>}
    </div>
  );
}

export default CustomInput;
