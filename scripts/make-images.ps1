Add-Type -AssemblyName System.Drawing

$assets = Join-Path $PSScriptRoot '..\src\assets'
New-Item -ItemType Directory -Force -Path $assets | Out-Null

function New-RoundedPath([float]$x,[float]$y,[float]$w,[float]$h,[float]$r) {
  $p = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $d = $r * 2
  $p.AddArc($x,$y,$d,$d,180,90); $p.AddArc($x+$w-$d,$y,$d,$d,270,90)
  $p.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $p.AddArc($x,$y+$h-$d,$d,$d,90,90); $p.CloseFigure()
  return $p
}

function Draw-BrandIcon($g,[int]$size,[float]$x,[float]$y) {
  $scale = $size / 128.0
  $green = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(55,122,99))
  $mint = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(232,255,244))
  $bg = New-RoundedPath $x $y $size $size (28*$scale); $g.FillPath($green,$bg)
  $shield = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $shield.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new($x+64*$scale,$y+18*$scale),[System.Drawing.PointF]::new($x+102*$scale,$y+33*$scale),
    [System.Drawing.PointF]::new($x+102*$scale,$y+61*$scale),[System.Drawing.PointF]::new($x+94*$scale,$y+84*$scale),
    [System.Drawing.PointF]::new($x+64*$scale,$y+111*$scale),[System.Drawing.PointF]::new($x+34*$scale,$y+84*$scale),
    [System.Drawing.PointF]::new($x+26*$scale,$y+61*$scale),[System.Drawing.PointF]::new($x+26*$scale,$y+33*$scale)))
  $g.FillPath($mint,$shield)
  $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(55,122,99),10*$scale); $pen.StartCap='Round';$pen.EndCap='Round';$pen.LineJoin='Round'
  $g.DrawLines($pen,[System.Drawing.PointF[]]@([System.Drawing.PointF]::new($x+43*$scale,$y+63*$scale),[System.Drawing.PointF]::new($x+57*$scale,$y+77*$scale),[System.Drawing.PointF]::new($x+86*$scale,$y+41*$scale)))
  $pen.Dispose();$green.Dispose();$mint.Dispose();$bg.Dispose();$shield.Dispose()
}

function Save-Icon([int]$size,[string]$name) {
  $bmp=[System.Drawing.Bitmap]::new($size,$size);$g=[System.Drawing.Graphics]::FromImage($bmp);$g.SmoothingMode='AntiAlias';$g.Clear([System.Drawing.Color]::Transparent)
  Draw-BrandIcon $g $size 0 0
  $bmp.Save((Join-Path $assets $name),[System.Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$bmp.Dispose()
}

Save-Icon 16 'favicon-16x16.png'; Save-Icon 32 'favicon-32x32.png'; Save-Icon 180 'apple-touch-icon.png'; Save-Icon 192 'icon-192.png'; Save-Icon 512 'icon-512.png'; Save-Icon 512 'logo-symbol.png'

# ICO container with a PNG-compressed 32px image.
$pngBytes = [System.IO.File]::ReadAllBytes((Join-Path $assets 'favicon-32x32.png'))
$icoPath = Join-Path $assets 'favicon.ico'
$stream = [System.IO.File]::Create($icoPath)
$writer = [System.IO.BinaryWriter]::new($stream)
$writer.Write([UInt16]0); $writer.Write([UInt16]1); $writer.Write([UInt16]1)
$writer.Write([Byte]32); $writer.Write([Byte]32); $writer.Write([Byte]0); $writer.Write([Byte]0)
$writer.Write([UInt16]1); $writer.Write([UInt16]32); $writer.Write([UInt32]$pngBytes.Length); $writer.Write([UInt32]22)
$writer.Write($pngBytes); $writer.Dispose(); $stream.Dispose()

$pages = @{
  'og-default.png'='병역판정검사 모의 시뮬레이터';
  'og-simulation.png'='단계별 병역판정 모의 검사';
  'og-bmi.png'='군대 BMI 계산기';
  'og-criteria.png'='질환별 신체등급 기준 검색';
  'og-grades.png'='병역판정 신체등급 1~7급';
  'og-guide.png'='병역판정검사 절차와 준비물'
}
foreach($item in $pages.GetEnumerator()) {
  $bmp=[System.Drawing.Bitmap]::new(1200,630);$g=[System.Drawing.Graphics]::FromImage($bmp);$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='AntiAliasGridFit'
  $g.Clear([System.Drawing.Color]::FromArgb(237,248,242))
  $glow=[System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(190,227,211));$g.FillEllipse($glow,770,-120,520,520);$g.FillEllipse($glow,850,360,340,340)
  Draw-BrandIcon $g 78 72 64
  $dark=[System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(24,56,45));$green=[System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(55,122,99));$white=[System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
  $f1=[System.Drawing.Font]::new('Arial',31,[System.Drawing.FontStyle]::Bold);$f2=[System.Drawing.Font]::new('Malgun Gothic',48,[System.Drawing.FontStyle]::Bold);$f3=[System.Drawing.Font]::new('Malgun Gothic',24,[System.Drawing.FontStyle]::Regular)
  $g.DrawString('MILCHECK',$f1,$dark,172,83);$g.DrawString($item.Value,$f2,$dark,72,205);$g.DrawString('나의 병역판정검사, 미리 알아보세요.',$f3,$green,76,292)
  $card=New-RoundedPath 774 96 330 430 46;$g.FillPath($white,$card)
  $clip=New-RoundedPath 820 148 240 314 30;$g.FillPath([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(225,244,235)),$clip)
  $pen=[System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(55,122,99),14);$pen.StartCap='Round';$pen.EndCap='Round';$pen.LineJoin='Round'
  $g.DrawLines($pen,[System.Drawing.PointF[]]@([System.Drawing.PointF]::new(861,260),[System.Drawing.PointF]::new(888,287),[System.Drawing.PointF]::new(940,220)))
  $thin=[System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(139,190,168),11);$thin.StartCap='Round';$thin.EndCap='Round';$g.DrawLine($thin,852,342,1025,342);$g.DrawLine($thin,852,386,985,386)
  $bmp.Save((Join-Path $assets $item.Key),[System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose();$bmp.Dispose();$glow.Dispose();$dark.Dispose();$green.Dispose();$white.Dispose();$f1.Dispose();$f2.Dispose();$f3.Dispose();$card.Dispose();$clip.Dispose();$pen.Dispose();$thin.Dispose()
}

Write-Host "Generated favicon and OG image set in $assets"
