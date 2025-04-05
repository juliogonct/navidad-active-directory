param (
    [string]$NombreUsuario = "gonzalo",
    [string]$NombreOU = "",
    [string]$NombreGrupo = "",
    [string]$EstadoUsuario = ""
)

Import-Module ActiveDirectory

function Get-ADUserDetails {
    param (
        [string]$Username,
        [string]$OU,
        [string]$Group,
        [string]$Estado
    )

    # Aplicar el mismo método de filtrado para Username y Group
    $userFilter = if ([string]::IsNullOrWhiteSpace($Username)) { "*" } else { "Name -like '*$($Username.Replace("'", "''"))*'" }
    $usuarios = Get-ADUser -Filter $userFilter -Properties Name, SamAccountName, DistinguishedName, EmailAddress, Enabled, MemberOf | Sort-Object

    # Filtrar por OU si se proporciona
    if (-not [string]::IsNullOrWhiteSpace($OU)) {
        $usuarios = $usuarios | Where-Object {
            $_.DistinguishedName -like "*OU=$($OU.Replace("'", "''"))*"
        }
    }

    # Filtrar por grupo si se proporciona
    if (-not [string]::IsNullOrWhiteSpace($Group)) {
        # Obtenemos los DN de los grupos que coinciden con el filtro de grupo
        $groupFilter = "Name -like '*$($Group.Replace("'", "''"))*'"
        $groupDNs = Get-ADGroup -Filter $groupFilter | Select-Object -ExpandProperty DistinguishedName
        # Filtramos los usuarios que son miembros de alguno de los grupos encontrados
        $usuarios = $usuarios | Where-Object {
            $memberGroups = $_.MemberOf
            $memberGroups | Where-Object { $groupDNs -contains $_ }
        }
    }

    # Filtrar por estado del usuario si se especifica
    if ($Estado -eq "Habilitado") {
        $usuarios = $usuarios | Where-Object { $_.Enabled -eq $true }
    } elseif ($Estado -eq "Deshabilitado") {
        $usuarios = $usuarios | Where-Object { $_.Enabled -eq $false }
    }


    # Generación de la salida HTML
    $htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
    <table>
        <tr>
            <th>Nombre</th>
            <th>Usuario</th>
            <th>Email</th>
            <th>OU</th>
            <th>Grupos</th>
            <th>Estado</th>
        </tr>
"@

    foreach ($usuario in $usuarios) {
        $correo = $usuario.EmailAddress
        $ouPart = if ($usuario.DistinguishedName -match ',OU=([^,]+),') { $matches[1] } else { "" }
        $groupNames = $usuario.MemberOf | ForEach-Object { (Get-ADGroup -Identity $_).Name } | Sort-Object
        $groupDisplay = ($groupNames -join "<br>")
        $estado = if ($usuario.Enabled) { "Habilitado" } else { "Deshabilitado" }

        # Manejar correo especial para usuarios 'ADM'
        if ([string]::IsNullOrEmpty($usuario.EmailAddress) -and $usuario.Name -match 'ADM$') {
            $nombreSinADM = $usuario.Name -replace '\sADM$'
            $usuarioSinADM = Get-ADUser -Filter "Name -eq '$nombreSinADM'" -Properties EmailAddress
            if ($usuarioSinADM) {
                $correo = $usuarioSinADM.EmailAddress
            }
        }

        # Inserción de fila en la tabla HTML para cada usuario
        $htmlOutput += "<tr>
            <td>$($usuario.Name)</td>
            <td>$($usuario.SamAccountName)</td>
            <td>${correo}</td>
            <td>${ouPart}</td>
            <td>${groupDisplay}</td>
            <td>${estado}</td>
        </tr>"
    }

    $htmlOutput += @"
    </table>
</body>
</html>
"@

    # Retorno del HTML construido
    return $htmlOutput
}

$htmlReport = Get-ADUserDetails -Username $NombreUsuario -OU $NombreOU -Group $NombreGrupo -Estado $EstadoUsuario
$htmlReport
