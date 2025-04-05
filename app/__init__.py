from flask import Flask
import subprocess

app = Flask(__name__)

# Configurar la ubicación de las carpetas
app.static_folder = '../static'
app.config['CERT_FOLDER'] = '../cert'
app.config['LOG_FOLDER'] = '../logs'
app.config['SCRIPTS_FOLDER'] = '../scripts'
app.template_folder = '../templates'

# Función para configurar la codificación de salida en PowerShell al iniciar la aplicación
def setup():
    script_path = "./scripts/configurar_codificacion.ps1"
    command = ["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", script_path]
    subprocess.run(command)

# Llamar a la función de configuración al iniciar la aplicación Flask
setup()

# Importar otras partes de la aplicación
from . import auth, config, logger, powershell_routes, powershell_utils, powershell, routes