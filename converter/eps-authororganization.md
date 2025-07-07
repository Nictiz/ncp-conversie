# A.1.5 Author and Organisation


**Target**: [Template  eHDSI Patient Summary](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.1.3-2024-04-19T100332.html)   
1 .. * M from [eHDSI Author (DYNAMIC)](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-2.16.840.1.113883.3.1937.777.11.10.102-DYNAMIC.html)  
1..1 M from from [eHDSI LegalAuthenticator (DYNAMIC)](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-2.16.840.1.113883.3.1937.777.11.10.109-DYNAMIC.html)  
1..1 M from [eHDSI Custodian](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-2.16.840.1.113883.3.1937.777.11.10.104-2020-10-06T082529.html)

**Source**: 
- Author:
  - [VZVZ Opleveren Allergie Intoleranties](https://decor.nictiz.nl/pub/vzvz/az-vzvz-html-20230717T130020/tmp-2.16.840.1.113883.2.4.3.111.3.3.10.20-2015-06-01T000000.html)
  - [ControlAct AuthorOrPerformer Device](https://decor.nictiz.nl/pub/vzvz/az-vzvz-html-20230717T130020/tmp-2.16.840.1.113883.2.4.3.11.60.102.10.519-2012-08-01T000000.html)
- [custodian](custodian.xml)
- [legalAuthenticator](legalAuthenticator.xml)

Custodian are legalAuthenticator provided from XML templates with fixed text. Can be changed later See: https://github.com/Duometis/ncp-conversie/issues/22 en https://github.com/Duometis/ncp-conversie/issues/23.

- author is filled with GP systems (HISsen) (containing the GP practice organization) since that is the only possible field in input which is mandatory, as the output is. See: https://github.com/Duometis/ncp-conversie/issues/44
  - assignedAuthoringDevice is required (or person, which we do not have on this level) and is populated with the first available of:
    - 'AORTA Applicatie-id: '+ extension
    - 'UZI-nummer systemen: '+ extension
    - 'SBV-Z Systeemnummer: '+ extension
    - nullFlavor="NI"
  - see: [Template  Assigned Device](https://decor.nictiz.nl/pub/vzvz/az-vzvz-html-20230717T130020/tmp-2.16.840.1.113883.2.4.3.11.60.102.10.513-2012-09-01T000000.html)
- functionCode is "2211" displayName:"Generalist medical practitioners", see: https://github.com/Duometis/ncp-conversie/issues/38
- the multiple systems (HIS) in input are deduplicated on UZI number, and the first one is used. (If not, output would contain at least 6 duplicate authors)
- participants are deduplicated (best effort, duplicates may occur due to various identifiers used) and all added