import { useState } from "react";
import CustomButton from "../../../components/global/CustomButton/CustomButton";
import CustomInput from "../../../components/global/CustomInput/CustomInput";
import Logo from "../../../Logo.svg";
import "./LoginPage.css";

function LoginPage({ onSubmit, isLoading = false, error }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit?.(email, password);
  };

  return (
    <div className="login-page">
      <div className="login-card">
        <div className="login-card-header">
          <img src={Logo} alt="EDDi logo" />
          <h1 className="login-title">EDDi</h1>
        </div>
        <div className="login-body">
          <h2>Bienvenido</h2>
          <form className="login-form" onSubmit={handleSubmit}>
            <CustomInput
              placeholder="Correo"
              type="email"
              value={email}
              onChange={(val) => setEmail(val)}
              required
            />
            <CustomInput
              placeholder="Contrasena"
              type="password"
              value={password}
              onChange={(val) => setPassword(val)}
              required
            />
            {error && <p className="login-error">{error}</p>}
            <CustomButton
              type="submit"
              label={isLoading ? "Entrando..." : "Iniciar Sesion"}
              disabled={isLoading}
            />
          </form>
        </div>
      </div>
    </div>
  );
}

export default LoginPage;
