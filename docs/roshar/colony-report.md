# Colony Report na Rosharze

Colony Report to dodatek do MineColonies, który pokazuje kolejkę dostaw,
postęp budów i historię tego, co kurierzy dostarczyli do poszczególnych
budynków. Roshar używa wersji **0.2.1** z Minecraftem 1.21.1,
NeoForge 21.1.250 i MineColonies 1.1.1403.

Prism pobiera mod przy starcie instancji Roshara z włączoną aktualizacją
Packwiz. Przepis na **Colony Report** znajdziesz w JEI.
[Konfiguracja Prism](../../README.md#instalacja-atm10a-w-prism-launcherze)

## Jak zrobić i otworzyć raport

1. Połącz **Clipboard** z MineColonies, **Paper** i **Ink Sac**. Kolejność
   składników w craftingu jest dowolna.
2. Trzymając raport w ręce, przytrzymaj **Shift** i kliknij prawym przyciskiem
   myszy blok **Town Hall**, który otwiera menu ratusza. Raport powiąże się
   z tą kolonią.
3. Puść **Shift** i kliknij prawym przyciskiem w powietrze, aby otworzyć
   raport. Potrzebujesz uprawnienia do otwierania chatek w tej kolonii.

## Overview

Licznik **Total** pokazuje łączną liczbę oczekujących zleceń dostawy.
Obok widać podział na jedzenie, dostawy dla budowniczych i pozostałe.
Niżej widać, ile budów czeka w kolejce. Lista aktywnych budów pokazuje etap
i przypisanego budowniczego. **Used** to procent wykorzystanych materiałów
budowy.

## Deliveries

1. Ustaw zakres **Last hour**, **Last 24 hours** lub **Last 7 days**.
   Jeden słupek obejmuje odpowiednio 10 minut, 4 godziny lub dobę.
   Prawy koniec osi pokazuje godzinę zakończenia zakresu.
2. Wybierz **All buildings**, aby zmienić odbiorcę. Wyszukaj budynek po
   nazwie lub współrzędnych. Współrzędne rozróżniają chatki o tej samej nazwie.
3. Najedź na słupek, żeby zobaczyć dokładny przedział, łączną liczbę
   dostarczonych stosów, podział na kategorie i stan kolejki.
4. Kliknij słupek, aby w **Delivery log** zobaczyć godzinę, odbiorcę,
   przedmiot i ilość z tego przedziału. Ponowne kliknięcie przywraca listę
   z całego zakresu. Dłuższą listę przewijaj kółkiem myszy nad wpisami lub
   przechodź między stronami strzałkami. Aby odświeżyć dane, zamknij
   i ponownie otwórz raport.

**Słupki czytaj z lewej osi.** Każdy pokazuje liczbę stosów przyjętych
od kurierów w danym przedziale. Kolumna **Qty** podaje liczbę sztuk
w konkretnej dostawie. Dostawa 64 Stone Bricks w jednym stosie dodaje
jeden stos do słupka.

**Przerywaną linię czytaj z prawej osi.** Pokazuje oczekujące zlecenia
według ostatniego odczytu dostępnego na koniec danego przedziału.

| Kategoria | Odbiorcy i przykłady |
| --- | --- |
| **Building** | Chatki budowniczych, na przykład Stone Bricks do Builder’s Hut |
| **Food** | Dining Hall, Chef’s Kitchen i Bakery, na przykład jaja do Chef’s Kitchen |
| **Other** | Pozostali odbiorcy, na przykład pszenica do Shepherd’s Hut, Large Bottles do Cowhand’s Hut lub sadzonki do Forester’s Hut |

## Historia i wersja 0.2.1

Serwer zapisuje przyjęte dostawy kurierów i odczytuje stan kolejki mniej
więcej co 5 minut. Historia zapisuje się ze światem i obejmuje do
**7 dni czasu rzeczywistego** od rozpoczęcia zbierania danych. Starsze
dostawy są automatycznie usuwane.

Wersja **0.2.1** dodaje sumę stosów do dymka, pokazuje koniec zakresu na osi
czasu i poprawia czytelność tekstu przy włączonym Dark Mode Everywhere.
[Plik moda w paczce Roshara](../../neoforge/atm10a/mods/colony-report-0.2.1.jar)
