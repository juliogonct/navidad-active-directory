from app import app, setup
import ssl

if __name__ == "__main__":
    setup() # Llama a la función setup para configurar la codificación de salida en PowerShell

    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    context.load_cert_chain(certfile='cert/cert.pem') # Reemplaza 'cert.pem' con tu certificado

    # Cambia 'navidad.navidad.es' y '443' según sea necesario
    app.run(debug=False, host='navidad.navidad.es', port=443, ssl_context=context) 