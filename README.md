# THM: Temperature Hash Monitor

<details>
<summary>English Description (click to expand)</summary>



## Description
THM (Temperature Hash Monitor) is a PowerShell script designed to monitor the temperature and hash rate of Bitaxe miners on a local network and send notifications via Telegram when certain conditions are met.

## Features
- **Temperature Monitoring**: THM continuously checks the temperature of connected Bitaxe miners.
- **Hash Rate Monitoring**: It also monitors the hash rate of the miners.
- **Telegram Notifications**: When the temperature exceeds predefined thresholds or the hash rate drops below a specified level, THM sends alerts via Telegram to notify the user.
- **Configurability**: You can customize various parameters such as temperature thresholds, hash rate minimums, and Telegram notification settings.

## Usage
1. **Configuration**: Before using THM, you need to configure the script by setting variables such as the Telegram bot token, chat ID, minimum and maximum temperature thresholds, minimum hash rate, etc.
2. **Execution**: You can run the script in a PowerShell environment. Additionally, if you want to run the script in a Windows environment without requiring PowerShell installed, you can convert the script to an executable using tools like PS2EXE.
3. **Monitoring**: THM continuously monitors connected Bitaxe miners for temperature and hash rate fluctuations.
4. **Alerts**: When abnormal conditions are detected (e.g., high temperature or low hash rate), THM sends alerts to the specified Telegram chat.

## How It Works
1. **Network Scanning**: THM scans the local network to identify connected Bitaxe miners using ARP tables.
2. **API Calls**: For each identified miner, THM makes API calls to obtain temperature and hash rate data.
3. **Condition Checking**: THM compares the obtained data with predefined thresholds to determine if an alert should be triggered.
4. **Telegram Notifications**: If abnormal conditions are detected, THM sends a notification via Telegram to inform you.

## Requirements
- PowerShell environment
- Bitaxe miners connected to the local network
- Access to a Telegram bot and its corresponding bot token and chat ID to receive notifications. To obtain the Telegram bot token, you need to create a bot using BotFather, a dedicated tool within the Telegram platform for managing bots.

## Migration to ESP32-2432S028R
Currently, I am exploring the possibility of migrating the THM program to a platform compatible with ESP32-2432S028R. If you are interested in contributing to the migration process or have experience with programming on the ESP32-2432S028R, I would love to have your help!

## Disclaimer
THM is provided as-is, without any warranties. You are responsible for configuring and using the script properly. Make sure to have the appropriate authorization to monitor devices on your network.

## Contributions
Contributions to THM are welcome. If you encounter any issues or have suggestions for improvements, feel free to open an issue or pull request on the GitHub repository.

## License
THM is released under the [MIT License](https://opensource.org/licenses/MIT). Feel free to modify and distribute according to the terms of the license.

</details>

<details>
<summary>Descripción en Español (haz clic para expandir)</summary>

## Descripción
THM (Temperature Hash Monitor) es un script de PowerShell diseñado para monitorear la temperatura y el hash rate de mineros Bitaxe en una red local y enviar notificaciones a través de Telegram cuando se cumplen ciertas condiciones.

## Características
- **Monitoreo de Temperatura**: THM verifica continuamente la temperatura de los mineros Bitaxe conectados.
- **Monitoreo de Hash Rate**: También monitorea el hash rate de los mineros.
- **Notificaciones de Telegram**: Cuando la temperatura excede los umbrales predefinidos o el hash rate cae por debajo de un nivel especificado, THM envía alertas a través de Telegram para notificar al usuario.
- **Configurabilidad**: Puedes personalizar varios parámetros como los umbrales de temperatura, los mínimos de hash rate y la configuración de notificación de Telegram.

## Uso
1. **Configuración**: Antes de usar THM, necesitas configurar el script estableciendo variables como el token del bot de Telegram, el ID del chat, los umbrales de temperatura mínimo y máximo, el hash rate mínimo, etc.
2. **Ejecución**: Puedes ejecutar el script en un entorno de PowerShell. Además, si deseas ejecutar el script en un entorno de Windows sin necesidad de PowerShell instalado, puedes convertir el script en un ejecutable usando herramientas como PS2EXE.
3. **Monitoreo**: THM monitorea continuamente los mineros Bitaxe conectados en busca de fluctuaciones de temperatura y hash rate.
4. **Alertas**: Cuando se detectan condiciones anormales (por ejemplo, alta temperatura o bajo hash rate), THM envía alertas al chat de Telegram especificado.

## Cómo Funciona
1. **Exploración de Red**: THM escanea la red local para identificar los mineros Bitaxe conectados utilizando las tablas ARP.
2. **Llamadas a la API**: Para cada minero identificado, THM realiza llamadas a la API para obtener datos de temperatura y hash rate.
3. **Verificación de Condiciones**: THM compara los datos obtenidos con umbrales predefinidos para determinar si se debe activar una alerta.
4. **Notificaciones de Telegram**: Si se detectan condiciones anormales, THM envía una notificación a través de Telegram para informarte.

## Requisitos
- Entorno de PowerShell
- Mineros Bitaxe conectados a la red local
- Acceso a un bot de Telegram y su token y ID de chat correspondientes para recibir notificaciones. Para obtener el token del bot de Telegram, necesitas crear un bot usando BotFather, una herramienta dedicada dentro de la plataforma de Telegram para administrar bots.

## Migración a ESP32-2432S028R
Actualmente, estoy explorando la posibilidad de migrar el programa THM a una plataforma compatible con la ESP32-2432S028R. Si estás interesado en contribuir al proceso de migración o tienes experiencia con la programación en la ESP32-2432S028R, ¡me encantaría contar con tu ayuda!

## Descargo de Responsabilidad
THM se proporciona tal cual, sin garantías de ningún tipo. Eres responsable de configurar y usar el script de manera adecuada. Asegúrate de tener la autorización adecuada para monitorear los dispositivos en tu red.

## Contribuciones
Las contribuciones a THM son bienvenidas. Si encuentras algún problema o tienes sugerencias de mejoras, no dudes en abrir un problema o enviar una solicitud de extracción en el repositorio de GitHub.

## Licencia
THM se publica bajo la [Licencia MIT](https://opensource.org/licenses/MIT). Siéntete libre de modificar y distribuir según los términos de la licencia.

</details>
