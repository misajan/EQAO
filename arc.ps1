try {
    # Add the service principal application ID and secret here
    $servicePrincipalClientId="967b031c-1b2c-4cf6-93da-b9f11923f9ab";
    $servicePrincipalSecret="yud8Q~R19Or626HGzYqagfQeV.ehqn4MwigEocOF";

    $env:SUBSCRIPTION_ID = "07009c2b-bbd7-41fc-9de1-5c222e679b48";
    $env:RESOURCE_GROUP = "EQAOResourceGroup";
    $env:TENANT_ID = "ae3a3b77-2c27-4f02-adff-f9d98aa69d45";
    $env:LOCATION = "canadacentral";
    $env:AUTH_TYPE = "principal";
    $env:CORRELATION_ID = "a7654925-52b2-4f49-94a6-9ef329c28da5";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    # Download the installation package
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";

    # Install the hybrid agent
    & "$env:TEMP\install_windows_azcmagent.ps1";
    if ($LASTEXITCODE -ne 0) { exit 1; }

    # Run connect command
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$servicePrincipalClientId" --service-principal-secret "$servicePrincipalSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --correlation-id "$env:CORRELATION_ID";
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}
