# eHDSI Medication Summary

Target: [Template  eHDSI Medication Summary](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.2.3-2020-09-07T095657.html)

Target: 
- [eHDSI Medication Item](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.4-2024-01-25T135932.html)
- [eHDSI PS Medication Information](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.31-2022-01-11T164400.html)

- Current and relevant past medicines: Relevant prescribed medicines whose period of time indicated for the treatment has not yet expired whether it has been dispensed or not, or medicines that influence current health status or are relevant to a clinical decision.

Source: [MP HL7 Medicatieafspraken Organizer](https://decor.nictiz.nl/pub/medicatieproces/mp-html-20181220T121121/tmp-2.16.840.1.113883.2.4.3.11.60.20.77.10.9265-2018-12-13T000000.html)

Source MA: [MP CDA Medicatieafspraak](https://decor.nictiz.nl/pub/medicatieproces/mp-html-20181220T121121/tmp-2.16.840.1.113883.2.4.3.11.60.20.77.10.9235-2018-12-04T143321.html)

## eHDSI dataelements

- substanceAdministration statusCode
  - The status of all elements must be either "active" or "completed". Status of "active" indicates a currently valid prescription, status of completed indicates a previously taken medication.
  - wordt afgeleid van einddatum: 
    - (einddatum = leeg of datum > Today = active) en (einddatum = datum < Today = completed) 
    - zie ook <https://github.com/Duometis/ncp-conversie/issues/57>
- medicinal product
  - The name of the substance or product. This should be sufficient for a provider to identify the kind of medication. It may be a trade name or a generic name.
  - Door de GPK-ATC mapping wordt hier altijd de generieke ATC naam gebruikt voor onze medicatie, tenzij er geen GPK code is (b.v. magistrale recepten)
  - EU [Template  eHDSI PS Manufactured Material](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.32-2024-04-11T135939.html) en dan [Template  eHDSI PS Medication Information](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.31-2022-01-11T164400.html)
  - NL [Template  MP CDA Medication Contents](https://decor.nictiz.nl/pub/medicatieproces/mp-html-20181220T121121/tmp-2.16.840.1.113883.2.4.3.11.60.20.77.10.9264-2018-12-11T154905.html) en dan [Template  MP CDA Ingredient](https://decor.nictiz.nl/pub/medicatieproces/mp-html-20181220T121121/tmp-2.16.840.1.113883.2.4.3.11.60.20.77.10.9106-2016-06-26T164013.html) voor de active ingredients.

## Syntax mapping

| eHDSI | source | target | remarks |
| ----------- | ----------- |-----------  |----------- |
| substanceAdministration | 
| @moodCode | | obv. einddatum, INT als toekomst, EVN als beëindigd
| .code | | fixed 'DRUG'
| .statusCode | | obv. einddatum, zie https://github.com/Duometis/ncp-conversie/issues/57 
| .effectiveTime als IVL_TS | COPY als IVL_TS in input | anders 'NI' | De eerste effectiveTime in eHDSI is duur medicatieafspraak
| .routeCode | COPY |
| .doseQuantity | COPY bij 1, weglaten bij meerdere (niet betrouwbaar)
| .rateQuantity | als doseQuantity
| .consumable | | ph:asSpecializedKind classCode="GRIC" voor ATC<br/>ph:asSpecializedKind classCode="GEN" voor HPK, PRK, GPK
| .ingredient ||weglaten, is niet gecodeerd naar wel/niet active in acute zorg

## Toelichting eHDSI CDA display tool

De eerste kolom bevat de generieke productnaam en dat is de ATC, zie: eHDSI PS Medication Information, eerste "pharm:asSpecializedKind", daar staat:

"This module is used for representing the classification of the Substance according to the WHO Anatomical Therapeutic Chemical (ATC) Classification System.

The classCode of "GRIC" identifies this structure as the representation of a generic equivalent of the medication described in the current Medicine entry."

Active ingredient staat iets verder onder "pharm:ingredient" en daar staat:

"One or more active ingredients may be represented with this structure. The classCode of "ACTI" indicates that this is an active ingredient. The element contains the coded representation of the ingredient and the element may be used for the plain text representation."

Die kunnen wij niet vullen omdat onze MP bouwstenen geen onderscheid maken tussen actieve en andere ingredienten.

Zo werkt de CDA display tool van de EU ook. Die laat - als aanwezig - de ATC code in de eerste kolom zien en als die niet aanwezig is de hele naam.

## Toelichting dosering

De Nederlandse dosering kent het volgende toedienschema bij de doseerschema's:

- Eenvoudig doseerschema met alleen één frequentie.
- Eenvoudig doseerschema met alleen één interval.
- Eenvoudig doseerschema met één vast tijdstip.
- Doseerschema met toedieningsduur.
- Doseerschema met meer dan één vast tijdstip.
- Cyclisch doseerschema.
- Eenmalig gebruik of aantal keren gebruik zonder tijd.
- Doseerschema één keer per week op één weekdag.
- Complexer doseerschema met weekdag(en).
- Nacht
- Ochtend
- Middag
- Avond
- Complexer doseerschema met meer dan één dagdeel.
- Veelal met eigen CDA templates en vaak NL datatypes.

De eHDSI Medication Item heeft:

- **IVL_TS**: The first element encodes the start and stop time of the medication regimen or the length of the medication regimen. This is an interval of time (xsi:type='IVL_TS'), and must be specified as shown. This is an additional constraint placed upon CDA Release 2.0 by this profile, and simplifies the exchange of start/stop/length and frequency information between EMR systems. If no information is available for the dosage period, a nullFlavor attribute has to be provided with the value 'UNK'.
  - **Case 1**: specified interval
  - **Case 2**: 'floating' period
- **TS**: This required element describes the frequency of intakes. If not known it shall be valued with the nullflavor "UNK". TS represents a single point in time, and is the simplest of all to represent.
- **PIVL_TS**: This is the most commonly used, representing a periodic interval of time.
- **EIVL_TS**: Represents an event-based time interval.
- **SXPR_TS**: Represents a parenthetical set of time expressions.

The datatypes from the NL dosages must be translated to the eHDSI dosage when we want to convert them. This is a complex matter requiring real MP knowledge, and it is questionable whether the conversion is possible.

Daaronder zitten twee een doseerschema's:

DoseQuantity: relatief eenvoudig maar met low/high en center die op de andere eHDSI doseringen aangepast moeten worden
Toedieningssnelheid: deze lijkt wel te mappen op de EU waarden
Deze zijn beter mapbaar maar hebben weinig betekenis zonder toedienschema.

Besloten is dosering niet te doen op dit moment; wanneer in pivot alleen active ingredient (ATC, b..v "IBUPROFEN") uitgewisseld wordt in vertaalde vorm is dosering in Nederlandse vorm zinloos: dat is b.v. 3x daags 2 weken, maar zonder sterkte (400 mg of zo) heeft dat geen informatieve waarde. Sterkte en vorm van medicatie zouden uit G-standaard gehaald moeten worden om zinvolle doseringen uit te kunnen wisselen.

Dosering kan wel in NL narrative en/of Original document.

## Acute zorg 

In [MP CDA Medicatieafspraak inhoud](https://decor.nictiz.nl/pub/medicatieproces/mp-html-20181220T121121/tmp-2.16.840.1.113883.2.4.3.11.60.20.77.10.9233-2018-12-04T130547.html) staan de volgende items:

Deze kunnen allen genegeerd worden:

- Stoptype
- Reden medicatieafspraak
- Reden van voorschrijven
- Aanvullende Instructie.
- Lichaamslengte
- Lichaamsgewicht
- Aanvullende informatie voor medicatieafspraak
- Toelichting
- Relatie naar dosering	(MPCdotsud2)
- Relatie naar afspraak of gebruik	(MPCdotsud2)

## Terminology Mapping

| eHDSI | source | target | remarks |
| ----------- | ----------- |-----------  |----------- |
||als [MP HL7 Medicatieafspraken Organizer] geen [hl7:component] heeft van [ MP CDA Medicatieafspraak] of [MP CDA Medicatieafspraak andermans]|[eHDSIAbsentOrUnknownMedication 2020‑04‑21](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.2.3-2020-09-07T095657.html)|One of the concepts from the target valueset shall be used in the code element to record that a patient is either not on medications, or that medications are not known.|
|medicinal product| [Template MP CDA Medication Code](https://decor.nictiz.nl/pub/medicatieproces/mp-html-20181220T121121/tmp-2.16.840.1.113883.2.4.3.11.60.20.77.10.9253-2018-12-06T133041.html0)|[Template  eHDSI PS Manufactured Material](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.32-2024-04-11T135939.html)| "The name of the substance or product. This should be sufficient for a provider to identify the kind of medication. It may be a trade name or a generic name. This information is required in all medication entries. If the name of the medication is unknown, the type, purpose or other description may be supplied. The name should not include packaging, strength or dosing information."|
|active ingredients |uit mapping GPK halen?||toekomst|
|strength |uit mapping GPK halen voor ieder ingredient?||toekomst|
|eHDSIDoseForm |||mapping FarmaceutischeVormCodelijst op DoseForm (CTS en NEC mapping)|
|units per intake |Doseerinstructie||toekomst|
|frequency of intake |Doseerinstructie||toekomst|
|eHDSIRouteofAdministration |[Template  MP CDA Medicatieafspraak](https://decor.nictiz.nl/pub/medicatieproces/mp-html-20181220T121121/tmp-2.16.840.1.113883.2.4.3.11.60.20.77.10.9235-2018-12-04T143321.html) cda:routeCode, mp-dataelement900-23242 final Toedieningsweg 9|Route of administration [eHDSIRouteofAdministration](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.12-DYNAMIC.html)|Toedieningsweg, G-Standaard tabel voor toedieningswegen: subtabel 0007, NL Value Set ID 2.16.840.1.113883.2.4.3.11.60.40.2.9.5.6. Combinatie van NEC en CTS items van - NL VoorschriftToedieningswegCodelijst naar EU eHDSIRouteofAdministration|
|duration of treatment |Gebruiksperiode:ingangsdatum + einddatum|||
|medication reason |staat niet in Medicatieafspraak|||
