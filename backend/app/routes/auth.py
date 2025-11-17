from flask import Blueprint
from main import app

auth_blueprint = Blueprint('auth', __name__)

@app.route('/auth/status')
def auth_status():
    return {"status": "Authentication service is running"} 