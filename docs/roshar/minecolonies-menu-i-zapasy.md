# Wise Peak — menu bez mleka i minimalne zapasy

Rozpiska dla Rosharu, MineColonies 1.1.1403. Wszystkie dziewięć potraw poniżej
powstaje bez mleka, masła i sera według receptur używanych przez kolonię.
Ilości to **ustawienia na start**. Jeśli danego składnika regularnie brakuje,
podnieś zapas tylko w budynku, który go zużywa.

## Menu restauracji

Zostaw włączone **Fish N Chips**, **Baked Salmon**, **Pepper Hummus**, **Kebab**,
**Hand Pie**, **Veggie Soup**, **Eggdrop Soup**, **Apple Pie** i **Spicy Eggplant**.
Osadnik z domem poziomu 5 potrzebuje pięciu różnych potraw w historii ostatnich
dziesięciu posiłków, żeby nie narzekać na monotonię. Warto więc na początek
rozłożyć dostępne dania między restauracje, żeby miały co wydawać od razu.

## Minimum Stock — wartości do wpisania w grze

**1 oznacza jeden pełny stack danego przedmiotu**. To zwykle 64 sztuki,
a w przypadku jaj 16. Zapas ustaw w budynku, który gotuje lub piecze.

| Gdzie | Składniki | Wartość dla każdego składnika |
| --- | --- | ---: |
| **Chef’s Kitchen** | Garlic, Onion | **2** |
| **Chef’s Kitchen** | Cod, Salmon, Mutton, Chicken — wszystkie surowe | **1** |
| **Chef’s Kitchen** | Durum Wheat, Potato, Carrot, Eggplant, Nether Pepper | **1** |
| **Chef’s Kitchen** | Bell Pepper, Chickpea, Brown Mushroom | **1** |
| **Chef’s Kitchen** | Bowl, Stick, Egg | **1** |
| **Bakery** | Durum Wheat, Apple, Sugar | **1** |

Na pierwszy test można użyć **Chef’s Kitchen przy `1959, 130, 1588`**,
która ma włączone wszystkie osiem przepisów kuchennych, i piekarni
przy **`2009, 142, 1640`** do Apple Pie. W pozostałych budynkach dodawaj
zapas według włączonych przepisów. Hand Pie i Spicy Eggplant robią kuchnie
od poziomu 4, więc np. Brown Mushroom pod Hand Pie pomiń w kuchni poziomu 3.
Stick dodawaj tam, gdzie kucharz robi Kebab.

**Garlic i Onion schodzą najszybciej**, bo wracają w wielu przepisach.
Jeśli jaj zabraknie przy częstych zamówieniach na Eggdrop Soup, podnieś
je z **1 do 2**. W pierwszej kolejności ustaw zapas w jednej kuchni i jednej
piekarni. Jeśli możesz, włóż pierwsze stacki ręcznie przez ich **Inventory**,
żeby kurierzy nie musieli uzupełniać wszystkich pozycji naraz.

Wise Peak ma ukończone badanie **Minimum Order Quantity**. Przy sprawdzaniu
minimalnego zapasu mod czeka, aż zabraknie **ponad jednej czwartej** ustawionej
ilości. Przykład dla zwykłego stacka: przy ustawieniu **1** zamówienie
uzupełniające może powstać, gdy w budynku zostanie **47 sztuk lub mniej**.
[Badania MineColonies](https://minecolonies.com/wiki/systems/research/)

Przy przejściu na powyższe menu usuń z **Minimum Stock** wpisy związane
wyłącznie ze starymi potrawami, np. **Large Milk Bottle**, **Butter**,
**Creamcheese**, **Cheddar Cheese**, **Feta Cheese** i oba serniki.
Gotowe dania uzupełnia menu restauracji. Osobny minimalny zapas gotowej
potrawy w kuchni lub piekarni daje kolejne zamówienie na jej przygotowanie.

## Skąd wzięła się lista składników

| Danie | Składniki na wykonanie przepisu |
| --- | --- |
| Fish N Chips | Garlic, Onion, Durum Wheat, surowy Cod, Potato |
| Baked Salmon | 3 Garlic, 2 Onion, 2 surowe Salmon → 2 porcje |
| Pepper Hummus | 2 Bell Pepper, 2 Chickpea, Garlic, Onion → 2 porcje |
| Kebab | Onion, Nether Pepper, Stick, surowa Mutton |
| Hand Pie | 2 Durum Wheat, Garlic, Brown Mushroom, Onion, surowa Mutton |
| Veggie Soup | 2 Garlic, Onion, Eggplant, Carrot, Bowl |
| Eggdrop Soup | 2 Onion, Garlic, 2 Egg, surowy Chicken, Bowl |
| Apple Pie | 3 Durum Wheat, 2 Apple, Sugar |
| Spicy Eggplant | 2 Nether Pepper, 2 Eggplant, Garlic, Onion, Bowl |

[Obsługa kuchni](https://minecolonies.com/wiki/buildings/kitchen/) ·
[Obsługa piekarni](https://minecolonies.com/wiki/buildings/baker/) ·
[Menu restauracji](https://minecolonies.com/wiki/buildings/cook/)
