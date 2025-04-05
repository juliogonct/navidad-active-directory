from flask import render_template, redirect, url_for, flash, request, session, jsonify
from markupsafe import Markup
from app import app
from app.powershell import validar_entrada, ejecutar_script_powershell, manejar_solicitud

############################################################################################################################################
# Creación Dinámica de Rutas para Scripts de PowerShell
############################################################################################################################################

# powershell_route: Define rutas dinámicamente para la ejecución de scripts basados en las opciones del menú.
def powershell_route(endpoint, script_name, form_fields):
    def generic_powershell_handler():
        if request.method == 'POST':
            content = manejar_solicitud(script_name, form_fields)
        else:
            content = ""
        return render_template(f'powershell/{endpoint}.html', content=content)
    generic_powershell_handler.__name__ = f'{endpoint}_handler'  # Asignar un nombre único a la función
    app.add_url_rule(f'/{endpoint}', endpoint, generic_powershell_handler, methods=['GET', 'POST'])

# Diccionario que mapea las opciones del menú
script_options = {

    'buscar_usuarios'       : ['nombre_usuario', 'nombre_ou', 'nombre_grupo', 'estado_usuario'],
    'buscar_grupos'         : ['nombre_grupo', 'nombre_usuario'],
    'buscar_equipos'        : ['nombre_equipo'],
    'buscar_ous'            : ['nombre_ou'],

    'comparar_usuarios'     : ['nombre_usuario1', 'nombre_usuario2'],
    'comparar_grupos'       : ['nombre_grupo1', 'nombre_grupo2'],

    'listar_usuarios'       : ['nombre_usuario', 'estado_usuario'],
    'listar_grupos'         : ['nombre_grupo'],
    'listar_equipos'        : ['nombre_equipo'],
    'listar_ous'            : ['nombre_ou'],

    'ultimo_sesion'         : ['nombre_usuario', 'estado_usuario'],
    'ultimo_expira_pass'    : ['nombre_usuario', 'estado_usuario', 'estado_pass'],
    'ultimo_cambio_pass'    : ['nombre_usuario', 'estado_usuario', 'estado_pass'],

    'restore_user'          : ['nombre_usuario'],
    'restore_pass'          : ['nombre_usuario']
}

# Crear las rutas utilizando el nombre de la clave para el nombre del archivo .ps1
for endpoint, form_fields in script_options.items():
    script_name = f"powershell/{endpoint}.ps1"
    powershell_route(endpoint, script_name, form_fields)