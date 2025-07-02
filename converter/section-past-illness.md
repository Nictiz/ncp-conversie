# eHDSI History Of Past Illness

Target: [Template  eHDSI History Of Past Illness](https://art-decor.ehdsi.eu/publication/epsos-html-20240422T073854/tmp-1.3.6.1.4.1.12559.11.10.1.3.1.2.10-2020-09-02T140710.html)

Source: [Template Organizer Concerns/Episodes](https://decor.nictiz.nl/pub/acutezorg/acutezorg-html-20210122T101324/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.16-2018-04-18T000000.html)

See [Section Active Problems](converter\section-active-problems.md) for main processing, for Past Illness the following applies:

- When there are no closed concerns, we do not generate an 'no known' section, since this section is optional.
- statusCode is always 'completed', eHDSI requires this. See: https://github.com/Duometis/ncp-conversie/issues/46
- When there is no end date on the problem (possible since closed concerns have an end date on the concern, which may not be the problem end date), we add an problem end date with nullFlavor UNK in the output. See: https://github.com/Duometis/ncp-conversie/issues/54