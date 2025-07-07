<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:hl7="urn:hl7-org:v3" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dm="http://duometis.nl/functions" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:nf="http://www.nictiz.nl/functions" exclude-result-prefixes="xs nf" version="2.0">

    <!--<xsl:template match="hl7:name[parent::hl7:assignedPerson]">
        <!-\- temporary solution -\->
        <name nullFlavor="NI"/>
    </xsl:template>-->

    <xsl:template name="addAuthors" exclude-result-prefixes="dm">
        <!-- Deduplicate on Aorta id -->
        <xsl:for-each-group select="//hl7:authorOrPerformer[parent::hl7:ControlActProcess]" group-by=".//hl7:id[@root = '2.16.840.1.113883.2.4.6.6']/@extension">
            <xsl:call-template name="makeAuthor"/>
        </xsl:for-each-group>
        <!-- If not present, deduplicate on the first extension -->
        <xsl:if test="not(//hl7:authorOrPerformer[parent::hl7:ControlActProcess]//hl7:id[@root = '2.16.840.1.113883.2.4.6.6'])"> 
            <xsl:for-each-group select="//hl7:authorOrPerformer[parent::hl7:ControlActProcess]" group-by="(.//hl7:AssignedDevice/hl7:id/@extension)[1]">
                <xsl:call-template name="makeAuthor"/>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:template>

    <xsl:template name="makeAuthor">
        <author typeCode="AUT" contextControlCode="OP">
            <!-- functionCode 0..1 R-->
            <functionCode code="2211" codeSystem="2.16.840.1.113883.2.9.6.2.7" displayName="Generalist medical practitioners"/>
            <!-- time 1..1 R-->
            <time nullFlavor="NI"/>
            <!-- assignedAuthor 1..1 R-->
            <xsl:for-each select="hl7:participant/hl7:AssignedDevice">
                <assignedAuthor classCode="ASSIGNED">
                    <xsl:apply-templates select="hl7:id"/>
                    <xsl:if test="not(hl7:id)">
                        <id nullFlavor="NI"/>
                    </xsl:if>
                    <xsl:apply-templates select="hl7:addr"/>
                    <xsl:if test="not(hl7:addr)">
                        <addr nullFlavor="NI"/>
                    </xsl:if>
                    <xsl:apply-templates select="hl7:telecom"/>
                    <xsl:if test="not(hl7:telecom)">
                        <telecom nullFlavor="NI"/>
                    </xsl:if>
                    <assignedAuthoringDevice classCode="DEV" determinerCode="INSTANCE">
                        <softwareName>
                            <xsl:choose>
                                <xsl:when test="hl7:id/@root='2.16.840.1.113883.2.4.6.6'">
                                    <xsl:value-of select="concat('AORTA Applicatie-id: ', hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension/string())"/>
                                </xsl:when>
                                <xsl:when test="hl7:id/@root='2.16.528.1.1007.3.2'">
                                    <xsl:value-of select="concat('UZI-nummer systemen: ', hl7:id[@root='2.16.528.1.1007.3.2']/@extension/string())"/>
                                </xsl:when>
                                <xsl:when test="hl7:id/@root='2.16.528.1.1007.4'">
                                    <xsl:value-of select="concat('SBV-Z Systeemnummer: ', hl7:id[@root='2.16.528.1.1007.4']/@extension/string())"/>
                                </xsl:when>
                                <xsl:otherwise><assignedAuthoringDevice nullFlavor="NI"/></xsl:otherwise>
                            </xsl:choose>
                        </softwareName>
                    </assignedAuthoringDevice>
                    <xsl:for-each select="hl7:Organization">
                        <representedOrganization>
                            <xsl:apply-templates select="hl7:id"/>
                            <xsl:if test="not(hl7:id)">
                                <id nullFlavor="NI"/>
                            </xsl:if>
                            <xsl:apply-templates select="hl7:name"/>
                            <xsl:if test="not(hl7:name)">
                                <name nullFlavor="NI"/>
                            </xsl:if>
                            <xsl:apply-templates select="hl7:telecom"/>
                            <xsl:if test="not(hl7:telecom)">
                                <telecom nullFlavor="NI"/>
                            </xsl:if>
                            <xsl:apply-templates select="hl7:addr"/>
                            <xsl:if test="not(hl7:addr)">
                                <addr>
                                    <country>NL</country>
                                </addr>
                            </xsl:if>
                        </representedOrganization>
                    </xsl:for-each>
                    <xsl:if test="not(hl7:Organization)">
                        <representedOrganization nullFlavor="NI">
                            <id nullFlavor="NI"/>
                            <name nullFlavor="NI"/>
                            <telecom  nullFlavor="NI"/>
                            <addr>
                                <country>NL</country>
                            </addr>
                        </representedOrganization>
                    </xsl:if>
                </assignedAuthor>
            </xsl:for-each>
        </author>
    </xsl:template>

    <xsl:template name="addParticipants">
        <xsl:for-each-group select="//hl7:organizer[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.66.10.16']//hl7:participantRole" group-by=".//hl7:id">
            <participant typeCode="IND">
                <templateId root="1.3.6.1.4.1.19376.1.5.3.1.2.4"/>
                <functionCode code="PCP" codeSystem="2.16.840.1.113883.5.88"/>
                <associatedEntity classCode="PRS">
                    <xsl:apply-templates select="(hl7:addr, hl7:telecom)"/>
                    <xsl:if test="not(hl7:addr)">
                        <addr nullFlavor="NI"/>
                    </xsl:if>
                    <xsl:if test="not(hl7:telecom)">
                        <telecom nullFlavor="NI"/>
                    </xsl:if>
                    <associatedPerson>
                        <xsl:apply-templates select="hl7:playingEntity/hl7:name"/>
                    </associatedPerson>
                </associatedEntity>
            </participant>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template name="custodian" exclude-result-prefixes="#all">
        <custodian>
            <xsl:copy-of select="doc('custodian.xml')"/>
        </custodian>
    </xsl:template>

    <xsl:template name="legalAuthenticator" exclude-result-prefixes="#all">
        <legalAuthenticator typeCode="LA" xmlns="urn:hl7-org:v3">
            <!-- To be replaced by definitive custodian -->
            <time value="{dm:formatTS(fn:current-dateTime())}"/>
            <signatureCode code="S"/>
            <xsl:copy-of select="doc('legalAuthenticator.xml')"/>
        </legalAuthenticator>
    </xsl:template>
</xsl:stylesheet>
