param (
    [string]$GroupName = "",
    [string]$UserName = ""
)

Import-Module ActiveDirectory

function Get-GroupUsers {
    param (
        [string]$GroupName,
        [string]$UserName = ""
    )

    # Definir el filtro para los grupos
    $groupFilter = if ([string]::IsNullOrWhiteSpace($GroupName)) { "*" } else { "Name -like '*$($GroupName.Replace("'", "''"))*'" }
    $groups = Get-ADGroup -Filter $groupFilter -Properties Members | Sort-Object Name

    $htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
    <title>Grupos de Active Directory y sus Miembros</title>
</head>
<body>
    <table>
        <tr>
            <th>Grupo</th>
            <th>Miembros Habilitados</th>
            <th>Miembros Deshabilitados</th>
            <th>Equipos</th>
            <th>Otros</th>
        </tr>
"@

    foreach ($group in $groups) {
        $members = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue

        $enabledUsers = @()
        $disabledUsers = @()
        $computers = @()
        $others = @()

        foreach ($member in $members) {
            switch ($member.objectClass) {
                'user' {
                    $user = Get-ADUser -Identity $member.DistinguishedName -Properties Enabled -ErrorAction SilentlyContinue
                    if ($user.Enabled) {
                        $enabledUsers += $user.Name
                    } else {
                        $disabledUsers += $user.Name
                    }
                }
                'computer' {
                    $computers += $member.Name
                }
                default {
                    $others += $member.Name
                }
            }
        }

        # Si se ha especificado un usuario, verificar si está en el grupo
        $containsSpecifiedUser = $false
        if (-not [string]::IsNullOrWhiteSpace($UserName)) {
            $containsSpecifiedUser = $enabledUsers -like "*$($UserName.Replace("'", "''"))*" -or $disabledUsers -like "*$($UserName.Replace("'", "''"))*"
        }

        # Mostrar los grupos solo si el usuario especificado está en el grupo o si no se ha especificado un usuario
        if ($containsSpecifiedUser -or [string]::IsNullOrWhiteSpace($UserName)) {

            $enabledUsers = $enabledUsers | Sort-Object
            $disabledUsers = $disabledUsers | Sort-Object
            $computers = $computers | Sort-Object
            $others = $others | Sort-Object
            
            $enabledUserNames = $enabledUsers -join "<br>"
            $disabledUserNames = $disabledUsers -join "<br>"
            $computerNames = $computers -join "<br>"
            $otherNames = $others -join "<br>"

            $htmlOutput += "<tr>
                <td>$($group.Name)</td>
                <td>$enabledUserNames</td>
                <td>$disabledUserNames</td>
                <td>$computerNames</td>
                <td>$otherNames</td>
            </tr>"
        }
    }

    $htmlOutput += @"
    </table>
</body>
</html>
"@

    return $htmlOutput
}

# Llamada a la función
$htmlReport = Get-GroupUsers -GroupName $GroupName -UserName $UserName
$htmlReport
