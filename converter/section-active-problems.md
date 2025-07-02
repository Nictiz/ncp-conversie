# eHDSI Active Problems

The active problem section shall contain a narrative description of the conditions currently being monitored for the patient. It shall include entries for patient conditions as described in the Entry Content Module.

This section can also be used to hold the Medical Alert information (other alerts not included in allergies). Alerts, of all types are to be considered for the next iteration of the specifications.

**Target**: 
- section level: [eHDSI Active Problems](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.2.9-2022-04-19T153354.html)
- act level: [eHDSI Problem Concern](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.15-2020-09-03T125944.html)
- observation level: [eHDSI Problem](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.7-2023-02-27T152542.html)

**Source**: 
- organizer level: [Organizer Concerns/Episodes](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.16-2018-04-18T000000.html) 
- act level: [KEZO Overdracht Concern](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.212-2015-07-03T000000.html) 
- observation level: [KEZO Probleem](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.213-2015-07-03T000000.html)

## Structure Mapping

In KEZO Overdracht Concern each Act contains observations. More observations would contain the change over time for a concern: this is not exchanged in Acute Zorg.

The act effectiveTime (KEZO Overdracht Concern) contains the dates of registration and the observation effectiveTime (KEZO Probleem) contains the onset and end date of the problem itself (see mapping to zib dataset items). In target this is the other way around: the act effectiveTime contains a mapping to dataset items onset and end, and the observation effectiveTime is optional and not mapped to onset and end, but a 'known to be true' period.

Therefore we take each observation from KEZO and make a separate entry and act out of it, to be able to re-map dates on the required level.


When there are no open concerns we make a (required) Active problem section with 'No known problems'. See: https://github.com/Duometis/ncp-conversie/issues/48

Source | Target | Remark
---|---|---
EACH observation | ONE entry + ONE act |
act.statusCode | COPY | same valueset
act.id | COPY from source
observation.id | COPY from source, is always 282291009 "Diagnosis interpretation" in source | observation.code
observation.effectiveTime | Onset: act.effectiveTime |
observation.value | Problem: COPY from source |
No fit | Diagnosis ascertion status (wave 7) | 
No fit | Health Professional Related with
No fit | External Resource related with

## Terminology Mapping

> in NL AZ zit de episode (naam via tekst en zowel open als een aantal aangevinkte gesloten episodes) met daaronder 1 of meerdere problemen (wederom open of gesloten). In ePS is de episode de concern (vrij tekst) met daaronder de problemen via 3 > valuesets:

> - eHDSIIllnessandDisorder
> or
> - eHDSIAbsentOrUnknownProblem
> or
> - eHDSIRareDisease (DYNAMIC)
>   die worden in NL niet gebruikt en we gaan de ICPC-1 via NEC tabel /'other' workaround er in zetten. 

- De probleemnaam definieert het probleem. Afhankelijk van de setting kunnen verschillende codestelsels worden gebruikt. De ProbleemNaamCodelijst geeft een overzicht van de mogelijke codestelsel
- bij de Acute zorg is bij de HIS-en alleen de ICPC-1 map nodig. Alles hierbij valt onder de 'Other workaround'. Hier moet dus een conceptmap voor komen

| source | target | remarks|
| ----------- | ----------- | ----------- |
| [ICPC-1-NL 2014‑11‑19](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/voc-2.16.840.1.113883.2.4.3.11.60.103.11.20-2014-11-19T000000.html) | hl7:text (dus geen coded data) |tab NHG24 in spreadsheet. Alles is NEC dus workaround. zie ook [#14](https://github.com/Duometis/ncp-conversie/issues/14 ) in de xls ontbreekt ook de NL description maar het lijkt er op dat alle HIS leveranciers deze via @displayname wel meesturen|
|[ProblemAct statusCode  2014‑06‑09](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/voc-2.16.840.1.113883.11.20.9.19-2014-06-09T000000.html) |[ActStatusActiveAbortedSuspendedCompleted](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-2.16.840.1.113883.3.1937.777.11.11.2-2017-05-17T140712.html)| zie https://github.com/Duometis/ncp-conversie/issues/46 het lijkt alsof niet de juiste valueset is gebruikt voor mapping. Alles wat door komt moet er in komen want is relevant voor overdracht|


