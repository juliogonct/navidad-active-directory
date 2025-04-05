param (
    [string]$NombreUsuario = "",
    [string]$UsuarioParaDesbloquear = ""
)

# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Función para desbloquear la cuenta de usuario
function Unlock-UserAccount {
    param ([string]$AccountName)
    Unlock-ADAccount -Identity $AccountName
    return "Cuenta desbloqueada: $AccountName"
}

# Filtrar usuarios si se especifica el nombre, de lo contrario listar todos
$filter = if (-not [string]::IsNullOrWhiteSpace($NombreUsuario)) {
    "Name -like '*$($NombreUsuario.Replace("'", "''"))*'"
} else {
    "*"
}

# Obtener los usuarios y ordenar por estado de bloqueo y nombre 
$usuarios = Get-ADUser -Filter $filter -Properties Enabled, LockedOut, SamAccountName | 
    Sort-Object -Property @{Expression={$_.LockedOut}; Descending=$true}, @{Expression={$_.Name}; Ascending=$true}

# Generar salida HTML con información de bloqueo
$htmlOutput = @"
<html>
<head>
    <meta charset='UTF-8'>
    <style>
    th:not(:first-child) {
        width: 15%;
    }
    </style>
</head>
<body>
    <table>
        <tr>
            <th>Nombre del Usuario</th>
            <th>Bloqueado</th>
            <th>Accion</th>
        </tr>
"@

foreach ($usuario in $usuarios) {
    $estadoBloqueo = if ($usuario.LockedOut) { 'Si' } else { 'No' }
    $accion = if ($usuario.LockedOut) { "<button onclick=""window.location.href='/desbloquear_usuario?usuario=$($usuario.SamAccountName)';"">Desbloquear</button>" } else { "" }
    $htmlOutput += "<tr><td>$($usuario.Name)</td><td>$estadoBloqueo</td><td>$accion</td></tr>"
}

$htmlOutput += @"
    </table>
</body>
</html>
"@

# Ejecutar desbloqueo si se especifica
if ($UsuarioParaDesbloquear) {
    $htmlOutput += Unlock-UserAccount -AccountName $UsuarioParaDesbloquear
}

$htmlOutput
