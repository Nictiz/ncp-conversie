<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" exclude-result-prefixes="xsl dm" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:dm="http://duometis.nl/functions" xmlns:nf="http://www.nictiz.nl/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="dm"/>

    <xsl:param name="doCts" select="false()" as="xs:boolean"/>
    <xsl:param name="targetLanguage" select="'en-US'" as="xs:string"/>

    <xsl:variable name="maphref" select="'../terminology/mapping.xml'"/>
    <xsl:variable name="mapping" select="doc($maphref)"/>
    <xsl:variable name="langhref" select="'../terminology/languagemap.xml'"/>
    <xsl:variable name="languagemap" select="doc($langhref)"/>
    <xsl:variable name="unencodedhref" select="'../terminology/unencoded-codesystems.xml'"/>
    <xsl:variable name="unencoded" select="doc($unencodedhref)"/>

    <xsl:key name="codemapping" match="row" use="nl_code"/>

    <xsl:template match="hl7:*[@code][@codeSystem]">
        <xsl:choose>
            <!-- Some codesystems will be unencoded, the OpenNCP refuses to accept codes from unknown systems. -->
            <xsl:when test="@codeSystem = $unencoded//@codeSystem">
                <xsl:comment>Codesytem from unencoded list, provide originalText</xsl:comment>
                <xsl:copy>
                    <xsl:attribute name="nullFlavor">OTH</xsl:attribute>
                    <xsl:attribute name="codeSystem">2.16.840.1.113883.5.1008</xsl:attribute>
                    <xsl:copy-of select="@xsi:type"/>
                    <xsl:if test="hl7:originalText">
                        <xsl:copy-of select="hl7:originalText"/>
                    </xsl:if>
                    <xsl:if test="not(hl7:originalText)">
                        <xsl:element name="originalText">
                            <xsl:value-of select="@displayName"/>
                        </xsl:element>
                    </xsl:if>
                    <translation>
                        <xsl:copy-of select="@*"/>
                    </translation>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- Find a translation for each coded element and <translation> elements beneath. 
            In the case of medication al lower level translation (GPK) may be the one to lookup. -->
                <xsl:variable name="translations">
                    <xsl:for-each select="./descendant-or-self::hl7:*[@code][@codeSystem]">
                        <xsl:variable name="lookup" select="@code/string()"/>
                        <xsl:variable name="lookupSystem" select="@codeSystem/string()"/>
                        <xsl:copy-of select="$mapping//row/key('codemapping', $lookup)[nl_codesystem/string() = $lookupSystem]"/>
                    </xsl:for-each>
                </xsl:variable>
                <!-- There should be only one, pick the first -->
                <xsl:variable name="translation" select="$translations[1]/row"/>
                <xsl:comment>
            <xsl:choose>
                <xsl:when test="$translation">
                    <xsl:value-of select="$translation/soort_mapping/string()"/>
                </xsl:when>
                <xsl:otherwise>No mapping</xsl:otherwise>
            </xsl:choose>
        </xsl:comment>
                <xsl:choose>
                    <!-- When there is a CTS mapping, make the EU side the code -->
                    <xsl:when test="$translation/soort_mapping = 'CTS' and $doCts">
                        <xsl:choose>
                            <!-- GPK to ATC mapping is already done in medication summary translation -->
                            <xsl:when test="$translation/eu_codesystem = '2.16.840.1.113883.6.73'">
                                <xsl:copy-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy>
                                    <xsl:attribute name="code" select="$translation/eu_concept_code/string()"/>
                                    <xsl:attribute name="codeSystem" select="$translation/$translation/eu_codesystem/string()"/>
                                    <xsl:attribute name="displayName" select="$translation/eu_description/string()"/>
                                    <xsl:copy-of select="@xsi:type"/>
                                    <!-- And put all other codes and translations as translation -->
                                    <xsl:for-each select="./descendant-or-self::hl7:*[@code][@codeSystem]">
                                        <translation>
                                            <xsl:copy-of select="@*"/>
                                        </translation>
                                    </xsl:for-each>
                                </xsl:copy>                                
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- For NEC and OTH, add nullFlavor as code -->
                    <xsl:when test="($translation/soort_mapping = 'NEC') and ($translation/nullflavour = 'OTH')">
                        <xsl:copy>
                            <xsl:attribute name="nullFlavor" select="'OTH'"/>
                            <xsl:attribute name="codeSystem" select="@codeSystem"/>
                            <xsl:copy-of select="@xsi:type"/>
                            <xsl:if test="hl7:originalText">
                                <xsl:copy-of select="hl7:originalText"/>
                            </xsl:if>
                            <xsl:if test="not(hl7:originalText)">
                                <xsl:element name="originalText">
                                    <xsl:value-of select="@displayName"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:variable name="translationCode" select="$translation/translation_code/string()"/>
                            <xsl:variable name="translationCodeSystem" select="$translation/translation_codesystem/string()"/>
                            <!-- Put the NEC translation in an <translation> element -->
                            <translation>
                                <xsl:attribute name="code" select="$translationCode"/>
                                <xsl:attribute name="codeSystem" select="$translationCodeSystem"/>
                                <xsl:attribute name="displayName" select="$translation/displayname/string()"/>
                                <xsl:copy-of select="@xsi:type"/>
                            </translation>
                            <!-- And put all other codes and translations as translation -->
                            <xsl:for-each select="./descendant-or-self::hl7:*[@code != $translationCode][@codeSystem != $translationCodeSystem]">
                                <translation>
                                    <xsl:copy-of select="@*"/>
                                </translation>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <!-- For NEC w/o OTH, use current code -->
                    <xsl:when test="($translation/soort_mapping = 'NEC') and ($translation/nullflavour != 'OTH')">
                        <xsl:comment>NEC w/o OTH in mapping</xsl:comment>
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <!-- For TT translations use unencoded text -->
                    <xsl:when test="($translation/soort_mapping = 'TXT') or ($translation/soort_mapping = 'Tekst')">
                        <xsl:copy>
                            <xsl:attribute name="nullFlavor" select="'OTH'"/>
                            <xsl:attribute name="codeSystem" select="'2.16.840.1.113883.5.1008'"/>
                            <xsl:attribute name="xsi:type">CD</xsl:attribute>
                            <!-- Put the TEXT translation in an <originalText> element -->
                            <originalText>
                                <xsl:value-of select="@displayName/string()"/>
                            </originalText>
                            <!-- And put original as translation -->
                            <translation>
                                <xsl:copy-of select="(@* except @displayName)"/>
                                <xsl:attribute name="displayName" select="$translation/text/string()"/>
                            </translation>
                        </xsl:copy>
                    </xsl:when>
                    <!-- Translate LOINC section codes etc. -->
                    <xsl:when test="string-length($targetLanguage) > 0">
                        <xsl:variable name="lookup" select="@code/string()"/>
                        <xsl:variable name="lookupSystem" select="@codeSystem/string()"/>
                        <xsl:variable name="display" select="$languagemap//map[@language = $targetLanguage]/code[@code = $lookup][@codeSystem = $lookupSystem]"/>
                        <xsl:choose>
                            <xsl:when test="$display">
                                <xsl:copy>
                                    <xsl:copy-of select="(@* except @displayName)"/>
                                    <xsl:copy-of select="$display/@displayName"/>
                                    <xsl:copy-of select="node()"/>
                                </xsl:copy>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
