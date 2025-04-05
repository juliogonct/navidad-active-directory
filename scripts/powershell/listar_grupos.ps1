[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param (
    [string]$NombreGrupo = $args[0]  # Tomar el nombre del grupo como argumento
)

# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Determinar el filtro
$filter = if (-not [string]::IsNullOrWhiteSpace($NombreGrupo)) {
    "Name -like '*$($NombreGrupo.Replace("'", "''"))*'"
} else {
    "*"
}

# Obtener los grupos de Active Directory utilizando el filtro
$groups = Get-ADGroup -Filter $filter | Sort-Object Name

# Generar salida HTML
$htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
    <title>Lista de Grupos</title>
</head>
<body>
    <table>
        <tr>
            <th>Nombre del Grupo</th>
        </tr>
"@

# Verificar si hay grupos y agregarlos a la tabla
if ($groups) {
    foreach ($group in $groups) {
        $htmlOutput += "<tr><td>$($group.Name)</td></tr>"
    }
} else {
    $htmlOutput += "<tr><td>No se encontraron grupos que coincidan con los criterios de búsqueda.</td></tr>"
}

# Finalizar la tabla y el documento HTML
$htmlOutput += @"
    </table>
</body>
</html>
"@

# Devolver la salida HTML
$htmlOutput
