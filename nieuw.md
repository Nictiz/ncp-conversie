## nieuwe plaatjes voor proces
# XSLT and openNCP transformations
```mermaid
sequenceDiagram
  participant B as NCP country B
  participant A as NCP country NL
create participant XSLT as XSLT
Note right of XSLT: consider this as XSLT-in-a-box
    A->>XSLT: response bundle SAZ
    A->>XSLT: SAZ, params: id, setId
    XSLT->>XSLT: convert to PS structure
Note right of XSLT: syntax conversion
Note right of XSLT: addition NL-narrative  
    XSLT->>XSLT: add transations to items that are not mapped onto MVC valueset items (NEC)
Note right of XSLT: This is the OTH-er-workaround
  create participant openNCP
    XSLT->>openNCP: eHDSI friendly + NEC 
   openNCP->>openNCP: transcode and ADD from CTS valueset items
Note left of openNCP: mapped transformations and translations via TSAM-TS
openNCP->>A:pivot CDA L3 xml
A->>A : create 'original document'
Note right of A: uses narrative sections from pivot + NL stylesheet to create a pdf
A->> B: pivot CDA L3
  A->> B: 'original document' CDA L1
```
