# Systemd 
Es un gestor de sistemas y servicios para sistemas operativos Linux. 
Está diseñado para ser compatible con scripts init de SysV y proporciona una serie de características, como:
- el inicio paralelo de los servicios del sistema en el momento del arranque
- la activación a petición de demonios
- la lógica de control de servicio basada en dependencias. 

A partir de Red Hat Enterprise Linux 7, systemd reemplazó a Upstart como sistema de inicio predeterminado. 

## Unidades (Units)
‎Systemd introduce el concepto de unidades.‎‎ 

### Ubicación de los ficheros de unidades
Estas unidades se representan mediante archivos de configuración ubicados en uno de los directorios siguientes: 

-***/usr/lib/systemd/system/***
:‎ Archivos de unidad Systemd distribuidos con paquetes RPM instalados. 

-***/run/systemd/system/***
:‎ Archivos de unidad Systemd creados en tiempo de ejecución. Este directorio tiene prioridad sobre el directorio con los archivos de unidad de servicio instalados. 

***/etc/systemd/system/***
:‎ Archivos de unidad Systemd creados adhoc. Este directorio tiene prioridad sobre el directorio con archivos de unidad en tiempo de ejecución.

### Tipos de unidades
‎- ***Servicio*** (.service)
:‎ Un servicio del sistema. 

- ***Unidad objetivo*** (.target)
:‎ Un grupo de unidades systemd. 

- ***Unidad de montaje automático*** (.automount)
:‎ Un punto de montaje automático del sistema de archivos. 

‎- ***Unidad de dispositivo*** (.device)
:‎ Un archivo de dispositivo reconocido por el kernel. 

‎- ***Unidad de montaje*** (.mount)
:‎ Un punto de montaje del sistema de archivos. 

‎- ***Unidad de ruta*** (.path)
:‎ Un archivo o directorio en un sistema de archivos. 

‎- ***Unidad de alcance*** (.scope)
:‎ Un proceso creado externamente. 

‎- ***Unidad de corte*** (.slice)
:‎ Un grupo de unidades organizadas jerárquicamente que gestionan los procesos del sistema. 

‎- ***Unidad de socket*** (.socket)
:‎ Un socket de comunicación entre procesos. 

‎- ***Unidad de intercambio*** (.swap)
:‎ Un dispositivo de intercambio o un archivo de intercambio. 

‎- ***Unidad de temporizador*** (.timer)
:‎ Un temporizador systemd. 

## Características del systemd
-‎ Activación basada en sockets:‎‎  en el momento del arranque, systemd‎‎ crea sockets de escucha para todos los servicios del sistema que admiten este tipo de activación y pasa los sockets a estos servicios tan pronto como se inician. Esto no sólo permite que systemd‎‎ inicie servicios en paralelo, sino que también permite reiniciar un servicio sin perder ningún mensaje que se le envíe mientras no está disponible: el socket correspondiente permanece accesible y todos los mensajes están en cola.‎

-‎ Activación basada en bus:‎‎  los servicios del sistema que utilizan D-Bus para la comunicación entre procesos se pueden iniciar a petición la primera vez que una aplicación cliente intenta comunicarse con ellos. 

-‎ Activación basada en dispositivos:‎‎  los servicios del sistema que admiten la activación basada en dispositivos se pueden iniciar a petición cuando un tipo determinado de hardware está conectado o está disponible. 
-‎ Activación basada en rutas‎‎  de acceso: los servicios del sistema que admiten la activación basada en rutas de acceso se pueden iniciar a petición cuando un archivo o directorio determinado cambia su estado. 

-‎ Gestión de puntos de montaje y montaje automático:‎‎ Systemd‎‎ 
supervisa y gestiona los puntos de montaje y montaje automático.

-‎‎Paralelización agresiva‎‎‎‎: Debido al uso de la activación basada en socket, systemd‎‎ puede iniciar los servicios del sistema en paralelo tan pronto como todos los sockets de escucha estén en su lugar. En combinación con los servicios del sistema que admiten la activación a petición, la activación en paralelo reduce significativamente el tiempo necesario para arrancar el sistema. 

-‎ Lógica de activación de unidad transaccional:‎‎  antes de activar o desactivar una unidad, systemd‎ calcula sus dependencias, crea una transacción temporal y comprueba que esta transacción es coherente. Si una transacción es incoherente, systemd‎‎ intenta corregirla automáticamente y quitarle trabajos no esenciales antes de notificar un error.

 -‎ Compatibilidad con sysV init: Systemd‎‎ admite scripts de inicio de SysV como se describe en la especificación de núcleo base estándar de Linux,‎‎lo que facilita la ruta de actualización a las unidades de servicio systemd.‎

 ## Gestión de servicios
Antiguamente, Red Hat Enterprise Linux, se distribuía con SysV init o Upstart, y utilizaban init scripts. Estos init scripts se escribían normalmente en Bash y permitían al administrador del sistema controlar el estado de los servicios y demonios en su sistema. 

A partir de Red Hat Enterprise Linux 7, estos scripts init se han reemplazado por unidades de servicio. 

Las unidades de servicio terminan con la extensión de archivo .service y sirven un propósito similar a los antiguos scripts init. 

Para ver, iniciar, detener, reiniciar, habilitar o deshabilitar los servicios del sistema, utilice el comando systemctl.

- Inicia un servicio.
```
systemctl start name.service
```
- Detiene un servicio.
```
systemctl stop name.service
```
- Reinicia un servicio.
```
systemctl restart name.service
```
- Reinicia un servicio solo si se está ejecutando.
```
systemctl try-restart name.service
```
- Recarga la configuración. Esta opción no siempre está disponible (systemctl reload-or-restart | reload-or-try-restart)
```
systemctl reload name.service
```
- Comprueba si se está ejecutando un servicio.
```
systemctl status name.service
systemctl is-active name.service
```
- Muestra el estado de todos los servicios.
```
systemctl list-units --type service --all
```

- Habilita un servicio.
```
systemctl enable name.service
systemctl reenable name.service
```

- Deshabilita un servicio.
```
systemctl disable name.service
```

- Comprueba si un servicio está habilitado.
```
systemctl status name.service
systemctl is-enabled name.service
```

- Enumera todos los servicios y comprueba si están habilitados.
```
systemctl list-unit-files --type service
```

- Enumera los servicios que se ordenan para iniciarse antes de la unidad especificada.
```
systemctl list-dependencies --after
```

- Enumera los servicios que se ordenan para iniciarse después de la unidad especificada.
```
systemctl list-dependencies --before
```
- Alias de una unidad de servicio
```
systemctl show nfs-server.service -p Names
```
- Enmascarar un servicio
```
systemctl mask name.service
```
- Desenmascarar un servicio
```
systemctl unmask name.service
```



# Targets Systemd
Antes, Red Hat Enterprise Linux se distribuía con SysV init o Upstart, e implementaban un conjunto predefinido de niveles de ejecución que representaban modos de operación específicos. 

Estos niveles de ejecución se numeraron de 0 a 6 y se definieron mediante una selección de servicios del sistema que se ejecutaban cuando el administrador del sistema habilitara un nivel de ejecución determinado. 

A partir de Red Hat Enterprise Linux 7, el concepto de niveles de ejecución se ha reemplazado por targets systemd.

- runlevel0.target, poweroff.target (0)
: Apaga el sistema.

- runlevel1.target, rescue.target (1)
: Prepara un entorno de rescate.

- runlevel2.target, multi-user.target (2)
: Configura un sistema multiusuario no gráfico.

- runlevel3.target, multi-user.target (3)
: Configura un sistema multiusuario no gráfico.

- runlevel4.target, multi-user.target (4)
: Configura un sistema multiusuario no gráfico.

- runlevel5.target, graphical.target (5)
: Configura un sistema gráfico multiusuario.

- runlevel6.target, reboot.target (6)
: Apagua y reinicia el sistema

### Target por defecto
```
systemctl get-default
systemctl set-default multi-user.target
```
### Enumerar todas las unidades cargadas independientemente de su estado:
```
systemctl list-units --type target --all
```
### Cambiar a otro target en la sesión actual
```
systemctl isolate multi-user.target
```
### Cambiar al modo de rescate del sistema
```
systemctl rescue
systemctl --no-wall rescue
systemctl isolate rescue.target
```

### Modo de emergencia
El modo de emergencia proporciona el entorno más mínimo posible y permite reparar el sistema incluso en situaciones en las que el sistema no puede entrar en modo de rescate. 

En el modo de emergencia, el sistema monta el sistema de archivos raíz sólo para la lectura, no intenta montar ningún otro sistema de archivos local, no activa las interfaces de red y sólo inicia unos pocos servicios esenciales.

Para cambiar el objetivo actual y entrar en el modo de emergencia:
```
systemctl emergency
systemctl --no-wall emergency
systemctl isolate emergency.target
```


### Apagar, suspender e hibernar el sistema

Detiene el sistema.
```
systemctl halt
```

Apaga el sistema.
```
systemctl poweroff
poweroff
systemctl --no-wall poweroff
shutdown --poweroff hh:mm
shutdown --halt +m
shutdown -c # Cancelar apagado
```

Reinicia el sistema.
```
reboot
systemctl reboot
```

Suspende el sistema.
```
pm-suspend
systemctl suspend
```

Hiberna el sistema.
```
pm-hibernate
systemctl hibernate
```

Hiberna y suspende el sistema.
```
pm-suspend-hybrid
systemctl hybrid-sleep
