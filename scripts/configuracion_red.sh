#!/bin/bash

function asignar_configuracion_red(){
    local interfaz=$1
    local ip=$2
    local gateway=$3
    local dns=$4

    echo Configurando la red: $interfaz
    echo   Asignando la IP: $ip
    nmcli connection mod $interfaz ipv4.addresses $ip
    echo   Asignando el gateway: $gateway
    nmcli connection mod $interfaz ipv4.gateway $gateway
    nmcli connection mod $interfaz ipv4.method manual
    echo   Asignando los dns: $dns
    nmcli connection mod $interfaz ipv4.dns $dns
    echo Cambios realizados
}
function capturar_nombre_interfaz(){
    local only_active=$1
    local tipo=$2
    local active_param=""
    local contype="ethernet"
    if [[ only_active ]];then
        active_param="--active"
    fi
    if [[ -n "$tipo" ]];then
        contype=$tipo
    fi
    echo $(nmcli -f name,type con show $active_param | grep $contype | head -n 1 | cut -d' ' -f1)
}


fichero_configuracion=""
ip=""
dns=""
gateway=""
only_active=0
interfaz=""
tipo=""

# Lectura de parametros
while [[ $# > 0 ]]
do
    case "$1" in
        --only-actives|-a)
            only_active=1
        ;;
        --config-file|-c)
            fichero_configuracion=$2
            shift
        ;;
        --config-file=*|-c=*)
            fichero_configuracion=${1#*=}
        ;;
        --connection-type|-t)
            tipo=$2
            shift
        ;;
        --connnection-type=*|-t=*)
            tipo=${1#*=}
        ;;
        --ip|-i)
            ip=$2
            shift
        ;;
        --ip=*|-i=*)
            ip=${1#*=}
        ;;
        --connection|-c)
            interfaz=$2
            shift
        ;;
        --connection=*|-c=*)
            interfaz=${1#*=}
        ;;
        --gateway|-g)
            gateway=$2
            shift
        ;;
        --gateway=*|-g=*)
            gateway=${1#*=}
        ;;
        --dns|-d)
            dns=$2
            shift
        ;;
        --dns=*|-d=*)
            dns=${1#*=}
        ;;
        *)
            echo Parametro no soportado: $1 >&2
            echo No se puede continuar >&2
            exit 100
        ;;
    esac
    shift
done


if [[ -z "$fichero_configuracion" ]];then
    if [[ -z "$ip" || -z "$gateway" || -z "$dns" ]];then
        echo Debe dar un fichero de configuración o las configuraciones correspondientes.>&2
        echo No se puede continuar >&2
        exit 101
    fi
elif [[ ! -f "$fichero_configuracion" ]];then
    echo El fichero de configuración no es válido.>&2
    echo No se puede continuar >&2
    exit 102
else
    echo Leyendo el fichero de configuración
    . $fichero_configuracion   # tambien se puede reemplazar el punto por la palabra source  
fi

if [[ -z "$interfaz" ]];then
    echo Obteniendo el nombre de la conexión de tipo ethernet
    interfaz=$(capturar_nombre_interfaz $only_active $tipo)
    echo   La conexión que se modificará es: $interfaz
fi
# Encapsulación: Que cada función maneje sus propias variables, 
# no dependa de variables globales
asignar_configuracion_red $interfaz $ip $gateway $dns

