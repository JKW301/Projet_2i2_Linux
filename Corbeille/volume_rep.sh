#!/bin/bash
afficher_taille_repertoire() {
    # Récupération du poids en kilooctets
    poids_ko=$(du -s /home/debian/script | cut -f1)

    # Conversion en mégaoctets, kilooctets et octets
    mo=$(( poids_ko / 1024 ))
    ko=$(( poids_ko % 1024 ))
    octets=$(( poids_ko * 1024 ))
    
    

    # Affichage de la taille avec les unités
    if [ $mo -gt 0 ]; then
        printf "%d Mo %d ko %d octets\n" $mo $ko $octets
    elif [ $ko -gt 0 ]; then
        printf "%d ko %d octets\n" $ko $octets
    else
        printf "%d octets\n" $octets
    fi
}


afficher_taille_repertoire "$taille_repertoire"
