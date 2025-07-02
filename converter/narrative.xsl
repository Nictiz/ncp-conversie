<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" exclude-result-prefixes="xsl dm" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns="urn:hl7-org:v3" xmlns:dm="http://duometis.nl/functions" xmlns:nf="http://www.nictiz.nl/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="dm"/>
    <xsl:include href="section-active-problems.xsl"/>
    <xsl:include href="section-allergies.xsl"/>
    <xsl:include href="section-medicationsummary.xsl"/>
    <xsl:include href="dm-functions.xsl"/>

    <xsl:template match="hl7:text[parent::hl7:section]" exclude-result-prefixes="dm nf">
        <xsl:choose>
            <xsl:when test="../hl7:code[@code = '48765-2']">
                <xsl:call-template name="allergyNarrative"/>
            </xsl:when>
            <xsl:when test="../hl7:code[@code = '11450-4']">
                <xsl:call-template name="problemNarrative"/>
            </xsl:when>
            <xsl:when test="../hl7:code[@code = '11348-0']">
                <xsl:call-template name="problemNarrative"/>
            </xsl:when>
            <xsl:when test="../hl7:code[@code = '10160-0']">
                <xsl:call-template name="medicationNarrative"/>
            </xsl:when>
            <!-- Copy other (existing) section texts -->
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="//processing-instruction()"/>
    
    <!-- Expliciet kopieren van entry voorkomt dat andere templates aangeroepen worden. -->
    <xsl:template match="hl7:entry">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
