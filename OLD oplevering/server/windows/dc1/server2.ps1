# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# The following script will build upon the Windows server configuration
# I used functions to start calls to execute multiple scripts in an interactive way
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Functions for interactive script calling
# -------------------------------------------------------------------------------------------------

function RunScript {
    param([string]$scriptPath)
    try {
        & $scriptPath
        Write-Host "$scriptPath has completed successfully."
    } catch {
        Write-Host "An error occurred while running $scriptPath : $_"
        return $false
    }
    return $true
}

function AskToRun {
    param([string]$question, [string]$scriptPath, [ref]$scriptQueue)
    
    $maxRetries = 3
    $retryCount = 0

    while ($true) {
        $response = Read-Host "$question (y/n)"
        switch ($response.Trim().ToLower()) {
            'y' {
                $scriptQueue.Value.Add($scriptPath)
                return  
            }
            'n' {
                Write-Host "Skipping $scriptPath"
                return  
            }
            default {
                Write-Host "Invalid response. Please answer 'y' or 'n'."
                $retryCount++
                if ($retryCount -ge $maxRetries) {
                    Write-Host "Maximum retries reached. Skipping this script."
                    return  
                }
            }
        }
    }
}

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

$scriptQueue = New-Object System.Collections.Generic.List[string]

AskToRun -question "Do you want to finalize the domain configuration?" -scriptPath "Z:\Windows\dc1\adConfig.ps1" -scriptQueue ([ref]$scriptQueue)
AskToRun -question "Do you want to configure DNS?" -scriptPath "Z:\Windows\dc1\dns.ps1" -scriptQueue ([ref]$scriptQueue)
AskToRun -question "Do you want to configure the shared drive?" -scriptPath "Z:\Windows\dc1\share.ps1" -scriptQueue ([ref]$scriptQueue)
AskToRun -question "Do you want to configure the DHCP role?" -scriptPath "Z:\Windows\dc1\dhcp.ps1" -scriptQueue ([ref]$scriptQueue)


# Execute all queued scripts
foreach ($script in $scriptQueue) {
    $result = RunScript -scriptPath $script
    if (-not $result) {
        Write-Host "Execution of $script failed, stopping further executions."
        break
    }
}

Write-Host "All operations completed."

