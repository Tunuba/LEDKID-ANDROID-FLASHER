@echo off
REM Levanta el spike WebUSB y lo expone por HTTPS con ngrok.
REM Uso: doble clic. Abre 2 ventanas (server + ngrok). Cierra ambas para parar.
cd /d "%~dp0"

echo Levantando servidor estatico en http://localhost:8080 ...
start "RoboKit Flasher - server" cmd /k python -m http.server 8080

timeout /t 2 /nobreak >nul

echo Abriendo tunel HTTPS con ngrok ...
start "RoboKit Flasher - ngrok" cmd /k ngrok http 8080

echo.
echo Listo. Busca la URL https://...ngrok... en la ventana de ngrok
echo y abrela en Chrome de tu celular (con el OTG conectado).
echo.
pause
