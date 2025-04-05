function buscarSugerencias(inputValue, datalistId, type) {
    const dataListElement = document.getElementById(datalistId);
    if (inputValue.length >= 3) {
        fetch(`/buscar_ad_sugerencias?type=${type}&query=${encodeURIComponent(inputValue)}`)
            .then(response => response.json())
            .then(data => {
                dataListElement.innerHTML = '';
                data.forEach((item) => {
                    let option = document.createElement('option');
                    option.value = item;
                    dataListElement.appendChild(option);
                });
            });
    } else {
        dataListElement.innerHTML = '';
    }
}

function validarSugerencias(inputElement, datalistId) {
    var valid = false;
    var inputValue = inputElement.value;
    var datalist = document.getElementById(datalistId);
    for (var i = 0; i < datalist.options.length; i++) {
        if (inputValue === datalist.options[i].value) {
            valid = true;
            break;
        }
    }

    if (!valid) {
        inputElement.value = ''; // Limpiar el input si no es válido
        document.getElementById('error_usuario').textContent = 'Seleccione un valor válido de la lista.';
    } else {
        document.getElementById('error_usuario').textContent = '';
    }
}
