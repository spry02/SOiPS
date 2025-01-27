#!/bin/bash

data_events=/tmp/events.txt
data_games=/tmp/games.txt

#GAMES
add_game() {
    game_title=$(dialog --stdout --title "Add Game" --inputbox "Enter Game Title" 0 0)
    if [ $? -eq 0 ]; then
        game_genre=$(dialog --stdout --title "Add Game" --menu "Select Game Genre" 0 0 0 \
            1 "Akcji" \
            2 "Przygodowa" \
            3 "RPG" \
            4 "Symulator" \
            5 "Strategia" \
            6 "Sport" \
            7 "Inne")
        if [ $? -eq 0 ]; then
            echo "$game_title - $game_genre" >> $data_games
            dialog --msgbox "Game added successfully!" 6 30
        else
            dialog --msgbox "No genre selected!" 6 30
        fi
    else
        dialog --msgbox "No title entered!" 6 30
    fi
}

delete_game() {
    game=$1
    dialog --yesno "Czy na pewno usunąć grę: $game?" 6 30
    if [ $? -eq 0 ]; then
        sed -i "/$game/d" $data_games
        dialog --msgbox "Game deleted successfully!" 6 30
        show_games
    fi
}

show_games() {
    games=$(cat $data_games)
    games_list=$(awk -F ' - ' '{print $1 " " $2}' $data_games | tr '\n' ' ')
    if [ -z "$games" ]; then
        dialog --msgbox "No games found!" 6 30
    else
        game=$(dialog --stdout --title "Games" --menu "Select Game" 0 0 0 $games_list)
        if [ $? -eq 0 ]; then
            action=$(dialog --stdout --title "$game" --menu "Choose an option" 0 0 0 \
                1 "Delete Game" \
                2 "Return to Games")

            case $action in
                1) delete_game "$game" ;;
                2) show_games ;;
                *) show_games ;;
            esac
        fi
    fi

}

#EVENTS

# Function to add an event
add_event() {
    event_date=$(dialog --stdout --title "Add Event" --calendar "Select Date" 0 0)
    if [ $? -eq 0 ]; then
        games_list=$(awk -F ' - ' '{print $1 " " $2}' $data_games | tr '\n' ' ')
        event_game=$(dialog --stdout --title "Add Event" --menu "Select Game" 0 0 0 $games_list)
        if [ $? -eq 0 ]; then
            event_desc=$(dialog --stdout --title "Add Event" --inputbox "Enter Event Description" 0 0)
            if [ $? -eq 0 ]; then
                echo "$event_date - $event_game - $event_desc" >> $data_events
                dialog --msgbox "Event added successfully!" 6 30
            else
                dialog --msgbox "No description entered!" 6 30
        else
            dialog --stdout --title "No game selected, input name" --inputbox "Input game name" 6 30
            if [ $? -eq 0 ]; then
                event_desc=$(dialog --stdout --title "Add Event" --inputbox "Enter Event Description" 0 0)
                if [ $? -eq 0 ]; then
                    echo "$event_date - $event_game - $event_desc" >> $data_events
                    dialog --msgbox "Event added successfully!" 6 30
                else
                    dialog --msgbox "No description entered!" 6 30
                fi
            else
                dialog --msgbox "No name provided!" 6 30
            fi
        fi
    else
        dialog --msgbox "No date selected!" 6 30
    fi
}

delete_event() {
    event=$1
    dialog --yesno "Czy na pewno usunąć wydarzenie: $event?" 6 30
    if [ $? -eq 0 ]; then
        sed -i "/$event/d" $data_events
        dialog --msgbox "Event deleted successfully!" 6 30
        show_events
    fi
}

# Function to show events
show_events() {
    event_date=$(dialog --stdout --title "Show Events" --calendar "Select Date" 0 0)
    if [ $? -eq 0 ]; then
        events=$(grep "$event_date" $data_events)
        if [ -z "$events" ]; then
            dialog --msgbox "No events found for the selected date!" 6 30
        else
            event_list=$(echo "$events" | awk -F ' - ' '{print $1 " " $2 " " $3}' | tr '\n' ' ')
            event=$(dialog --stdout --title "Events" --menu "Select Event" 0 0 0 $event_list)
            if [ $? -eq 0 ]; then
                action=$(dialog --stdout --title "$event" --menu "Choose an option" 0 0 0 \
                    1 "Delete Event" \
                    2 "Return to Events")

                case $action in
                    1) delete_event "$event" ;;
                    2) show_events ;;
                    *) show_events ;;
                esac

            else
                dialog --msgbox "No event selected!" 6 30
            fi
        fi
    else
        dialog --msgbox "No date selected!" 6 30
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

# Menu eventów
event_menu() {
    choice=$(dialog --stdout --title "Kalendarz wydarzeń" --menu "Choose an option" 0 0 0 \
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

#Tworzenie nizbędnych plików
touch $data_events
touch $data_games

#Obsługa zamknięcia programu i usunięcia danych
clear_data() {
    dialog --yesno "Czy na pewno usunąć wszystkie dane i opuścić program?" 6 30
    if [ $? -eq 0 ]; then
        rm -f $data_events
        rm -f $data_games
        dialog --msgbox "Dane zostały usunięte! Opuszczanie" 6 30
        clear
        exit
    fi
}

exit_prog() {
    dialog --yesno "Czy na pewno opuścić program?" 6 30
    if [ $? -eq 0 ]; then
        dialog --msgbox "Do zobaczenia!" 6 30
        clear
        exit
    fi
}

clear
