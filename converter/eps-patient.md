# ePS Patient

**Target**: [Template  eHDSI Patient Summary](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.1.3-2024-04-19T100332.html), see: recordTarget.patientRole


**Source**: the source is a batch of CDA clinical statements, possibly several patient records, for the same patient but from different sources, are available. The patient records in the separate building blocks in the acute zorg batch are: [Template  CDA recordTarget SDTC NL BSN Minimal](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/tmp-2.16.840.1.113883.2.4.3.11.60.3.10.2-2017-06-02T000000.html)

For recordTarget, we select an arbitrary one (the first) from the batch, see https://github.com/Duometis/ncp-conversie/issues/12.

Some header fields are fixed values, those are not listed here.

Patient fields:

- id:  COPY, id can be null in AZ but in European context not.

> PS-AK2: Het burgerservicenummer (BSN) zal gebruikt worden ter identificatie van de patiënt.

- addr: COPY, nullFlavor if no address
- telecom: COPY, nullFlavor if no telecom
- patient.name: family and given are mandatory, if absent put full name in both
- name.given: COPY
- name.family: COPY all name parts except given in order 'as is' See:  https://github.com/Duometis/ncp-conversie/issues/15 
- patient.administrativeGenderCode: COPY from source
- patient.birthTime: COPY from source
- patient.guardian: not in source
- patient.languageCommunication: not in source See: https://github.com/Duometis/ncp-conversie/issues/13

## Terminology Mapping 

| source | target | remarks |
| ----------- | ----------- |----------- |
| [GeslachtCodelijst 2015‑04‑01](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/voc-2.16.840.1.113883.2.4.3.11.60.40.2.0.1.1-2015-04-01T000000.html) | [eHDSIAdministrativeGender 2020‑04‑21](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/voc-1.3.6.1.4.1.12559.11.10.1.3.1.42.34-2020-04-21T180000.html) | https://github.com/Duometis/ncp-conversie/issues/18 soort vertaling: 1:1|

