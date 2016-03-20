#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

# Updates the ValidDependencyVersions.txt file with the latest CoreFX build number
function UpdateValidDependencyVersionsFile
{
    # TODO: change to rc3 and get this from a variable
    $CoreFxLatestVersion = Invoke-WebRequest $env:COREFX_VERSION_URL -UseBasicParsing
    $CoreFxLatestVersion = $CoreFxLatestVersion.ToString().Trim()

    $ValidDependencyVersionsPath = "$PSScriptRoot\ValidDependencyVersions.txt"
    $ValidDependencyVersionsText = [IO.File]::ReadAllText($ValidDependencyVersionsPath)

    $CoreFxRegex = new-object Text.RegularExpressions.Regex 'CoreFX_ExpectedPrerelease=.*\d+'

    $ValidDependencyVersionsText = $CoreFxRegex.Replace($ValidDependencyVersionsText, "CoreFX_ExpectedPrerelease=$CoreFxLatestVersion")

    [IO.File]::WriteAllText($ValidDependencyVersionsPath, $ValidDependencyVersionsText, [Text.Encoding]::UTF8)
}

# Updates all the project.json files with out of date version numbers
function RunUpdatePackageDependencyVersions
{
    cmd /c $PSScriptRoot\build.cmd /t:UpdateInvalidPackageVersions | Out-Null
}

# Creates a Pull Request for the updated version numbers
function CreatePullRequest
{
    git add .
    $UserName = $env:GITHUB_USER
    $Email = $env:GITHUB_EMAIL
    
    $CommitMessage = 'Updating dependencies from latest build numbers'
    $env:GIT_COMMITTER_NAME = $UserName
    $env:GIT_COMMITTER_EMAIL = $Email
    git commit -m "$CommitMessage" --author "$UserName <$Email>"

    $RemoteUrl = "github.com/$env:GITHUB_ORIGIN_OWNER/$env:GITHUB_PROJECT.git"
    $RemoteBranchName = "UpdateDependencies$([DateTime]::UtcNow.ToString('yyyyMMddhhmmss'))"
    $RefSpec = "HEAD:refs/heads/$RemoteBranchName"

    Write-Host "git push https://$RemoteUrl $RefSpec"
    # pipe this to null so the password secret isn't in the logs
    git push "https://$($UserName):$env:GITHUB_PASSWORD@$RemoteUrl" $RefSpec 2>&1 | Out-Null

    $CreatePRBody = @"
    {
        "title": "$CommitMessage", 
        "head": "$($UserName):$RemoteBranchName", 
        "base": "$env:GITHUB_UPSTREAM_BRANCH" 
    }
"@

    $CreatePRHeaders = @{'Accept'='application/vnd.github.v3+json'; 'Authorization'="token $env:GITHUB_PASSWORD"}

    Invoke-WebRequest https://api.github.com/repos/$env:GITHUB_UPSTREAM_OWNER/$env:GITHUB_PROJECT/pulls -Method Post -Body $CreatePRBody -Headers $CreatePRHeaders
}

function EnsureEnvironmentVariable([string]$envVarName)
{
    If ([Environment]::GetEnvironmentVariable($envVarName) -eq $null)
    {
        throw "Can't find environment variable '$envVarName'"
    }
}

function SetEnvIfDefault([string]$envVarName, [string]$value)
{
    If ([Environment]::GetEnvironmentVariable($envVarName) -eq $null)
    {
        [Environment]::SetEnvironmentVariable($envVarName, $value)
    }
}

EnsureEnvironmentVariable "GITHUB_USER"
EnsureEnvironmentVariable "GITHUB_EMAIL"
EnsureEnvironmentVariable "GITHUB_PASSWORD"

# TODO change this to rc3 and under dotnet
SetEnvIfDefault 'COREFX_VERSION_URL' 'https://raw.githubusercontent.com/eerhardt/versions/master/corefx/release/1.0.0-rc2/Latest.txt'
SetEnvIfDefault 'GITHUB_ORIGIN_OWNER' $env:GITHUB_USER
SetEnvIfDefault 'GITHUB_UPSTREAM_OWNER' 'eerhardt' # TODO 'dotnet'
SetEnvIfDefault 'GITHUB_PROJECT' 'corefx'
SetEnvIfDefault 'GITHUB_UPSTREAM_BRANCH' 'master'

UpdateValidDependencyVersionsFile
RunUpdatePackageDependencyVersions
CreatePullRequest
