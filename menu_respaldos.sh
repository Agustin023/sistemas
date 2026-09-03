#!/bin/bash

# VARIABLES
opc=69
fecha=$(date +"%Y-%m-%d")

# FUNCIONES

function menu(){
    echo "========================================="
    echo "          GESTION DE RESPALDOS           "
    echo "========================================="
    echo "1 - Crear respaldo de BD"
    echo "2 - Crear respaldo de Logs del sistema"
    echo "3 - Restaurar respaldo de BD"
    echo "4 - Restaurar respaldo de Logs del sistema"
    echo "5 - Eliminar respaldo"
    echo "6 - Listar respaldos disponibles"
    echo "7 - Configurar programacion de respaldos"
    echo "8 - Enviar respaldo a ubicacion remota"
    echo "0 - Salir"
    echo "========================================="
}

function crear_respaldo_bd(){
    clear
    echo "Creando respaldo de la base de datos..."
    mkdir -p $carpeta_bd
    mysqldump -u root -p --databases cartas --routines --triggers --events > $fecha-cartas_bd_backup.sql
    mv $fecha-cartas_bd_backup.sql $carpeta_bd/
    echo "Respaldo de BD creado exitosamente."
    read -p "Presione ENTER para continuar..." pausa
}

function crear_respaldo_logs(){
    clear
    echo "Creando respaldo de los logs del sistema"
    mkdir -p $carpeta_logs
    tar -czvf $fecha-logs_sistema_backup.tar.gz /var/log
    mv $fecha-logs_sistema_backup.tar.gz $carpeta_logs/
    echo "Respaldo de logs creado exitosamente."
    read -p "Presione ENTER para continuar..." pausa
}

function restaurar_respaldo_bd(){
    clear
    echo "--- Restaurando respaldo de la base de datos ---"
    echo "Respaldos de BD guardados en el sistema:"
    ls -l $carpeta_bd/*.sql
    read -p "Ingrese el nombre del archivo de respaldo de BD a restaurar (ejemplo: 2026-09-11-cartas_bd_backup.sql): " respaldo_bd
    mysql -u root -p < $carpeta_bd/$respaldo_bd
    echo "Respaldo de BD restaurado exitosamente."
    read -p "Presione ENTER para continuar..." pausa
}

function restaurar_respaldo_logs(){
    clear
    echo "Restaurando respaldo de los logs del sistema"
    echo "Respaldos de logs guardados en el sistema:"
    ls -l $carpeta_logs/*.tar.gz
    read -p "Ingrese el nombre del archivo de respaldo de logs a restaurar (ejemplo: 2026-09-11-logs_sistema_backup.tar.gz): " respaldo_logs
    mkdir -p $carpeta_restaurados
    tar -xzvf $carpeta_logs/$respaldo_logs -C $carpeta_restaurados
    echo "Respaldo de logs restaurado exitosamente."
    read -p "Presione ENTER para continuar..." pausa
}

function eliminar_respaldo(){
    clear
    echo "Eliminando respaldo..."
    echo "Respaldos de BD disponibles:"
    ls -l $carpeta_bd/*.sql 2>/dev/null
    echo "Respaldos de logs disponibles:"
    ls -l $carpeta_logs/*.tar.gz 2>/dev/null
    read -p "Ingrese el nombre exacto del archivo a eliminar: " archivo_borrar
    rm -f $carpeta_bd/$archivo_borrar $carpeta_logs/$archivo_borrar
    echo "Respaldo eliminado exitosamente."
    read -p "Presione ENTER para continuar" pausa
}

function listar_respaldos(){
    clear
    echo "Listando respaldos disponibles"
    echo "Respaldos de BD:"
    ls -l $carpeta_bd/*.sql 2>/dev/null
    echo "Respaldos de logs del sistema:"
    ls -l $carpeta_logs/*.tar.gz 2>/dev/null
    read -p "Presione ENTER para continuar..." pausa
}

function configurar_programacion_respaldos(){
    clear
    echo "Configurando programacion de respaldos"
    crontab -e
    echo "Programacion de respaldos configurada exitosamente."
    read -p "Presione ENTER para continuar..." pausa
}

function enviar_respaldo_remoto(){
    clear
    echo "Enviando respaldo a ubicacion remota"
    read -p "Ingrese usuario@servidor: " destino_remoto
    read -p "Ingrese ruta remota destino: " ruta_remota
    read -p "Ingrese el archivo a enviar: " archivo_enviar
    scp $carpeta_bd/$archivo_enviar $destino_remoto:$ruta_remota
    echo "Respaldo enviado a ubicacion remota exitosamente."
    read -p "Presione ENTER para continuar..." pausa
}


# MAIN
while [ $opc -ne 0 ]
do
    menu
    read -p "Ingrese la opcion: " opc

    case $opc in
        1) crear_respaldo_bd ;;
        2) crear_respaldo_logs ;;
        3) restaurar_respaldo_bd ;;
        4) restaurar_respaldo_logs ;;
        5) eliminar_respaldo ;;
        6) listar_respaldos ;;
        7) configurar_programacion_respaldos ;;
        8) enviar_respaldo_remoto ;;
        0)
            clear
            echo "Saliendo del programa..."
            break ;;
        *)
            echo "[ERROR] Opcion incorrecta. Por favor ingrese un numero del 0 al 8."
            read -p "Presione ENTER para continuar..." pausa
        ;;
    esac
done
