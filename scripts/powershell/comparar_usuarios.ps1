param (
    [Parameter(Mandatory=$true)]
    [string]$UserName1,

    [Parameter(Mandatory=$true)]
    [string]$UserName2
)

Import-Module ActiveDirectory

function Get-Groups {
    param (
        [string]$UserName1,
        [string]$UserName2
    )

    $user1 = Get-ADUser -Filter "Name -eq '$UserName1'" -ErrorAction SilentlyContinue
    $user2 = Get-ADUser -Filter "Name -eq '$UserName2'" -ErrorAction SilentlyContinue

    if (-not $user1 -or -not $user2) {
        Write-Error "Uno o ambos usuarios no se encuentran o no se tienen permisos suficientes para acceder a ellos."
        return @()
    }

    $user1Groups = Get-ADPrincipalGroupMembership -Identity $user1 | Select-Object -ExpandProperty Name | Sort-Object
    $user2Groups = Get-ADPrincipalGroupMembership -Identity $user2 | Select-Object -ExpandProperty Name | Sort-Object

    $commonGroups = $user1Groups | Where-Object { $_ -in $user2Groups }
    $user1UniqueGroups = $user1Groups | Where-Object { $_ -notin $user2Groups }
    $user2UniqueGroups = $user2Groups | Where-Object { $_ -notin $user1Groups }

    # Asegura de que los arrays no estén vacíos para evitar problemas en el reporte HTML
    if (-not $commonGroups) { $commonGroups = @("") }
    if (-not $user1UniqueGroups) { $user1UniqueGroups = @("") }
    if (-not $user2UniqueGroups) { $user2UniqueGroups = @("") }

    return $commonGroups, $user1UniqueGroups, $user2UniqueGroups
}


function GenerateHTMLReport {
    param (
        [array]$CommonGroups,
        [array]$User1UniqueGroups,
        [array]$User2UniqueGroups
    )

    $maxCount = @($CommonGroups.Count, $User1UniqueGroups.Count, $User2UniqueGroups.Count) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

    $htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
    <style>
        th {
            width: 33.33%;
        }
    </style>
</head>
<body>
    <table>
        <tr>
            <th>Grupos comunes</th>
            <th>Grupos exclusivos de $UserName1</th>
            <th>Grupos exclusivos de $UserName2</th>
        </tr>
"@
    for ($i=0; $i -lt $maxCount; $i++) {
        $htmlOutput += "<tr>
            <td>$($CommonGroups[$i])</td>
            <td>$($User1UniqueGroups[$i])</td>
            <td>$($User2UniqueGroups[$i])</td>
        </tr>"
    }

    $htmlOutput += @"
    </table>
</body>
</html>
"@

    return $htmlOutput
}

# Ejecución de las funciones
$commonGroups, $user1UniqueGroups, $user2UniqueGroups = Get-Groups -UserName1 $UserName1 -UserName2 $UserName2
$htmlReport = GenerateHTMLReport -CommonGroups $commonGroups -User1UniqueGroups $user1UniqueGroups -User2UniqueGroups $user2UniqueGroups
$htmlReport