# ROBOKIT-ANDROID-FLASHER

Proyecto **externo** al simulador. Objetivo: flashear los `.bin` del simulador
en un ESP32 **desde el celular por OTG**, sin PC. No toca ni depende de
ROBOKIT-SIMULADOR.

> Nota: la carpeta `ROBOKIT-ANDROID` estaba ocupada (era un clon del proyecto
> final Proyecto-Final-ADFS-y-DABD1), por eso esto vive aquí. Renómbrala si querés.

## Estado

Paso 1 de 1: **spike de diagnóstico WebUSB** (`index.html`).

No flashea nada todavía. Solo responde la pregunta cara:
**¿tu Android puede tomar el chip del ESP32 (CP2102/CH340) por OTG y reclamar su
interfaz USB?** Si eso pasa, el flasher completo es viable. Si no, hay que ir por
placa nativa (ESP32-S3/C3) o el plan .exe/PC.

## Qué necesitas

- Android con **Chrome** o **Edge** (Firefox y Samsung Internet NO sirven).
- Adaptador **OTG USB-C a USB-A hembra, con DATOS** (no de solo carga).
- El cable USB del ESP32 y la placa.
- La página servida por **HTTPS** (WebUSB no corre en `http://` ni `file://`).

## Cómo probarlo (con ngrok, que ya usas)

En la PC, dentro de esta carpeta:

```powershell
# 1) Servidor estático simple (Python)
python -m http.server 8080
```

En otra terminal:

```powershell
# 2) Túnel HTTPS público (ngrok termina el TLS -> WebUSB feliz)
ngrok http 8080
```

3. Abre en el **celular** la URL `https://...ngrok...` que te dé ngrok.
4. Conecta OTG -> cable -> ESP32.
5. Toca **"Conectar ESP32 conocido"**. Elige el dispositivo en el selector.
6. Lee el veredicto en pantalla (el log va explicando cada paso).

> Si no tienes Python: cualquier server estático sirve (`npx serve`,
> `php -S 0.0.0.0:8080`, etc.). Lo único que importa es que ngrok lo exponga por HTTPS.

## Cómo leer el resultado

- **SÍ SE PUEDE / claim OK** -> el data path USB está libre en tu teléfono.
  Seguimos al flasher real (WebUSB + esptool-js + mini-driver CP2102/CH340).
- **claim FALLÓ / lo tomó Android** -> el kernel reclama ese chip en tu equipo.
  Ese modelo no se flashea por WebUSB directo aquí; probar placa nativa o plan PC.
- **No se eligió dispositivo** -> el chip no aparece por OTG. Revisa que el OTG
  sea de datos y prueba **"Mostrar TODOS los dispositivos USB"**.

Manda captura del log y seguimos según lo que salga.

## Rumbo (para después del spike, si pasa)

1. Portar mini-driver del chip puente (CP2102/CH340) sobre WebUSB:
   control transfers de baudrate + líneas DTR/RTS (secuencia de reset/boot).
2. Puente `web-serial-polyfill` (o driver propio) -> alimentar a `esptool-js`.
3. Los `.bin` los sigue cocinando el backend del simulador (ya devuelve
   bootloader@0x1000, partitions@0x8000, app@0x10000). Esta app solo los flashea.

   ⚠️ **Los 10 `.bin` de `proyectos/` son de julio de 2026, ANTERIORES al rebrand
   a LEDKID.** `wifi_control_leds.bin` levanta la red `ROBOKIT-ESP32` con el
   nombre viejo compilado dentro; `proyectos.json` ya dice `LEDKID-ESP32`, que es
   lo que hace el firmware de hoy. **Hay que recocinarlos antes de que esto
   flashee de verdad**: si no, el alumno flashea, busca la red que le dice la
   pantalla y encuentra otra — y el sintoma parece un flasheo fallido.
4. Empaquetar como **PWA** instalable (manifest + service worker) con lista de
   programas: "abrir y flashear", como un visor de PDF.

## Qué NO es

- No es un `.exe`. No es app de Play Store. No es extensión de Chrome.
- Es una web con **WebUSB**, luego empaquetada como **PWA**. Solo Android.
- iPhone/iOS queda fuera (no tiene WebUSB en ningún navegador).
