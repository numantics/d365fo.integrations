﻿

function Get-D365ODataPublicEntity {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $false)]
        [string] $ODataQuery,

        [Parameter(Mandatory = $false)]
        [Alias('$AADGuid')]
        [string] $Tenant = $Script:ODataTenant,

        [Parameter(Mandatory = $false)]
        [Alias('URI')]
        [string] $URL = $Script:ODataUrl,

        [Parameter(Mandatory = $false)]
        [string] $ClientId = $Script:ODataClientId,

        [Parameter(Mandatory = $false)]
        [string] $ClientSecret = $Script:ODataClientSecret

    )

    $bearerParms = @{
        Resource     = $URL
        ClientId     = $ClientId
        ClientSecret = $ClientSecret
    }

    $bearerParms.AuthProviderUri = "https://login.microsoftonline.com/$Tenant/oauth2/token"

    $bearer = Invoke-ClientCredentialsGrant @bearerParms | Get-BearerToken

    $headerParms = @{
        URL         = $URL
        BearerToken = $bearer
    }

    $headers = New-AuthorizationHeaderBearerToken @headerParms

    [System.UriBuilder] $odataEndpoint = $URL
    $odataEndpoint.Path = "metadata/PublicEntities"

    if (-not ([string]::IsNullOrEmpty($ODataQuery))) {
        $odataEndpoint.Query = "$ODataQuery"
    }

    try {
        Invoke-RestMethod -Method Get -Uri $odataEndpoint.Uri.AbsoluteUri -Headers $headers -ContentType 'application/json'
    }
    catch {
        Write-PSFMessage -Level Host -Message "Something went wrong while trying to send a message to the users." -Exception $PSItem.Exception
        Stop-PSFFunction -Message "Stopping because of errors."
        return
    }
}