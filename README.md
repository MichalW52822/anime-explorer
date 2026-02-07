# Anime Explorer

Anime Explorer to aplikacja mobilna stworzona w technologii Flutter, umożliwiająca
eksplorację treści anime z wykorzystaniem publicznego API (Jikan).
Projekt został zrealizowany jako nowatorski projekt indywidualny.

## Funkcjonalności
- przeglądanie listy anime
- widok szczegółów anime
- wyszukiwanie anime
- dodawanie anime do listy ulubionych
- przełączanie widoku: lista / siatka
- losowy wybór anime

## Nowatorskie interakcje
Aplikacja wykorzystuje czujniki telefonu oraz haptykę jako alternatywny sposób interakcji:
- potrząśnięcie telefonem (shake) losuje anime z aktualnej listy
- przechylenie telefonu (tilt) przełącza tryb widoku
- haptyka zapewnia informację zwrotną przy kluczowych akcjach

Na emulatorze dostępny jest przycisk losowania jako alternatywa dla czujników.

## Technologie
- Flutter / Dart
- BLoC / Cubit
- REST API (Jikan)
- sensors_plus