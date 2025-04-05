from flask import request
from markupsafe import Markup
import re
import subprocess

############################################################################################################################################
# Funciones de Validación y Ejecución de Scripts
############################################################################################################################################

# validar_entrada: Verifica la validez de los datos de entrada.
def validar_entrada(texto):
    pattern = r'^[\w\sáéíóúÁÉÍÓÚñÑ]+$'
    if texto is None:
        return False
    if re.fullmatch(pattern, texto):
        return True
    return False

# ejecutar_script_powershell: Ejecuta scripts de PowerShell y retorna la salida.
def ejecutar_script_powershell(script_name, params=[]):
    script_path = f"./scripts/{script_name}"
    command = ["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", script_path] + params
    result = subprocess.run(command, capture_output=True, text=True, encoding='utf-8')
    return result.stdout if result.stdout else "<p>Error al ejecutar el script de PowerShell</p>"

# manejar_solicitud: Procesa y valida datos de entrada antes de ejecutar scripts.
def manejar_solicitud(script_name, form_fields):
    form_data = [request.form.get(field, '') for field in form_fields]
    if all(validar_entrada(data) for data in form_data if data):
        html_output = ejecutar_script_powershell(script_name, form_data)
        return Markup(html_output)
    return Markup("<p>Error: Entrada inválida. Asegúrese de que la entrada no contenga caracteres no permitidos.</p>")


