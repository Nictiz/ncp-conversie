<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:dm="http://duometis.nl/functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:template name="section-allergies" exclude-result-prefixes="dm">
        <xsl:comment>Allergies, adverse reactions, alerts</xsl:comment>
        <!-- Allergies, adverse reactions, alerts -->
        <component>
            <section moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.2.12"/>
                <!-- No id, source has no section.id and is 0..1 R in target -->
                <code code="48765-2" codeSystem="2.16.840.1.113883.6.1" displayName="Allergieën en/of allergische reacties"/>
                <title>Allergieën en/of allergische reacties</title>
                <text> TODO, no text now. </text>
                <xsl:if test="count(//hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.66.10.216']) = 0">
                    <xsl:call-template name="noAllergyInformation"/>
                </xsl:if>
                <xsl:apply-templates select="hl7:REPC_IN990131NL"/>
            </section>
        </component>
    </xsl:template>

    <xsl:template name="noAllergyInformation">
        <entry>
            <act classCode="ACT" moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.16"/>
                <id nullFlavor="NI"/>
                <code code="CONC" codeSystem="2.16.840.1.113883.5.6"/>
                <statusCode code="active"/>
                <entryRelationship typeCode="SUBJ" inversionInd="false">
                    <observation classCode="OBS" moodCode="EVN">
                        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.17"/>
                        <id root="2.16.840.1.113883.2.4.3.46.10.6.1" extension="{concat('allergies-none-', translate(substring-before(xs:string(current-dateTime()), '.'), 'T-:', ''))}"/>
                        <code code="420134006" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="Propensity to adverse reaction"/>
                        <text>
                            <reference value="#Allergies_NoInformation"/>
                        </text>
                        <statusCode code="completed"/>
                        <value code="no-allergy-info" displayName="No information about allergies" codeSystem="2.16.840.1.113883.5.1150.1" xsi:type="CD"/>
                    </observation>
                </entryRelationship>
            </act>
        </entry>
    </xsl:template>

    <xsl:template match="hl7:REPC_IN990131NL">
        <xsl:apply-templates select='.//hl7:act[hl7:templateId/@root = "2.16.840.1.113883.2.4.3.11.60.66.10.215"]'/>
    </xsl:template>

    <xsl:template match='hl7:act[hl7:templateId/@root = "2.16.840.1.113883.2.4.3.11.60.66.10.215"]'>
        <entry>
            <act classCode="ACT" moodCode="EVN">
                <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.16"/>
                <xsl:comment>Type of propensity</xsl:comment>
                <code code="CONC" codeSystem="2.16.840.1.113883.5.6"/>
                <xsl:apply-templates select="hl7:statusCode"/>
                <xsl:apply-templates select="hl7:effectiveTime"/>
                <!-- 1..* entry relationships identifying allergies of concern -->
                <xsl:for-each select="hl7:entryRelationship">
                    <entryRelationship typeCode="SUBJ" inversionInd="false">
                        <xsl:apply-templates/>
                    </entryRelationship>
                </xsl:for-each>
            </act>
        </entry>
    </xsl:template>

    <xsl:template match='hl7:observation[hl7:templateId/@root = "2.16.840.1.113883.2.4.3.11.60.66.10.216"]'>
        <xsl:comment>Allergy</xsl:comment>
        <observation classCode="OBS" moodCode="EVN" negationInd="false">
            <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.17"/>
            <xsl:comment>Type of propensity</xsl:comment>
                    <code>
                        <xsl:apply-templates select="hl7:value/@*"/>
                    </code>
            <!-- Referred-to narrative to be generated later -->
            <text>
                <reference value="#allergy-{generate-id()}"/>
            </text>
            <xsl:apply-templates select="(hl7:statusCode)"/>
            <xsl:comment>Duration (Onset-End date)</xsl:comment>
            <xsl:apply-templates select="(hl7:effectiveTime, hl7:author, hl7:informant)"/>
            <!-- This is the allergen - the substance that caused the allergy. Will need terminology mapping. -->
            <xsl:comment>Contains agent (code)</xsl:comment>
            <xsl:apply-templates select="hl7:participant[@typeCode = 'CSM']"/>
            <!-- Reaction Manifestation -->
            <xsl:for-each select="hl7:entryRelationship/hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.66.10.217']">
                <entryRelationship typeCode="MFST">
                    <observation classCode="OBS" moodCode="EVN">
                        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.44"/>
                        <!-- See issue #33 -->
                        <code code="404684003" displayName="Clinical finding" codeSystem="2.16.840.1.113883.6.96"/>
                        <text>
                            <reference value="#manifestation-{generate-id()}"/>
                        </text>
                        <statusCode code="completed"/>
                        <!-- Zie issue #34, wat te doen als effTime er niet is?  -->
                        <xsl:choose>
                            <xsl:when test="not(hl7:effectiveTime)">
                                <effectiveTime>
                                    <low nullFlavor="UNK"/>
                                </effectiveTime>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="hl7:effectiveTime"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:comment>Manifestation</xsl:comment>
                        <xsl:apply-templates select="hl7:value"/>
                        <!-- This is how the severity of the allergy is described (Optional)-->
                        <xsl:for-each select="hl7:entryRelationship/hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.66.10.219']">
                            <entryRelationship typeCode="SUBJ" inversionInd="true">
                                <observation classCode="OBS" moodCode="EVN">
                                    <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.8"/>
                                    <!-- This code is from HL7 and indicates that the observation is about severity -->
                                    <code code="SEV" displayName="Severity" codeSystem="2.16.840.1.113883.5.4" codeSystemName="ActCode"/>
                                    <text>
                                        <reference value="#severity--{generate-id()}"/>
                                    </text>
                                    <statusCode code="completed"/>
                                    <xsl:comment>Severity</xsl:comment>
                                    <xsl:apply-templates select="hl7:value"/>
                                </observation>
                            </entryRelationship>
                        </xsl:for-each>
                    </observation>
                </entryRelationship>
            </xsl:for-each>
            <!-- If there is a criticality -->
            <xsl:if test="hl7:entryRelationship/hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.66.10.218']">
                <entryRelationship typeCode="SUBJ" inversionInd="true">
                    <observation classCode="OBS" moodCode="EVN">
                        <templateId root="1.3.6.1.4.1.12559.11.10.1.3.1.3.33"/>
                        <code code="82606-5" codeSystem="2.16.840.1.113883.6.1"/>
                        <text>
                            <reference value="#criticality-{generate-id()}"/>
                        </text>
                        <statusCode code="completed"/>
                        <xsl:comment>Criticality</xsl:comment>
                        <xsl:apply-templates select="hl7:entryRelationship/hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.2.4.3.11.60.66.10.218']/hl7:value"/>
                    </observation>
                </entryRelationship>
            </xsl:if>
            <!--  1.3.6.1.4.1.12559.11.10.1.3.1.3.35 eHDSI Allergy Certainty Observation is not a fit in fit/gap -->
            <!--  1.3.6.1.4.1.12559.11.10.1.3.1.3.34 eHDSI Allergy Status Observation is not a fit? Open issue #60 -->
        </observation>
    </xsl:template>

    <xsl:template name="allergyNarrative">
        <xsl:choose>
            <xsl:when test="..//hl7:observation/hl7:value[@code = 'no-allergy-info'][@codeSystem = '2.16.840.1.113883.5.1150.1']">
                <text>
                    <paragraph ID="Allergies_NoInformation">Geen informatie over allergieën.</paragraph>
                </text>
            </xsl:when>
            <xsl:otherwise>
                <text>
                    <table>
                        <thead>
                            <tr>
                                <!--<th>Reaction type</th>
                        <th>Clinical manifestation</th>
                        <th>Agent</th>
                        <th>Duration</th>
                        <th>Severity</th>
                        <th>Criticality</th>
                        <th>Allergy Status</th>
                        <th>Certainty</th>-->
                                <th>Type reactie</th>
                                <th>Reactie symptoom</th>
                                <th>Specifieke stof</th>
                                <th>Duur</th>
                                <th>Ernst</th>
                                <th>Mate van kritiek zijn</th>
                                <th>Status</th>
                                <th>Zekerheid</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="..//hl7:observation[hl7:templateId/@root = '1.3.6.1.4.1.12559.11.10.1.3.1.3.17']">
                                <tr>
                                    <!--Type of propensity-->
                                    <td ID="{dm:getRefID(.)}">
                                        <xsl:value-of select="hl7:code/@displayName"/>
                                    </td>
                                    <!--Manifestation-->
                                    <xsl:for-each select="..//hl7:observation[hl7:templateId/@root = '1.3.6.1.4.1.12559.11.10.1.3.1.3.44']">
                                        <td ID="{dm:getRefID(.)}">
                                            <xsl:value-of select="hl7:value/@displayName"/>
                                        </td>
                                    </xsl:for-each>
                                    <xsl:if test="not(..//hl7:observation[hl7:templateId/@root = '1.3.6.1.4.1.12559.11.10.1.3.1.3.44'])">
                                        <td/>
                                    </xsl:if>
                                    <!--Agent-->
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="hl7:participant/hl7:participantRole/hl7:playingEntity/hl7:code/@displayName">
                                                <xsl:value-of select="hl7:participant/hl7:participantRole/hl7:playingEntity/hl7:code/@displayName"/>
                                            </xsl:when>
                                            <xsl:when test="hl7:participant/hl7:participantRole/hl7:playingEntity/hl7:code/hl7:originalText">
                                                <xsl:value-of select="hl7:participant/hl7:participantRole/hl7:playingEntity/hl7:code/hl7:originalText/text()"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </td>
                                    <!--Duration (Onset-End date)-->
                                    <td>
                                        <xsl:value-of select="concat('Vanaf: ', dm:formatHl7date(hl7:effectiveTime/hl7:low/@value/string()))"/>
                                        <xsl:if test="hl7:effectiveTime/hl7:high">
                                            <xsl:value-of select="concat(' tot: ', dm:formatHl7date(hl7:effectiveTime/hl7:high/@value/string()))"/>
                                        </xsl:if>
                                    </td>
                                    <!--Severity-->
                                    <xsl:for-each select="..//hl7:observation[hl7:templateId/@root = '1.3.6.1.4.1.12559.11.10.1.3.1.3.8']">
                                        <td ID="{dm:getRefID(.)}">
                                            <xsl:value-of select="hl7:value/@displayName"/>
                                        </td>
                                    </xsl:for-each>
                                    <xsl:if test="not(..//hl7:observation[hl7:templateId/@root = '1.3.6.1.4.1.12559.11.10.1.3.1.3.8'])">
                                        <td/>
                                    </xsl:if>
                                    <!--Criticality-->
                                    <xsl:for-each select="..//hl7:observation[hl7:templateId/@root = '1.3.6.1.4.1.12559.11.10.1.3.1.3.33']">
                                        <td ID="{dm:getRefID(.)}">
                                            <xsl:value-of select="hl7:value/@displayName"/>
                                        </td>
                                    </xsl:for-each>
                                    <xsl:if test="not(..//hl7:observation[hl7:templateId/@root = '1.3.6.1.4.1.12559.11.10.1.3.1.3.33'])">
                                        <td/>
                                    </xsl:if>
                                    <!--Status-->
                                    <td/>
                                    <!-- Certainty -->
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
