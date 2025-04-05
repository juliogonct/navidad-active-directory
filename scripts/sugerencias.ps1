param (
    [Parameter(Mandatory=$true)]
    [string]$ObjectType,  # Tipo de objeto (User, Group, Computer, OU)

    [Parameter(Mandatory=$true)]
    [string]$Filter  # Filtro para la búsqueda
)

Import-Module ActiveDirectory

function Search-ADObject {
    param (
        [string]$ObjectType,
        [string]$Filter
    )

    switch ($ObjectType) {
        'User' {
            $objects = Get-ADUser -Filter "Name -like '*$Filter*'" -Property Name | Select-Object -ExpandProperty Name | Sort-Object
        }
        'Group' {
            $objects = Get-ADGroup -Filter "Name -like '*$Filter*'" -Property Name | Select-Object -ExpandProperty Name | Sort-Object
        }
        'Computer' {
            $objects = Get-ADComputer -Filter "Name -like '*$Filter*'" -Property Name | Select-Object -ExpandProperty Name | Sort-Object
        }
        'OU' {
            $objects = Get-ADOrganizationalUnit -Filter "Name -like '*$Filter*'" -Property Name | Select-Object -ExpandProperty Name | Sort-Object
        }
        default {
            throw "Unsupported object type: $ObjectType"
        }
    }

    return $objects -join "`n"
}

# Llamar a la función con los parámetros proporcionados
$result = Search-ADObject -ObjectType $ObjectType -Filter $Filter
return $result
