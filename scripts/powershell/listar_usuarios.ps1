[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param (
    [string]$NombreUsuario = $args[0]
)

# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Determinar el filtro
$filter = if (-not [string]::IsNullOrWhiteSpace($NombreUsuario)) {
    "Name -like '*$($NombreUsuario.Replace("'", "''"))*'"
} else {
    "*"
}

# Obtener los usuarios de Active Directory utilizando el filtro
$usuarios = Get-ADUser -Filter $filter -Properties Enabled | Select-Object -Property Name, Enabled | Sort-Object Name

# Generar salida HTML
$htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
    <table>
        <tr>
            <th>Nombre del Usuario</th>
        </tr>
"@

# Verificar si hay usuarios y agregarlos a la tabla
if ($usuarios) {
    foreach ($usuario in $usuarios) {
        $htmlOutput += "<tr><td>$($usuario.Name)</td></tr>"
    }
} else {
    $htmlOutput += "<tr><td colspan='2'>No se encontraron usuarios que coincidan con los criterios de búsqueda.</td></tr>"
}

# Finalizar la tabla y el documento HTML
$htmlOutput += @"
    </table>
</body>
</html>
"@

# Devolver la salida HTML
$htmlOutput
