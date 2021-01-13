#!/bin/bash
######
# Queremos un servicio que al iniciar el sistema, arranque un contenedor
# Pero puede ser que el contenedor no exista, en cuyo caso, tendríamos que crearlo
# El contenedor va a tener montado un volumen
# Al parar el contenedor, se debe hacer una copia de seguridad del volumen, 
# generando un fichero zip, tar.gz con la fecha del backup

function asegurar_existencia_contenedor(){
    local nombre_contenedor=$1
    local imagen_contenedor=$2
    local carpeta_del_volumen_host=$3
    local carpeta_del_volumen_en_contenedor=$4
    local puertos=$5

    local existe=$(sudo docker ps --all | grep -c $nombre_contenedor)
    
    if (( $existe == 0 ));then
        crear_el_contenedor \
                $nombre_contenedor \
                $imagen_contenedor \
                $carpeta_del_volumen_host \
                $carpeta_del_volumen_en_contenedor \
                "$puertos"  
    fi

}

function asegurar_existencia_carpeta_del_volumen(){
    local carpeta=$1
    
    if [[ -f "$carpeta" ]]; then
        echo La carpeta de volumen definida, ya existe y es un fichero. >&2
        echo Carpeta indicada: $carpeta >&2
        echo No se puede continuar. >&2
        exit 1 # No 
    fi
    echo Carpeta indicada: $carpeta
    
    if [[ -d "$carpeta" ]]; then
        echo La carpeta ya existe. No hacemos nada.
    else
        echo La carpeta no existe. Procediendo a su creación.
        mkdir -p $carpeta
        chmod 777 $carpeta
    fi
}

function crear_el_contenedor(){
    local nombre_contenedor=$1
    local imagen_contenedor=$2
    local carpeta_del_volumen_host=$3
    local carpeta_del_volumen_en_contenedor=$4
    local puertos=( $5 )
    local parametros_puertos=""

    # puertos               => parametros_puertos
    # "8080:8080 8443:8443" => " -p 8080:8080 -p 8443:8443"
    for puerto in ${puertos[@]}
    do
        parametros_puertos="$parametros_puertos -p $puerto"
    done

    echo Creando contenedor
    docker container create \
        --name $nombre_contenedor \
        $parametros_puertos \
        -v $carpeta_del_volumen_host:$carpeta_del_volumen_en_contenedor \
        $imagen_contenedor

    local resultado=$?
    if (( $resultado > 0 ));then
        echo Error al crear el contenedor: $nombre_contenedor. >&2
        echo No se puede continuar. >&2
        exit 2 # No 
    fi
    echo Contenedor creado

}

function arranque_del_contenedor(){
    local nombre_contenedor=$1
    local imagen_contenedor=$2
    local carpeta_del_volumen_host=$3
    local carpeta_del_volumen_en_contenedor=$4
    local puertos=$5

    asegurar_existencia_carpeta_del_volumen $carpeta_del_volumen_host
    
    asegurar_existencia_contenedor \
                $nombre_contenedor \
                $imagen_contenedor \
                $carpeta_del_volumen_host \
                $carpeta_del_volumen_en_contenedor \
                "$puertos"

    echo Arrancando contenedor
    docker start $nombre_contenedor 

    local resultado=$?
    if (( $resultado > 0 ));then
        echo Error al iniciar el contenedor: $nombre_contenedor. >&2
        echo No se puede continuar. >&2
        exit 5
    fi    
    echo Contenedor arrancado 
}

function copia_de_seguridad_del_volumen(){
    local carpeta=$1
    local carpeta_backups=$2
    local fecha=$(date +%d%m%Y-%M%S)
    local fichero_backup=$carpeta_backups/$fecha.log

    echo Generando copia de seguridad de la carpeta: $carpeta
    mkdir -p $carpeta_backups
    echo   Fichero de destino: $fichero_backup
    
    zip -r $fichero_backup $carpeta
    
    if (( $? > 0 )); then
        echo Error al crear la copia de seguridad. >&2
        echo No se puede continuar. >&2
        exit 3 
    else
        echo Copia de seguridad generada
    fi
}

function parada_del_contenedor(){
    # Aqui paras el contenedor 
    local nombre_contenedor=$1
    local carpeta=$2
    local carpeta_backups=$3
    
    echo Parando el contenedor
    docker stop $nombre_contenedor

    local resultado=$?
    if (( $resultado > 0 ));then
        echo Error al detener el contenedor: $nombre_contenedor. >&2
        echo No se puede continuar. >&2
        exit 4
    fi    
    echo Contenedor parado
    # Aquí pido hacer la copia de seguridad
    copia_de_seguridad_del_volumen "$carpeta" "$carpeta_backups"
}

### Fichero .service
# [Service]
# ExecStart=.....contenedor.sh --start
# ExecStop=.....contenedor.sh --stop
# ExecRestart=.....contenedor.sh --restart

### Llamada al script
# --start >>>   arranque_del_contenedor
# --stop >>>    parada_del_contenedor
# --restart >>> parada_del_contenedor + arranque_del_contenedor
# --container-description-file >>> fichero.properties

# contenedor.sh --start --container-description-file nginx_container.conf
# contenedor.sh --container-description-file nginx_container.conf --start
# contenedor.sh --stop -c nginx_container.conf
# contenedor.sh --restart --container-description-file=nginx_container.conf

funcion_a_ejecutar=""
fichero_configuracion=""
# Lectura de parametros
while [[ $# > 0 ]]
do
    case "$1" in
        --start|-s)
            funcion_a_ejecutar=arranque_del_contenedor
        ;;
        --stop|-S)
            funcion_a_ejecutar=parada_del_contenedor
        ;;
        --container-description-file|-c)
            fichero_configuracion=$2
            shift
        ;;
        --container-description-file=*|-c=*)
            fichero_configuracion=${1#*=}
        ;;
        *)
            # ./contenedor.sh --fuerza-reinicio
            echo Parametro no soportado: $1 >&2
            echo No se puede continuar >&2
            exit 100
        ;;
    esac
    shift
done


# ¿Qué pasa si no me han dado fichero o función a ejecutar?????
if [[ -z "$fichero_configuracion" ]];then
    echo Debe dar un fichero de configuración.>&2
    echo No se puede continuar >&2
    exit 101
fi
if [[ ! -f "$fichero_configuracion" ]];then
    echo El fichero de configuración no es válido.>&2
    echo No se puede continuar >&2
    exit 102
fi
if [[ -z "$funcion_a_ejecutar" ]];then
    echo No se ha indicado que operación hacer: --start | --stop .>&2
    echo No se puede continuar >&2
    exit 103
fi
. $fichero_configuracion   # tambien se puede reemplazar el punto por la palabra source  
# Basicamente esta instrucción me daría acceso a las siguientes variables:
#nombre_contenedor=mi_nginx
#imagen_contenedor=nginx
#carpeta_del_volumen_host=/datos/nginx
#carpeta_del_volumen_en_contenedor=/datos
#puertos=80:8080
#carpeta_backups=/datos/backups/nginx

if [[ $funcion_a_ejecutar == "arranque_del_contenedor" ]];then
    arranque_del_contenedor $nombre_contenedor \
                            $imagen_contenedor \
                            $carpeta_del_volumen_host \
                            $carpeta_del_volumen_en_contenedor \
                            "$puertos"
elif [[ $funcion_a_ejecutar == "parada_del_contenedor" ]];then
    parada_del_contenedor $nombre_contenedor \
                            $carpeta_del_volumen_host \
                            $carpeta_backups
fi

### sudo ./contenedor.sh -S -c mi_nginx.conf
