[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param (
    [string]$NombreEquipo = $args[0]
)

# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Determinar el filtro
$filter = if (-not [string]::IsNullOrWhiteSpace($NombreEquipo)) {
    "Name -like '*$($NombreEquipo.Replace("'", "''"))*'"
} else {
    "*"
}

# Obtener los equipos de Active Directory utilizando el filtro
$equipos = Get-ADComputer -Filter $filter | Sort-Object Name

# Generar salida HTML
$htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
    <style>
        th:not(:first-child) {
            width: 20%;
        }
    </style>
</head>
<body>
    <table>
        <tr>
            <th>Nombre del Equipo</th>
        </tr>
"@

# Verificar si hay equipos y agregarlos a la tabla
if ($equipos) {
    foreach ($equipo in $equipos) {
        $htmlOutput += "<tr><td>$($equipo.Name)</td></tr>"
    }
} else {
    $htmlOutput += "<tr><td colspan='4'>No se encontraron equipos que coincidan con los criterios de búsqueda.</td></tr>"
}

# Finalizar la tabla y el documento HTML
$htmlOutput += @"
    </table>
</body>
</html>
"@

# Devolver la salida HTML
$htmlOutput
