#!/usr/bin/env pwsh

# Quick test runner with timeout - simple version
# Usage: .\run_tests_quick.ps1 [timeout_seconds]

param([int]$TimeoutSeconds = 10)

Write-Host "Running tests with $TimeoutSeconds second timeout..."

# Start the process with timeout using Wait-Process
$process = Start-Process -FilePath "godot" `
    -ArgumentList "--headless", "-d", "-s", "--path", ".", "addons/gut/gut_cmdln.gd" `
    -PassThru -NoNewWindow

# Wait for the process with timeout
$finished = $process.WaitForExit($TimeoutSeconds * 1000)  # Convert to milliseconds

if ($finished) {
    $exitCode = $process.ExitCode
    Write-Host "✅ Tests completed with exit code: $exitCode" -ForegroundColor Green
    exit $exitCode
} else {
    Write-Host "❌ Tests timed out after $TimeoutSeconds seconds!" -ForegroundColor Red
    Write-Host "This likely indicates a syntax error causing infinite error loops." -ForegroundColor Yellow
    
    # Kill the hung process
    try {
        $process.Kill()
        Write-Host "Killed hung Godot process." -ForegroundColor Yellow
    } catch {
        Write-Host "Warning: Could not kill hung process: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    exit 124  # Standard timeout exit code
}
