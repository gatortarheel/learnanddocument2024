  # Function
        function Increment-Version ([string]$Version, [int]$Increment = 1) {
            $parts = $Version -split '\.'
            $lastPart = [int]$parts[-1]
            $newLastPart = $lastPart + $Increment
            $parts[-1] = $newLastPart.ToString()
            return [string]::Join('.', $parts)
        }

        ## Constants
        $patToken = ""  # Expires 2024-05-30
        $projectId = "1dd5806d-aca7-41c8-8e74-21857acaf6ba"
        $feedID = "0ac9e6d4-7365-4d85-8c42-3f42f0b10879"
        ###

        ## 1. Get an Authorization Token
        # Authenticate with Azure DevOps REST API
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($patToken)"))
        $headers = @{
            "Authorization" = "Basic $base64AuthInfo"
        }

        ## 2. Get the latest version of the package
        $urlVersions = "https://feeds.dev.azure.com/VDACS-DevOps/_apis/Packaging/Feeds/0ac9e6d4-7365-4d85-8c42-3f42f0b10879/Packages/1165909c-52eb-4a8f-8107-191aa1578476/Versions"
        $response = Invoke-RestMethod -Uri $urlVersions -Headers $headers
        $latestVersion = $response.value | Where-Object { $_.isLatest -eq $true } | Select-Object -First 1

        ## 3. Display the latest version
        Write-Host "Latest version of $($packageName): $($latestVersion.version)"
        $nextVersion = Increment-Version($latestVersion.version)
        Write-Host "next version of $($packageName): $($nextVersion)"
        Write-Host "##vso[task.setvariable variable=nextVersion;isOutput=true]$nextVersion"



        ## resources
        ## to get all the feeds - test in boomerang
        ## https://feeds.dev.azure.com/VDACS-DevOps/DevOps/_apis/packaging/feeds?api-version=7.0
        ## to get all the artifacts in the feed
        ## https://feeds.dev.azure.com/VDACS-DevOps/_apis/packaging/Feeds/0ac9e6d4-7365-4d85-8c42-3f42f0b10879/packages?api-version=7.0
        ## https://learn.microsoft.com/en-us/rest/api/azure/devops/artifacts/artifact-details/get-packages?view=azure-devops-rest-7.0




