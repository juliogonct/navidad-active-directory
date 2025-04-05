param (
    [string]$NombreUsuario = "",
    [string]$UsuarioParaResetear = ""
)

# Importar módulo de Active Directory
Import-Module ActiveDirectory

function Generate-RandomPassword {
    $length = 12
    $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    $password = -join ((1..$length) | ForEach-Object { Get-Random -InputObject $characters.ToCharArray() })
    return $password
}

function Reset-Password {
    param ([string]$AccountName)
    $randomPassword = Generate-RandomPassword
    $SecurePass = ConvertTo-SecureString $randomPassword -AsPlainText -Force
    Set-ADAccountPassword -Identity $AccountName -NewPassword $SecurePass -Reset
    Set-ADUser -Identity $AccountName -ChangePasswordAtLogon $true

    # Construir el string HTML solo con el usuario y la contraseña generados
    $htmlOutput = @"
    <div>
        <p><strong>Usuario:</strong> $AccountName</p>
        <p><strong>Contrasena:</strong> $randomPassword</p>
    </div>
"@
    
    return $htmlOutput
}

# Filtrar usuarios si se especifica el nombre, de lo contrario listar todos
$filter = if (-not [string]::IsNullOrWhiteSpace($NombreUsuario)) {
    "Name -like '*$($NombreUsuario.Replace("'", "''"))*'"
} else {
    "*"
}

# Obtener los usuarios
$usuarios = Get-ADUser -Filter $filter -Properties Enabled | Select-Object -Property Name, Enabled, SamAccountName | Sort-Object Name

# Generar salida HTML con botón para resetear contraseña
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
            <th>Estado</th>
            <th>Accion</th>
        </tr>
"@

foreach ($usuario in $usuarios) {
    $estado = if ($usuario.Enabled) { 'Habilitado' } else { 'Deshabilitado' }
    $htmlOutput += "<tr><td>$($usuario.Name)</td><td>$estado</td><td><button onclick=""window.location.href='/reset_password?usuario=$($usuario.SamAccountName)';"">Restaurar Contrasena</button></td></tr>"
}

$htmlOutput += @"
    </table>
</body>
</html>
"@

# Ejecutar reseteo si se especifica
if ($UsuarioParaResetear) {
    $htmlOutput = Reset-Password -AccountName $UsuarioParaResetear
}

$htmlOutput

