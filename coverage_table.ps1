$lcov = "coverage/lcov.info"

$rows = @()
$currentFile = ""
$lineTotal = 0
$lineHit = 0

Get-Content $lcov | ForEach-Object {

    if ($_ -match '^SF:(.+)$') {

        if ($currentFile -like "lib/*") {

            $coverage = 0
            if ($lineTotal -gt 0) {
                $coverage = [math]::Round(($lineHit / $lineTotal) * 100, 2)
            }

            $rows += [PSCustomObject]@{
                File = $currentFile
                Lines = $lineTotal
                Hits = $lineHit
                Missed = ($lineTotal - $lineHit)
                Coverage = "$coverage%"
            }
        }

        $currentFile = $matches[1] -replace '\\','/'
        $lineTotal = 0
        $lineHit = 0
    }

    elseif ($_ -match '^DA:\d+,(\d+)$') {

        $lineTotal++

        if ([int]$matches[1] -gt 0) {
            $lineHit++
        }
    }
}

$rows | Sort-Object File | Format-Table -AutoSize

$rows | Out-File "coverage/coverage_table.txt"