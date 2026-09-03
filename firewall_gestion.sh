#!/bin/bash

opc=69
fecha=$(date +"%Y-%m-%d")

function menu() {
    clear
    echo "---------------------------------------------------------------------"
    echo "                         GESTION DE FIREWALLD"
    echo "---------------------------------------------------------------------"
    echo "1 - Verificar estado de Firewall"
    echo "2 - Permitir HTTPS y HTTP"
    echo "3 - Bloquear una IP sospechosa"
    echo "4 - Establecer politicas restrictivas"
    echo "5 - Habilitar solicitudes de PING"
    echo "6 - Listar servicios permitidos"
    echo "7 - Bloquear direccion MAC"
    echo "8 - Agregar un servicio"
    echo "0 - Salir"
    echo "---------------------------------------------------------------------"
    echo "                              S.I.G.S.M"
    echo "---------------------------------------------------------------------"
}

function estado_firewall() {
    clear
    echo "----- Estado de FirewallD -----"
    firewall-cmd --state
    read -p "Presione INTRO para continuar..." pausa
}

function permitir_https_http() {
    clear
    echo "----- Permitiendo trafico HTTPS y HTTP -----"
    firewall-cmd --permanent --add-service=https
    firewall-cmd --permanent --add-service=http
    firewall-cmd --reload
    echo ""
    read -p "Presione INTRO para continuar..." pausa
}

function bloquear_ip() {
    clear
    echo "----- Bloquear una direccion IP sospechosa -----"
    read -p "Ingrese la direccion IP a bloquear (Ej. 192.168.2.28): " ip
    firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='$ip' drop"
    firewall-cmd --reload
    read -p "Presione INTRO para continuar..." pausa
}

function politicas_restrictivas() {
    clear
    echo "----- Establecer Politicas Restrictivas en el servidor -----"
    firewall-cmd --set-default-zone=drop
    echo ""
    read -p "Presione INTRO para continuar..." pausa
}

function habilitar_ping() {
    clear
    echo "----- Habilitar solicitudes de PING -----"
    firewall-cmd --permanent --add-rich-rule='rule protocol value="icmp" accept'
    firewall-cmd --reload
    echo "Solicitudes de PING habilitadas con exito."
    echo ""
    read -p "Presione INTRO para continuar..." pausa
}

function listar_servicios() {
    clear
    echo "----- Servicios permitidos en la zona actual -----"
    zona=$(firewall-cmd --get-default-zone)
    echo "Zona actual: $zona"
    echo "Los servicios habilitados son:"
    firewall-cmd --list-services
    echo ""
    read -p "Presione INTRO para continuar..." pausa
}

while [ $opc -ne 0 ]
do
      menu
      read -p "Seleccione la opción: " opc

      case $opc in
      1) estado_firewall ;;
      2) permitir_https_http ;;
      3) bloquear_ip ;;
      4) politicas_restrictivas ;;
      5) habilitar_ping ;;
      6) listar_servicios ;;
      7) bloquear_mac ;;
      8) agregar_servicio ;;
      0)
         echo "Finalizando programa... Hasta la proxima"
      ;;
      *)
         echo "[ERROR] opcion invalida. Por favor, ingrese un numero del 0 al 8."
          read -p "Presione INTRO para continuar..." pausa
      ;;
    esac
done
