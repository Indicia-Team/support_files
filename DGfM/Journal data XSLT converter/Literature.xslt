<!-- Convert literature data into APA format terms that can be imported into a termlist-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:variable name="comma" select="'&#44;'" />
    <xsl:variable name="full_stop" select="'&#46;'" />
    <xsl:variable name="open_bracket" select="'&#40;'" />
    <xsl:variable name="close_bracket" select="'&#41;'" />
    <xsl:variable name="ampersand" select="'&#38;'" />
    <xsl:variable name="double_quote" select="'&#34;'" />
    <xsl:variable name="space" select="'&#32;'" />
    <xsl:variable name="newline" select="'&#10;'" />

    <xsl:template match="/">
        <xsl:text>Reference_term</xsl:text>
        <xsl:value-of select="$newline" />
        <xsl:for-each select="Sources/Source">
            <xsl:value-of select="$double_quote" />
            <xsl:for-each select="Author/Author/NameList/Person">
               <xsl:choose>
               <!-- Only display first 7 and last author (other authors are replaced with ...)-->
                <xsl:when test="position() &lt; 8 or (last() &gt; 7 and position() = last())">
                  <xsl:choose>
                    <xsl:when test="position() != last() and last() != 1 and position() &lt; 8 and position() != 1">
                      <xsl:value-of select="$comma" />
                      <xsl:value-of select="$space" />
                    </xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                    <!-- Last author must be preceded with &. The exception to this if there are more than 7, in which case
                    the last author is preceded with ...-->
                    <xsl:when test="position() = last() and last() != 1 and position() &lt; 8">
                        <xsl:value-of select="$space" />
                        <xsl:value-of select="$ampersand" />
                        <xsl:value-of select="$space" />
                    </xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                    <xsl:when test="position() = 8">
                      <xsl:value-of select="$comma" />
                      <xsl:value-of select="$full_stop" />
                      <xsl:value-of select="$full_stop" />
                      <xsl:value-of select="$full_stop" />
                    </xsl:when>
                  </xsl:choose> 
                  <xsl:value-of select="Last" />
                  <xsl:if test="First or Middle">
                    <xsl:value-of select="$comma" />
                  </xsl:if>
                  <xsl:if test="First">
                    <xsl:value-of select="$space" />
                    <xsl:value-of select="First" />
                  </xsl:if>
                  <xsl:if test="Middle">
                    <xsl:value-of select="$space" />
                    <xsl:value-of select="Middle" />
                  </xsl:if>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>

            <!--Identical to above, apart from the path to the author information is different-->
            <xsl:for-each select="Author/Editor/NameList/Person">
               <xsl:choose>
                <xsl:when test="position() &lt; 8 or (last() &gt; 7 and position() = last())">
                  <xsl:choose>
                    <xsl:when test="position() != last() and last() != 1 and position() &lt; 8 and position() != 1">
                      <xsl:value-of select="$comma" />
                      <xsl:value-of select="$space" />
                    </xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                    <xsl:when test="position() = last() and last() != 1 and position() &lt; 8">
                        <xsl:value-of select="$space" />
                        <xsl:value-of select="$ampersand" />
                        <xsl:value-of select="$space" />
                    </xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                    <xsl:when test="position() = 8">
                      <xsl:value-of select="$comma" />
                      <xsl:value-of select="$full_stop" />
                      <xsl:value-of select="$full_stop" />
                      <xsl:value-of select="$full_stop" />
                    </xsl:when>
                  </xsl:choose> 
                  <xsl:value-of select="Last" />
                  <xsl:if test="First or Middle">
                    <xsl:value-of select="$comma" />
                  </xsl:if>
                  <xsl:if test="First">
                    <xsl:value-of select="$space" />
                    <xsl:value-of select="First" />
                  </xsl:if>
                  <xsl:if test="Middle">
                    <xsl:value-of select="$space" />
                    <xsl:value-of select="Middle" />
                  </xsl:if>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
            <xsl:value-of select="$space" />
            <xsl:value-of select="$open_bracket" />
            <xsl:value-of select="Year" />
            <xsl:value-of select="$close_bracket" />
            <xsl:value-of select="$full_stop" />
            <xsl:value-of select="$space" />
            <xsl:value-of select="Title" />
            <xsl:value-of select="$full_stop" />
            <xsl:value-of select="$space" />
            <xsl:if test="PeriodicalTitle">
              <xsl:value-of select="PeriodicalTitle" />
              <!--Only need to include comma if there is data after PeriodicalTitle-->
              <xsl:if test="Volume or Pages">
                <xsl:value-of select="$comma" />
                <xsl:value-of select="$space" />
              </xsl:if>
            </xsl:if>
            <xsl:if test="Volume">
              <xsl:value-of select="Volume" />
               <!--Only need to include comma if there is data after Volume-->
               <xsl:if test="Pages">
                 <xsl:value-of select="$comma" />
                 <xsl:value-of select="$space" />
              </xsl:if>
            </xsl:if>
            <xsl:if test="Pages">
              <xsl:value-of select="Pages" />
            </xsl:if>  
            <xsl:if test="PeriodicalTitle or Volume or Pages"> 
              <xsl:value-of select="$full_stop" />      
            </xsl:if>     
            <xsl:value-of select="$double_quote" />
            <xsl:value-of select="$newline" />
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>