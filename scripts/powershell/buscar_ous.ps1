param (
    [string]$NombreOU = ""
)

Import-Module ActiveDirectory

function Get-OUDetails {
    param (
        [string]$OUName
    )

    # Fix filter logic for the OU
    $ouFilter = if (-not [string]::IsNullOrWhiteSpace($OUName)) { 
        "Name -like '*$($OUName.Replace("'", "''"))*'"
    } else { 
        "Name -like '*'"
    }

    $ous = Get-ADOrganizationalUnit -Filter $ouFilter -Properties distinguishedName | Sort-Object Name

    $htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
    <table>
        <tr>
            <th>OU</th>
            <th>Usuarios Habilitados</th>
            <th>Usuarios Deshabilitados</th>
            <th>Grupos</th>
            <th>Equipos</th>
            <th>Otras OUs</th>
        </tr>
"@

    foreach ($ou in $ous) {
        $enabledUsers = @()
        $disabledUsers = @()
        $groups = @()
        $computers = @()
        $subOUs = @()

        # Fetch users and other objects in the OU
        $users = Get-ADUser -Filter * -SearchBase $ou.DistinguishedName -SearchScope OneLevel
        $otherObjects = Get-ADObject -Filter * -SearchBase $ou.DistinguishedName -SearchScope OneLevel -Properties ObjectClass

        foreach ($user in $users) {
            if ($user.Enabled) {
                $enabledUsers += $user.Name
            } else {
                $disabledUsers += $user.Name
            }
        }

        foreach ($obj in $otherObjects) {
            switch ($obj.ObjectClass) {
                'group' { $groups += $obj.Name }
                'computer' { $computers += $obj.Name }
                'organizationalUnit' { $subOUs += $obj.Name }
            }
        }

        $enabledUserNames = $enabledUsers -join "<br>"
        $disabledUserNames = $disabledUsers -join "<br>"
        $groupNames = $groups -join "<br>"
        $computerNames = $computers -join "<br>"
        $subOUNames = $subOUs -join "<br>"

        $htmlOutput += "<tr>
            <td>$($ou.Name)</td>
            <td>$enabledUserNames</td>
            <td>$disabledUserNames</td>
            <td>$groupNames</td>
            <td>$computerNames</td>
            <td>$subOUNames</td>
        </tr>"
    }

    $htmlOutput += @"
    </table>
</body>
</html>
"@

    return $htmlOutput
}

$htmlReport = Get-OUDetails -OUName $NombreOU
$htmlReport
