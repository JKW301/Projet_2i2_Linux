#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 fichier_source"
    exit 1
fi

source_file=$1
if [ ! -f "$source_file" ]; then
    echo "Le fichier source $source_file n'existe pas."
    exit 1
fi

generate_login() {
    local firstname=$1
    local lastname=$2
    local login="${firstname:0:1}${lastname}"
    local counter=0

    while id -u "$login" &>/dev/null; do
        ((counter++))
        login="${firstname:0:1}${lastname}${counter}"
    done

    echo "$login"
}

create_user() {
    local firstname=$1
    local lastname=$2
    local groups=$3
    local sudo=$4
    local password=$5

    local login=$(generate_login "$firstname" "$lastname")

    primary_group=$(echo "$groups" | cut -d, -f1)
    if ! grep -q "^$primary_group:" /etc/group; then
        sudo groupadd "$primary_group"
    fi

    IFS=',' read -ra secondary_groups <<<"$groups"
    for group in "${secondary_groups[@]}"; do
        if ! grep -q "^$group:" /etc/group; then
            sudo groupadd "$group"
        fi
    done

    sudo useradd -m -s /bin/bash -g "$primary_group" -G "${secondary_groups[*]}" -c "$firstname $lastname" "$login"

    echo "$login:$password" | sudo chpasswd

    if [ "$sudo" = "oui" ]; then
        sudo usermod -aG sudo "$login"
    fi

    echo "Utilisateur $firstname $lastname ($login) créé avec succès."
}

generate_files() {
    local user_home=$1

    for ((i = 1; i <= RANDOM % 6 + 5; i++)); do
        size=$((RANDOM % 46 + 5))
        dd if=/dev/urandom of="$user_home/file_$i" bs=1M count="$size" &>/dev/null
    done

    echo "Fichiers générés dans $user_home."
}

while IFS=':' read -r firstname lastname groups sudo password; do
    if [ -z "$firstname" ] || [ -z "$lastname" ] || [ -z "$groups" ] || [ -z "$sudo" ] || [ -z "$password" ]; then
        echo "Erreur: Format incorrect dans le fichier source."
        continue
    fi

    login=$(generate_login "$firstname" "$lastname")
    if id -u "$login" &>/dev/null; then
        echo "Utilisateur $firstname $lastname existe déjà, saut de création."
        continue
    fi

    create_user "$firstname" "$lastname" "$groups" "$sudo" "$password"

    user_home=$(eval echo ~"$login")

    generate_files "$user_home"

done <"$source_file"
