Tu je [mapa](http://petervojtek.github.io/mapa-romskych-osad/)

Ako podklad som zobral [tento zoznam osád](http://narodnyblok.sk/kriminalita/osady.html) a cez google geocoding API som k nim získal polohu. Potom som ich zobrazil cez Leaflet JS.

Aktuálny prístup má nedostatky:
* poloha nie je presná, je to obvykle centrum obce a nie poloha samotnej osady
* niektoré lokality sa google geocoding API nepodarilo trafiť
* nie je definované čo je to `osada`

TODOs:
* získať presnejšie polohy osád
* získať a [vizualizovať počet obyvateľov osád](http://romovia.vlada.gov.sk/3556/regiony.php)
