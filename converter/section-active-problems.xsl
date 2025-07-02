<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:dm="http://duometis.nl/functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xs" version="2.0">

    <xsl:template name="problems">
        <xsl:variable name="problems" select="//hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.66.10.213']"/>
        <xsl:variable name="alerts" select="//hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.66.10.214']"/>
        <xsl:variable name="activeproblems" select="($problems | $alerts)[not(../../hl7:effectiveTime/hl7:high)]"/>
        <xsl:variable name="inactiveproblems" select="($problems | $alerts)[../../hl7:effectiveTime/hl7:high]"/>
        <xsl:call-template name="section-active-problems">
            <xsl:with-param name="problems" select="$activeproblems"/>
        </xsl:call-template>
        <xsl:if test="count($inactiveproblems) > 0">
            <xsl:call-template name="section-past-illness">
                <xsl:with-param name="problems" select="$inactiveproblems"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="section-active-problems">
        <xsl:param name="problems"/>
        <xsl:comment>Active problems</xsl:comment>
        <component>
            <section moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.2.9"/>
                <templateId root="2.16.840.1.113883.10.20.1.11"/>
                <!-- No id, source has no section.id and is 0..1 R in target -->
                <code code="11450-4" codeSystem="2.16.840.1.113883.6.1" displayName="Probleemlijst"/>
                <title>Probleemlijst</title>
                <text>TODO, narrative</text>
                <xsl:if test="count($problems) = 0">
                    <xsl:call-template name="noKnownActiveProblems"/>
                </xsl:if>
                <xsl:for-each select="$problems">
                    <xsl:call-template name="problem">
                        <xsl:with-param name="active" select="true()"/>
                        <xsl:with-param name="problem" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </section>
        </component>
    </xsl:template>

    <xsl:template name="section-past-illness">
        <xsl:param name="problems"/>
        <xsl:comment>History of past illness</xsl:comment>
        <component>
            <section moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.2.10"/>
                <templateId root="1.3.6.1.4.1.19376.1.5.3.1.3.8"/>
                <!-- No id, source has no section.id and is 0..1 R in target -->
                <code code="11348-0" codeSystem="2.16.840.1.113883.6.1" displayName="Ziektegeschiedenis"/>
                <title>Ziektegeschiedenis</title>
                <text>TODO, narrative</text>
                <xsl:for-each select="$problems">
                    <xsl:call-template name="problem">
                        <xsl:with-param name="active" select="false()"/>
                        <xsl:with-param name="problem" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </section>
        </component>
    </xsl:template>

    <xsl:template name="noKnownActiveProblems">
        <entry>
            <act classCode="ACT" moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.15"/>
                <templateId root="2.16.840.1.113883.10.20.1.27"/>
                <id nullFlavor="NA"/>
                <code code="CONC" codeSystem="2.16.840.1.113883.5.6"/>
                <statusCode code="active"/>
                <entryRelationship inversionInd="false" typeCode="SUBJ">
                    <observation classCode="OBS" moodCode="EVN">
                        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.7"/>
                        <id root="2.16.840.1.113883.2.4.3.46.10.6.1" extension="{concat('problems-none-', translate(substring-before(xs:string(current-dateTime()), '.'), 'T-:', ''))}"/>
                        <code code="404684003" codeSystem="2.16.840.1.113883.6.96" displayName="Clinical finding" codeSystemName="SNOMED CT"/>
                        <text>
                            <reference value="#Problems_None"/>
                        </text>
                        <statusCode code="completed"/>
                        <value code="no-known-problems" displayName="No known problems" codeSystem="2.16.840.1.113883.5.1150.1" xsi:type="CD"/>
                    </observation>
                </entryRelationship>
            </act>
        </entry>
    </xsl:template>

    <!-- Problemen -->
    <xsl:template name="problem" exclude-result-prefixes="dm">
        <xsl:param name="active"/>
        <xsl:param name="problem"/>
        <entry>
            <act classCode="ACT" moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.15"/>
                <templateId root="2.16.840.1.113883.10.20.1.27"/>
                <!-- act id -->
                <xsl:apply-templates select="$problem/../../hl7:id"/>
                <xsl:if test="not($problem/../../hl7:id)">
                    <id nullFlavor="NI"/>
                </xsl:if>
                <code code="CONC" codeSystem="2.16.840.1.113883.5.6"/>
                <xsl:choose>
                    <xsl:when test="not($active)">
                        <statusCode code="completed"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$problem/../../hl7:statusCode"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- Onset and end date in acute zorg are on the observation, in eHDSI on the act -->
                <xsl:comment>Onset date</xsl:comment>
                <xsl:choose>
                    <xsl:when test="not($active) and not($problem/hl7:effectiveTime/hl7:high)">
                        <effectiveTime>
                            <xsl:apply-templates select="$problem/hl7:effectiveTime/hl7:low"/>
                            <high nullFlavor="UNK"/>
                        </effectiveTime>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$problem/hl7:effectiveTime"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- entryRelationship 1..* R-->
                <entryRelationship typeCode="SUBJ">
                    <observation classCode="OBS" moodCode="EVN">
                        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.7"/>
                        <!-- id 1..1 R-->
                        <xsl:apply-templates select="$problem/hl7:id"/>
                        <!-- code 1..1 R-->
                        <!-- Is fixed on 282291009 in source for concern, this is part of target allowed values, but for alerts codes outside eHDSI problem may be used, set to generic 'problem' -->
                        <xsl:choose>
                            <xsl:when test="$problem/hl7:code = '282291009'">
                                <xsl:apply-templates select="$problem/hl7:code"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <code code="404684003" codeSystem="2.16.840.1.113883.6.96" displayName="Clinical finding (finding)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- text 1..1 R-->
                        <text>
                            <reference value="#problem-{generate-id()}"/>
                        </text>
                        <!-- statusCode 0..1 R-->
                        <statusCode code="completed"/>
                        <!-- Add onset date here too, actually observation expects time when problem is known to be true, but we don't have that. -->
                        <xsl:choose>
                            <xsl:when test="not($active) and not($problem/hl7:effectiveTime/hl7:high)">
                                <effectiveTime>
                                    <xsl:apply-templates select="$problem/hl7:effectiveTime/hl7:low"/>
                                    <high nullFlavor="UNK"/>
                                </effectiveTime>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$problem/hl7:effectiveTime"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- value 1..1 R-->
                        <xsl:comment>Problem</xsl:comment>
                        <xsl:apply-templates select="$problem/hl7:value"/>
                    </observation>
                </entryRelationship>
            </act>
        </entry>
    </xsl:template>

    <xsl:template name="problemNarrative">
        <xsl:param name="active"/>
        <xsl:choose>
            <xsl:when test="..//hl7:observation/hl7:value[@code='no-known-problems'][@codeSystem='2.16.840.1.113883.5.1150.1']">
                <text>
                    <paragraph ID="Problems_None">Geen bekende problemen.</paragraph>
                </text>
            </xsl:when>
            <xsl:otherwise>
                <text>
                    <table>
                        <thead>
                            <tr>
                                <!--<th>Problem</th>
                        <th>Onset date</th>
                        <th>Diagnosis Assertion Status</th>
                        <th>Related Health Professional</th>
                        <th>Related external source</th>-->
                                <th>Probleem</th>
                                <th>Begindatum</th>
                                <th>Diagnose bevestiging</th>
                                <th>Gerelateerde zorgverlener</th>
                                <th>Gerelateerde externe bron</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="..//hl7:observation[hl7:templateId/@root = '1.3.6.1.4.1.12559.11.10.1.3.1.3.7']">
                                <tr>
                                    <!--Active problem-->
                                    <td ID="{dm:getRefID(.)}">
                                        <xsl:choose>
                                            <xsl:when test="hl7:value/@displayName">
                                                <xsl:value-of select="hl7:value/@displayName"/>
                                            </xsl:when>
                                            <xsl:when test="hl7:value/hl7:translation/@displayName">
                                                <xsl:value-of select="hl7:value/hl7:translation/@displayName"/>
                                            </xsl:when>
                                            <xsl:otherwise> No translation for code: <xsl:value-of select="hl7:value/@code/string()"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                    </td>
                                    <!--Onset date-->
                                    <td>
                                        <xsl:value-of select="concat('Vanaf: ', dm:formatHl7date(../../hl7:effectiveTime/hl7:low/@value/string()))"/>
                                    </td>
                                    <td/>
                                    <td/>
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
