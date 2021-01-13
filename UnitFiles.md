# Ficheros unit
## Seccion [Unit]
### Description
Descripción significativa de la unidad. Este texto se muestra en la salida del comando systemctl status.

### Documentation

Proporciona una lista de URI que hacen referencia a la documentación de la unidad.

### After
Define el orden en que se inician las unidades. 

La unidad se inicia solo después de que las unidades especificadas en After estén activas. 

A diferencia Requires, After no activa explícitamente las unidades especificadas. 

La opción Before tiene la funcionalidad opuesta a After.

### Requires
Configura dependencias de otras unidades. 

Las unidades enumeradas en Requires se activan junto con la unidad. 

Si alguna de las unidades requeridas no se inicia, la unidad no se activa.

### Wants
Configura dependencias más débiles que Requires. 

Si alguna de las unidades enumeradas no se inicia correctamente, no tiene ningún impacto en la activación de la unidad. 

Ésta es la forma recomendada de establecer dependencias de unidades personalizadas.

### Conflicts
Configura dependencias negativas, un opuesto a Requires.

## Seccion [Service]
### Type
Configura el tipo de inicio del proceso de la unidad que afecta la funcionalidad ExecStarty las opciones relacionadas. Uno de:

* simple: El valor predeterminado. El proceso con el que se inició es el proceso principal del servicio.

* forking: El proceso iniciado genera un proceso hijo que se convierte en el proceso principal del servicio. El proceso principal finaliza cuando se completa el inicio.

* oneshot: Este tipo es similar a simple, pero el proceso finaliza.

* dbus: Este tipo es similar a simple, pero las unidades consiguientes se inician solo después de que el proceso principal obtiene un nombre D-Bus.

* notify: Este tipo es similar a simple, pero las unidades consiguientes se inician solo después de que se envía un mensaje de notificación mediante la función sd_notify ().

* idle: similar a simple, la ejecución real del binario del servicio se retrasa hasta que se terminan todos los trabajos, lo que evita mezclar la salida de estado con la salida de shell de los servicios.

### ExecStart
Especifica comandos o scripts que se ejecutarán cuando se inicie la unidad. 

ExecStartPre y ExecStartPost permiten especificar comandos personalizados que se ejecutarán antes y después ExecStart. 

En combinación con Type=oneshot, se pueden especificar varios comandos que se ejecutan secuencialmente.

### ExecStop
Especifica comandos o scripts que se ejecutarán para detener la unidad.

### ExecReload
Especifica comandos o scripts que se ejecutarán para  recargar la unidad.

### Restart
Con esta opción habilitada, el servicio se reinicia después de que finaliza su proceso, con la excepción de una parada limpia por parte del comando systemctl.

### RemainAfterExit
Si se establece en True, el servicio se considera activo incluso cuando todos sus procesos salieron. El valor predeterminado es Falso. Esta opción es especialmente útil si Type=oneshotestá configurada.

### TimeoutSec
La cantidad de tiempo que systemdesperará al detener o detener el servicio antes de marcarlo como fallado o matarlo por la fuerza. También se puede establecer tiempos de espera separados con TimeoutStartSec y TimeoutStopSec

## Seccion [Timer]
Unidades de temporizador que se utilizan para programar tareas para que funcionen en un momento específico o después de un cierto retraso. 

Este tipo de unidad reemplaza o complementa algunas de las funciones de los demonios cron y at. 

Se debe proporcionar una unidad asociada que se activará cuando se alcance el temporizador.


### OnActiveSec
Esta directiva permite que la unidad asociada se active en relación con la .timeractivación de la unidad.
### OnBootSec
Esta directiva se utiliza para especificar la cantidad de tiempo después de que se inicia el sistema cuando se debe activar la unidad asociada.
### OnStartupSec
Esta directiva es similar al temporizador anterior, pero en relación con el momento systemden que se inició el proceso.
### OnUnitActiveSec
Establece un temporizador según la última vez que se activó la unidad asociada.
### OnUnitInactiveSec
Esto establece el temporizador en relación con la última vez que la unidad asociada se marcó como inactiva.
### OnCalendar
Esto le permite activar la unidad asociada especificando un absoluto en lugar de relativo a un evento.
### AccuracySec
Esta unidad se utiliza para establecer el nivel de precisión con el que se debe cumplir el temporizador. De forma predeterminada, la unidad asociada se activará dentro de un minuto después de que se alcance el temporizador. El valor de esta directiva determinará los límites superiores de la ventana en la que systemd programa la activación para que ocurra.
### Unit
Esta directiva se utiliza para especificar la unidad que debe activarse cuando transcurre el temporizador. Si no está configurado, systemd buscará una unidad .service con un nombre que coincida con esta unidad.
### Persistent
Si está configurado, systemd activará la unidad asociada cuando el temporizador se active si se hubiera activado durante el período en el que el temporizador estuvo inactivo.
### WakeSystem
Establecer esta directiva le permite reactivar un sistema desde la suspensión si se alcanza el temporizador en ese estado.

## Seccion [Path]
Una unidad de ruta define una ruta del sistema de archivos que es monitorizada. 

Debe existir otra unidad que se activará cuando se detecte cierta actividad en la ubicación de la ruta. 

### PathExists
Esta directiva se utiliza para comprobar si existe la ruta en cuestión. Si lo hace, se activa la unidad asociada.
### PathExistsGlob
Es lo mismo que el anterior, pero admite expresiones globales de archivos para determinar la existencia de la ruta.
### PathChanged
Observa la ubicación de la ruta en busca de cambios. La unidad asociada se activa si se detecta un cambio cuando se cierra el archivo observado.
### PathModified
Esto observa cambios como la directiva anterior, pero se activa en las escrituras de archivos, así como cuando se cierra el archivo.
### DirectoryNotEmpty
Esta directiva permite activar la unidad asociada cuando el directorio ya no está vacío.
### Unit
Esto especifica la unidad que se activará cuando se cumplan las condiciones de ruta especificadas anteriormente. Si se omite, systemd buscará un archivo .service que comparta el mismo nombre de unidad base que esta unidad.
### MakeDirectory
Esto determina si systemdse creará la estructura de directorio de la ruta en cuestión antes de ver.
### DirectoryMode
Si lo anterior está habilitado, esto establecerá el modo de permiso de cualquier componente de ruta que deba crearse.

## Seccion Install
### Alias
Proporciona una lista separada por espacios de nombres adicionales para la unidad. La mayoría de los comandos, (excluido systemctl enable), pueden utilizar alias en lugar del nombre real de la unidad.

### RequiredBy

Una lista de unidades que dependen de la unidad. Cuando esta unidad está habilitada, las unidades enumeradas en RequiredBy ganan una dependencia Required de la unidad.

### WantedBy

Una lista de unidades que dependen débilmente de la unidad. Cuando esta unidad está habilitada, las unidades enumeradas en WantedBy ganan una dependencia Want de la unidad.

### Also

Especifica una lista de unidades que se instalarán o desinstalarán junto con la unidad.

## Ejemplo de fichero
### Plantilla de fichero de servicio
```
[Unit]

Description=service_description

After=network.target httpd.service

[Service]

ExecStart=path_to_executable

ExecReload=path_to_executable

ExecStop=path_to_executable

Type=forking

PIDFile=path_to_pidfile

KillMode=process

Restart=on-failure

RestartSec=42s

[Install]

WantedBy=default.target

