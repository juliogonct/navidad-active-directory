from flask import abort, session, request, flash, redirect, url_for
from app import app
from app.config import KEYCLOAK_BASE_URL, REALM_NAME, CLIENT_ID
from jwt.algorithms import get_default_algorithms
import jwt
import requests

############################################################################################################################################
# Middleware
############################################################################################################################################

# Middleware
@app.before_request
def check_login():
    if not session.get('logged_in') and request.endpoint not in ['login', 'login_callback', 'logout']:
        flash("Necesitas iniciar sesión para acceder a esta página.", "error")
        return redirect(url_for('login'))

############################################################################################################################################
# Rutas de Autenticación con Keycloak
############################################################################################################################################

# Ruta para iniciar sesión
@app.route('/login', methods=['GET'])
def login():
    keycloak_login_url = f"{KEYCLOAK_BASE_URL}/realms/{REALM_NAME}/protocol/openid-connect/auth"
    params = {
        'client_id': CLIENT_ID,
        'response_type': 'code',
        'redirect_uri': url_for('login_callback', _external=True),
    }
    return redirect(keycloak_login_url + '?' + '&'.join([f'{k}={v}' for k, v in params.items()]))

# Decodificar el token del usuario
def decode_access_token(access_token):
    decoded_token = jwt.decode(access_token, options={"verify_signature": False})
    return decoded_token

# Ruta de retorno de inicio de sesión
@app.route('/login/callback', methods=['GET'])
def login_callback():
    code = request.args.get('code')
    if code:
        token_url = f"{KEYCLOAK_BASE_URL}/realms/{REALM_NAME}/protocol/openid-connect/token"
        data = {
            'client_id': CLIENT_ID,
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': url_for('login_callback', _external=True),
        }
        response = requests.post(token_url, data=data)
        if response.status_code == 200:
            token_info = response.json()
            access_token = token_info.get('access_token')
            if access_token:
                decoded_token = decode_access_token(access_token)
                resource_access = decoded_token.get('resource_access', {})
                client_access = resource_access.get(CLIENT_ID, {})
                roles = client_access.get('roles', [])
                if 'PAPANOEL' in roles:
                    session['access_token'] = access_token
                    session['logged_in'] = True
                    return redirect(url_for('menu'))
        abort(403)
    abort(400)

# Ruta para cerrar sesión
@app.route('/logout', methods=['GET', 'POST'])
def logout():
    # Limpiar la sesión local
    session.clear()
    # Construir la URL de logout de Keycloak
    keycloak_logout_url = f"{KEYCLOAK_BASE_URL}/realms/{REALM_NAME}/protocol/openid-connect/logout"
    redirect_uri = url_for('login', _external=True)
    logout_params = {
        'redirect_uri': redirect_uri,
    }
    # Redirigir al usuario a la página de logout de Keycloak
    return redirect(keycloak_logout_url + '?' + '&'.join([f'{k}={v}' for k, v in logout_params.items()]))




