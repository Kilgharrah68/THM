#
# THM: Temperature Hash Monitor
#

# Define configuration variables
# Read the configuration file
$configFile = "config.txt"
$configData = Get-Content $configFile

# Parse data from the configuration file and assign values to variables
foreach ($line in $configData) {
  $key, $value = $line.Split('=').Trim()
  switch ($key) {
    "token" { $token = $value }
    "chat_id" { $chat_id = $value }
    "num_miners" { $num_miners = $value }
    "wait_time_seconds" { $wait_time_seconds = $value }
    "min_temp" { $min_temp = $value }
    "max_temp" { $max_temp = $value }
    "min_hashrate" { $min_hashrate = [int]$value }
  }
}

# Define function to send message to Telegram
function SendMessageTelegram($message) {
    try {
        # Get current date and time
        $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
        # Add date, time, and remote IP to message

        $messageWithDateTime = "$ip_miner - $currentDateTime - $message"
         # Construct Telegram API URL
        $url = "https://api.telegram.org/bot$token/sendMessage"
        $body = @{
            chat_id = $chat_id
            text = $messageWithDateTime
            parse_mode = "HTML"
        }

        # Send message to Telegram
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body

        if ($response.ok) {
            Write-Host "Message sent successfully to Telegram."
            # Write to log file
            WriteToLog $ip_miner $tempValue $hashRateValue
        } else {
            Write-Host "Error sending message to Telegram: $($response.error_code) - $($response.description)"
            # Write to log file
            WriteToLog "Error sending message to Telegram: $($response.error_code) - $($response.description)"
        }

    } catch {
        Write-Host "Error sending message to Telegram: $_"
        # Write to log file
        WriteToLog "Error sending message to Telegram: $_"
    }
}

function WriteToLog($ip_miner, $tempValue, $hashRateValue) {
    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $messageWithDateTime = "$ip_miner - $currentDateTime - Temp: $tempValue, HashRate: $hashRateValue"
    Add-Content -Path "log.txt" -Value $messageWithDateTime
}

# Function to search for Bitaxe miners on the local network
function SearchForBitaxeMiners {
    # Get IP addresses assigned by the router
    $arpOutput = arp -a | Where-Object { $_ -match '192.168.1' } | ForEach-Object { ($_ -split '\s+')[1] }
    $ipAddresses = $arpOutput -split '\s+'

    # Define a list to store identified Bitaxe miners
    $bitaxeMiners = New-Object System.Collections.ArrayList

    # Wait time in seconds (adjustable as needed)
    $waitTime = 0.6

    # Iterate through each IP address assigned by the router
    foreach ($ipAddress in $ipAddresses) {
        CheckBitaxeMiner $ipAddress

        # Check if the desired number of Bitaxe devices has been reached
        if ($bitaxeMiners.Count -ge $num_miners) {
            break  # Exit the loop if enough devices have been found
        }
    }

    if ($bitaxeMiners.Count -lt $num_miners) {
        SendMessageTelegram "Error: Not enough Bitaxe devices found on the local network."
    }

    return $bitaxeMiners
}

function CheckBitaxeMiner([string]$ipAddress) {
        try {
            # Construct API URL for the current IP address
            $apiUrl = "http://$ipAddress/api/system/info"

            # Invoke REST API call with timeout
            $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method Get -TimeoutSec $waitTime -ErrorAction Stop

            # Check if the response contains ASICModel and capture its value
            if ($apiResponse -match '"ASICModel"\s*:\s*"BM.+?"') {
                # Add the current IP address to the list of identified Bitaxe miners
                [void]$bitaxeMiners.Add($ipAddress)
                Write-Output $ipAddress  # Only return the IP address

                # Check if the desired number of Bitaxe devices has been reached
                if ($bitaxeMiners.Count -ge $num_miners) {
                    return  # Exit the function if enough devices have been found
                }
            }

        } catch {
            # Handle any exceptions that occur during API calls
            # Write-Warning "Error connecting to IP: $ipAddress - Error: $($_.Exception.Message)"
        }
    }

# Initial search for Bitaxe miners
Write-Output "Searching for miners..."
$bitaxeMiners = SearchForBitaxeMiners

# Main loop
while ($true) {
    foreach ($ip_miner in $bitaxeMiners) {
        $successful_connection = $false
        try {
            # Attempt to retrieve system data from the URL
            $systemInfo = Invoke-RestMethod -Uri "$ip_miner/api/system/info" -TimeoutSec 120
            # Mark connection as successful if no errors occur while getting data
            $successful_connection = $true

            # Get "temp" and "hashRate" values directly from JSON string
            if ($systemInfo -match '"temp":\s*(\d+)') {
                $tempValue = [int]$matches[1]
            }

            if ($systemInfo -match '"hashRate":\s*([\d.]+)') {
                $hashRateValue = [int]$matches[1]
            }

            # Determine conditions for sending message to Telegram
            $message = ""
            if ($tempValue -lt $min_temp -or $tempValue -gt $max_temp) {
                $message += "<b>Temp: $tempValue</b>, HashRate: $hashRateValue"
            }

            if ($hashRateValue -lt $min_hashrate) {
                $message += "Temp: $tempValue, <b>HashRate: $hashRateValue</b>"
            }

            # Send message to Telegram if any condition is met
            if (-not [string]::IsNullOrWhiteSpace($message)) {
                SendMessageTelegram($message)
                # Search for Bitaxe miners before continuing with the loop
                Write-Output "Searching for miners..."
                $bitaxeMiners = SearchForBitaxeMiners
                Start-Sleep -Seconds (10 * $num_miners)
            } 
        } catch {
            # Display error message only if connection was not successful after 120 seconds
            if (-not $successful_connection) {
                Write-Host $ip_miner
                Write-Host "Error retrieving system data: Unable to connect to remote server."
            }
        }
    }

    # Get current date, time, and remote IP for displaying in console
    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $consoleMessage = "$ip_miner - $currentDateTime - Temp: $tempValue, HashRate: $hashRateValue"
   
    Write-Host $consoleMessage
    WriteToLog $ip_miner $tempValue $hashRateValue

    # Wait for specified time before next check
    Start-Sleep -Seconds $wait_time_seconds
}
