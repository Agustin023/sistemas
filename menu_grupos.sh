#!/bin/bash

opc=69
fecha=$(date +%Y-%m-%d)

function menu() {
	clear
	echo "-------------------------------------------"
	echo "      MENU DE GESTION DE GRUPOS      "
	echo "-------------------------------------------"
	echo "1 - Agregar grupo"
	echo "2 - Eliminar grupo"
	echo "3 - Editar grupo"
	echo "4 - Listar grupos en el sistema"
	echo "5 - Buscar grupos en el sistema"
	echo "0 - Salir"
	echo "-------------------------------------------"
	echo "               S.I.G.S.M               "
	echo "-------------------------------------------"
}

function agregar_grupo() {
	echo "----- AGREGAR GRUPO -----"
	read -p "Ingrese el nombre del grupo a agregar: " grupoUsuario
	grupo=$(echo "$grupoUsuario" | tr '[:upper:]' '[:lower:]')
	if getent group "$grupo" > /dev/null; then
		echo "El grupo $grupo ya existe dentro del sistema"
	else
		groupadd "$grupo"
		if [ $? -eq 0 ]; then
			echo "Grupo agregado exitosamente en el sistema"
		else
			echo "ERROR al agregar el grupo $grupo al sistema"
		fi
	fi
	echo ""
	echo "Presione INTRO para volver al menu principal"
	read pausa
}

function eliminar_grupo() {
	echo "----- BORRAR GRUPO -----"
	read -p "Ingrese el nombre del grupo a eliminar: " grupoUsuario
	grupo=$(echo "$grupoUsuario" |tr '[:upper:]' '[:lower:]')
	if getent group "$grupo" > /dev/null; then
		groupdel "$grupo"
		if [ $? -eq 0 ]; then
			echo "Grupo $grupo eliminado exitosamente"
		else
			echo "ERROR al borrar el grupo $grupo del sistema"
		fi
	else
		echo "El grupo $grupo no existe en el sistema"
	fi
	echo ""
	echo "Presione INTRO para volver al menu principal"
	read pausa
}

function editar_grupo() {
	echo "----- EDITAR GRUPO -----"
	read -p "Ingrese el nombre del grupo a editar: " grupoUsuario
	grupo=$(echo "$grupoUsuario" | tr '[:upper:]' '[:lower:]')
	if getent group "$grupo" > /dev/null; then
		read -p "Ingrese el nuevo nombre del grupo: " nuevoGrupo
		nuevoGrupo=$(echo "$nuevoGrupo" | tr '[:upper:]' '[:lower:]')
		if getent group "$nuevoGrupo" > /dev/null; then
			echo "El grupo $nuevoGrupo ya existe dentro del sistema"
		else
			groupmod -n "$nuevoGrupo" "$grupo"
			if [ $? -eq 0 ]; then
				echo "Grupo $grupo editado exitosamente a $nuevoGrupo"
			else
				echo "ERROR al editar el grupo $grupo"
			fi
		fi
	else
		echo "El grupo $grupo no existe dentro del sistema"
	fi
	echo ""
	echo "Presione INTRO para volver al menu principal"
	read pausa
}

function listar_grupos() {
	echo "----- Lista de grupos en el sistema -----"
	getent group | cut -d: -f1
	echo ""
	echo "Presione INTRO para volver al menu principal"
	read pausa
}

function buscar_grupo () {
	echo "----- Buscar grupos en el sistema -----"
	read -p "Ingrese en nombre del grupo a buscar: " grupoUsuario
	grupo=$(echo "$grupoUsuario" | tr '[:upper:]' '[:lower:]')
	if getent group "$grupo"; then
		echo "El grupo $grupo existe dentro del sistema"
	else
		echo "El grupo $grupo no existe dentro del sistema"
	fi
	echo ""
	echo "Presione INTRO para volver al menu principal"
	read pausa
}

while [ "$opc" != "0" ]
do
	clear
	menu
	read -p "Ingrese la opcion correspondiente: " opc
	case "$opc" in
	1)
		agregar_grupo;;
	2)
		eliminar_grupo;;
	3)
		editar_grupo;;
	4)
		listar_grupos;;
	5)
		buscar_grupo;;
	0)
		echo "Volviendo al menu principal..."; break ;;
	*)
		echo "Seleccciono una opcion invalida"
		sleep 2
		continue;;
	esac
done
