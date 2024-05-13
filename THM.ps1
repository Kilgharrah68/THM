#
# THM: Temperature Hash Monitor
#

# Define configuration variables
# Read the configuration file
$configFile = "config.txt"
$configData = Get-Content $configFile

# Parse configuration data from file
foreach ($line in $configData) {
    $key, $value = $line.Split('=').Trim()
    switch ($key) {
        "apikey" { $apikey = $value }
        "phone" { $phone = $value }
        "token" { $token = $value }
        "chat_id" { $chat_id = $value }
        "num_miners" { $num_miners = $value }
        "wait_time_seconds" { $wait_time_seconds = $value }
        "min_temp" { $min_temp = $value }
        "max_temp" { $max_temp = $value }
        "min_hashrate" { $min_hashrate = [int]$value }
    }
}

# Function to send message via WhatsApp
function SendMessageWhatsapp($message) {
    try {
        $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $messageWithDateTime = "$ip_miner - $currentDateTime - $message"
        $url = "https://api.callmebot.com/whatsapp.php?phone=$phone&text=$messageWithDateTime&apikey=$apikey"
       
        $body = @{
            chat_id = $chat_id
            text = $messageWithDateTime
            parse_mode = "HTML"
        }

        # Invoke REST API
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body

        if ($response -match "You will receive it in a few seconds") {
            Write-Host "Message sent successfully to WhatsApp."
            WriteToLog $ip_miner $tempValue $hashRateValue
        } else {
            Write-Host "Error sending message to WhatsApp: $response"
            WriteToLog "Error sending message to WhatsApp: $response"
        }
    } catch {
        Write-Host "Error sending message to WhatsApp: $_"
        WriteToLog "Error sending message to WhatsApp: $_"
    }
}

# Function to send message via Telegram
function SendMessageTelegram($message) {
    try {
        $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $messageWithDateTime = "$ip_miner - $currentDateTime - $message"
        $url = "https://api.telegram.org/bot$token/sendMessage"

        $body = @{
            chat_id = $chat_id
            text = $messageWithDateTime
            parse_mode = "HTML"
        }

        # Invoke REST API
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body

        if ($response.ok) {
            Write-Host "Message sent successfully to Telegram."
            WriteToLog $ip_miner $tempValue $hashRateValue
        } else {
            Write-Host "Error sending message to Telegram: $($response.error_code) - $($response.description)"
            WriteToLog "Error sending message to Telegram: $($response.error_code) - $($response.description)"
        }
    } catch {
        Write-Host "Error sending message to Telegram: $_"
        WriteToLog "Error sending message to Telegram: $_"
    }
}

# Function to write to log file
function WriteToLog($ip_miner, $tempValue, $hashRateValue) {
    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $messageWithDateTime = "$ip_miner - $currentDateTime - Temp: $tempValue, HashRate: $hashRateValue"
    Add-Content -Path "log.txt" -Value $messageWithDateTime
}

# Function to search for Bitaxe miners on the local network
function SearchForBitaxeMiners {
    $arpOutput = arp -a | Where-Object { $_ -match '192.168.1' } | ForEach-Object { ($_ -split '\s+')[1] }
    $ipAddresses = $arpOutput -split '\s+'

    # Define a list to store identified Bitaxe miners
    $bitaxeMiners = New-Object System.Collections.ArrayList
    $waitTime = 0.6

    foreach ($ipAddress in $ipAddresses) {
        CheckBitaxeMiner $ipAddress

        if ($bitaxeMiners.Count -ge $num_miners) {
            break
        }
    }

    if ($bitaxeMiners.Count -lt $num_miners) {
        SendMessageTelegram "Error: Not enough Bitaxe devices found on the local network."
    }

    return $bitaxeMiners
}

# Function to check Bitaxe miner status
function CheckBitaxeMiner([string]$ipAddress) {
    try {
        $apiUrl = "http://$ipAddress/api/system/info"
        $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method Get -TimeoutSec $waitTime -ErrorAction Stop

        if ($apiResponse -match '"ASICModel"\s*:\s*"BM.+?"') {
            [void]$bitaxeMiners.Add($ipAddress)

            if ($bitaxeMiners.Count -ge $num_miners) {
                return
            }
        }
    } catch {
        # Handle any exceptions that occur during API calls
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
            $systemInfo = Invoke-RestMethod -Uri "$ip_miner/api/system/info" -TimeoutSec 120
            $successful_connection = $true

            if ($systemInfo -match '"temp":\s*(\d+)') {
                $tempValue = [int]$matches[1]
            }

            if ($systemInfo -match '"hashRate":\s*([\d.]+)') {
                $hashRateValue = [int]$matches[1]
            }

            $messageT = ""
            $messageW = ""
            if ($tempValue -lt $min_temp -or $tempValue -gt $max_temp) {
                $messageT += "<b>Temp: $tempValue</b>, HashRate: $hashRateValue"
                $messageW += "_*Temp: $tempValue*_, HashRate: $hashRateValue"
            }

            if ($hashRateValue -lt $min_hashrate) {
                $messageT += "Temp: $tempValue, <b>HashRate: $hashRateValue</b>"
                $messageW += "Temp: $tempValue, _*HashRate: $hashRateValue*_"
            }

            if (($token -ne "" -and $chat_id -ne "") -and (-not [string]::IsNullOrWhiteSpace($messageT))) {
                SendMessageTelegram($messageT)
            }

            if (($apikey -ne "" -and $phone -ne "") -and (-not [string]::IsNullOrWhiteSpace($messageW))) {
                SendMessageWhatsapp($messageW)
            }

            Write-Output "Searching for miners..."
            $bitaxeMiners = SearchForBitaxeMiners
            Start-Sleep -Seconds (10 * $num_miners)
        } catch {
            # Handle errors
        }
    }

    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $consoleMessage = "$ip_miner - $currentDateTime - Temp: $tempValue, HashRate: $hashRateValue"
   
    Write-Host $consoleMessage
    WriteToLog $ip_miner $tempValue $hashRateValue

    Start-Sleep -Seconds $wait_time_seconds
}
