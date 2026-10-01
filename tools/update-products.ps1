$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$portfolioRoot = Join-Path $projectRoot 'assets\img\portfolio'
$outputFile = Join-Path $projectRoot 'assets\js\products.js'
$imageExtensions = @('.jpg', '.jpeg', '.png', '.webp', '.gif', '.avif')

$categories = @(
    @{ Folder = 'sofa-go'; Class = 'filter-app'; Title = 'Sofa Gỗ'; Gallery = 'portfolio-gallery-sofa'; Description = 'Sofa gỗ tự nhiên, sang trọng, tinh tế và bền đẹp.' },
    @{ Folder = 'ban-an'; Class = 'filter-product'; Title = 'Bàn Ăn'; Gallery = 'portfolio-gallery-ban-an'; Description = 'Bàn ăn gỗ tự nhiên, ấm cúng và phù hợp với không gian gia đình.' },
    @{ Folder = 'giuong'; Class = 'filter-branding'; Title = 'Giường'; Gallery = 'portfolio-gallery-giuong'; Description = 'Giường gỗ chắc chắn, tinh tế và thoải mái.' },
    @{ Folder = 'tu-tivi'; Class = 'filter-books'; Title = 'Tủ tivi'; Gallery = 'portfolio-gallery-tu-tivi'; Description = 'Tủ, kệ tivi gỗ với thiết kế hài hòa và tiện dụng.' }
)

$products = foreach ($category in $categories) {
    $folderPath = Join-Path $portfolioRoot $category.Folder
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null

    Get-ChildItem -LiteralPath $folderPath -File |
        Where-Object { $imageExtensions -contains $_.Extension.ToLowerInvariant() } |
        Sort-Object { [regex]::Replace($_.Name, '\d+', { param($match) $match.Value.PadLeft(20, '0') }) } |
        ForEach-Object {
            [ordered]@{
                path = 'assets/img/portfolio/{0}/{1}' -f $category.Folder, $_.Name
                category = $category.Class
                title = $category.Title
                description = $category.Description
                gallery = $category.Gallery
            }
        }
}

$json = $products | ConvertTo-Json -Depth 3
if (-not $json) { $json = '[]' }
$content = "// Tep nay duoc tao tu dong. Hay them anh vao 4 thu muc san pham.`r`nwindow.KY_MOC_PRODUCTS = $json;`r`n"
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

Write-Host "Da cap nhat $($products.Count) san pham."
