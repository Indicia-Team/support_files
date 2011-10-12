DROP VIEW bat_locations; 
CREATE VIEW bat_locations  AS 
 SELECT l.id, l.name, l.code, l.centroid_geom as the_geom, lw.website_id, l.location_type_id, lav1.text_value as commune, lav2.text_value as village
   FROM locations l
   LEFT JOIN locations_websites lw ON l.id = lw.location_id and lw.deleted=false and lw.website_id=<TBD> and l.location_type_id=<TBD>
   OUTER JOIN location_attribute_values lav1 ON l.id = lav1.location_id and lav1.deleted=false and lav1.location_attribute_id=<TBD>
   OUTER JOIN location_attribute_values lav2 ON l.id = lav1.location_id and lav2.deleted=false and lav2.location_attribute_id=<TBD>
   WHERE l.parent_id IS NULL AND l.deleted = FALSE AND lw.deleted = FALSE;



<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>batloc</Name>    
    <UserStyle>
      <Title>Point and Name</Title>
      <Abstract>A style that prints out a 6px wide red square with a name</Abstract>
      <FeatureTypeStyle>
        <!--FeatureTypeName>Feature</FeatureTypeName-->
        <Rule>
          <Title>Red square</Title>
          <PointSymbolizer>
            <Graphic>
              <Mark>
                <WellKnownName>square</WellKnownName>
                <Fill>
                  <CssParameter name="fill">#FF0000</CssParameter>
                </Fill>
              </Mark>
              <Size>6</Size>
            </Graphic>
          </PointSymbolizer>
        </Rule>
        <Rule>
          <MaxScaleDenominator>1000000</MaxScaleDenominator>
          <TextSymbolizer>
            <Label>
              <ogc:PropertyName>name</ogc:PropertyName> (<ogc:PropertyName>commune</ogc:PropertyName> / <ogc:PropertyName>village</ogc:PropertyName>) No. <ogc:PropertyName>code</ogc:PropertyName>
            </Label>
            <Font>
              <CssParameter name="font-family">Arial</CssParameter>
              <CssParameter name="font-family">Sans-Serif</CssParameter>
              <CssParameter name="font-style">bold</CssParameter>
              <CssParameter name="font-size">14</CssParameter>
              <CssParameter name="font-color">#FF0000</CssParameter>
            </Font>
            <Halo><Radius>2</Radius></Halo>
          </TextSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor> 


