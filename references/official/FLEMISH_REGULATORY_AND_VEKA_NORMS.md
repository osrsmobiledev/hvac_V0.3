# Flemish HVAC Regulations, VLAREM II, NBN Standards & VEKA API Reference

> **Purpose:** Authoritative, single-source reference document capturing all statutory decrees, emission limits, efficiency thresholds, NBN EN 1749 appliance connection codes, and VEKA Meldingen API schemas for boiler maintenance in Flanders, Belgium.
> **Legal Basis:** 
> - Besluit van de Vlaamse Regering van 8 december 2006 (het *Vlaams Stooktoestellenbesluit*).
> - VLAREM II (Titel II van het VLAREM, inzonderheid Hoofdstuk 5.43 & Bijlagen).
> - NBN EN 1749 / NBN CR 1749 (Europese indeling van gastoestellen).
> - NBN D 51-003 (Binneninstallaties voor aardgas & ventilatienormen).
> - NBN EN 303-5 (Centrale stooktoestellen op vaste brandstof).
> - VEKA API Specificatie: `POST /meldingCentraleStooktoestellen`.

---

## 1. Verplichte Onderhoudsfrequentie (Besluit 8 dec 2006)

Voor centrale stooktoestellen met een nominaal vermogen $\ge 20\text{ kW}$:

| Brandstoftype | Frequentie | Uitvoerder | Certificaat |
| :--- | :--- | :--- | :--- |
| **Vloeibare brandstof** (Stookolie / Mazout) | **Jaarlijks (1 jaar)** | Erkend technicus vloeibare brandstof (TV) | Reinigings- en verbrandingsattest |
| **Gasvormige brandstof** (Aardgas, Butaan, Propaan/LPG) | **Tweejaarlijks (2 jaar)** | Erkend technicus gasvormige brandstof (GV: G1 of G2) | Reinigings- en verbrandingsattest |
| **Vaste brandstof** (Hout, Pellets, Biomassa) | **Jaarlijks (1 jaar)** | Geschoold vakman | Reinigings- en verbrandingsattest |

> [!NOTE]
> Voor toestellen $< 20\text{ kW}$ is er geen wettelijke onderhoudsfrequentie onder het Vlaams Stooktoestellenbesluit, maar fabrikantenvoorschriften en verzekeringspolissen leggen meestal dezelfde frequenties op.

---

## 2. Statutaire Emissie- en Rendementsnormen

### 2.1 Koolstofmonoxide (CO) Grenswaarden
Onder VLAREM II en het Vlaams Stooktoestellenbesluit (art. 5, §1 & art. 5.43.2.1) wordt de CO-concentratie uitgedrukt in **$\text{mg/kWh}$** (onverdund rookgas, omgerekend naar een referentiezuurstofgehalte van 0% $O_2$):

| Brandstoftype | Maximale Uitstoot (Wettelijk Afkeurpunt) | Opmerkingen |
| :--- | :--- | :--- |
| **Gasvormige brandstof** (Aardgas / LPG) | **$\le 150\text{ mg/kWh}$** | Zowel voor B1- als niet-B1-toestellen. |
| **Vloeibare brandstof** (Stookolie) | **$\le 150\text{ mg/kWh}$** | Geharmoniseerd met VLAREM II (historisch 155 mg/kWh). |
| **Vaste brandstof** (Hout / Pellets) | **Conform NBN EN 303-5** | Typisch $\le 500\text{ mg/m³}$ (klasse 3/4/5). |

> [!TIP]
> Fabrikanten en kwaliteitscodes (zoals HR-Top of ErP Ecodesign) streven naar $< 100\text{ mg/kWh}$ ($< 50\text{ ppm}$), maar het wettelijk afkeurcriterium voor het officiële attest in Vlaanderen is **$150\text{ mg/kWh}$**.

### 2.2 Verbrandingsrendement ($H_i$ — Onderste Verbrandingswaarde)
Het minimaal vereiste verbrandingsrendement op basis van $H_i$:

| Brandstof / Toesteltype | Wettelijke Minimumnorm | Uitleg & Praktijk |
| :--- | :--- | :--- |
| **Vloeibaar (Stookolie)** | **$\ge 90.0\%$** | Geldt voor alle stookolieketels vanaf 20 kW. |
| **Gas — Type B1 (Open met trekonderbreker)** | **$\ge 88.0\%$** | Toestellen met trekonderbreker en natuurlijke trek (bv. B11, B11BS, B14). Omdat een trekonderbreker warmteverliezen via de schouw met zich meebrengt, kent de wet een tolerantie toe tot 88%. |
| **Gas — Niet-B1 (Type C & Type B2)** | **$\ge 90.0\%$** | Dit omvat alle **Type C** gesloten ketels én **Type B2** ketels met mechanische ventilator (bv. B22, B23, B23P). Condenserende ketels halen in de praktijk $\ge 98\%$, maar de wettelijke ondergrens in het besluit is 90%. |
| **Vaste brandstof** | **$\ge 80.0\%$** | Minimumnorm volgens NBN EN 303-5. |

### 2.3 Roetindex (Bacharach) — Enkel Vloeibare Brandstof
* **Norm:** Maximaal **$\le 1$** op de schaal van Bacharach (geen zichtbare samengeklonterde roetdeeltjes).
* **Oliespoor:** Er mag **geen enkel oliespoor** (gele/bruine verkleuring op het filterpapier) zichtbaar zijn. Een oliespoor duidt op onverbrande zware koolwaterstoffen en leidt direct tot afkeuring.
* **Tolerantie voor ketels van vóór 1988:** Bacharach 2 kan worden gedoogd mits er geen enkel oliespoor is, maar moderne instellingen vereisen $\le 1$.

---

## 3. NBN EN 1749 / NBN CR 1749 Toestelclassificatie

De Europese norm **NBN EN 1749** (geïntegreerd in de Belgische gasnorm **NBN D 51-003**) classificeert gastoestellen volgens hun verbrandingsluchttoevoer en rookgasafvoer:

### 3.1 Type A (Open toestellen zonder afvoerkanaal)
* Haalt lucht uit de ruimte, loost rookgassen in de ruimte (bv. kookfornuis, kleine badgeiser zonder schouw). *Niet van toepassing op centrale verwarming.*

### 3.2 Type B (Open toestellen met afvoerkanaal)
Haalt verbrandingslucht uit de stookplaats/ruimte, voert rookgassen af naar buiten.
* **Eerste cijfer (1 of 2):**
  * **1:** Met trekonderbreker (*draft hood*) $\to$ **Type B1** (Wettelijk rendement $\ge 88\%$).
  * **2:** Zonder trekonderbreker, met mechanische ventilator $\to$ **Type B2** (Wettelijk rendement $\ge 90\%$).
* **Tweede cijfer (1, 2, 3 of 4):**
  * **1:** Natuurlijke trek (geen ventilator).
  * **2:** Ventilator achter de warmtewisselaar (onderdruk in toestel).
  * **3:** Ventilator vóór de brander (overdruk in de verbrandingskamer).
  * **4:** Ventilator vóór de trekonderbreker.
* **Suffixen:**
  * **`BS`**: Beveiligd met TTB (Thermische Terugslagbeveiliging).
  * **`P`**: Afvoerkanaal staat onder positieve overdruk (drukklasse P1).
* **Overzicht gangbare Type B configuraties:**
  * **`B11 / B11BS`**: Klassieke atmosferische ketel met trekonderbreker en natuurlijke trek ($\ge 88\%$).
  * **`B23`**: Open ketel met ventilator na warmtewisselaar, zonder trekonderbreker ($\ge 90\%$).
  * **`B23P`**: Open ketel met ventilator, waarbij de schouw/afvoerpijp onder positieve overdruk staat ($\ge 90\%$). Typisch gebruikt bij renovatie van stookplaatsen met een schouwtubering.

### 3.3 Type C (Gesloten / Room-Sealed toestellen)
Volledig gesloten verbrandingskring ten opzichte van het opstellingslokaal. Haalt verse lucht van buiten en voert rookgassen mechanisch af naar buiten.
* **`C13` (Geveldoorvoer):** Horizontaal concentrisch of parallel door de buitenmuur.
* **`C33` (Dakdoorvoer):** Verticaal concentrisch door hellend of plat dak.
* **`C93` (Schouwtubering met ringvormige toevoer):** Flexibele buis in schouw voor rookgassen; de ruimte tussen buis en schacht fungeert als verse luchttoevoer.
* **`C43` (CLV-systeem):** Collectief gecombineerd toevoer- en afvoerkanaal in appartementsgebouwen.
* **`C53` (Gescheiden leidingen):** Aparte toevoer- en afvoerleidingen die uitmonden in verschillende drukzones.
* **`C83` (Collectieve afvoer + eigen toevoer):** Aangesloten op collectieve onderdrukschouw met eigen individuele luchttoevoer via de gevel.

---

## 4. Veilige en Goede Staat van Werking (Keuringspunten)

Tijdens het onderhoud en de verbrandingscontrole moeten de volgende wettelijke punten worden geëvalueerd:

1. **Rookgasafvoerkanaal & Schouwtrek:**
   * Voor Type B1 (natuurlijke trek) moet onder normale weersomstandigheden een stabiele onderdruk van **minstens $-5\text{ Pa}$** aanwezig zijn om terugslag van rookgassen (en risico op CO-intoxicatie) te voorkomen.
2. **Verluchting en Ventilatie Stookplaats (NBN D 51-003 / NBN B 61-002):**
   * Voor open toestellen (Type B) is een permanente, niet-afsluitbare **lage verluchting** (luchttoevoer nabij de vloer) én **hoge verluchting** (luchtafvoer nabij het plafond) strikt wettelijk verplicht.
3. **Dichtheid Brandstoftoevoerleiding:**
   * Gasinstallaties: drukproef van gasmeter tot de ketelafsluiter (geen gaslekken bij bedrijfsdruk).
   * Stookolie-installaties: leiding, filter en ontluchter moeten absoluut vloeistof- en luchtdicht zijn.
4. **Dichtheid Rookgasafvoer (Type C):**
   * De afvoerleiding en concentrische aansluiting moeten luchtdicht zijn zodat er geen rookgassen in de opstellingsruimte lekken.
5. **Geen Ongewenste Condensatie (Type B):**
   * Schouwen van klassieke Type B ketels mogen niet condenseren (voorkomt schouwbrand en aantasting van het metselwerk).

---

## 5. VEKA API Specificatie (`meldingCentraleStooktoestellen`)

De officiële Vlaamse overheidsserver (VEKA) accepteert meldingen via een REST JSON API.

### 5.1 Datamodel `eindbeoordeling`
In het JSON payload van de melding wordt de wettelijke beoordeling als volgt vastgelegd:

```json
"eindbeoordeling": {
  "stooktoestelConform": "OK",        // Keuze: "OK" | "NOK"
  "rookgasafvoerkanaalConform": "OK", // Keuze: "OK" | "NOK"
  "stookplaatsConform": "OK",         // Keuze: "OK" | "NOK"
  "verbrandingscontrole": "OK",       // Keuze: "OK" | "NOK" (Rendement Hi + CO + Roetindex)
  "toestelWerkingGoed": "Goed",       // Keuze: "Goed" | "Niet goed"
  "toestelWerkingVeilig": "Veilig"     // Keuze: "Veilig" | "Niet veilig"
}
```

### 5.2 Verplichte Geografische Identifiers
VEKA koppelt stooktoestellen verplicht aan het Vlaamse Gebouwen- en Adressenregister:
* **`adresId`**: Unieke sleutel uit het CRAB / Adressenregister Vlaanderen (**absolute minimumvereiste**).
* **`gebouwId`**: ID uit het Gebouwenregister (indien niet gekend: `"gebouwIdNietGekend": true`).
* **`gebouweenheidId`**: ID voor appartementen / busnummers (indien niet gekend: `"gebouweenheidIdNietGekend": true`).

---

## 6. Gevolgen van Niet-Conformiteit (3-Maanden Regel)

Indien een centrale stookinstallatie bij het onderhoud **niet voldoet** aan de emissienormen, het rendement, of de veiligheidscriteria:
1. De technicus duidt op het attest **"Niet goed"**, **"Niet veilig"**, of **"Niet conform"** aan en noteert de specifieke gebreken.
2. De eigenaar of gebruiker krijgt wettelijk **3 maanden de tijd** om de installatie te laten herstellen of afstellen.
3. Binnen deze 3 maanden moet een **nieuw onderhoud** worden uitgevoerd en een **nieuw conform verbrandingsattest** worden uitgereikt.
4. Indien de installatie na 3 maanden niet conform is hersteld, is er sprake van een **milieumisdrijf** onder het Vlaams Milieuhandhavingsdecreet en kan de installatie door toezichthouders worden stilgelegd.
