<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"
        indent="yes" omit-xml-declaration="no" encoding="utf-8"/>

<!-- default rule -->
<xsl:template match="*" mode="consolidate_profiles">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="consolidate_profiles"/>
    </xsl:copy>
</xsl:template>


<!-- consolidate all profiles sections into one because OBS cannot handle multiple ones -->
<xsl:template match="profiles" mode="consolidate_profiles"/>

<xsl:template match="profiles[1]" mode="consolidate_profiles">
    <xsl:copy>
      <xsl:copy-of select="following-sibling::profiles/profile"/>
      <xsl:apply-templates mode="consolidate_profiles"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
