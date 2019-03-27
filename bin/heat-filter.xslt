<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://schemas.microsoft.com/wix/2006/wi"
    xmlns:wix="http://schemas.microsoft.com/wix/2006/wi"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

  <xsl:output method="xml" indent="yes"/>

  <!-- Set up keys for matchin certain elements -->
  <xsl:key name="local-ini-file" match="wix:Component[contains(wix:File/@Source, '\etc\local.ini')]" use="@Id"/>

  <!-- Identity Transform  (Copy everything)-->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


  <!-- Match the local.ini file -->
  <xsl:template match="wix:Component[key('local-ini-file', @Id)]">
     <xsl:copy>
     <!-- Set the Permanent attribute to yes-->
      <xsl:attribute name="Permanent">
         <xsl:text>yes</xsl:text>
      </xsl:attribute>
      
      <!-- Set the NeverOverwrite to yes -->
      <xsl:attribute name="NeverOverwrite">
         <xsl:text>yes</xsl:text>
      </xsl:attribute>

      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>