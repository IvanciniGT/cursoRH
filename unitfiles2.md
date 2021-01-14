# Más plantillas de unit files
## Temporizador que se inicia 15 minutos después del arranque y después cada 2 dias mientras el sistema se está ejecutando.

[Unit]

Description=Me ejecuto cada 2 días y al arranque

[Timer]

OnBootSec=15min

OnUnitActiveSec=2d

[Install]

WantedBy=timers.target

## Temporizadores con una fecha/hora fija

[Unit]
Description=Me ejecuto cada minuto

[Timer]
OnCalendar=*:0/1

[Install]
WantedBy=timers.target

## Valores disponibles para OnCalendar

El formato de la fecha es DiaDeLaSemana Año-Mes-Día Hora:Minuto:Segundo. 

Se puede utilizar,

- * para indicar cualquier valor
valores separados por comas para indicar un listado de posibles
- .. para indicar un rango continuo de valores
- / seguido por un valor. Esto indica que se ejecutará en ese valor y en los múltiplos correspondientes. Así *:0/10 indica que se ejecutará cada 10 minutos.
- ~ indica el último día del mes. Por ejemplo, *-02~03 indica el tercer último dia del mes de febrero.

Ejemplos,

- OnCalendar=Mon,Tue *-*-01..04 12:00:00 indica que se ejecutará los cuatro primeros días de cada mes las 12 horas siempre y cuando sea lunes o martes.
- OnCalendar=*-*-* 20:00:00 se ejecutará todos los días a las 20 horas.
- OnCalendar=Mon..Fri *-*-* 20:00:00 se ejecutará de lunes a vierne a las 20 horas.
- OnCalendar=*-*-* *:0/15 ó OnCalendar=*:0/15 se ejecutará cada 15 minutos

Palabras especiales:

- OnCalendar=minutely → *-*-* *:*:00
- OnCalendar=hourly → *-*-* *:00:00
- OnCalendar=daily → *-*-* 00:00:00
- OnCalendar=monthly → *-*-01 00:00:00
- OnCalendar=weekly → Mon *-*-* 00:00:00
- OnCalendar=yearly → *-01-01 00:00:00
- OnCalendar=quarterly → *-01,04,07,10-01 00:00:00
- OnCalendar=semiannually → *-01,07-01 00:00:00

