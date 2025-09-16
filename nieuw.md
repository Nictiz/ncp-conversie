# XSLT and openNCP transformations
```mermaid
sequenceDiagram

  participant A as NCP country NL
 
create participant XSLT

 
    A->>XSLT: response bundle SAZ

    A->>XSLT: SAZ, params: id, setId
  
    XSLT->>XSLT: convert to ePS
Note right of XSLT: syntax conversion
Note right of XSLT: addition NL-narrative

    XSLT->>A: eHDSI friendly version
    A->>A: create original document (pdf)
XSLT->>XSLT: add strenght, unit, farmaceutische vorm based on GPK-ATC map
Note right of XSLT: This is where the data for the GPK split is inserted
Note right of XSLT: Also row per active ingredient added or is this done during the syntax conversion?  
Note left of A: PDF created from added NL-narrative
    XSLT->>XSLT: add transations to items that are not mapped onto MVC valueset items (NEC)
Note right of XSLT: This is the OTH-er-workaround
  create participant openNCP
    XSLT->>openNCP: eHDSI friendly + NEC 
   openNCP->>openNCP: add CTS valueset items
Note left of openNCP: mapped transformations and translations via TSAM-TS
create participant NCP country ES
    openNCP->> NCP country ES: eHDSI pivot

```
