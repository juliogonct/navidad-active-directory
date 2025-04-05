[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param (
    [string]$NombreEquipo = $args[0]
)

# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Determinar el filtro
$filter = if (-not [string]::IsNullOrWhiteSpace($NombreEquipo)) {
    "Name -like '*$($NombreEquipo.Replace("'", "''"))*'"
} else {
    "*"
}

# Obtener los equipos de Active Directory utilizando el filtro
$equipos = Get-ADComputer -Filter $filter -Properties * |
           Select-Object -Property Name, OperatingSystem, OperatingSystemVersion, DistinguishedName, LastLogonDate |
           Sort-Object Name

# Generar salida HTML
$htmlOutput = @"
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
    <table>
        <tr>
            <th>Nombre del Equipo</th>
            <th>Sistema Operativo</th>
            <th>Version del SO</th>
            <th>OU</th>
            <th>Ultimo Acceso</th>
        </tr>
"@

# Verificar si hay equipos y agregarlos a la tabla
if ($equipos) {
    foreach ($equipo in $equipos) {
        $ou = ($equipo.DistinguishedName -split ',') | Where-Object { $_ -match '^OU=' } | ForEach-Object { $_.Substring(3) }
        $ou = $ou -join ', '
        $fecha = if ($equipo.LastLogonDate -ne $null) { $equipo.LastLogonDate.ToString("dd/MM/yy HH:mm:ss") } else { "No Disponible" }
        $htmlOutput += "<tr><td>$($equipo.Name)</td><td>$($equipo.OperatingSystem)</td><td>$($equipo.OperatingSystemVersion)</td><td>$ou</td><td>$fecha</td></tr>"
    }
} else {
    $htmlOutput += "<tr><td colspan='6'>No se encontraron equipos que coincidan con los criterios de búsqueda.</td></tr>"
}

# Finalizar la tabla y el documento HTML
$htmlOutput += @"
    </table>
</body>
</html>
"@

# Devolver la salida HTML
$htmlOutput
