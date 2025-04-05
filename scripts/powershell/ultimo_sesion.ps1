param (
    [string]$NombreUsuario,
    [string]$EstadoUsuario
)

# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Determinar el filtro
$filter = if (-not [string]::IsNullOrWhiteSpace($NombreUsuario)) {
    "Name -like '*$($NombreUsuario.Replace("'", "''"))*'"
} else {
    "*"
}

# Obtener los usuarios de Active Directory utilizando el filtro y seleccionando las propiedades necesarias
$usuarios = Get-ADUser -Filter $filter -Properties Enabled, LastLogonDate |
            Select-Object Name, Enabled, LastLogonDate |
            Sort-Object LastLogonDate -Descending

# Filtrar por estado del usuario si se especifica
if ($EstadoUsuario -eq "Habilitado") {
    $usuarios = $usuarios | Where-Object { $_.Enabled -eq $true }
} elseif ($EstadoUsuario -eq "Deshabilitado") {
    $usuarios = $usuarios | Where-Object { $_.Enabled -eq $false }
}

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
            <th>Nombre del Usuario</th>
            <th>Ultimo Inicio de Sesion</th>
            <th>Estado</th>
        </tr>
"@

# Verificar si hay usuarios y agregarlos a la tabla
if ($usuarios) {
    foreach ($usuario in $usuarios) {
        $estado = if ($usuario.Enabled) { "Habilitado" } else { "Deshabilitado" }
        $lastLogon = if ($usuario.LastLogonDate -ne $null) { $usuario.LastLogonDate.ToString("yyyy-MM-dd") } else { "Nunca" }
        $htmlOutput += "<tr><td>$($usuario.Name)</td><td>$lastLogon</td><td>$estado</td></tr>"
    }
} else {
    $htmlOutput += "<tr><td colspan='3'>No se encontraron usuarios que coincidan con los criterios de búsqueda.</td></tr>"
}

# Finalizar la tabla y el documento HTML
$htmlOutput += @"
    </table>
</body>
</html>
"@

# Devolver la salida HTML
$htmlOutput
