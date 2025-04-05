[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param (
    [string]$NombreOU = $args[0]  # Tomar el nombre de la OU como argumento
)

# Importar el módulo de Active Directory
Import-Module ActiveDirectory

# Determinar el filtro
$filter = if (-not [string]::IsNullOrWhiteSpace($NombreOU)) { 
    "Name -like '*$($NombreOU.Replace("'", "''"))*'"
} else { 
    "*"
}

# Obtener y ordenar alfabéticamente las OUs que coinciden con el filtro
$unidadesOrganizativas = Get-ADOrganizationalUnit -Filter $filter | Sort-Object Name

# Generar salida HTML
$htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
    <table>
        <tr>
            <th>Nombre de la Unidad Organizativa</th>
        </tr>
"@

# Verificar si hay unidades organizativas y agregarlas a la tabla
if ($unidadesOrganizativas) {
    foreach ($ou in $unidadesOrganizativas) {
        $htmlOutput += "<tr><td>$($ou.Name)</td></tr>"
    }
} else {
    $htmlOutput += "<tr><td>No se encontraron unidades organizativas que coincidan con los criterios de búsqueda.</td></tr>"
}

# Finalizar la tabla y el documento HTML
$htmlOutput += @"
    </table>
</body>
</html>
"@

# Devolver la salida HTML
$htmlOutput
