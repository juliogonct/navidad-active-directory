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
            Select-Object Name, Enabled, PasswordLastSet, PasswordNeverExpires

# Filtrar por estado del usuario si se especifica
if ($EstadoUsuario -eq "Habilitado") {
    $usuarios = $usuarios | Where-Object { $_.Enabled -eq $true }
} elseif ($EstadoUsuario -eq "Deshabilitado") {
    $usuarios = $usuarios | Where-Object { $_.Enabled -eq $false }
}

# Filtrar por estado de la contraseña si se especifica
if ($EstadoPassword -eq "Expira") {
    $usuarios = $usuarios | Where-Object { -not $_.PasswordNeverExpires -and ($_.PasswordLastSet -ge (Get-Date).AddDays(-90) -or $_.whenCreated -ge (Get-Date).AddDays(-90)) }
} 
elseif ($EstadoPassword -eq "Expirada") {
    $usuarios = $usuarios | Where-Object { -not $_.PasswordNeverExpires -and $_.PasswordLastSet -lt (Get-Date).AddDays(-90) -and $_.whenCreated -lt (Get-Date).AddDays(-90) }
} 
elseif ($EstadoPassword -eq "NoExpira") {
    $usuarios = $usuarios | Where-Object { $_.PasswordNeverExpires -eq $true }
}

# Calcular la fecha de caducidad de la contraseña para cada usuario y ordenar por ella
$usuarios = $usuarios | ForEach-Object {
    $usuario = $_
    $expira = if (-not $usuario.PasswordNeverExpires) {
        $usuario.PasswordLastSet.AddDays((Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.TotalDays)
    } else {
        "Nunca"
    }
    [PSCustomObject]@{
        Name = $usuario.Name
        Enabled = $usuario.Enabled
        PasswordLastSet = $usuario.PasswordLastSet
        PasswordExpires = $expira
        DaysUntilExpiration = if ($expira -ne "Nunca") { ($expira - (Get-Date)).Days } else { "Nunca" }
    }
} | Sort-Object DaysUntilExpiration

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
            <th>Dias hasta expiracion</th>
            <th>Estado</th>
        </tr>
"@

# Verificar si hay usuarios y agregarlos a la tabla
if ($usuarios) {
    foreach ($usuario in $usuarios) {
        $estado = if ($usuario.Enabled) { "Habilitado" } else { "Deshabilitado" }
        $lastPasswordSet = if ($usuario.PasswordLastSet -ne $null) { $usuario.PasswordLastSet.ToString("yyyy-MM-dd HH:mm:ss") } else { "Nunca" }
        $passwordExpires = if ($usuario.PasswordExpires -ne $null) { $usuario.PasswordExpires.ToString("yyyy-MM-dd HH:mm:ss") } else { "Nunca" }
        $htmlOutput += "<tr><td>$($usuario.Name)</td><td>$lastPasswordSet</td><td>$passwordExpires</td><td>$($usuario.DaysUntilExpiration)</td><td>$estado</td></tr>"
    }
} else {
    $htmlOutput += "<tr><td colspan='5'>No se encontraron usuarios que coincidan con los criterios de búsqueda.</td></tr>"
}

# Finalizar la tabla y el documento HTML
$htmlOutput += @"
    </table>
</body>
</html>
"@

# Devolver la salida HTML
$htmlOutput
