<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:hl7nl="urn:hl7-nl:v3" xmlns:sdtc="urn:hl7-org:sdtc" version="2.0">

    <xsl:template match="hl7:recordTarget">
        <recordTarget typeCode="RCT" contextControlCode="OP">
            <xsl:for-each select="hl7:patientRole">
                <patientRole classCode="PAT">
                    <!-- id 1..* R-->
                    <xsl:apply-templates select="hl7:id"/>
                    <!-- addr 1..1 R-->
                    <xsl:if test="not(hl7:addr)">
                        <addr nullFlavor="NI"/>
                    </xsl:if>
                    <!-- epSOS AD -->
                    <xsl:apply-templates select="hl7:addr"/>
                    <!-- telecom 1..* R-->
                    <xsl:if test="not(hl7:telecom)">
                        <telecom nullFlavor="NI"/>
                    </xsl:if>
                    <xsl:apply-templates select="hl7:telecom"/>
                    <!-- patient 1..1 R-->
                    <xsl:for-each select="hl7:patient">
                        <patient classCode="PSN" determinerCode="INSTANCE">

                            <!-- name 1..* R-->
                            <xsl:for-each select="hl7:name">
                                <xsl:choose>
                                    <!-- Only text -->
                                    <xsl:when test="not(*)">
                                        <name>
                                            <family>
                                                <xsl:value-of select="text()"/>
                                            </family>
                                            <given>
                                                <xsl:value-of select="text()"/>
                                            </given>
                                        </name>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <name>
                                            <xsl:apply-templates select="hl7:given"/>
                                            <xsl:variable name="family" select="string-join((* except (hl7:given, hl7:validTime))/string())"/>
                                            <family>
                                                <xsl:value-of select="$family"/>
                                            </family>
                                        </name>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            <xsl:apply-templates select="(hl7:administrativeGenderCode, hl7:birthTime)"/>
                        </patient>
                    </xsl:for-each>
                </patientRole>
            </xsl:for-each>
        </recordTarget>
    </xsl:template>

    <xsl:template match="hl7:administrativeGenderCode">
        <xsl:choose>
            <xsl:when test="@displayName">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@code = 'M'">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="displayName" select="'Man'"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@code = 'F'">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="displayName" select="'Vrouw'"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@code = 'UN'">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="displayName" select="'Ongedifferentieerd'"/>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
