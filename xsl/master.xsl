<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:exslt="http://exslt.org/common"
        exclude-result-prefixes="exslt"
>

<xsl:import href="consolidate_profiles.xsl"/>
<xsl:import href="pretty.xsl"/>

<xsl:output encoding="utf-8"/>

<xsl:template match="/">
    <xsl:variable name="preprocess">
        <xsl:apply-templates select="/" mode="consolidate_profiles"/>
    </xsl:variable>

    <xsl:apply-templates
        select="exslt:node-set($preprocess)" mode="pretty"
    />
</xsl:template>

</xsl:stylesheet>
