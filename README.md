# 2023_msnr_portal_e2e_testing
# Opis projekta
Implementacija end-to-end testova nad projektom MSNR portal. <br />
Klijentski deo portala pisan je u jeziku Elm, a serverski deo u jeziku Elixir.<br /><br />
***Elixir***<br />
Elixir je dinamički tipiziran funkcionalni jezik dizajniran za
izgradnju skalabilnih aplikacija, lakih za održavanje. <br /> Više o ovom jeziku možete pronaći na sledećoj adresi:
(https://elixir-lang.org/)<br />
***Elm***<br />
Elm je statički tipiziran, čisto funkcionalni programski jezik namenjen iskljucivo za kreiranje veb aplikacija, razvijen sa ciljem da GUI programiranje učini prijatnijim.<br />
Više o ovom jeziku možete pronaći na sledećoj adresi: (https://guide.elm-lang.org/)
# Instalacija
## Preuzimanje projekta
```git clone git@github.com:MATF-Software-Verification/2023_msnr_portal_unittest.git```
## Pokretanje projekta
Serverski deo se može pokrenuti pozivom narednih komandi iz direktorijuma msnr_api
```
mix deps.get
mix ecto.setup
mix phx.server
```
Klijentski deo se može pokrenuti pozivom narednih komandi iz direktorijuma msnr_elm
```
npm install -g http-server-spa
elm make --output=app.js src/Main.elm
http-server-spa .
```
## Biblioteke korišćene
### Hound
Biblioteka jezika Elixir koja omogućava automatizaciju pretraživača i pisanje integracionih testova za veb aplikacije.<br />
Više o podešavanju ove biblioteke možete pronaći na ovoj adresi: (https://github.com/HashNuke/hound)<br />
Više o metodama koje ova biblioteka nudi možete pronaći na ovoj adresi: (https://hexdocs.pm/hound/readme.html)
### ExUnit
Skup alata koji je deo glavne biblioteke jezika Elixir, korišćen za pisanje testova nad ovim jezikom. Testovi su implementirani u vidu Elixir skripti i imena ovih datoteka se
završavaju sa ekstenzijom ***.exs***.<br />
Više o ovoj biblioteci možete pronaći na ovoj adresi: (https://hexdocs.pm/ex_unit/1.15/ExUnit.html)
## Pokretanje testova
Testovi su smešteni na putanji ***portal/msnr_api/test/e2e***.
Neophodno je prvo pokrenuti webdriver kako bismo mogli pokrenuti testove, u radu se mogu koristiti ***chromedriver*** i ***phantomJS***. Podešavanje webdriver-a koji želite koristiti se vrši u 
datotekama **config.exs, test.exs i dev.exs**:
```
config :hound, driver: "odgovarajući webdriver"
```
Poziv za chromedriver je sledeći
```
chromedriver
```
Poziv za phantomJS je sledeći
```
phantomjs --wd
```
Testovi se potom mogu pokrenuti pozivom naredne komande iz direktorijuma msnr_api
```
mix test test\e2e\ime_testa.exs
```
## Link ka repozitorijumu originalnog projekta
https://github.com/NemanjaSubotic/master-rad.git
## Autori
- Anđela Križan 1083/2020
- Ivana Cvetkoski 1111/2021
- Jelena Jeremić 1099/2021
