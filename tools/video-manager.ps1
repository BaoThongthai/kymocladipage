$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Web
[System.Windows.Forms.Application]::EnableVisualStyles()

$projectRoot = Split-Path -Parent $PSScriptRoot
$videoFile = Join-Path $projectRoot 'assets\js\videos.js'

function Get-CurrentLinks {
    if (-not (Test-Path -LiteralPath $videoFile)) { return @() }

    $content = [System.IO.File]::ReadAllText($videoFile)
    return [regex]::Matches($content, '[''"](https?://[^''"]+)[''"]') |
        ForEach-Object { $_.Groups[1].Value }
}

function Get-YoutubeId([string]$link) {
    try {
        $uri = [Uri]$link
        $hostName = $uri.Host.ToLowerInvariant() -replace '^www\.', '' -replace '^m\.', ''

        if ($hostName -eq 'youtu.be') {
            $candidate = $uri.AbsolutePath.Trim('/').Split('/')[0]
        }
        elseif ($hostName -in @('youtube.com', 'youtube-nocookie.com')) {
            $parts = $uri.AbsolutePath.Trim('/').Split('/')
            if ($uri.AbsolutePath -eq '/watch') {
                $candidate = [System.Web.HttpUtility]::ParseQueryString($uri.Query).Get('v')
            }
            elseif ($parts.Count -ge 2 -and $parts[0] -in @('embed', 'shorts', 'live')) {
                $candidate = $parts[1]
            }
        }

        if ($candidate -match '^[a-zA-Z0-9_-]{11}$') { return $candidate }
    }
    catch {}

    return $null
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Quan ly video YouTube - Ky Moc'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(760, 570)
$form.MinimumSize = New-Object System.Drawing.Size(620, 480)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$form.BackColor = [System.Drawing.Color]::FromArgb(247, 248, 250)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'QUAN LY VIDEO YOUTUBE'
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 17)
$title.ForeColor = [System.Drawing.Color]::FromArgb(30, 45, 55)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24, 20)
$form.Controls.Add($title)

$help = New-Object System.Windows.Forms.Label
$help.Text = "Dan moi link YouTube tren mot dong. Co the dung link youtube.com, youtu.be, Shorts hoac livestream."
$help.ForeColor = [System.Drawing.Color]::FromArgb(90, 95, 100)
$help.AutoSize = $true
$help.Location = New-Object System.Drawing.Point(27, 62)
$form.Controls.Add($help)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ScrollBars = 'Vertical'
$textBox.AcceptsReturn = $true
$textBox.WordWrap = $false
$textBox.Anchor = 'Top, Bottom, Left, Right'
$textBox.Location = New-Object System.Drawing.Point(30, 95)
$textBox.Size = New-Object System.Drawing.Size(684, 340)
$textBox.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$textBox.Text = (Get-CurrentLinks) -join [Environment]::NewLine
$form.Controls.Add($textBox)

$status = New-Object System.Windows.Forms.Label
$status.Text = 'Moi dong la mot video.'
$status.ForeColor = [System.Drawing.Color]::FromArgb(90, 95, 100)
$status.AutoSize = $true
$status.Anchor = 'Bottom, Left'
$status.Location = New-Object System.Drawing.Point(30, 452)
$form.Controls.Add($status)

$updateButton = New-Object System.Windows.Forms.Button
$updateButton.Text = 'CAP NHAT VIDEO'
$updateButton.Anchor = 'Bottom, Right'
$updateButton.Location = New-Object System.Drawing.Point(510, 445)
$updateButton.Size = New-Object System.Drawing.Size(204, 48)
$updateButton.FlatStyle = 'Flat'
$updateButton.BackColor = [System.Drawing.Color]::FromArgb(255, 77, 40)
$updateButton.ForeColor = [System.Drawing.Color]::White
$updateButton.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 11)
$updateButton.Cursor = 'Hand'
$updateButton.Add_Click({
    $links = @($textBox.Lines |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ } |
        Select-Object -Unique)

    $invalidLinks = @($links | Where-Object { -not (Get-YoutubeId $_) })
    if ($invalidLinks.Count -gt 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "Link khong hop le:`n`n$($invalidLinks -join "`n")",
            'Kiem tra lai link',
            'OK',
            'Warning'
        ) | Out-Null
        return
    }

    $lines = @(
        '// Tep nay duoc cap nhat bang cong cu Quan-ly-video.cmd.'
        'window.KY_MOC_YOUTUBE_VIDEOS = ['
    )

    foreach ($link in $links) {
        $safeLink = $link.Replace("'", "\'")
        $lines += "  '$safeLink',"
    }
    $lines += '];'

    [System.IO.File]::WriteAllText(
        $videoFile,
        ($lines -join "`r`n") + "`r`n",
        [System.Text.UTF8Encoding]::new($false)
    )

    $status.Text = "Da cap nhat $($links.Count) video. Bay gio ban chi can push len GitHub."
    $status.ForeColor = [System.Drawing.Color]::FromArgb(20, 130, 70)
    [System.Windows.Forms.MessageBox]::Show(
        "Da cap nhat $($links.Count) video thanh cong!`n`nBan co the push len GitHub ngay bay gio.",
        'Hoan tat',
        'OK',
        'Information'
    ) | Out-Null
})
$form.Controls.Add($updateButton)

$form.AcceptButton = $updateButton
[void]$form.ShowDialog()
