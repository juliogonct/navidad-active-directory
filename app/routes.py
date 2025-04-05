from flask import render_template, redirect, url_for, flash, request, session
from app import app
from app.powershell_routes import script_options

# Rutas
@app.route("/", methods=['GET'])
def home():
    return redirect(url_for('login'))

############################################################################################################################################
# Ruta del Menú Principal
############################################################################################################################################

@app.route("/menu", methods=['GET', 'POST'])
def menu():
    # Verificar si el usuario está logueado
    if 'logged_in' in session and session['logged_in']:
        if request.method == 'POST':
            opcion = request.form.get('opcion')
            # Asegurarse de que la opción existe en el diccionario de opciones
            if opcion in script_options:
                return redirect(url_for(opcion))
            else:
                flash('Opción no válida. Intente de nuevo.', 'error')
        # Mostrar el menú con las opciones disponibles
        return render_template('menu.html', opciones=script_options.keys())
    else:
        # Si no está logueado o la sesión ha expirado, redirigir al login
        flash('Tu sesión ha expirado o no estás autorizado.', 'error')
        return redirect(url_for('login'))