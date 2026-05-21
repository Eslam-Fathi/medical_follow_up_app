Add-Type -AssemblyName System.Drawing

$srcPath = "d:\working_space\medical_follow_up_app\assets\300ppi\Asset 1@300x.png"

function Resize-Image {
    param (
        [string]$destPath,
        [int]$width,
        [int]$height
    )
    Write-Host "Generating launcher icon: $destPath ($width x $height)..."
    
    # Ensure parent directory exists
    $parent = Split-Path -Parent $destPath
    if (!(Test-Path -Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    # Load master logo image
    $logo = [System.Drawing.Image]::FromFile($srcPath)

    # Create destination bitmap
    $dest = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    
    # Enable high-quality rendering
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    # Draw the beautiful Indigo/Azure gradient background (#6366F1 to #0EA5E9)
    $rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $color1 = [System.Drawing.Color]::FromArgb(255, 99, 102, 241)  # #6366F1 (Indigo)
    $color2 = [System.Drawing.Color]::FromArgb(255, 14, 165, 233)  # #0EA5E9 (Azure)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $color1, $color2, 45.0)
    $g.FillRectangle($brush, 0, 0, $width, $height)
    $brush.Dispose()

    # Calculate padding & centering to keep the logo in the Android safe zone (15% padding)
    $paddingX = [int]($width * 0.15)
    $paddingY = [int]($height * 0.15)
    $logoW = $width - (2 * $paddingX)
    $logoH = $height - (2 * $paddingY)
    
    # Draw the white logo centered
    $g.DrawImage($logo, $paddingX, $paddingY, $logoW, $logoH)

    # Save to path
    $dest.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Dispose resources
    $g.Dispose()
    $dest.Dispose()
    $logo.Dispose()
}

# Android launcher icons (standard mipmaps)
Resize-Image "d:\working_space\medical_follow_up_app\android\app\src\main\res\mipmap-mdpi\ic_launcher.png" 48 48
Resize-Image "d:\working_space\medical_follow_up_app\android\app\src\main\res\mipmap-hdpi\ic_launcher.png" 72 72
Resize-Image "d:\working_space\medical_follow_up_app\android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" 96 96
Resize-Image "d:\working_space\medical_follow_up_app\android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" 144 144
Resize-Image "d:\working_space\medical_follow_up_app\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" 192 192

# Web PWA icons
Resize-Image "d:\working_space\medical_follow_up_app\web\favicon.png" 32 32
Resize-Image "d:\working_space\medical_follow_up_app\web\icons\Icon-192.png" 192 192
Resize-Image "d:\working_space\medical_follow_up_app\web\icons\Icon-512.png" 512 512
Resize-Image "d:\working_space\medical_follow_up_app\web\icons\Icon-maskable-192.png" 192 192
Resize-Image "d:\working_space\medical_follow_up_app\web\icons\Icon-maskable-512.png" 512 512

Write-Host "All Android and Web launcher icons successfully generated from Asset 1@300x.png!"
