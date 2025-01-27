#!/bin/bash

data_events=/tmp/events.txt
data_games=/tmp/games.txt

#GAMES

#Dodawanie gry do biblioteki
add_game() {
    game_title=$(dialog --stdout --title "Dodaj gre" --inputbox "Podaj tytul" 0 0)
    if [ $? -eq 0 ]; then
        game_genre=$(dialog --stdout --title "Dodaj gre: $game_title" --menu "Wybierz gatunek gry" 0 0 0 \
            "Akcji" "action" \
            "Przygodowa" "survival" \
            "RPG" "rpg" \
            "Symulator" "simulator" \
            "Strategia" "strategy" \
            "Sport" "sport"\
            "Inne" "other")
        if [ $? -eq 0 ]; then
            echo "$game_title - $game_genre" >> $data_games
            dialog --msgbox "Pomyslnie dodano gre!" 6 30
        else
            dialog --msgbox "Nie wybrano gatunku!" 6 30
        fi
    else
        dialog --msgbox "Nie podano tytulu!" 6 30
    fi
}

#Usuwanie gry z biblioteki
delete_game() {
    game=$1
    dialog --yesno "Czy na pewno usunac gre: $game?" 6 30
    if [ $? -eq 0 ]; then
        sed -i "/$game/d" $data_games
        dialog --msgbox "Gra usunieta pomyslnie!" 6 30
        show_games
    fi
}

#Zarządzanie grami (przegladanie i usuwanie)
show_games() {
    games=$(cat $data_games)
    games_list=$(awk -F ' - ' '{print $1 " " $2}' $data_games | tr '\n' ' ')
    if [ -z "$games" ]; then
        dialog --msgbox "Nie znaleziono gier!" 6 30
    else
        game=$(dialog --stdout --title "Gry" --menu "Wybierz gre" 0 0 0 $games_list)
        if [ $? -eq 0 ]; then
            action=$(dialog --stdout --title "$game" --menu "Wybierz opcje" 0 0 0 \
                1 "Usun gre" \
                2 "Powrot do gier")

            case $action in
                1) delete_game "$game" ;;
                2) show_games ;;
                *) show_games ;;
            esac
        fi
    fi

}

#EVENTS

#Dodawanie eventu dla gry
add_event() {
    event_date=$(dialog --stdout --title "Dodaj wydarzenie" --calendar "Wybierz date" 0 0)
    if [ $? -eq 0 ]; then
        #pobranie listy gier
        games_list=$(awk -F ' - ' '{print $1 " " $2}' $data_games | tr '\n' ' ')

        #Wybor gry z listy dla eventu
        event_game=$(dialog --stdout --title "Dodaj wydarzenie" --menu "Wybierz gre" 0 0 0 $games_list)
        if [ $? -eq 0 ]; then
            event_desc=$(dialog --stdout --title "Dodaj wydarzenie" --inputbox "Podaj opis wydarzenia" 0 0)
            if [ $? -eq 0 ]; then
                echo "$event_date - $event_game - $event_desc" >> $data_events
                dialog --msgbox "Pomyslnie dodano wydarznie!" 6 30
            else
                dialog --msgbox "Nie podano opisu!" 6 30
        else
            #Wprowadzenie nazwy gry dla eventu w przypadku gry spoza biblioteki
            dialog --stdout --title "Nie wybrano gry, podaj nazwe" --inputbox "Podaj nazwe gry" 6 30
            if [ $? -eq 0 ]; then
                event_desc=$(dialog --stdout --title "Dodaj wydarznie" --inputbox "Podaj opis wydarzenia" 0 0)
                if [ $? -eq 0 ]; then
                    echo "$event_date - $event_game - $event_desc" >> $data_events
                    dialog --msgbox "Pomyslnie dodano wydarzenie!" 6 30
                else
                    dialog --msgbox "Nie podano opisu!" 6 30
                fi
            else
                dialog --msgbox "Nie podano nazwy!" 6 30
            fi
        fi
    else
        dialog --msgbox "Nie wybrano daty!" 6 30
    fi
}

#Usuwanie eventu
delete_event() {
    event=$1
    dialog --yesno "Czy na pewno usunac wydarzenie: $event?" 6 30
    if [ $? -eq 0 ]; then
        sed -i "/$event/d" $data_events
        dialog --msgbox "Pomyslnie usunieto wydarzenie!" 6 30
        show_events
    fi
}

#Wyswietlanie eventow i zarzadzanie nimi
show_events() {
    event_date=$(dialog --stdout --title "Zarzadzanie wydarzeniami" --calendar "Wybierz date" 0 0)
    if [ $? -eq 0 ]; then
        events=$(grep "$event_date" $data_events)
        if [ -z "$events" ]; then
            dialog --msgbox "Brak wydarzen na wskazana date!" 6 30
        else
            event_list=$(echo "$events" | awk -F ' - ' '{print $3 " " $2}' | tr '\n' ' ')
            dialog --msgbox "$event_list" 0 0
            event=$(dialog --stdout --title "Wydarzenia" --menu "Wybierz wydarzenie" 0 0 0 $event_list)
            if [ $? -eq 0 ]; then
                action=$(dialog --stdout --title "$event" --menu "Wybierz opcje" 0 0 0 \
                    1 "Usun wydarzenie" \
                    2 "Powrot do wydarzen")

                case $action in
                    1) delete_event "$event" ;;
                    2) show_events ;;
                    *) show_events ;;
                esac

            else
                dialog --msgbox "Nie wybrano wydarzenia!" 6 30
            fi
        fi
    else
        dialog --msgbox "Nie wybrano daty!" 6 30
    fi
}


# Menu główne
main_menu() {
    choice=$(dialog --stdout --title "Menu glowne" --menu "Choose an option" 0 0 0 \
        1 "Game Library" \
        2 "Game Events Calendar" \
        3 "Clear program data" \
        4 "Exit")

    case $choice in
        1) game_menu ;;
        2) event_menu ;;
        3) clear_data ;;
        4) exit_prog ;;
        *) exit_prog ;;
    esac

    main_menu
}

#Menu biblioteki gier
game_menu() {
    choice=$(dialog --stdout --title "Biblioteka gier" --menu "Choose an option" 0 0 0 \
        1 "Add Game" \
        2 "Manage Games" \
        3 "Return to main menu")

    case $choice in
        1) add_game ;;
        2) show_games ;;
        3) main_menu ;;
        *) dialog --msgbox "Invalid option" 6 30 ;;
    esac

    game_menu
}

# Menu eventow
event_menu() {
    choice=$(dialog --stdout --title "Kalendarz wydarzen" --menu "Choose an option" 0 0 0 \
        1 "Add Event" \
        2 "Manage Events" \
        3 "Return to main menu")

    case $choice in
        1) add_event ;;
        2) show_events ;;
        3) main_menu ;;
        *) dialog --msgbox "Invalid option" 6 30 ;;
    esac

    event_menu
}

#Tworzenie nizbednych plikow
touch $data_events
touch $data_games

#Obsluga zamkniecia programu i usunięcia danych
clear_data() {
    dialog --yesno "Czy na pewno usunac wszystkie dane i opuscic program?" 6 30
    if [ $? -eq 0 ]; then
        rm -f $data_events
        rm -f $data_games
        dialog --msgbox "Dane zostaly usuniete! Opuszczanie" 6 30
        clear
        exit
    fi
}

exit_prog() {
    dialog --yesno "Czy na pewno opuscic program?" 6 30
    if [ $? -eq 0 ]; then
        dialog --msgbox "Do zobaczenia!" 6 30
        clear
        exit
    fi
}

clear