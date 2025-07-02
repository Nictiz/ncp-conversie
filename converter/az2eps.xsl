<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Author: Marc de Graauw, Linda Mook 2024
-->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:hl7="urn:hl7-org:v3" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns="urn:hl7-org:v3" 
    xmlns:dm="http://duometis.nl/functions" xmlns:nf="http://www.nictiz.nl/functions" xmlns:ph="urn:hl7-org:pharm" xmlns:pharm="urn:ihe:pharm:medication"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:include href="eps-patient.xsl"/>
    <xsl:include href="eps-authororganization.xsl"/>
    <xsl:include href="datatypes-epsos.xsl"/>
    <xsl:include href="section-active-problems.xsl"/>
    <xsl:include href="section-allergies.xsl"/>
    <xsl:include href="section-medicationsummary.xsl"/>
    <xsl:include href="dm-functions.xsl"/>

    <xsl:param name="documentIdRoot"/>
    <xsl:param name="documentSetIdRoot"/>
    <xsl:param name="documentId"/>
    <xsl:param name="documentSetId"/>
    <xsl:param name="targetLanguage"/>
    <xsl:param name="genSchemaRefs" select="false()"/>

    <xsl:output method="xml" indent="true"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select=".//hl7:MCCI_IN200101"/>
    </xsl:template>

    <xsl:template match="hl7:MCCI_IN200101">
        <xsl:if test="$genSchemaRefs">
            <xsl:processing-instruction name="xml-model"> href="../eps/epsos-runtime-20240422T073854/epsos-PatientSummary.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        </xsl:if>

        <ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:ph="urn:hl7-org:pharm" xmlns:sdtc="urn:hl7-org:sdtc">
            <xsl:call-template name="header"/>
            <component>
                <structuredBody>
                    <xsl:call-template name="section-medicationsummary"/>
                    <xsl:call-template name="section-allergies"/>
                    <xsl:call-template name="section-surgeries"/>
                    <!-- Active problems, history of past illness and alerts -->
                    <xsl:call-template name="problems"/>
                    <xsl:call-template name="section-medicaldevices"/>
                </structuredBody>
            </component>
        </ClinicalDocument>
    </xsl:template>

    <xsl:template name="header">
        <xsl:if test="$genSchemaRefs">
            <xsl:attribute name="xsi:schemaLocation">urn:hl7-org:v3 ../../../HL7/CDA-core-2.0/schema/extensions/SDTC/infrastructure/cda/CDA_SDTC.xsd</xsl:attribute>
        </xsl:if>
        <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
        <!-- Template ID for eHDSI Patient Summary L3 document -->
        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.1.3"/>
        <!--<id root="1.2.752.129.2.1.2.1" extension="PS_W7_EU"/>-->
        <id root="{upper-case($documentIdRoot)}" extension="{upper-case($documentId)}"/>
        <!-- Determines the document type "eHDSI Patient Summary Document" -->
        <code code="60591-5" codeSystem="2.16.840.1.113883.6.1" displayName="Patiënt samenvatting"/>
        <!-- title used for display purposes -->
        <title>Patiënt samenvatting</title>
        <!-- time must be precise to the second, and with timezone according to eps specs -->
        <effectiveTime value="{dm:formatTS(fn:current-dateTime())}"/>
        <!-- always N -->
        <confidentialityCode code="N" displayName="normal" codeSystem="2.16.840.1.113883.5.25"/>
        <!-- document language code -->
        <languageCode code="{$targetLanguage}"/>
        <!-- setID: remains unchanged among all the existing transformations, only generate for the eHDSI friendly, copy for pivot and PDF -->
        <setId root="{upper-case($documentSetIdRoot)}" extension="{upper-case($documentSetId)}"/>
        <!-- recordTarget: Patient Information -->
        <xsl:apply-templates select="(.//hl7:recordTarget)[1]"/>
        <!--<xsl:apply-templates select="(//hl7:author)[1]"/>-->
        <xsl:call-template name="addAuthors"/>
        <xsl:call-template name="custodian"/>
        <xsl:call-template name="legalAuthenticator"/>
        <xsl:call-template name="addParticipants"/>
        <documentationOf typeCode="DOC">
            <serviceEvent classCode="PCPR" moodCode="EVN">
                <effectiveTime>
                    <high value="{dm:formatTS(fn:current-dateTime())}"/>
                </effectiveTime>
            </serviceEvent>
        </documentationOf>
        <relatedDocument typeCode="XFRM">
            <parentDocument>
                <xsl:comment>TODO relation to PDF</xsl:comment>
                <id root="2.999" extension="example"/>
            </parentDocument>
        </relatedDocument>
    </xsl:template>

    <xsl:template name="section-surgeries">
        <!-- History of Procedures -->
        <component>
            <section moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.2.11"/>
                <code code="47519-4" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" codeSystemVersion="2.59" displayName="Voorgeschiedenis met verrichtingen"/>
                <title>Voorgeschiedenis met verrichtingen</title>
                <text>
                    <paragraph ID="Procedures_Unknown">Geen informatie over operaties beschikbaar.</paragraph>
                </text>
                <entry>      
                    <procedure classCode="PROC" moodCode="EVN">
                        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.26"/>
                        <id nullFlavor="NI"/>
                        <code code="no-procedure-info" displayName="No information about past history of procedures" codeSystem="2.16.840.1.113883.5.1150.1"/>
                        <text>
                            <reference value="#Procedures_Unknown"/>
                        </text>
                        <statusCode code="completed"/>
                        <effectiveTime nullFlavor="NA" xsi:type="IVL_TS"/>
                    </procedure>
                </entry>
            </section>
        </component>
    </xsl:template>

    <xsl:template name="section-medicaldevices">
        <!-- History of medical device use -->
        <component>
            <section classCode="DOCSECT" moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.2.4"/>
                <templateId root="2.16.840.1.113883.10.20.1.7"/>
                <id nullFlavor="NI"/>
                <code code="46264-8" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" codeSystemVersion="2.59" displayName="Voorgeschiedenis van gebruik van hulpmiddel"/>
                <title>Voorgeschiedenis van gebruik van hulpmiddel</title>
                <text>
                    <paragraph ID="Medical_Devices_None">Geen informatie over hulpmiddelen beschikbaar.</paragraph>
                </text>
                <entry>
                    <supply classCode="SPLY" moodCode="EVN">
                        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.5"/>
                        <text>
                            <reference value="#Medical_Devices_None"/>
                        </text>
                        <effectiveTime xsi:type="IVL_TS">
                            <hl7:low nullFlavor="NA"/>
                        </effectiveTime>
                        <participant typeCode="DEV">
                            <participantRole classCode="MANU">
                                <playingDevice classCode="DEV" determinerCode="INSTANCE">
                                    <code code="no-device-info" displayName="No information about devices" codeSystem="2.16.840.1.113883.5.1150.1"/>
                                </playingDevice>
                            </participantRole>
                        </participant>
                    </supply>
                </entry>
            </section>
        </component>
    </xsl:template>

    <xsl:template match="pharm:*" exclude-result-prefixes="pharm">
        <xsl:element name="ph:{local-name()}" namespace="urn:hl7-org:pharm" >
            <xsl:apply-templates select="@*, node()" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="@* | node()" exclude-result-prefixes="#all">
        <xsl:copy copy-namespaces="false">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="//processing-instruction()"/>

    <xsl:template match="//comment()"/>
</xsl:stylesheet>
