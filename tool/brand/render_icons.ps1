# Draws the icon PNGs and the Windows .ico from docs/brand/icon-tile.svg.
# Run tool/brand/make_brand_marks.dart first. Needs Microsoft Edge, which
# draws the SVG; Windows' own image code then scales it to each size.
#
# Usage, from the repository root: powershell -File tool\brand\render_icons.ps1
#
# android/app/src/main/res/mipmap-*/ic_launcher.png   Android 7 launchers
# windows/runner/resources/app_icon.ico               window, taskbar, installer
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$edge = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$work = Join-Path $env:TEMP 'veran-icons'
New-Item -ItemType Directory -Force $work | Out-Null

# Draw the tile once, large, on a transparent page.
$svg = Get-Content "$root\docs\brand\icon-tile.svg" -Raw
$page = '<!doctype html><html><head><style>html,body{margin:0;background:transparent}' +
    'svg{display:block;width:512px;height:512px}</style></head><body>' + $svg + '</body></html>'
Set-Content "$work\tile.html" $page -Encoding utf8
$big = "$work\tile.png"
Remove-Item $big -ErrorAction SilentlyContinue
$url = 'file:///' + ($work -replace '\\', '/') + '/tile.html'
Start-Process $edge -Wait -WindowStyle Hidden -ArgumentList @(
    '--headless=new', '--disable-gpu', '--hide-scrollbars',
    '--default-background-color=00000000', '--window-size=512,512',
    "--screenshot=$big", $url)
if (-not (Test-Path $big)) { throw 'Edge did not draw the tile.' }
$source = [Drawing.Image]::FromFile($big)

function Save-Png([int]$size, [string]$path) {
    $bmp = New-Object Drawing.Bitmap $size, $size, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([Drawing.Color]::Transparent)
    # Clamping the edges stops a faint halo around the tile.
    $edges = New-Object Drawing.Imaging.ImageAttributes
    $edges.SetWrapMode([Drawing.Drawing2D.WrapMode]::TileFlipXY)
    $dest = New-Object Drawing.Rectangle 0, 0, $size, $size
    $g.DrawImage($source, $dest, 0, 0, $source.Width, $source.Height, [Drawing.GraphicsUnit]::Pixel, $edges)
    $g.Dispose()
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

$densities = @{ mdpi = 48; hdpi = 72; xhdpi = 96; xxhdpi = 144; xxxhdpi = 192 }
foreach ($d in $densities.Keys) {
    $path = "$root\android\app\src\main\res\mipmap-$d\ic_launcher.png"
    Save-Png $densities[$d] $path
    Write-Output "wrote mipmap-$d/ic_launcher.png ($($densities[$d]) px)"
}

# An .ico holds one PNG per size, after a 6-byte header and a 16-byte entry
# for each (a width of 0 means 256).
$sizes = @(16, 20, 24, 32, 40, 48, 64, 256)
$images = @()
foreach ($s in $sizes) {
    $path = "$work\ico-$s.png"
    Save-Png $s $path
    $images += , [IO.File]::ReadAllBytes($path)
}
$source.Dispose()
$stream = New-Object IO.MemoryStream
$w = New-Object IO.BinaryWriter $stream
$w.Write([uint16]0); $w.Write([uint16]1); $w.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $side = if ($sizes[$i] -ge 256) { 0 } else { $sizes[$i] }
    $w.Write([byte]$side); $w.Write([byte]$side); $w.Write([byte]0); $w.Write([byte]0)
    $w.Write([uint16]1); $w.Write([uint16]32)
    $w.Write([uint32]$images[$i].Length); $w.Write([uint32]$offset)
    $offset += $images[$i].Length
}
foreach ($bytes in $images) { $w.Write($bytes) }
[IO.File]::WriteAllBytes("$root\windows\runner\resources\app_icon.ico", $stream.ToArray())
Write-Output "wrote app_icon.ico ($($sizes -join ', ') px)"
