<#
.SYNOPSIS
Build LUA project for the Playdate

.PARAMETER in
Path to your project folder (main folder or Source directory)

.PARAMETER o
Output Folder (should end in .pdx)

.PARAMETER I
(optional) Pass in a folder outside the project path with additional sources. Will be passed to pdc with the -I option.

.PARAMETER nobuild
Skip the build step and only run in simulator or zip

.PARAMETER run
Run the project in the simulator after building

.PARAMETER zip
Zip the output project, to create a file ready for uploading to itch.io or via the sideloading interface.
The filename will be the output foler name + .zip

.DESCRIPTION
Pass in a project directory, which is then built using the PlaydateSDK's pdc.
You can optonally run it in the simulator or zip it up for shipping.
PLAYDATE_SDK_PATH environment variable needs to be set before calling this.
See https://sdk.play.date/2.0.3/Inside%20Playdate.html#_compiling_a_project for more info.

.INPUTS
None.

.OUTPUTS
Debug log as System.String.

.EXAMPLE
PS> .\build_lua .\Asheteroids\ -o .\Asheteroids\Asheteroids.pdx -run -zip
(Run in %PLAYDATE_SDK_PATH%\Examples)

.LINK
https://sdk.play.date/2.0.3/Inside%20Playdate.html
https://github.com/foxblock/playdate-build-scripts
#> 

[CmdletBinding()]
param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$in,
    [string]$I,
    [Parameter(Mandatory=$true)]
    [string]$o,
    [switch]$nobuild,
    [switch]$run,
    [switch]$zip
)

if ($nobuild -eq $true -and $run -ne $true -and $zip -ne $true) {
    Write-Warning "Nothing to do"
    Return
}

if ($env:PLAYDATE_SDK_PATH -eq $null -or $env:PLAYDATE_SDK_PATH -eq "") {
    $(throw "PLAYDATE_SDK_PATH environment variable needs to be set!")
}

try {
    Get-Command pdc -ErrorAction Stop | Out-Null
} catch {
    $(throw "pdc was not found. Please check if your PlaydateSDK is properly installed and the PLAYDATE_SDK_PATH environment variable set.")
    Return
}

if ((Split-Path $in -Leaf) -ne "Source") {
    $in = Join-Path $in "Source"
}

if ([IO.Path]::GetExtension($o) -ne ".pdx") {
    Write-Warning "Output does not end in .pdx (will be automatically appended)"
    $o += ".pdx"
}

if ($nobuild -ne $true) {
    $build = "pdc";
    if ($I -ne $null -and $I -ne "") {
        $build = "$build -I `"$I`""
    }
    $build = "$build `"$in`" `"$o`""

    echo "Building $in..."
    echo "Output path: $o"
    echo "Call: $build"

    Invoke-Expression "& $build"
}

if ($zip -eq $true) {
    $zipOut = $o + ".zip"
    echo "Zipping project to $zipOut..."
    Compress-Archive -Path $o -DestinationPath $zipOut -Force -CompressionLevel Optimal
}

if ($run -eq $true) {
    echo "Running PlaydateSimulator..."
    Invoke-Expression "& PlaydateSimulator `"$o`""
}

echo "All done!"