param (
    [Parameter(Mandatory=$true)]
    [string]$Group1Name,

    [Parameter(Mandatory=$true)]
    [string]$Group2Name
)

Import-Module ActiveDirectory

function Get-Members {
    param (
        [string]$Group1Name,
        [string]$Group2Name
    )

    $group1 = Get-ADGroup -Identity $Group1Name -ErrorAction SilentlyContinue
    $group2 = Get-ADGroup -Identity $Group2Name -ErrorAction SilentlyContinue

    if (-not $group1 -or -not $group2) {
        Write-Error "Uno o ambos grupos no se encuentran o no se tienen permisos suficientes para acceder a ellos."
        return @()
    }

    $group1Members = Get-ADGroupMember -Identity $group1 | ForEach-Object {($_ -split ",")[0] -replace 'CN=', ''} | Sort-Object
    $group2Members = Get-ADGroupMember -Identity $group2 | ForEach-Object {($_ -split ",")[0] -replace 'CN=', ''} | Sort-Object

    $commonMembers = $group1Members | Where-Object { $_ -in $group2Members }
    $group1UniqueMembers = $group1Members | Where-Object { $_ -notin $group2Members }
    $group2UniqueMembers = $group2Members | Where-Object { $_ -notin $group1Members }

    # Asegura de que los arrays no estén vacíos para evitar problemas en el reporte HTML
    if (-not $commonMembers) { $commonMembers = @("") }
    if (-not $group1UniqueMembers) { $group1UniqueMembers = @("") }
    if (-not $group2UniqueMembers) { $group2UniqueMembers = @("") }

    return $commonMembers, $group1UniqueMembers, $group2UniqueMembers
}

function GenerateHTMLReport {
    param (
        [array]$CommonMembers,
        [array]$Group1UniqueMembers,
        [array]$Group2UniqueMembers
    )

    $maxCount = @($CommonMembers.Count, $Group1UniqueMembers.Count, $Group2UniqueMembers.Count) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

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
            <th>Miembros comunes</th>
            <th>Miembros exclusivos de $Group1Name</th>
            <th>Miembros exclusivos de $Group2Name</th>
        </tr>
"@
    for ($i=0; $i -lt $maxCount; $i++) {
        $htmlOutput += "<tr>
            <td>$($CommonMembers[$i])</td>
            <td>$($Group1UniqueMembers[$i])</td>
            <td>$($Group2UniqueMembers[$i])</td>
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
$commonMembers, $group1UniqueMembers, $group2UniqueMembers = Get-Members -Group1Name $Group1Name -Group2Name $Group2Name
$htmlReport = GenerateHTMLReport -CommonMembers $commonMembers -Group1UniqueMembers $group1UniqueMembers -Group2UniqueMembers $group2UniqueMembers
$htmlReport

