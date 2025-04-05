param (
    [string]$NombreUsuario,
    [string]$EstadoUsuario,
    [string]$EstadoPassword
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
$usuarios = Get-ADUser -Filter $filter -Properties PasswordLastSet, PasswordNeverExpires, Enabled | 
            Select-Object Name, Enabled, PasswordLastSet, PasswordNeverExpires | 
            Sort-Object PasswordLastSet -Descending    

# Filtrar por estado del usuario si se especifica
if ($EstadoUsuario -eq "Habilitado") {
    $usuarios = $usuarios | Where-Object { $_.Enabled -eq $true }
} elseif ($EstadoUsuario -eq "Deshabilitado") {
    $usuarios = $usuarios | Where-Object { $_.Enabled -eq $false }
}

# Filtrar por estado de la contraseña si se especifica
if ($EstadoPassword -eq "Si") {
    $usuarios = $usuarios | Where-Object { -not $_.PasswordNeverExpires }
} elseif ($EstadoPassword -eq "No") {
    $usuarios = $usuarios | Where-Object { $_.PasswordNeverExpires -eq $true }
}

# Generar salida HTML
$htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
    <style>
    th:not(:first-child) {
        max-width: 15%;
    }
    </style>
</head>
<body>
    <table>
        <tr>
            <th>Nombre del Usuario</th>
            <th>Ultimo Cambio de Contrasena</th>
            <th>Expira contrasena</th>
            <th>Estado</th>
        </tr>
"@

# Verificar si hay usuarios y agregarlos a la tabla
if ($usuarios) {
    foreach ($usuario in $usuarios) {
        $estado = if ($usuario.Enabled) { "Habilitado" } else { "Deshabilitado" }
        $passwordNeverExpires = if (-not $usuario.PasswordNeverExpires) { "Si" } else { "No" }
        $lastPasswordSet = if ($usuario.PasswordLastSet -ne $null) { $usuario.PasswordLastSet.ToString("yyyy-MM-dd HH:mm:ss") } else { "Nunca" }
        $htmlOutput += "<tr><td>$($usuario.Name)</td><td>$lastPasswordSet</td><td>$passwordNeverExpires</td><td>$estado</td></tr>"
    }
} else {
    $htmlOutput += "<tr><td colspan='4'>No se encontraron usuarios que coincidan con los criterios de búsqueda.</td></tr>"
}

# Finalizar la tabla y el documento HTML
$htmlOutput += @"
    </table>
</body>
</html>
"@

# Devolver la salida HTML
$htmlOutput
