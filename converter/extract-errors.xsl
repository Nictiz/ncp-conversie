<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="3.0">
    
    <xsl:output method="xml" indent="true" exclude-result-prefixes="#all"/>
        
    <xsl:template match="hl7:MCCI_IN200101" >
        <errors>
            <xsl:apply-templates select="*"/>
        </errors>
    </xsl:template>
    
    <xsl:template match="hl7:acknowledgement">
        <xsl:copy-of select="." copy-namespaces="0"/>
    </xsl:template>
    
    <xsl:template match="hl7:queryAck">
        <xsl:copy-of select="." copy-namespaces="0"/>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()" />
    </xsl:template>      
</xsl:stylesheet>