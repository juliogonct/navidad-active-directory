from flask import render_template, redirect, url_for, flash, request, session, jsonify
from markupsafe import Markup
from app import app
from app.powershell import validar_entrada, ejecutar_script_powershell, manejar_solicitud
from app.logger import unlock_account_logger, reset_password_logger

############################################################################################################################################
# Rutas Específicas para Funcionalidades de Active Directory
############################################################################################################################################

# buscar_ad_sugerencias: Devuelve sugerencias de AD basadas en la entrada del usuario.
@app.route('/buscar_ad_sugerencias', methods=['GET'])
def buscar_ad_sugerencias():
    object_type = request.args.get('type')  # User, Group, etc.
    query = request.args.get('query', '')
    if len(query) >= 3:  # Solo buscar si hay al menos 3 caracteres
        output = ejecutar_script_powershell('sugerencias.ps1', [object_type, query])
        return jsonify(output.split('\n'))
    return jsonify([])

# desbloquear_usuario: Desbloquea un usuario en AD y registra la acción.
@app.route('/desbloquear_usuario', methods=['GET'])
def desbloquear_usuario():
    usuario_para_desbloquear = request.args.get('usuario')
    if usuario_para_desbloquear:
        resultado = ejecutar_script_powershell('powershell/restore_user.ps1', ['--UsuarioParaDesbloquear', usuario_para_desbloquear])
        user = session.get('username', 'Desconocido')  # Asume que el nombre de usuario está almacenado en la sesión
        user_ip = request.remote_addr
        unlock_account_logger.info(f'Usuario admin: {user}, IP: {user_ip}, Cuenta modificada: {usuario_para_desbloquear}')
        flash('Usuario desbloqueado correctamente: ' + usuario_para_desbloquear, 'success')
    else:
        flash('No se especificó usuario.', 'error')
    return redirect(url_for('restore_user'))

# reset_password: Restablece la contraseña de un usuario en AD y registra la acción.
@app.route('/reset_password', methods=['GET'])
def reset_password():
    usuario_para_resetear = request.args.get('usuario')
    if usuario_para_resetear:
        resultado = ejecutar_script_powershell('powershell/restore_pass.ps1', ['--UsuarioParaResetear', usuario_para_resetear])
        user_ip = request.remote_addr # IP del usuario
        reset_password_logger.info(f'IP: {user_ip}, Cuenta modificada: {usuario_para_resetear}') # Registro de log
        flash('Contraseña reseteada correctamente para: ' + usuario_para_resetear, 'success')
        session['resultado_reset_password'] = resultado # Almacena el resultado en la sesión
        return redirect(url_for('restore_pass_result'))
    else:
        flash('No se especificó usuario.', 'error')
        return redirect(url_for('restore_pass'))
    
@app.route('/restore_pass_result', methods=['GET'])
def restore_pass_result():
    resultado = session.pop('resultado_reset_password', None)
    return render_template('/powershell/restore_pass_result.html', resultado=resultado)
