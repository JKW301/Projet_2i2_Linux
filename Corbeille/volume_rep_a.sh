#!/bin/bash

# Exécution de la commande "du -sb" sur le répertoire courant et stockage du résultat dans une variable
du_output=$(du -sb . 2>/dev/null | cut -f1)

# Séparation de la valeur en séries de trois chiffres
formatted_output=()
while [[ ${#du_output} -gt 0 ]]; do
    part="${du_output: -3}" # On prend les trois derniers chiffres
    du_output="${du_output:0: -3}" # On supprime ces trois chiffres
    formatted_output=(" $part" "${formatted_output[@]}") # On ajoute ces trois chiffres au début du tableau
done

# Affichage de la taille sous forme de séries de trois chiffres sur une seule ligne
echo -n "Taille totale du répertoire courant: "
for index in "${!formatted_output[@]}"; do
    case $index in
        0)
            echo -n "${formatted_output[$index]} Mo "
            ;;
        1)
            echo -n "${formatted_output[$index]} Ko "
            ;;
        2)
            echo -n "${formatted_output[$index]} octets "
            ;;
        *)
            echo -n "${formatted_output[$index]} "
            ;;
    esac
done
echo