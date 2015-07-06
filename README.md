Tu je [mapa](http://petervojtek.github.io/mapa-romskych-komunit/)

Ako podklad som zobral [tento zoznam z atlasu rómskych komunít](http://romovia.vlada.gov.sk/3556/regiony.php) a cez google geocoding API som k nim získal polohu. 
Potom som ich zobrazil cez [Leaflet JS](https://github.com/Leaflet/Leaflet). Musel som použiť rozšírenie [Leaflet MarkerCluster](https://github.com/Leaflet/Leaflet.markercluster), ktoré zhlukuje body označujúce polohu, inak LeafLet príliš zaťažuje CPU.

Mapa je približná:
* poloha je nepresná, je to obvykle centrum obce
* niektoré obce sa google geocoding API nepodarilo trafiť (ale každej adrese našiel polohu, sú to false accepts)

TODOs:
* získať presnejšie polohy osád
