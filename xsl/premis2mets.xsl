<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:premis="info:lc/xmlns/premis-v2" 
	xmlns="http://www.loc.gov/METS/" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/premis:premis">
		<mets xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/version17/mets.xsd 
			info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/draft-schemas-2-0/premis-v2-0.xsd 
			http://www.loc.gov/mix/v10 http://www.loc.gov/standards/mix/mix10/mix10.xsd">
			<amdSec>
				<xsl:apply-templates select="premis:object[@xsi:type='file']" mode="bucket"/>
				<xsl:apply-templates select="premis:event"/>
				<xsl:apply-templates select="premis:agent"/>
			</amdSec>
			<fileSec>
				<fileGrp>
					<xsl:apply-templates select="premis:object[@xsi:type='file']" mode="file"/>
				</fileGrp>
			</fileSec>
			<xsl:apply-templates select="premis:object[@xsi:type='representation'][premis:relationship/premis:relationshipType='Structural']"/>
		</mets>
	</xsl:template>
	<!-- mets file -->
	<xsl:template match="premis:object[@xsi:type='file']" mode="file">
		<file>
			<!-- ID -->
			<xsl:attribute name="ID">
				<xsl:text>FILE-</xsl:text><xsl:value-of select="position()" />
			</xsl:attribute>
			<!-- ADMID -->
			<xsl:attribute name="ADMID">
				<xsl:text>OBJECT-</xsl:text><xsl:value-of select="position()" />
			</xsl:attribute>
			<!-- size -->
			<xsl:attribute name="SIZE">
				<xsl:value-of select="premis:objectCharacteristics/premis:size"/>
			</xsl:attribute>
			<!-- checksum -->
			<xsl:attribute name="CHECKSUM">
				<xsl:value-of select="premis:objectCharacteristics/premis:fixity/premis:messageDigest"/>
			</xsl:attribute>
			<xsl:if test="contains('HAVAL MD5 SHA-1 SHA-256 SHA-384 SHA-512 TIGER WHIRLPOOL', premis:objectCharacteristics/premis:fixity/premis:messageDigestAlgorithm)">
				<xsl:attribute name="CHECKSUMTYPE">
					<xsl:value-of select="premis:objectCharacteristics/premis:fixity/premis:messageDigestAlgorithm"/>
				</xsl:attribute>
			</xsl:if>
			<!-- if identifier type is in LOCTYPE then set LOCTYPE to it, otherwise set it to OTHER and OTHERLOCTYPE -->
			<FLocat>
				<xsl:choose>
					<xsl:when test="contains('ARK URN URL PURL HANDLE DOI', premis:objectIdentifier/premis:objectIdentifierType)">
						<xsl:attribute name="LOCTYPE">
							<xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierType"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="LOCTYPE">
							<xsl:text>OTHER</xsl:text>
						</xsl:attribute>
						<xsl:attribute name="OTHERLOCTYPE">
							<xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierType"/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="xlink:href">
					<xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierValue"/>
				</xsl:attribute>
			</FLocat>
		</file>
	</xsl:template>
	
	<!-- make structmap for every representation -->
	<xsl:template match="premis:object[@xsi:type='representation' and premis:relationship/premis:relationshipType='Structural']">
		<structMap>
			<xsl:attribute name="ID">
				<xsl:text>REPRESENTATION-</xsl:text><xsl:value-of select="position()"/>
			</xsl:attribute>
			<div>
				<!-- find file position where type and value match -->
				<xsl:variable name="oType">
					<xsl:value-of select="premis:relationship/premis:relatedObjectIdentification/premis:relatedObjectIdentifierType"/>					
				</xsl:variable>
				<xsl:variable name="oValue">
					<xsl:value-of select="premis:relationship/premis:relatedObjectIdentification/premis:relatedObjectIdentifierValue"/>
				</xsl:variable>
				<xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
					<xsl:if test="(premis:objectIdentifier/premis:objectIdentifierType=$oType) and (premis:objectIdentifier/premis:objectIdentifierValue=$oValue)">
						<fptr>
							<xsl:attribute name="FILEID">
								<xsl:text>OBJECT-</xsl:text><xsl:value-of select="position()" />
							</xsl:attribute>
						</fptr>
					</xsl:if>
				</xsl:for-each>
			</div>
		</structMap>
	</xsl:template>
	
<!-- techMD for premis files -->
	<xsl:template match="premis:object[@xsi:type='file']" mode="bucket">
		<xsl:call-template name="tech-bucket">
			<xsl:with-param name="contents">
				<xsl:copy-of select="."/>
			</xsl:with-param>
			<xsl:with-param name="identifier">
				<xsl:text>OBJECT-</xsl:text><xsl:value-of select="position()" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
<!-- event digiprovMD -->
	<xsl:template match="premis:event">
		<xsl:call-template name="digiprov-bucket">
			
			<xsl:with-param name="contents">
				<xsl:copy-of select="."/>
			</xsl:with-param>
			
			<xsl:with-param name="identifier">
				<xsl:text>EVENT-</xsl:text><xsl:value-of select="position()" />
			</xsl:with-param>
			
			<xsl:with-param name="relatedObjects">
				
				<!-- objects of this event -->
				<xsl:variable name="oType">
					<xsl:value-of select="premis:linkingObjectIdentifier/premis:linkingObjectIdentifierType"/>
				</xsl:variable>
				<xsl:variable name="oValue">
					<xsl:value-of select="premis:linkingObjectIdentifier/premis:linkingObjectIdentifierValue"/>
				</xsl:variable>
				<xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
					<xsl:if test="premis:objectIdentifier/premis:objectIdentifierType=$oType and premis:objectIdentifier/premis:objectIdentifierValue=$oValue">
						<xsl:text> </xsl:text>
						<xsl:text>OBJECT-</xsl:text><xsl:value-of select="position()" />
					</xsl:if>
				</xsl:for-each>
				
				<!-- objects with relationships that match this event -->
				<xsl:variable name="eType">
					<xsl:value-of select="premis:eventIdentifier/premis:eventIdentifierType"/>
				</xsl:variable>
				<xsl:variable name="eValue">
					<xsl:value-of select="premis:eventIdentifier/premis:eventIdentifierValue"/>
				</xsl:variable>
				<xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
					<xsl:if test="premis:relationship/premis:relatedEventIdentification/premis:relatedEventIdentifierType=$eType and premis:relationship/premis:relatedEventIdentification/premis:relatedEventIdentifierValue=$eValue">
						<xsl:text>OBJECT-</xsl:text><xsl:value-of select="position()" />
						<xsl:variable name="oRelType">
							<xsl:value-of select="premis:relationship/premis:relatedObjectIdentification/premis:relatedObjectIdentifierType"/>
						</xsl:variable>
						<xsl:variable name="oRelValue">
							<xsl:value-of select="premis:relationship/premis:relatedObjectIdentification/premis:relatedObjectIdentifierValue"/>
						</xsl:variable>
						<xsl:for-each select="/premis:premis/premis:object[@xsi:type='file']">
							<xsl:if test="premis:objectIdentifier/premis:objectIdentifierType=$oRelType and premis:objectIdentifier/premis:objectIdentifierValue=$oRelValue">
								<xsl:text> </xsl:text>
								<xsl:text>OBJECT-</xsl:text><xsl:value-of select="position()" />
							</xsl:if>
						</xsl:for-each>						
					</xsl:if>
				</xsl:for-each>
			</xsl:with-param>						

			<!-- agents related to this event -->
			<xsl:with-param name="relatedAgents">
				<xsl:variable name="aType">
					<xsl:value-of select="premis:linkingAgentIdentifier/premis:linkingAgentIdentifierType"/>
				</xsl:variable>
				<xsl:variable name="aValue">
					<xsl:value-of select="premis:linkingAgentIdentifier/premis:linkingAgentIdentifierValue"/>
				</xsl:variable>
				<xsl:for-each select="/premis:premis/premis:agent">
					<xsl:if test="premis:agentIdentifier/premis:agentIdentifierType=$aType and premis:agentIdentifier/premis:agentIdentifierValue=$aValue">
						<xsl:text>AGENT-</xsl:text><xsl:value-of select="position()" />
					</xsl:if>
				</xsl:for-each>
			</xsl:with-param>			
		</xsl:call-template>
	</xsl:template>
	
<!-- agent digiprovMD -->
	<xsl:template match="premis:agent">
		<xsl:call-template name="digiprov-bucket">
			<xsl:with-param name="contents">
				<xsl:copy-of select="."/>
			</xsl:with-param>
			<xsl:with-param name="identifier">
				<xsl:text>AGENT-</xsl:text><xsl:value-of select="position()" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
<!-- mets digiprovMD bucket -->
	<xsl:template name="digiprov-bucket">
		<xsl:param name="contents"/>
		<xsl:param name="identifier"/>
		<xsl:param name="relatedObjects"/>
		<xsl:param name="relatedAgents"/>
		<digiprovMD>
			<xsl:attribute name="ID">
				<xsl:value-of select="$identifier"/>
			</xsl:attribute>
			<xsl:if test="string-length(concat($relatedAgents, $relatedObjects)) != 0">
				<xsl:attribute name="ADMID">
					<xsl:value-of select="concat($relatedAgents, ' ', $relatedObjects)"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="mdwrap-xmldata-bucket">
				<xsl:with-param name="contents">
					<xsl:copy-of select="$contents"/>
				</xsl:with-param>
				<xsl:with-param name="mdtype">PREMIS</xsl:with-param>
			</xsl:call-template>
		</digiprovMD>
	</xsl:template>
	
<!-- mets techMD bucket -->
	<xsl:template name="tech-bucket">
		<xsl:param name="contents"/>
		<xsl:param name="identifier"/>
		<techMD>
			<xsl:attribute name="ID">
				<xsl:value-of select="$identifier"/>
			</xsl:attribute>
			<xsl:call-template name="mdwrap-xmldata-bucket">
				<xsl:with-param name="contents">
					<xsl:copy-of select="$contents"/>
				</xsl:with-param>
				<xsl:with-param name="mdtype">PREMIS</xsl:with-param>
			</xsl:call-template>
		</techMD>
	</xsl:template>
	
<!-- mets mdWrap/xmlData bucket -->
	<xsl:template name="mdwrap-xmldata-bucket">
		<xsl:param name="contents"/>
		<xsl:param name="mdtype"/>
		<mdWrap MDTYPE="$mdtype">
			<xsl:attribute name="MDTYPE">
				<xsl:value-of select="$mdtype"/>
			</xsl:attribute>
			<xmlData>
				<xsl:copy-of select="$contents"/>
			</xmlData>
		</mdWrap>
	</xsl:template>
	
</xsl:stylesheet>
