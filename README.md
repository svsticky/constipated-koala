Operation Constipated Koala
===========================

Dit is een (leden)administratie en informatie systeem wordt voor het bijhouden van leden en activitetien voor Studievereniging Sticky.
Op dit moment is het mogelijk om leden te bekijken/doorzoeken/aanpassen. In de komende tijd komen hier meerdere features bij.

## Requirements

- Unix server
- Ruby v2.1.2 (via RVM of rbenv)
- Sqlite 3

## Installatie

1. Zorg dat je de requirements hebt geinstalleerd.
2. Clone de repo:```$ git clone git@github.com:StickyUtrecht/ConstipatedKoala.git```
3. Ga in de directory:```$ cd ConstipatedKoala```
4. Installeer gems:```$ bundle install```
5. Maak een dev database aan:```$ rake db:migrate```
6. Vul de database met test data:```$ rake db:seed```
7. Start de webserver:```$ rails server```
8. Ga naar de webpagina: http://localhost:3000/
9. Knutselen!

## Licentie
```
ConstipatedKoala is licensed under the GPLv3 license.

Copyright (C) 2014 Tako Marks

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
