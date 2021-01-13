# Firewalld
En el kernel de Linux existe un filtro de paquetes llamado NetFilter.
Iptables sirve para gestionar las reglas que utiliza dicho filtro.
Firewalld es un software que ofrece una capa por encima de iptables, facilitando la gestión de las reglas.

## Zonas de Firewalld:
Firewalld se base en zonas dinámicas.

Al ser dinámicas, está permitido crear, cambiar y eliminar las reglas sin la necesidad de reiniciar el demonio del firewall cada vez que se cambian las reglas.

Las zonas son conjuntos de reglas predefinidos. Las interfaces de red y las fuentes se pueden asignar a una zona. 

Las zonas predefinidas se almacenan en el directorio ```/usr/lib/firewalld/zones/``` y se pueden aplicar instantáneamente a cualquier interfaz de red disponible. Estos archivos se copian en el directorio ```/etc/firewalld/zones/``` solo después de que se modifican. 

La configuración predeterminada de las zonas predefinidas es la siguiente:

- ***block***
: Cualquier conexión de red entrante se rechaza con un mensaje IPv4icmp-host-forbidden para y icmp6-adm-forbidden para IPv6. Solo son posibles las conexiones de red iniciadas desde dentro del sistema.

- ***dmz***
: Para computadoras en su zona desmilitarizada que son de acceso público con acceso limitado a su red interna. Solo se aceptan las conexiones entrantes seleccionadas.

- ***drop***
: Los paquetes de red entrantes se descartan sin ninguna notificación. Solo son posibles las conexiones de red salientes.

- ***external***
: Para usar en redes externas con enmascaramiento habilitado, especialmente para enrutadores. No confía en que las otras computadoras de la red no dañen su computadora. Solo se aceptan las conexiones entrantes seleccionadas.

- ***home***
: Para usar en casa cuando confía principalmente en las otras computadoras de la red. Solo se aceptan las conexiones entrantes seleccionadas.

- ***internal***
: Para usar en redes internas cuando confía principalmente en las otras computadoras de la red. Solo se aceptan las conexiones entrantes seleccionadas.

- ***public***
: Para usar en áreas públicas donde no confía en otros equipos de la red. Solo se aceptan las conexiones entrantes seleccionadas.

- ***trusted***
: Se aceptan todas las conexiones de red.

- ***work***
: Para usar en el trabajo donde confía principalmente en las otras computadoras de la red. Solo se aceptan las conexiones entrantes seleccionadas.

Una de estas zonas está configurada como zona predeterminada. Cuando se agregan conexiones de interfaz a través de NetworkManager, se asignan a la zona predeterminada. En la instalación, la zona predeterminada en firewalld se establece como la zona ```public```. La zona predeterminada se puede cambiar.

Las zonas se pueden agregar, modificar y eliminar mediante la herramienta firewall-cmd.

Alternativamente, pueden editarse los archivos XML en el directorio ```/etc/firewalld/zones/```. 

Para ver los archivos de zona predeterminados, puede utilizarse el siguiente comando como root:

```
$ ls /usr/lib/firewalld/zones/
```

***Estos archivos no deben editarse***. Se utilizan de forma predeterminada si no existe un archivo equivalente en el directorio ```/etc/firewalld/zones/```.
Para ver los archivos de zona que han cambiado de los predeterminados, puede utilizarse el siguiente comando como root:

```
$ ls /etc/firewalld/zones/
```

Para editar el archivo predefinido de una zona, primero hay que copiarlo:

```
$ cp /usr/lib/firewalld/zones/work.xml /etc/firewalld/zones/
```

Ahora puede editarse el archivo en el directorio ```/etc/firewalld/zones/```. Si se elimina el archivo, firewalld volverá a utilizar el archivo predeterminado en /usr/lib/firewalld/zones/.

Para agregar un servicio a una zona, por ejemplo para permitir SMTP en una zona de trabajo, puede editarse el archivo XML de la zona añadiendo:

```
<service name = "smtp" />
```


## Servicios
Los servicios de firewall son reglas predefinidas que cubren todas las configuraciones necesarias para permitir el tráfico entrante para un servicio específico y se aplican dentro de una zona. 

Un servicio puede ser una lista de puertos, protocolos, puertos de origen y destinos locales que se cargan automáticamente si un servicio está habilitado. El uso de servicios ahorra tiempo a los usuarios porque pueden realizar varias tareas, como abrir puertos, definir protocolos, habilitar el reenvío de paquetes y más, en un solo paso, en lugar de configurar uno tras otro.

Los servicios se especifican por medio de archivos de configuración XML individuales, que son nombrados en el formato siguiente: ```service-name.xml```. En firewalld se prefieren los nombres de protocolo sobre los nombres de servicios o aplicaciones.

Los servicios se pueden agregar, modificar y eliminar mediante las herramienta firewall-cmd.

Alternativamente, pueden editarse los archivos XML en el directorio ```/etc/firewalld/services/```. 
Los archivos del directorio ```/usr/lib/firewalld/services/``` se pueden utilizar como plantillas si desea agregar o cambiar un servicio.

## Runtime vs Permanent
Firewalld dispone de 2 entornos de definición de reglas: Runtime y Permanent

Los cambios realizados en el runtime:
- No se almacenan de forma permanente implicitamente, hay que explicitarlo.
- Se aplican de forma inmediata.
Los cambios realizados en el Permanent:
- Se almacenan de forma permanente implicitamente.
- No se aplican de forma inmediata. Hay que cargarlos explicitamente.

Cualquier cambio realizado en el modo de ejecución solo se aplica mientras firewalld se está ejecutando. Cuando firewalld se reinicia, la configuración vuelve a sus valores permanentes.

Para que los cambios persistan entre reinicios, hay que aplicarlos usando la opcion ```--permanent```. 

Para que los cambios sean persistentes mientras firewalld se está ejecutando, se usa la opcion ```--runtime-to-permanent``` .

Si establece las reglas usando solo la opción ```--permanent``` mientras firewalld se está ejecutando, no se harán efectivas hasta que firewalld se reinicie. Sin embargo, reiniciar firewalld cierra todos los puertos abiertos y detiene el tráfico de red.

### Modificación de la configuración en tiempo de ejecución y configuración permanente mediante CLI.

Con la CLI, no es posible modificar la configuración del firewall en ambos modos al mismo tiempo. Solo se puede modifica el modo de ejecución o el permanente. 

Para modificar la configuración del firewall en el modo permanente, se usa la opcion --permanent.

```
$ firewall-cmd --permanent <otras opciones>
```

Sin esta opción, el comando modifica el modo de ejecución.

Para cambiar la configuración en ambos modos, puede utilizarse dos métodos:

1. Cambiar la configuración del tiempo de ejecución y luego hacerla permanente de la siguiente manera:

```
$ firewall-cmd <otras opciones>
$ firewall-cmd --runtime-to-permanent
```

2. Establecer la configuración permanente y recargar la configuración en el modo de ejecución:

```
$ firewall-cmd --permanent <otras opciones> 
$ firewall-cmd --reload
```
El primer método permite probar la configuración antes de aplicarla al modo permanente.


## Comandos útiles
### Instalación de firewalld
```
$ yum install firewall-config
```

### Estado del servicio
```
$ firewall-cmd --state
$ systemctl status firewalld
```

### Ayuda
```
$ firewall-cmd --help
```

### Configuración del firewall
```
# Muestra la zona por defecto
$ firewall-cmd --list-all

# Muestra una zona concreta
$ firewall-cmd --list-all --zone =public
```

### Inicio del servicio de firewalld
```
# Permite arrancar el servicio
$ systemctl unmask firewalld

# Arranca el servicio)
$ systemctl start firewalld

# Activa el autoarranque del servicio
$ systemctl enable firewalld
```

### Detención del servicio de firewalld
```
# Detiene el servicio
$ systemctl stop firewalld

# Desactiva el autoarranque del servicio
$ systemctl disable firewalld

# Impide el arranque del servicio
$ systemctl mask firewalld
```

### Verificar la configuración permanente del servicio firewalld:

```
$ firewall-cmd --check-config 
```

### Deshabilitar todo el trafico de red en caso de emergencia
```
$ firewall-cmd --panic-on
```

### Deshabilitar el modo panico
```
$ firewall-cmd --panic-off
```

### Comprobar el estado del modo pánico
```
$ firewall-cmd --query-panic
```

### Comprobar servicios permitidos
```
$ firewall-cmd --list-services 
```
### Enumerar todos los servicios definidos
```
$ firewall-cmd --get-services 
```
### Agregar un servicio a los servicios permitidos:
```
$ firewall-cmd --add-service=<nombre-servicio>
```
### Alta de un servicio
```
# Alta de un servicio en blanco
$ firewall-cmd --new-service=service-name --permanent

# Alta de un servicio desde un fichero
$ firewall-cmd --new-service-from-file=service-name.xml --name=new-service-name --permanent
```

### Configuración de un servicio
```
firewall-cmd --permanent --service=myservice --set-description=description
firewall-cmd --permanent --service=myservice --set-short=description
firewall-cmd --permanent --service=myservice --add-port=portid[-portid]/protocol
firewall-cmd --permanent --service=myservice --add-protocol=protocol
firewall-cmd --permanent --service=myservice --add-source-port=portid[-portid]/protocol
firewall-cmd --permanent --service=myservice --add-module=module
firewall-cmd --permanent --service=myservice --set-destination=ipv:address[/mask]
```

### Enumerar todos los puertos permitidos
```
$ firewall-cmd --list-ports
```
### Agregar un puerto a los puertos permitidos para abrirlo para el tráfico entrante:

```
$ firewall-cmd --add-port=número-puerto/tipo-puerto
```
### Quitar un puerto
```
$ firewall-cmd --remove-port=número-puerto/tipo-puerto
```

### Para ver qué zonas están disponibles
```
$ firewall-cmd --get-zones
```
### Para ver información detallada de todas las zonas
```
$ firewall-cmd --list-all-zones
```
### Para ver información detallada de una zona específica:
```
$ firewall-cmd --zone=nombre-zona --list-all
```

### Modificar una zona concreta
```
$ firewall-cmd --add-service=ssh --zone=public
```

### Zona predeterminada actual
```
$ firewall-cmd --get-default-zone
```

### Configurar una nueva zona predeterminada
```
$ firewall-cmd --set-default-zone zone-name
```

### Enumerar las zonas activas y las interfaces asignadas a ellas
```
$ firewall-cmd --get-active-zones
```
### Crear una nueva zona
```
$ firewall-cmd --new-zone=nombre-zona
```
### Enumerar el objetivo predeterminado de una zona
```
$ firewall-cmd --zone = nombre-zona --list-all
```
### Establezcer un nuevo objetivo en una zona
```
$ firewall-cmd --permanent --zone=zone-name --set-target =<default|ACCEPT|REJECT|DROP>
```

## Añadir un origen para una zona
```
$ firewall-cmd --zone=mizona --add-source=<origen-CIDR>
```
### Eliminar un origen para una zona
```
$ firewall-cmd --zone=nombre-zona --remove-source =<origen-CIDR>
```
## Añadir un puerto de origen
```
$ firewall-cmd --zone=nombre-zona --add-source-port=<nombre-puerto>/<tcp|udp|sctp|dccp>
```
## Añadir un puerto de origen hacia un destino
```
$ firewall-cmd --zone=nombre-zona --add-source-port=<nombre-puerto>/<tcp|udp|sctp|dccp> --add-source=<origen-CIDR>
```
### Eliminar un puerto de origen 
```
$ firewall-cmd --zone=nombre-zona --remove-source-port=<nombre-puerto>/<tcp|udp|sctp|dccp> 
```
### Agregar un protocolo a una zona
```
# Los protocolos están definidos en /etc/protocols
$ firewall-cmd --zone=nombre-zona --add-protocol=nombre-protocolo/tcp|udp|sctp|dccp|igmp
```
### Eliminar un protocolo de una zona
```
# Los protocolos están definidos en /etc/protocols
$ firewall-cmd --zone=nombre-zona --remove-protocol=nombre-protocolo/tcp|udp|sctp|dccp|igmp
```
### Enmascaramiento de direcciones
```
$ firewall-cmd --zone = external --query-masquerade
$ firewall-cmd --zone = external --add-masquerade
$ firewall-cmd --zone = external --remove-masquerade --permanent
```
### Reenvio de puertos
```
$ firewall-cmd --add-forward-port=port=número de puerto:proto=tcp|udp|sctp|dccp:toport=número de puerto
$ firewall-cmd --remove-forward-port=port=número de puerto:proto= <tcp|udp>:toport=número de puerto:toaddr=<IP>

```

### Para enumerar todos los tipos ICMP disponibles 
```
# Están definidas en el directorio /usr/lib/firewalld/icmptypes/
$ firewall-cmd --get-icmptypes
```
### Para ver para qué protocolo utiliza las solicitudes :
```
# firewall-cmd --info-icmptype = <icmptype>
```

### Para ver si una solicitud ICMP está bloqueada actualmente:
```
# firewall-cmd --query-icmp-block = <icmptype>
```
### Para bloquear una solicitud ICMP:
```
$ firewall-cmd --add-icmp-block = <icmptype>
```
### Para eliminar el bloqueo de una solicitud ICMP:
```
$ firewall-cmd --remove-icmp-block = <icmptype>
```

### Para consultar si el bloqueo del firewall está habilitado
```
$ firewall-cmd --query-lockdown
```
### Para habilitar el bloqueo
```
$ firewall-cmd --lockdown-on
```
###Para deshabilitar el bloqueo
```
$ firewall-cmd --lockdown-off
```
### Registro de paquetes denegados
```
$ firewall-cmd --get-log-denged
$ firewall-cmd --set-log-denied=all|unicast|broadcast|multicast|off
```

### Ver paquetes denegados
```
$ journalctl -x -e
```

### Añadir reglas enriquecidas
```
$ firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='180.76.15.0/24' reject"
```

### Mitigar ataques DoD
```
https://www.certdepot.net/rhel7-mitigate-http-attacks/
```
## Plantillas de archivos
### Archivo de zona:
```xml
<?xml version="1.0" encoding="utf-8"?> 
<zone> 
    <short>Mi zona</short> 
    <description>Detalle de la zona.<description> 
    <service name="http"/> 
    <port port="9090-9099" protocol="tcp"/> 
</zone>
```
### Bloqueos del firewall
```xml
<? xml version = "1.0" encoding = "utf-8"?> 
<whitelist> 
	  <command name = "/ usr / libexec / platform-python -s / bin / firewall-cmd *" /> 
	  <selinux context = " system_u: system_r: NetworkManager_t: s0 "/> 
	  <user id =" 815 "/> 
	  <user name =" user "/> 
</whitelist>
```


## Registrar paquetes rechazados en un archivo
1. Crear un nuevo archivo de configuración llamado /etc/rsyslog.d/firewalld-droppd.conf en el servidor
```
$ sudo vim /etc/rsyslog.d/firewalld-droppd.conf
```
2. Agregar la siguiente configuración
```
:msg,contains,"_DROP" /var/log/firewalld-droppd.log
:msg,contains,"_REJECT" /var/log/firewalld-droppd.log
& stop
```
```
$ sudo systemctl restart rsyslog.service
```
```
$ sudo tail -f /var/log/firewalld-droppd.log
```
