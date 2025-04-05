from app import app, setup

if __name__ == "__main__":
    setup()  # Llama a la función setup para configurar la codificación de salida en PowerShell

    # Cambia 'navidad.ad.es' según sea necesario
    app.run(debug=True, use_reloader=True, host='navidad.ad.es')