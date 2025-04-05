from app import app, setup

if __name__ == "__main__":
    setup()  # Llama a la función setup para configurar la codificación de salida en PowerShell

    app.run(debug=True, use_reloader=True, host='navidad.apc.es')