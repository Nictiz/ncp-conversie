<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:dm="http://duometis.nl/functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ph="urn:hl7-org:pharm" xmlns:pharm="urn:ihe:pharm:medication" exclude-result-prefixes="xs" version="2.0">

    <xsl:variable name="maphref" select="'../terminology/mapping.xml'"/>
    <xsl:variable name="mapping" select="doc($maphref)"/>
    <xsl:key name="codemapping" match="row" use="nl_code"/>

    <xsl:template name="section-medicationsummary" exclude-result-prefixes="#all">
        <xsl:comment>Medication summary</xsl:comment>
        <!-- History of medication use -->
        <component>
            <section classCode="DOCSECT">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.2.3"/>
                <templateId root="2.16.840.1.113883.10.20.1.8"/>
                <code code="10160-0" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Medicijngebruik"/>
                <title>Medicijngebruik</title>
                <text>TODO, no text now. </text>
                <xsl:if test="count(.//hl7:substanceAdministration) = 0">
                    <xsl:call-template name="noMedicationInformation"/>
                </xsl:if>
                <xsl:apply-templates select="hl7:QUMA_IN991203NL02"/>
            </section>
        </component>
    </xsl:template>

    <xsl:template name="noMedicationInformation" exclude-result-prefixes="#all">
        <entry>
            <substanceAdministration classCode="SBADM" moodCode="INT">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.4"/>
                <templateId root="2.16.840.1.113883.10.20.1.24"/>
                <id root="2.16.840.1.113883.2.4.3.46.10.6.1" extension="{concat('med-none-', translate(substring-before(xs:string(current-dateTime()), '.'), 'T-:', ''))}"/>
                <code code="no-known-medications" codeSystem="2.16.840.1.113883.5.1150.1" displayName="No known medications"/>
                <text>
                    <reference value="#Medication_Unknown"/>
                </text>
                <statusCode code="completed"/>
                <effectiveTime nullFlavor="UNK" xsi:type="IVL_TS"/>
                <effectiveTime nullFlavor="NA"/>
                <consumable>
                    <manufacturedProduct classCode="MANU">
                        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.31"/>
                        <manufacturedMaterial classCode="MMAT" determinerCode="KIND" nullFlavor="NA">
                            <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.32"/>
                        </manufacturedMaterial>
                    </manufacturedProduct>
                </consumable>
            </substanceAdministration>
        </entry>
    </xsl:template>

    <xsl:template match="hl7:QUMA_IN991203NL02">
        <!-- Pas op deze zijn genest, alleen de bovenste hier meenemen. -->
        <!-- Zowel 'eigen' als 'andermans' medicatieafspraken meenemen.
            https://github.com/Duometis/ncp-conversie/issues/56
        -->
        <xsl:apply-templates select=".//hl7:substanceAdministration[hl7:templateId/@root = ('2.16.840.1.113883.2.4.3.11.60.20.77.10.9235', '2.16.840.1.113883.2.4.3.11.60.20.77.10.9241')]"/>
    </xsl:template>

    <xsl:template match="hl7:substanceAdministration[hl7:templateId/@root = ('2.16.840.1.113883.2.4.3.11.60.20.77.10.9235', '2.16.840.1.113883.2.4.3.11.60.20.77.10.9241')]" exclude-result-prefixes="#all">
        <!-- De dosering indien gesplitst is in aparte subsAdmins in source.
        Als MP CDA Dosering 1x voorkomt: 
        - Normal Dosing 1.3.6.1.4.1.19376.1.5.3.1.4.7.1
        Bij 2x of meer:
        - Split Dosing 1.3.6.1.4.1.19376.1.5.3.1.4.9
        Bij 0x:
        - heel vreemd maar is niet 1..1 M, dan maar overnemen wat je hebt?
        -->
        <xsl:variable name="aantal_doseringen" select="count(.//hl7:substanceAdministration/hl7:templateId[@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9149'])"/>
        <!-- substanceAdministration .. R-->
        <xsl:variable name="medicatieAfspraak" select="."/>
        <!-- Dit is de dosering hl7:substanceAdministration -->
        <xsl:variable name="dosering1" select="(.//hl7:substanceAdministration[hl7:templateId[@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9149']])[1]"/>
        <entry>
            <substanceAdministration classCode="SBADM">
                <xsl:choose>
                    <xsl:when test="dm:isFuture($medicatieAfspraak/hl7:effectiveTime/hl7:high/@value/string())">
                        <xsl:attribute name="moodCode">INT</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="moodCode">EVN</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="medicationContent">
                    <xsl:with-param name="templateId">1.3.6.1.4.1.19376.1.5.3.1.4.7.1</xsl:with-param>
                    <xsl:with-param name="medicatieAfspraak" select="."/>
                    <xsl:with-param name="dosering" select="$dosering1"/>
                    <xsl:with-param name="aantal_doseringen" select="$aantal_doseringen"/>
                </xsl:call-template>
                <!-- entryRelationship 0..* R-->
                <!--<xsl:for-each select="">
                        <entryRelationship typeCode="SUBJ"/>
                    </xsl:for-each>-->
                <!-- sequenceNumber 1..1 R-->
                <xsl:if test="$aantal_doseringen > 1">
                    <!-- Skip for now, see: https://github.com/Duometis/ncp-conversie/issues/81 -->
                    <!--<xsl:for-each select="(.//hl7:substanceAdministration[hl7:templateId[@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9149']])[position() > 1]">
                        <entryRelationship typeCode="COMP">
                            <substanceAdministration classCode="SBADM">
                                <xsl:choose>
                                    <xsl:when test="dm:isFuture($medicatieAfspraak/hl7:effectiveTime/hl7:high/@value/string())">
                                        <xsl:attribute name="moodCode">INT</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="moodCode">EVN</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:apply-templates select="../hl7:sequenceNumber"/>
                                <xsl:call-template name="medicationContent">
                                    <xsl:with-param name="templateId">1.3.6.1.4.1.19376.1.5.3.1.4.9</xsl:with-param>
                                    <xsl:with-param name="medicatieAfspraak" select="$medicatieAfspraak"/>
                                    <xsl:with-param name="dosering" select="."/>
                                </xsl:call-template>
                            </substanceAdministration>
                        </entryRelationship>
                    </xsl:for-each>-->
                </xsl:if>
            </substanceAdministration>
        </entry>
    </xsl:template>

    <xsl:template name="medicationContent">
        <xsl:param name="templateId"/>
        <xsl:param name="medicatieAfspraak"/>
        <xsl:param name="dosering"/>
        <xsl:param name="aantal_doseringen"/>
        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.4"/>
        <templateId root="2.16.840.1.113883.10.20.1.24"/>
        <templateId root="{$templateId}"/>
        <!-- id is 1..1 M in eHDSI, there is no id on dosing in AZ, so we concat MA id with dosing seq.nr. -->
        <id extension="{concat($medicatieAfspraak/hl7:id/@extension, '-', ../hl7:sequenceNumber/@value)}">
            <xsl:apply-templates select="$medicatieAfspraak/hl7:id/@root"/>
        </id>
        <xsl:apply-templates select="$medicatieAfspraak/hl7:text"/>
        <!-- statusCode 1..1 M-->
        <!-- See: https://github.com/Duometis/ncp-conversie/issues/57
             use completed when end date in future, else active (also when no end date is present)-->
        <xsl:choose>
            <xsl:when test="dm:isFuture($medicatieAfspraak/hl7:effectiveTime/hl7:high/@value/string())">
                <statusCode code="active"/>
            </xsl:when>
            <xsl:otherwise>
                <statusCode code="completed"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- <effectiveTime xsi:type="IVL_TS"> is 0..1 in source -->
        <xsl:choose>
            <xsl:when test="$medicatieAfspraak/hl7:effectiveTime[@xsi:type = 'IVL_TS']">
                <xsl:apply-templates select="$medicatieAfspraak/hl7:effectiveTime[@xsi:type = 'IVL_TS']"/>
            </xsl:when>
            <xsl:otherwise>
                <effectiveTime xsi:type="IVL_TS" nullFlavor="UNK"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- TODO: the other hl7:effectiveTimes. Voor nu, de tweede effectiveTime
                    die in eHDSI verplicht is null; maar voor pivot moet dat vertaald naar
                    eHDSI specs en datatypes, zie https://github.com/Duometis/ncp-conversie/issues/81 -->
        <effectiveTime nullFlavor="UNK"/>
        <xsl:apply-templates select="$medicatieAfspraak/hl7:routeCode"/>
        <!-- doseQuantity 0..1 R-->
        <!-- rateQuantity 0..1 R-->
        <!-- Skip als meer dan 1, is nu niet betrouwbaar -->
        <xsl:if test="$aantal_doseringen = 1">
            <xsl:apply-templates select="($dosering/hl7:doseQuantity | $dosering/hl7:rateQuantity)"/>
        </xsl:if>
        <!-- consumable 1..1 R-->
        <consumable typeCode="CSM">
            <xsl:apply-templates select="$medicatieAfspraak/hl7:consumable/*"/>
        </consumable>
    </xsl:template>

    <xsl:template match="hl7:manufacturedMaterial">
        <xsl:variable name="gpk" select=".//(hl7:code | hl7:translation)[@codeSystem = '2.16.840.1.113883.2.4.4.1']"/>
        <xsl:variable name="lookup" select="$gpk/@code"/>
        <xsl:variable name="lookupSystem" select="'2.16.840.1.113883.2.4.4.1'"/>
        <xsl:variable name="translation" select="$mapping//row/key('codemapping', $lookup)[nl_codesystem/string() = $lookupSystem]"/>
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*"/>
            <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.32"/>
            <xsl:apply-templates select="* except pharm:ingredient"/>
            <xsl:if test="$gpk and $translation">
                <ph:asSpecializedKind classCode="GRIC">
                    <ph:generalizedMaterialKind classCode="MMAT" determinerCode="KIND">
                        <ph:code code="{$translation/eu_concept_code/string()}" codeSystem="2.16.840.1.113883.6.73" codeSystemName="Anatomical Therapeutic Chemical" displayName="{$translation/eu_description/string()}"/>
                    </ph:generalizedMaterialKind>
                </ph:asSpecializedKind>
            </xsl:if>
            <!-- Trial for now, see #128 -->
            <!--<xsl:for-each select="./hl7:code | ./hl7:code/hl7:translation">
                <ph:asSpecializedKind classCode="GEN">
                    <ph:generalizedMaterialKind classCode="MMAT" determinerCode="KIND">
                        <ph:code><xsl:copy-of select="@*"></xsl:copy-of></ph:code>
                    </ph:generalizedMaterialKind>
                </ph:asSpecializedKind>
            </xsl:for-each>-->
            <!-- Ingredient niet overnemen, codering valt niet op coderingen eHDSI te mappen. Zie : https://github.com/Duometis/ncp-conversie/issues/92-->
            <!--<xsl:apply-templates select="pharm:ingredient"/>-->
        </xsl:copy>
    </xsl:template>

    <!-- Replace templateId on manufacturedProduct -->
    <xsl:template match="hl7:templateId[@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9254']">
        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.31"/>
    </xsl:template>

    <!-- Template wordt niet gebruikt ivm. https://github.com/Duometis/ncp-conversie/issues/92 , zie ook hierboven.
        De acute zorgh medicatie mist ingredientSubstance die in EU verplicht is, toevoegen. -->
    <xsl:template match="pharm:ingredient">
        <!--<ph:ingredient>
            <xsl:apply-templates select="(@* except @classCode)" />
            <xsl:attribute name="classCode" select="'ACTI'"/>
            <ph:ingredientSubstance classCode="MMAT" determinerCode="KIND">
                <xsl:apply-templates select="*"/>
            </ph:ingredientSubstance>  
        </ph:ingredient>-->
    </xsl:template>

    <xsl:template name="medicationNarrative">
        <xsl:choose>
            <xsl:when test="..//hl7:substanceAdministration/hl7:code[@code='no-known-medications'][@codeSystem = '2.16.840.1.113883.5.1150.1']">
                <text>
                    <paragraph ID="Medication_Unknown">Geen bekende medicatie.</paragraph>
                </text>
            </xsl:when>
            <xsl:otherwise>
                <text>
                    <table>
                        <thead>
                            <!--<tr>
                        <th>Medicinal Product</th>
                        <th>Active ingredient</th>
                        <th>Strength</th>
                        <th>Dose form</th>
                        <th>Units per intake</th>
                        <th>Frequency of intakes</th>
                        <th>Route of administration</th>
                        <th>Duration of treatment</th>
                        <th>Medication Reason</th>
                    </tr>-->
                            <tr>
                                <th>Medicijn</th>
                                <th>Actief ingrediënt</th>
                                <th>Sterkte</th>
                                <th>Farmaceutische vorm</th>
                                <th>Eenheden per keer</th>
                                <th>Frequentie</th>
                                <th>Toedieningsweg</th>
                                <th>Doseerduur</th>
                                <th>Reden van voorschrijven</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Single dosing only for now -->
                            <xsl:for-each select="..//hl7:substanceAdministration[hl7:templateId/@root = '1.3.6.1.4.1.19376.1.5.3.1.4.7.1']">
                                <xsl:variable name="hpk" select=".//hl7:manufacturedMaterial//(hl7:code | hl7:translation)[@codeSystem = '2.16.840.1.113883.2.4.4.7']/@displayName"/>
                                <xsl:variable name="prk" select=".//hl7:manufacturedMaterial//(hl7:code | hl7:translation)[@codeSystem = '2.16.840.1.113883.2.4.4.10']/@displayName"/>
                                <xsl:variable name="gpk" select=".//hl7:manufacturedMaterial//(hl7:code | hl7:translation)[@codeSystem = '2.16.840.1.113883.2.4.4.1']/@displayName"/>
                                <!-- ATC is added to eHDSI PS from terminology map -->
                                <xsl:variable name="atc" select=".//ph:asSpecializedKind/ph:generalizedMaterialKind/ph:code[@codeSystem = '2.16.840.1.113883.6.73']/@displayName"/>
                                <xsl:variable name="medicationName" select="(.//hl7:manufacturedMaterial/hl7:name)[1]/text()"/>
                                <xsl:variable name="medicationOriginalText" select="(.//hl7:manufacturedMaterial//hl7:originalText)[1]/text()"/>
                                <xsl:variable name="medicationDesc" select="(.//hl7:manufacturedMaterial/hl7:desc)[1]/text()"/>
                                <tr>
                                    <!--Medicinal Product-->
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="$hpk">
                                                <xsl:value-of select="$hpk"/>
                                            </xsl:when>
                                            <xsl:when test="$prk">
                                                <xsl:value-of select="$prk"/>
                                            </xsl:when>
                                            <xsl:when test="$gpk">
                                                <xsl:value-of select="$gpk"/>
                                            </xsl:when>
                                            <xsl:when test="$medicationName">
                                                <xsl:value-of select="$medicationName"/>
                                            </xsl:when>
                                            <xsl:when test="$medicationOriginalText">
                                                <xsl:value-of select="$medicationOriginalText"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$medicationDesc"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    <!-- Active ingredient -->
                                    <td> </td>
                                    <!-- Strength -->
                                    <td/>
                                    <!-- Dose form -->
                                    <td/>
                                    <!-- Units per intake -->
                                    <td/>
                                    <!-- Frequency of intakes -->
                                    <td/>
                                    <!-- Route of administration -->
                                    <td>
                                        <xsl:value-of select="./hl7:routeCode/@displayName"/>
                                    </td>
                                    <!-- Duration of treatment -->
                                    <td>
                                        <xsl:value-of select="concat('Vanaf: ', dm:formatHl7date(./hl7:effectiveTime/hl7:low/@value/string()), ' tot: ', dm:formatHl7date(./hl7:effectiveTime/hl7:high/@value/string()))"/>
                                    </td>
                                    <!-- Medication Reason -->
                                    <td/>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
