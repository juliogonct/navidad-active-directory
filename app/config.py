from app import app

app.secret_key = 'R5d07*h'  # La clave secreta para la gestión de sesiones

# Configuración de Keycloak (Colocar los valores correspondientes entre las comillas)
KEYCLOAK_BASE_URL = ''
REALM_NAME = ''
CLIENT_ID = ''
