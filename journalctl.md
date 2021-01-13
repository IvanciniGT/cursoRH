# Journalctl
El comando journalctl permite ver los registros del diario. 

De forma predeterminada, las entradas enumeradas incluyen una marca de tiempo, el nombre de host, la aplicación que realizó la operación y el mensaje real.
```
$ journalctl
```
La salida del comando tiene el siguiente formato:
- Las entradas se muestran una página a la vez.
- Las marcas de tiempo se convierten a su zona horaria local.
- La prioridad de las entradas está marcada:  
  - Las entradas con prioridad de error y superior son rojas. 
  - Las entradas con prioridad de aviso y advertencia están en negrita.
- El inicio del proceso de arranque se indica con una entrada especial.

Cuando se ejecuta el comando journalctl sin opciones ni argumentos, se muestran todos los datos de registro, incluidos los registros rotados. 

Las entradas más antiguas se enumeran primero. 

## Opciones

### Mostrar primero las entradas de registro más recientes

```
$ journalctl -reverse
```

### Mantener abierto el log
```
journalctl --follow
```

### Mostrar un número específico de entradas de registro recientes
```
journalctl --lines 50
```

### Mostrar los logs desde el último boot
```
journalctl --boot 2
journalctl --boot
```
### Mostrar entradas desde/hasta una fecha
```
$ journalctl --since "2015-12-25 19:00:00"
$ journalctl --since yesterday
$ journalctl --since "2015-12-25" --until "2 hours ago"
```

### Mostrar logs de un usuario
```
journalctl _UID=$(id -u usuario)
```
### Mostrar logs de un proceso
```
journalctl _PID=1221
```
### Mostrar los logs del kernel
```
journalctl -k
journalctl -k -b 2
```
### Filtrado
```
journalctl --grep=PATRON --case-sensitive=1
```
### Mostrar entradas de registro de prioridad específica
```
# Las prioridades válidas son debug, info, notice, warning, err, crit, alert y emerg.
# 0: emerg
# 1: alert
# 2: critical
# 3: error
# 4: warning
# 5: notice
# 6: info
# 7: debug
$ journalctl --priority crit
```

### Mostrar las entradas del registro solo para la unidad systemd específica
```
$ journalctl --unit unidad
```

### Formateado de la salida
```
# Los formatos de salida válidos son short, short-iso, short-precis, short-monotonic, verbose, export, json, jsonpretty, json-see y cat.
$ journalctl -output verbose
```
### Otras opciones
--disk-use Muestra el uso total del disco de todos los archivos de diario
```
journalctl --disk-usage
```
--vacuum-size = BYTES Reduce el uso del disco por debajo del tamaño especificado

--vacuum-files = INT Deje solo el número especificado de archivos de diario

--vacuum-time = TIME Elimina los archivos de diario más antiguos que el tiempo especificado
```
$journalctl --vacuum-time=1years
```
--verify Verificar la consistencia del archivo de diario

--sync Sincroniza los mensajes del diario no escritos en el disco

--flush Vaciar todos los datos del diario de /run en /var

--rotate Solicita la rotación inmediata de los archivos de diario

## Persistencia
El log del sistema está configurado de forma predeterminada para almacenar registros solo en un pequeño búfer rotativo /run/log/journal, que no es persistente.

Los registros de la base de datos de diario no sobreviven al reinicio del sistema.

Configuración para almacenar persistentemente los registros de diario 
1. Crear una carpeta para el almacenado de los logs
```
mkdir -p /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
```
1. o cambiar la configuración del demonio journal
```
# sed -i 's/#Storage=auto/Storage=persistent/' /etc/systemd/journald.conf
```
3. Reiniciar el demonio
```
# systemctl restart systemd-journald.service
```
