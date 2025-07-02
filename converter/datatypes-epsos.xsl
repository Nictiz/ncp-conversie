<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:template match="hl7:addr">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates/>
            <xsl:if test="not(hl7:country)">
                <country>NL</country>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="hl7:postalCode | hl7:county">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@* except (@code, @codeSystem)"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="hl7:country">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@* except (@code, @codeSystem)"/>
            <xsl:copy-of select="if (text()) then text() else if (@code/string()) then @code/string else 'NL'"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="hl7:name[parent::*[@classCode='PSN']]">
        <xsl:copy copy-namespaces="no">
            <xsl:if test="not(hl7:given)">
                <given nullFlavor="NI"/>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="not(hl7:family)">
                <family nullFlavor="NI"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
