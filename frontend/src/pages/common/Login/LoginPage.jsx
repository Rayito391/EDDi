import CustomInput from "../../../components/global/CustomInput/CustomInput";
import Logo from "../../../Logo.svg";
import "./LoginPage.css";

function LoginPage() {

  return (
    <div className="login-page">
      <div className="login-card">
        <div className="login-card-header">
          <img src={Logo} alt="EDDi logo" />
          <h1 className="login-title">EDDi</h1>
        </div>
        <div className="login-body">
          <h2>Bienvenido</h2>
          <CustomInput placeholder="Correo" type="email" />
          <CustomInput placeholder="Contrasena" type="password" />
          <button className="login-button" type="button">
            Login
          </button>
        </div>
      </div>
    </div>
  );
}

export default LoginPage;
