# eHDSI Alerts

**Target**:[Template  eHDSI Problem Concern](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.15-2020-09-03T125944.html#_2.16.840.1.113883.3.1937.777.11.9.787_)

>Description of medical alerts in textual format: any clinical information that is imperative to know so that the life or health of the patient does not come under threat.

**Source**: [active Template  Organizer Alerts](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.18-2018-04-18T000000.html)
[ Template  KEZO Alert](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.214-2015-11-25T000000.html)

> [PS-NL - PS-EU VanNaar tabel 2.0] Is codelijst contra indicaties (G standaard) --> is dit nuttig want nederlandse lijst en wordt niet vertaald?--> zijn snomed clinical terms dus engels ook aanwezig

- hl7:value 0..1 R Het element value kan een code bevatten uit een van de genoemde value sets / codestelsels en/of een stuk vrije tekst in value/originalText.
Indien alleen tekst wordt doorgegeven dient nullFlavor="OTH" gebruikt te worden (zie voorbeelden). Dan dus alleen in de narrative en vrije tekst maar niet vertaald.

## Syntax mapping

Als in sectie problems, alert is een observation in acute zorg die in ePS onderdeel wordt van active problems of history of past illness.
zie ook https://github.com/Duometis/ncp-conversie/issues/106

## Terminology Mapping 

| source | target | remarks |
| ----------- | ----------- |----------- |
| [AlertNaamCodelijst 2017‑12‑31](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/voc-2.16.840.1.113883.2.4.3.11.60.40.2.8.3.2-DYNAMIC.html)|hl7:reference met @value verwijzing naar narrative|This valueset is extensible so there could be other snomed codes present than those in the valueset. What to do about that? (https://github.com/Duometis/ncp-conversie/issues/6). older version of valueset used see https://github.com/Duometis/ncp-conversie/issues/47. soort vertaling: NEC|
|[G-Standaard Thesaurus 40 contra-indicatieaard 2015‑08‑27](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/voc-2.16.840.1.113883.2.4.3.11.60.66.11.118-DYNAMIC.html)|hl7:reference met @value verwijzing naar narrative|Als 'alert' kan er ook gewezen worden naar een problem (of allergieen en intolerantie). |
||ActStatusActiveAbortedSuspendedCompleted (DYNAMIC)||
