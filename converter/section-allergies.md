# Allergies and Other Adverse Reactions

**Target**: [Template  eHDSI Allergies and Other Adverse Reactions](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.2.12-2021-12-17T092901.html)
   
   Contains 1..*  R [eHDSI Allergy And Intolerance Concern (DYNAMIC)](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.16-DYNAMIC.html)

**Source**: [Template  Organizer AllergieIntoleranties](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.20-2018-04-18T000000.html)  
 Bevat 0..* R [KEZO Allergy Concern (2015‑07‑15)](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.215-2015-07-15T000000.html) 

uit [Memo fit gap analyse dekkingsgraad EU-PS]Allergieën en intoleranties
De huisarts legt alleen medicatie overgevoeligheden vast en geen specifieke stof allergieën. Dit houdt in dat in plateau 1 waarbij het LSP wordt aangesloten op het NCPeH-NL een gedeeltelijkoverzicht van de allergieën en intoleranties kan worden opgeleverd.
## Structure Mapping

Target: Template eHDSI Allergy And Intolerance Concern (act)

- alles overnemen

Target: eHDSI Allergy And Intolerance Concern (observation)

- alles overnemen, behalve:

| Source | Target | remark |
| ----------- | ----------- | ---------- |
| hl7:value CD contains AllergieCategorie from  [AllergieCategorieCodelijst (DYNAMISCH)](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/voc-2.16.840.1.113883.2.4.3.11.60.40.2.8.2.2-DYNAMIC.html) maps onto:| hl7:code CD from [eHDSIAdverseEventType (DYNAMIC)](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.18-2024-01-25T161500.html) | See: https://github.com/Duometis/ncp-conversie/issues/4 and https://github.com/Duometis/ncp-conversie/issues/27|
| If no allergies in source |hl7:value nullFlavor NI| 'No known allergies' is not supported in NL GP systems|
| hl7:participant[@typeCode='CSM'] (Veroorzakende stof) | hl7:participant (The substance that causes the allergy or intolerance, there is only 1 participant in target) |Copy all except code, needs terminology mapping for Veroorzakende Stoffen Lijst|
| hl7:participant[@typeCode='VRF'] (Verifier) | Omit, no such field in target ||
|hl7:entryRelationship (Criticality) contains [KEZO Criticality Observatie](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.218-2015-08-21T000000.html) |hl7:entryRelationship contains [eHDSI Criticality Observation](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.33-2022-03-01T110132.html)|Copy all from target, except value which needs mapping. text is 1..1 M and not in source.|
|hl7:entryRelationship contains [KEZO Reactie Observatie](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.217-2015-07-15T000000.html) with Symptoom in value|[eHDSI Reaction Manifestation](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.44-2022-01-05T163939.html)|Similar valueset, see terminology mappings|
| | Always use 404684003 "Clinical finding" for code in eHDSI Reaction Manifestation, actual code is from a valueset, no similar field in input | See https://github.com/Duometis/ncp-conversie/issues/33 |
| [KEZO Severity Observatie](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.219-2015-07-15T000000.html) | [eHDSI Severity](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.8-2020-09-02T151641.html) | See terminology |
| No fit | [eHDSI Allergy Certainty Observation](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.35-DYNAMIC.html) | Not a fit |
| No fit? | [eHDSI Allergy Status Observation](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.34-DYNAMIC.html)| No fit? See: https://github.com/Duometis/ncp-conversie/issues/60 |

## Terminology Mapping

| Source | Target | Remarks |
|---|---|---|
| [Veroorzakende Stoffen Lijst](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/voc-2.16.840.1.113883.2.4.3.11.60.66.11.119-DYNAMIC.html) | - [eHDSIAllergenNoDrug ](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.19-DYNAMIC.html) (deze zullen niet gebruikt worden met alleen het HIS als bron and [eHDSIActiveIngredient](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.24-DYNAMIC.html) and [eHDSISubstance (DYNAMIC)](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.61-DYNAMIC.html) | VeroorzakendeStof komt bij het HIS uit de uit de G-standaard en zijn gemapt op Engelse ACT termen indien de GPK codes worden meegestuurd. In het geval dat er geen GPK codes worden meegestuurd, kan er geen mapping worden gemaakt en moet de invulling No Information zijn.|
| | | zie boven, onduidelijk hoe de mapping wordt gedaan, zie https://github.com/Duometis/ncp-conversie/issues/36 |
| [ErnstCodelijst ](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/voc-2.16.840.1.113883.2.4.3.11.60.40.2.8.2.6-DYNAMIC.html)| [eHDSI Severity](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.3.8-DYNAMIC.html) | Severity codelijst (soort vertaling 1:1) |
| [SymptoomCodelijst](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/voc-2.16.840.1.113883.2.4.3.11.60.40.2.8.2.5-2020-09-01T000000.html) | [eHDSIReactionAllergy](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.11-2023-07-05T133500.html) and [eHDSIIllnessandDisorder](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.5-2024-01-25T163000.html) | Manifestation, See issue https://github.com/Duometis/ncp-conversie/issues/32 (soort vertaling: CTS, 1:1, NEC|
|||@marc conceptmap om NEC mapping voor SymptoomCodelijst uit te proberen staat hier [conceptmapNEC.fsh](https://github.com/Duometis/ncp-conversie/commit/24b9daef79eb8ac7c0f7b80632269e04e2252bf2)
| [Criticality](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20240603T081743/voc-2.16.840.1.113883.2.4.3.11.60.66.11.117-2015-08-21T000000.html) | [eHDSICriticality](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.57-2022-04-28T160000.html) | See issue https://github.com/Duometis/ncp-conversie/issues/29

