<#
.SYNOPSIS
    Saves a screenshot from the clipboard into the docs image folder and inserts
    the Markdown reference with the correct relative path.

.DESCRIPTION
    Take a screenshot (Win+Shift+S) or copy an image file in Explorer, then run
    this script. The image is written to docs/assets/<page-name>/ and the
    Markdown snippet is either appended to the page (-Append) or placed on the
    clipboard so you can paste it exactly where you want it.

    Inside VS Code you normally do not need this script at all: just press
    Ctrl+V inside a docs/*.md file. See .vscode/settings.json.

.EXAMPLE
    .\scripts\Paste-Image.ps1 -Page lab-tasks -Append
    Saves the clipboard image as docs/assets/lab-tasks/lab-tasks-01.png and
    appends ![Screenshot](./assets/lab-tasks/lab-tasks-01.png) to the page.

.EXAMPLE
    .\scripts\Paste-Image.ps1 -Page theory -Name nat-order -Alt "NAT order" -Width 700
    Saves the image and copies the Markdown snippet to the clipboard.

.EXAMPLE
    .\scripts\Paste-Image.ps1 -Page topologies -From C:\temp\diagram.png -Append
    Imports an existing image file instead of reading the clipboard.
#>
[CmdletBinding()]
param(
    # Page to attach the image to: a path, or just the page name (e.g. "lab-tasks").
    # Defaults to the most recently edited Markdown file under docs/.
    [Parameter(Position = 0)]
    [string]$Page,

    # File name for the image. Defaults to <page-name>-NN.png.
    [string]$Name,

    # Alt text used in the Markdown image tag.
    [string]$Alt = 'Screenshot',

    # Import this image file instead of reading the clipboard.
    [string]$From,

    # Optional rendered width in pixels.
    [int]$Width,

    # Append the Markdown snippet to the end of the page instead of copying it.
    [switch]$Append
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$docsDir = Join-Path $repoRoot 'docs'
if (-not (Test-Path -LiteralPath $docsDir)) {
    throw "Could not find the docs folder at '$docsDir'."
}

function Resolve-PagePath {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        $latest = Get-ChildItem -LiteralPath $docsDir -Filter *.md -Recurse -File |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if (-not $latest) { throw "No Markdown pages found under '$docsDir'." }
        return $latest.FullName
    }

    foreach ($candidate in @($Value, (Join-Path $docsDir $Value), (Join-Path $docsDir "$Value.md"))) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    throw "Markdown page '$Value' not found. Pass a path or a page name such as 'lab-tasks'."
}

function Get-ClipboardImageSource {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    if (-not ('DocsClipboard' -as [type])) {
        $references = @(
            [System.Windows.Forms.Clipboard].Assembly.Location
            [System.Drawing.Bitmap].Assembly.Location
        )
        if ($PSVersionTable.PSEdition -eq 'Core') {
            $runtimeDir = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
            $references += [System.Object].Assembly.Location
            $references += @('System.Runtime.dll', 'System.Threading.Thread.dll', 'netstandard.dll') |
                ForEach-Object { Join-Path $runtimeDir $_ } |
                Where-Object { Test-Path -LiteralPath $_ }
        }

        # The Windows clipboard can only be read from a single-threaded apartment,
        # which PowerShell 7 does not provide, so the read runs on a dedicated STA thread.
        Add-Type -ReferencedAssemblies $references -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Threading;
using System.Windows.Forms;

public static class DocsClipboard
{
    static readonly string[] Extensions = { ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp", ".svg" };

    public static string Kind;
    public static string Source;
    public static string Error;

    public static void Load()
    {
        Kind = "none";
        Source = null;
        Error = null;

        Thread worker = new Thread(delegate()
        {
            try
            {
                if (Clipboard.ContainsImage())
                {
                    string temp = Path.Combine(Path.GetTempPath(), "docs-paste-" + Guid.NewGuid().ToString("N") + ".png");
                    using (Image image = Clipboard.GetImage())
                    {
                        image.Save(temp, ImageFormat.Png);
                    }
                    Kind = "image";
                    Source = temp;
                }
                else if (Clipboard.ContainsFileDropList())
                {
                    foreach (string file in Clipboard.GetFileDropList())
                    {
                        if (Array.IndexOf(Extensions, Path.GetExtension(file).ToLowerInvariant()) >= 0)
                        {
                            Kind = "file";
                            Source = file;
                            break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Error = ex.Message;
            }
        });

        worker.SetApartmentState(ApartmentState.STA);
        worker.Start();
        worker.Join();
    }
}
'@
    }

    [DocsClipboard]::Load()
    if ([DocsClipboard]::Error) { throw "Could not read the clipboard: $([DocsClipboard]::Error)" }
    if ([DocsClipboard]::Kind -eq 'none') {
        throw 'The clipboard does not contain an image. Take a screenshot (Win+Shift+S) or copy an image file first.'
    }

    [pscustomobject]@{
        Path        = [DocsClipboard]::Source
        IsTemporary = ([DocsClipboard]::Kind -eq 'image')
    }
}

function Get-RelativeMarkdownPath {
    param([string]$FromDirectory, [string]$TargetFile)

    $fromUri = [Uri]($FromDirectory.TrimEnd('\') + '\')
    $relative = [Uri]::UnescapeDataString($fromUri.MakeRelativeUri([Uri]$TargetFile).ToString())
    $relative = ($relative -replace '\\', '/') -replace ' ', '%20'
    if ($relative -notmatch '^\.{1,2}/') { $relative = "./$relative" }
    return $relative
}

$pagePath = Resolve-PagePath -Value $Page
if ([IO.Path]::GetExtension($pagePath) -ne '.md') {
    throw "'$pagePath' is not a Markdown file."
}

if ($From) {
    if (-not (Test-Path -LiteralPath $From -PathType Leaf)) { throw "Image file '$From' not found." }
    $source = [pscustomobject]@{ Path = (Resolve-Path -LiteralPath $From).Path; IsTemporary = $false }
}
else {
    $source = Get-ClipboardImageSource
}

$pageName = [IO.Path]::GetFileNameWithoutExtension($pagePath)
$imageDir = Join-Path (Join-Path (Split-Path -Parent $pagePath) 'assets') $pageName
New-Item -ItemType Directory -Force -Path $imageDir | Out-Null

$extension = [IO.Path]::GetExtension($source.Path)
if ($Name) {
    $stem = [IO.Path]::GetFileNameWithoutExtension($Name)
    if ([IO.Path]::GetExtension($Name)) { $extension = [IO.Path]::GetExtension($Name) }
    $fileName = "$stem$extension"
    $index = 0
}
else {
    $stem = $pageName
    $fileName = '{0}-01{1}' -f $stem, $extension
    $index = 1
}

while (Test-Path -LiteralPath (Join-Path $imageDir $fileName)) {
    $index++
    if ($index -gt 999) { throw "Could not find a free file name in '$imageDir'." }
    $fileName = '{0}-{1:d2}{2}' -f $stem, $index, $extension
}

$targetPath = Join-Path $imageDir $fileName
Copy-Item -LiteralPath $source.Path -Destination $targetPath -Force
if ($source.IsTemporary) { Remove-Item -LiteralPath $source.Path -Force -ErrorAction SilentlyContinue }

$relativePath = Get-RelativeMarkdownPath -FromDirectory (Split-Path -Parent $pagePath) -TargetFile $targetPath
$markdown = if ($Width) { "![$Alt]($relativePath){ width=`"$Width`" }" } else { "![$Alt]($relativePath)" }

if ($Append) {
    Add-Content -LiteralPath $pagePath -Value "`r`n$markdown`r`n" -Encoding UTF8
    Write-Host "Saved  : $targetPath"
    Write-Host "Added  : $markdown"
    Write-Host "Page   : $pagePath"
}
else {
    Set-Clipboard -Value $markdown
    Write-Host "Saved            : $targetPath"
    Write-Host "Copied clipboard : $markdown"
    Write-Host 'Paste it into the page where you want the image to appear.'
}
