<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:premis="info:lc/xmlns/premis-v2" xmlns="http://www.loc.gov/METS/"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:output method="xml" indent="yes"/> 

	<xsl:template match="/premis:premis">
		<mets>
			<amdSec>
				<xsl:apply-templates select="premis:object[@xsi:type='file']" mode="bucket"/>
				<xsl:apply-templates select="premis:object[xsi:type='representation']"/>
				<xsl:apply-templates select="premis:event"/>
				<xsl:apply-templates select="premis:agent"/>
			</amdSec>
			<fileSec>
				<fileGrp>
					<xsl:apply-templates select="premis:object[@xsi:type='file']" mode="file"/>
				</fileGrp>
			</fileSec>
			<xsl:apply-templates select="object[xsi:type='representation']"/>
		</mets>

	</xsl:template>

	<!-- mets file -->
	<xsl:template match="premis:object[@xsi:type='file']" mode="file">
		<file>
			<!-- if identifier type is in loctype then set loctype to it, otherwise set it to other and otherloctype -->
			<Flocat>
				<xsl:choose>
					<xsl:when test="contains('ARK URN URL PURL HANDLE DOI', premis:objectIdentifier/premis:objectIdentifierType)">
						<xsl:attribute name="TYPE"><xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierType"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="TYPE"><xsl:text>OTHER</xsl:text></xsl:attribute>
						<xsl:attribute name="OTHERLOCTYPE"><xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierType"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="xlink:href"><xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierValue"/></xsl:attribute>
			</Flocat>
		</file>
	</xsl:template>

	<!-- want to make structmap for every representation -->
	<xsl:template match="object[@xsi:type='representation']">
		<structMap>
			<div>
				<xsl:comment>TODO div for each representation goes here</xsl:comment>
			</div>
		</structMap>
	</xsl:template>

	<!-- techMD for premis files -->
	<xsl:template match="premis:object[@xsi:type='file']" mode="bucket">
		<techMD>
			<mdWrap MDTYPE="PREMIS">
				<xmlData>
					<xsl:copy-of select="."/>
				</xmlData>
			</mdWrap>
		</techMD>
	</xsl:template>

	<!-- digiprovMD for premis representations -->
	<xsl:template match="premis:object[xsi:type='representation']">
		<digiprovMD>
			<mdWrap MDTYPE="PREMIS">
				<xmlData>
					<xsl:copy-of select="."/>
				</xmlData>
			</mdWrap>
		</digiprovMD>
	</xsl:template>

	<!-- digiprovMD for premis event -->
	<xsl:template match="premis:event">
		<digiprovMD>
			<mdWrap MDTYPE="PREMIS">
				<xmlData>
					<xsl:copy-of select="."/>
				</xmlData>
			</mdWrap>
		</digiprovMD>
	</xsl:template>

	<!-- digiprovMD for premis agent -->
	<xsl:template match="premis:agent">
		<digiprovMD>
			<mdWrap MDTYPE="PREMIS">
				<xmlData>
					<xsl:copy-of select="."/>
				</xmlData>
			</mdWrap>
		</digiprovMD>
	</xsl:template>

</xsl:stylesheet>
