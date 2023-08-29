# 2023_msnr_portal_e2e_testing

# Instalacija
## Preuzimanje projekta
```git clone git@github.com:MATF-Software-Verification/2023_msnr_portal_unittest.git```
## Pokretanje projekta
Serverski deo se moze pokrenuti pozivom narednih komandi iz direktorijuma msnr_api
```
mix deps.get
mix ecto.setup
mix phx.server
```
Klijentski deo se moze pokrenuti pozivom narednih komandi iz direktorijuma msnr_elm
```
npm install -g http-server-spa
elm make --output=app.js src/Main.elm
http-server-spa .
```
## Pokretanje testova
Testovi su smešteni na putanji ***portal/msnr_api/test/e2e***.
Neophodno je prvo pokrenuti webdriver kako bismo mogli pokrenuti testove, u radu se mogu koristiti ***chromedriver*** i ***phantomJS***. Podešavanje webdriver-a koji želite koristiti se vrši u 
datotekama ***config.exs, test.exs i dev.exs***:
```
config :hound, driver: "webdriver"
```
Poziv za chromedriver je sledeći
```
chromedriver
```
Poziv za chromedriver je sledeći
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
