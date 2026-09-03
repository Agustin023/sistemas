#!/bin/bash

opc=69
year=$(date +%Y-%m-%d)

function menu() {
	clear
	echo "-------------------------------------------------------------"
	echo "                MENU DE GESTION DE USUARIOS                  "
	echo "-------------------------------------------------------------"
	echo "1 - Agregar usuario"
	echo "2 - Borrar usuario"
	echo "3 - Editar nombre de usuario"
	echo "4 - Listar usuarios del sistema"
	echo "5 - Buscar un usuario del sistema"
	echo "6 - Cambiar password de un usuario"
	echo "7 - Bloquear usuario"
	echo "8 - Desbloquear usuario"
	echo "0 - Salir"
	echo "-------------------------------------------------------------"
	echo "                        S.I.G.S.M                        "
	echo "-------------------------------------------------------------"
}

function agregar_usuario() {
	clear
	echo "Ingrese el nombre y apellido del ususario en formato: nombreapellido:"
	read nombre
	usuario=$(echo "$nombre" | tr '[:upper:]' '[:lower:]')
	if grep -q "^$usuario:" /etc/passwd; then
		echo "El usuario ya existe"
		echo "El usuario $USER en la fecha $(date +%Y-%m-%d-%H:%M:%S) trato de crear un usuario con el nombre $usuario pero el usuario ya existe en /etc/passwd" \
			>> /root/log/log_propios/usuarios.txt
		read pausa
	else
		echo "Ingrese grupo: "
		read grupo
		user_group=$(echo "$grupo" | tr '[:upper:]' '[:lower:]')
		grup=$(cat /etc/group | grep -c "$user_group")
		if grep -q "^$user_group:" /etc/group; then
			useradd -g "$user_group" -c "$usuario" -m -k /etc/skel -s /bin/bash "$usuario"
			echo "$usuario:12345" | chpasswd
			echo "El usuario $USER en la fecha $(date +%Y-%m-%d-%H:%M:%S) agrego el usuario $usuario que pertenece al grupo $user_group al sistema" \
				>> /root/log/log_propios/usuarios.txt
			echo "usuario dado de alta"
			read pausa
		else
			echo "El grupo no existe"
			echo "$(date +%Y-%m-%d-%H:%M:%S) se trato de agregar el grupo $grup al sistema pero el grupo ya existe." >> /root/log/log_propios/grupos.txt
			read pausa
		fi
	fi
}

function borrar_usuario() {
	clear
	echo "Ingrese el nombre y apellido en formato: nombreapellido: "
	read nombre
	usuario=$(echo "$nombre" | tr '[:upper:]' '[:lower:]')
	nom=$(grep -c "^$usuario:" /etc/passwd)
	if [ "$nom" -eq 1 ]; then
		echo "Usuario $usuario sera eliminado del sistema, esta seguro que desea eliminarlo? S/N"
		read letra
		if [ "$letra" == "S" -o "$letra" == "s" ]; then
			userdel "$usuario"
			echo "Usuario eliminado del sistema, presione INTRO para continuar"
			echo "$(date +%Y-%m-%d-%H:%M:%S) Usuario: $nom fue eliminado del sistema" >> /root/log/log_propios/usuarios.txt
			read pausa
		else
			echo "operacion cancelada presione INTRO para volveer al menu principal"
			read pausa
		fi
	else
		echo "Operacion cancelada, presione INTRO para volveer al menu principal"
		read pausa
	fi
}

function editar_usuario() {
	clear
	echo "Ingrese el nombre del actual usuario en formato: nombreapellido:"
	read nombre_actual
	usuario_actual=$(echo "$nombre_actual" | tr '[:upper:]' '[:lower:]')
	## verifica la existencia del usuario
	if ! grep -q "^$usuario_actual" /etc/passwd; then
		echo "El usuario no existe dentro del sistema"
		read -p "Presione INTRO para continuar..."
		return
	fi
	## Solicita y valida el nuevo nombre
	echo "Ingrese el nuevo nombre del usuario en formato: nombreapellido:"
	read nuevo_nombre
	nuevo_usuario=$(echo "$nuevo_nombre" | tr '[:upper:]' '[:lower:]')
	if grep -q "^$nuevo_usuario:" /etc/passwd; then
		read -p "Presione INTRO para continuar..."
		return
	fi
	if [ -z "$nuevo_usuario" ]; then
		echo "El nuevo nombre no puede estar vacio"
		read -p "Presione INTRO para continuar..."
		return
	fi
	## Confirma el cambio de nombre
	echo "Se cambiara el usuario $usuario_actual por $nuevo_usuario"
	echo "Esta seguro que desea continuar? S/N"
	read letra
	if [ "$letra" == "S" -o "$letra" == "s" ]; then
		usermod -l "$nuevo_usuario" "$usuario_actual"
		## Modifica el nombre del usuario y registro de log
		if usermod -l "$nuevo_usuario" "$usuario_actual"; then
			echo "$(date +%Y-%m-%d-%H:%M:%S) Se modifico el usuario $usuario_actual por $nuevo_usuario" >> /root/log/log_propios/usuarios.txt
			echo "Usuario modificado exitosamente"
		else
			echo "ERROR al modificar el usuario"
		fi
	else
		echo "Operacion cancelada"
	fi
	read -p "Presione INTRO para volver al menu principal"
}

function listar_usuarios() {
	echo "USUARIOS EN EL SISTEMA"
	echo ""
	cut -d ":" -f1 /etc/passwd | sort | more
	echo "Presione INTRO para volver al menu principal"
	read pausa
}

function buscar_usuario() {
	echo "Ingrese el nombre y apellido del usuario en formato: nombreapellido: "
	read nombre
	usuario=$(echo "$nombre" | tr '[:upper:]' '[:lower:]')
	if id "$usuario" &>/dev/null; then
		echo "El usuario: $usuario existe en el sistema, presione INTRO para continuar"
		read pausa
	else
		echo "El usuario $usuario no existe en el sistema, presione INTRO para continuar"
		read pausa
	fi
}

function cambiar_passwd_usuario() {
	clear
	echo "Ingrese el nombre y apellido del usuario en formato: nombreapellido: "
	read nombre
	usuario=$(echo "$nombre" | tr '[:upper:]' '[:lower:]')
	if id "$usuario" &>/dev/null; then
		echo "Se procede a cambiar la password al usuario $usuario"
		passwd "$usuario"
		read pausa
	else
		echo "El usuario: $usuario no existe en el sistema, presione INTRO para continuar"
		read pausa
	fi
}

function bloquear_usuario() {
	clear
	echo "Ingrese el nombre y apellido del usuario en formato: nombreapellido: "
	read nombre
	usuario=$(echo "$nombre" | tr '[:upper:]' '[:lower:]')
	if id "$usuario" &>/dev/null; then
		usermod -L "$usuario"
		echo "Se procede a bloquear la cuenta del usuario $usuario, presione INTRO para volver al menu principal"
		read pausa
	else
		echo "El usuario: $usuario no existe en el sistema, presione INTRO para continuar"
		read pausa
	fi
}

function desbloquear_usuario() {
	clear
	echo "Ingrese el nombre y apellido del usuario en formato: nombreapellido: "
	read nombre
	usuario=$(echo "$nombre" | tr '[:upper:]' '[:lower:]')
	if id "$usuario" &>/dev/null; then
		echo "Se procede a desbloquear la cuenta del usuario $usuario"
		usermod -U "$usuario"
		read pausa
	else
		echo "El usuario: $usuario no existe en el sistema, presione INTRO para continuar"
		read pausa
	fi
}

while [ "$opc" != 0 ]
do
	clear
	menu
	read -p "Ingrese la opcion correspondiente: " opc
	case "$opc" in
	1)
		agregar_usuario;;
	2)
		borrar_usuario;;
	3)
		editar_usuario;;
	4)
		listar_usuarios;;
	5)
		buscar_usuario;;
	6)
		cambiar_passwd_usuario;;
	7)
		bloquear_usuario;;
	8)
		desbloquear_usuario;;
	0)
		echo "Volviendo al menu principal... Hasta luego"; break ;;
	*)
		echo "[ERROR] Opcion invalida. Por favor, ingrese un numero del 0 al 8"
		sleep 2
		continue ;;
	esac
done
