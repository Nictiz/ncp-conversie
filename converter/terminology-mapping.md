# Terminology mapping

This code needs the latest mapping.xml from https://github.com/Nictiz/ncp-terminologie

Terminology mapping occurs in several places:

- CTS is a part of the NCP which uses the Master Value Catalog to do code-to-code mappings. The mappings are provided by Nictiz. This is not done by the ncp-conversion software. (The ncp-conversion can do a simulated CTS mapping with de doCts flag for testing purposes, this is however not a reliable replacement of the NCP/CTS conversion and should not be used in production.)
- NEC mappings, which is done by the ncp-conversion software.
- TEXT mappings, also done by the ncp-conversion software.

The mappings are done using a mapping.xml in /terminology which is made with the ncp-terminology Github repo code, taking an Excel as input and generating a mapping.xml.

- nl_codesystem: input, to be translated
- versie_nl_codesystem
- nl_code: input, to be translated
- nl_description
- eu_concept_code: only for CTS mappings
- eu_description: only for CTS mappings
- eu_codesystem: only for CTS mappings
- versie_eu_codesystem
- nullflavour_codesystem
- nullflavour: should be 'OTH' for NEC mappings, can be ignored for CTS and Tekst
- translation_codesystem: target for NEC mappings
- translation_code: target for NEC mappings
- displayname: target for NEC mappings
- soort_mapping: CTS, NEC, Tekst
- map: the name of the Excel tab
- text: to be used for TXT mappings

The column 'soort_mapping' decides which mapping is done in ncp-conversie, CTS is skipped (unless the doCts flag for testing is used).

## NEC/OTH mappings

Mapping done by terminology_mapping.xslt.

The GPK-ATC mapping is done in: section-medicationsummary.xsl

The ATC codes are supplied in another CDA part than the original GPK codes: therefore this is not done in the generic terminology_mapping.xsl which only changes a code or value element. The section-medicationsummary.xsl will add a generic code construct with the proper ATC code to the pivot document.

Other NEC mappings are done in terminology_mapping.xsl.

This will:
- look for elements which may be translated (all elemnts with code and codeSystem, hl7:*[@code][@codeSystem])
- look in unencoded-codesystems.xml, codes which will lead to an NCP errors for unknown codesystem, and are therefore changed to originalText
- otherwise, find the corresponding row in mapping.xml
- if soort_mapping = 'CTS', skip (unless testing with the doCts flag)
- if soort_mapping = 'NEC' and 'nullflavour' = 'OTH':
  - add OTH and codesytem
  - copy originalText if source has it
  - otherwise use displayName for originalText
  - add translation element with English text from mapping.xml translation columns

I.e. this fragment:

```xml
<value xsi:type="CD"
      code="L03"
      codeSystem="2.16.840.1.113883.2.4.4.31.1"
      displayName="Lage-rugpijn zonder uitstraling"/>
```

will be translated to this:

```xml
<value nullFlavor="OTH"
        codeSystem="2.16.840.1.113883.2.4.4.31.1"
        xsi:type="CD">
    <originalText>Lage-rugpijn zonder uitstraling</originalText>
    <translation code="L03"
                codeSystem="2.16.840.1.113883.2.4.4.31.1"
                displayName="Low back symptoms/complaints without radiaton"
                xsi:type="CD"/>
</value>
```

Existing translation elements in source will be copied as well. This may be higher-level G-standaard codes.

## NEC without OTH

Mapping done by terminology_mapping.xslt.

Code will be copied as-is from source to target.

## Tekst mappings

Mapping done by terminology_mapping.xslt.

Some mappings are marked 'Tekst', they must contain a field 'text'.

The value of 'text' is copied to the translation element.

## G-standaard mapping

Mapping done by section-medicationsummary.xsl.

Mapping for the G-standaard cannot be done in the generic terminology_mapping.xslt since the translated part (ATC-code) which is derived from the G-standaard GPK code is not stored in the eHDSI pivot document in a generic value+translation element, but is stored in a separate construct. 

## Country code mapping

To be done, the country codes aren't properly coded in the AZ batch and need special treatment.
