#!/bin/bash

# Queremos un servicio que al iniciar el sistema arranque un contenedor
# Puede ser que el contendor no exista, en cuyo caso, tendríamos que arrancarlo
# El contendor tiene que tener montado un volumen
# Al parar el contenedor, se debe realizar una copia de sguridad del volumen generando un zip con la fecha.


# Tareas:
# - Asegurar la existencia del contenedor
# - Asegurar la existencia carpeta del volumen
# - crear contenedor
# - arranque del contenedor
# - Parada del contenedor
# - copia de seguridad del volumen

##Fichero .service
# [Service]
# ExecStart=----contenedor.sh --start
# ExecStop=----contenedor.sh --stop
# ExecRestart=----contenedor.sh --restart

### Llamada al script
# --start >>> arranque del contendor
# --stop >>> parada del contendor
# --restart >> parada del contendor + arranque
# --container-despription-file >> fichero.porperties

# contendor.sh --start --container-description-file nginx_container_conf
# contendor.sh --stop -c nginx_container_conf
# contendor.sh --restart -c -container-description-file=nginx_container_conf


function Asegurar_existencia_contendor(){
    # Crear_contedor
    local nombre_contenedor=$1
    local imagen_contenedor=$2
    local carpeta_volumen=$3
    local punto_montaje=$4
    local puerto=$5

    local existe=$(docker ps --all | grep -c $nombre_contenedor)
    

    if (( $existe == 0 )); then
        Crear_contedor \
            $nombre_contenedor \
            $imagen_contenedor \
            $carpeta_volumen \
            $punto_montaje \
            $puerto
    fi
}

function Asegurar_existencia_carpeta(){
    local carpeta=$1
    if [[ -f "$carpeta" ]]; then
        echo El nombre de la carpeta definida para el volumen, existe como fichero >&2
        echo El nombre de la carpeta es: $carpeta >&2
        echo NO se puede continuar >&2
        exit 1
    fi
    echo Carpeta indicada: $carpeta
    if [[ -d "$carpeta" ]]; then
        echo La carpeta ya existe. No hacemos nada.
    else
        echo La carpeta NO existe. Se procede a crearla
        mkdir -p $carpeta
        chmod 777 $carpeta
    fi
}

function Crear_contedor(){
    local nombre_contenedor=$1
    local imagen_contenedor=$2
    local carpeta_volumen=$3
    local punto_montaje=$4
    local puertos=$5
    local parametros_puertos=""

    for puerto in ${puertos[@]}
    do
        parametros_puertos="$parametros_puertos -p $puerto"
    done
    
    # echo Estos son los puertos: "$parametros_puertos"
    docker container create \
        --name $nombre_contenedor \
        $parametros_puertos \
        -v $carpeta_volumen:$punto_montaje \
        $imagen_contenedor
    
    local resultado=$?

    if (( $resultado > 0 )); then
        echo Error al crear el contenedor: $nombre_contenedor. >&2
        echo NO se puede continuar. >&2
        exit 2
    fi
    
    abrir_puertos "${puertos[@]}"
}

function abrir_puertos(){
    local puertos=( $1 )
    for puerto in ${puertos[@]}
        # Ojo que esto puede fallar.
        echo firewall-cmd --permanent --add-port=${puerto%:*}/tcp
        echo firewall-cmd --add-port=${puerto%:*}/tcp
}

function Iniciar_contenedor(){
    # Asegurar_existencia_contendor
    # Asegurar_existencia_carpeta
    local nombre_contenedor=$1
    local imagen_contenedor=$2
    local carpeta_volumen=$3
    local punto_montaje=$4
    local puerto=$5

    Asegurar_existencia_carpeta $carpeta_volumen
    
    Asegurar_existencia_contendor \
        $nombre_contenedor \
        $imagen_contenedor \
        $carpeta_volumen \
        $punto_montaje \
        $puerto

    docker start $nombre_contenedor

    local resultado=$?

    if (( $resultado > 0 )); then
        echo Error al iniciar el contenedor: $nombre_contenedor. >&2
        echo NO se puede continuar. >&2
        exit 5
    fi
}

function Parar_contenedor(){
    # Backup_volumen
    local nombre_contenedor=$1
    local carpeta=$2
    local carpeta_backup=$3
    
    docker stop $nombre_contenedor

    local resultado=$?

    if (( $resultado > 0 )); then
        echo Error al parar el contenedor: $nombre_contenedor. >&2
        echo NO se puede continuar. >&2
        exit 4
    fi
    # Aqui se pide hacer la copia de seguridad
    Backup_volumen "$carpeta" "$carpeta_backup"
}

function Backup_volumen(){
    local carpeta=$1
    local carpeta_backup=$2
    local fichero_backup=$(date +%d%m%Y).bck
    echo Generando copia de seguridad en la carpeta $carpeta_backup
    mkdir -p $carpeta_backup
    echo Fichero: $fichero_backup

    zip -r $carpeta_backup/$fichero_backup $carpeta
    
    local resultado=$?
    
    if (( $resultado > 0 )); then
        echo Error al realizar la copia de seguridad en: $carpeta_backup/$fichero_backup. >&2
        exit 3
    fi
}

fichero_de_configuracion=""
funcion_a_ejecutar=""

# Lectura de parametros de entrada del script
while [[ $# > 0 ]]
do
    case "$1" in 
        --start|-s) # El ) es el limitar de lo que tengo que bustar. Sintaxis del CASE
            # Código a ejcutar
            funcion_a_ejecutar=Iniciar_contenedor
        ;;
        --stop|-S)
            funcion_a_ejecutar=Parar_contenedor
        ;;
        --restart|-r)
            funcion_a_ejecutar=Reiniciar_contendor
        ;;
        --container-description-file|-c)
            fichero_de_configuracion=$2
            shift
        ;;
        --container-description-file=*|-c=*)
            fichero_de_configuracion=${1#*=}
            shift
        ;;
        *)
            echo Parametro $1 NO SOPORTADO >&2
            echo No se puede continuar >&2
            exit 100
        ;;
    esac
    shift
done

if [[ -z "$fichero_de_configuracion" ]]; then
    echo Debe indicar un fichero de fichero_de_configuracion. >&2
    echo NO se puede continuar. >&2
    exit 101
fi

if [[ ! -f "$fichero_de_configuracion" ]]; then
    echo El nombre proporcionado existe pero no es un fichero. >&2
    echo NO se puede continuar. >&2
    exit 102
fi

if [[ -z "$funcion_a_ejecutar" ]]; then
    echo No se ha indicado que operación hacer. >&2
    echo NO se puede continuar. >&2
    exit 103
fi

. $fichero_de_configuracion # tambien se puede reemplazar el punto por la palabra source

if [[ $funcion_a_ejecutar == "Iniciar_contenedor" ]]; then
    Iniciar_contenedor \
        $nombre_contenedor \
        $imagen_contenedor \
        $carpeta_volumen \
        $punto_montaje \
        "$puertos"
elif [[ $funcion_a_ejecutar == "Parar_contenedor" ]]; then
    Parar_contenedor \
        $nombre_contenedor \
        $carpeta_volumen \
        $carpeta_backup
fi

if [[ $funcion_a_ejecutar == "Reiniciar_contendor" ]]; then
    Parar_contenedor \
        $nombre_contenedor \
        $carpeta_volumen \
        $carpeta_backup
    Iniciar_contenedor \
        $nombre_contenedor \
        $imagen_contenedor \
        $carpeta_volumen \
        $punto_montaje \
        "$puertos"
fi