#!/bin/bash


# ----- Configuracion general -----
LOG_DIR="/root/log/log_propios"
LOG_FILE="$LOG_DIR/sistema.txt"
MAX_LOG_SIZE=1048576   # 1 MB en bytes, para rotacion
MAX_LOG_DIAS=30        # dias de antiguedad para limpieza automatica


function inicializar_logs() {
	if [ ! -d "$LOG_DIR" ]; then
		mkdir -p "$LOG_DIR"
	fi
	if [ ! -f "$LOG_FILE" ]; then
		touch "$LOG_FILE"
	fi
}

# ----- Funcion: log_evento -----

function log_evento() {
	local nivel="$1"
	local mensaje="$2"
	local archivo="${3:-$LOG_FILE}"

	inicializar_logs
	echo "$(date +%Y-%m-%d-%H:%M:%S) [$nivel] Usuario: $USER - $mensaje" >> "$archivo"
}

# ----- Funciones de conveniencia por nivel -----
function log_info() {
	log_evento "INFO" "$1" "$2"
}

function log_warning() {
	log_evento "WARNING" "$1" "$2"
}

function log_error() {
	log_evento "ERROR" "$1" "$2"
}

function log_debug() {
	log_evento "DEBUG" "$1" "$2"
}

# ----- Funcion: log_accion -----

function log_accion() {
	local entidad="$1"
	local accion="$2"
	local objetivo="$3"
	local archivo="$LOG_DIR/${entidad}.txt"

	inicializar_logs
	echo "$(date +%Y-%m-%d-%H:%M:%S) El usuario $USER $accion $objetivo" >> "$archivo"
}


function ver_logs() {
	local archivo="${1:-$LOG_FILE}"
	local nivel="$2"

	if [ ! -f "$archivo" ]; then
		echo "El archivo de log $archivo no existe"
		return 1
	fi

	if [ -n "$nivel" ]; then
		grep "\[$nivel\]" "$archivo" | more
	else
		cat "$archivo" | more
	fi
}

function buscar_en_logs() {
	local patron="$1"
	local archivo="${2:-$LOG_FILE}"

	if [ ! -f "$archivo" ]; then
		echo "El archivo de log $archivo no existe"
		return 1
	fi

	grep -i "$patron" "$archivo"
}


function rotar_log() {
	local archivo="${1:-$LOG_FILE}"

	if [ -f "$archivo" ]; then
		local tamano=$(stat -c%s "$archivo" 2>/dev/null)
		if [ "$tamano" -ge "$MAX_LOG_SIZE" ]; then
			mv "$archivo" "${archivo%.txt}_$(date +%Y%m%d%H%M%S).txt"
			touch "$archivo"
			log_info "Log rotado por tamaño maximo alcanzado" "$archivo"
		fi
	fi
}


function limpiar_logs_antiguos() {
	find "$LOG_DIR" -type f -name "*_*.txt" -mtime +"$MAX_LOG_DIAS" -exec rm -f {} \;
	log_info "Limpieza automatica de logs antiguos ejecutada"
}


function log_error_critico() {
	local mensaje="$1"
	local salir="$2"

	log_error "$mensaje"
	echo "[ERROR CRITICO] $mensaje" >&2

	if [ "$salir" == "salir" ]; then
		exit 1
	fi
}
