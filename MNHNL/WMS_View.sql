DROP VIEW btw_transects; 
CREATE VIEW btw_transects AS 
 SELECT l.id, l.id as location_id, l.name, l.code, l.boundary_geom, lw.website_id, l.location_type_id
   FROM locations l
   LEFT JOIN locations_websites lw ON l.id = lw.location_id
   WHERE l.parent_id IS NULL AND l.deleted = FALSE AND lw.deleted = FALSE AND l.boundary_geom IS NOT NULL;

//In geoserver, Create a style as defined below.
//Create layers for the above view, and for the locations table, which both use the style.

// map now builds a WMS overlay.
// WMS overlay can reference the btw_transects as above.
// Now transects layer style set to display the lines as thicker and only display names if not too far zoomed out.
// Sect Map location_layer dettails in iform param to => Name:Location,URL:http://localhost/geoserver/wms,LAYERS:indicia:btw_transects,SRS:EPSG:2169,FORMAT:image/png,minScale:0,maxScale:10000,units:m

<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>redflag</Name>    
    <UserStyle>
      <Title>1 px blue line</Title>
      <IsDefault>1</IsDefault>
      <FeatureTypeStyle>
        <!--FeatureTypeName>Feature</FeatureTypeName-->
        <Rule>
          <Title>Blue Line</Title>
          <LineSymbolizer>
            <Geometry>
              <ogc:PropertyName>boundary_geom</ogc:PropertyName>
            </Geometry>
            <Stroke>
              <CssParameter name="stroke">#0000FF</CssParameter>
              <CssParameter name="stroke-width">2</CssParameter>
              <CssParameter name="stroke-linecap">round</CssParameter>
            </Stroke>
          </LineSymbolizer>
        </Rule>
        <Rule>
          <MaxScaleDenominator>1000000</MaxScaleDenominator>
          <TextSymbolizer>
            <Label>
              <ogc:PropertyName>name</ogc:PropertyName>
            </Label>
            <Font>
              <CssParameter name="font-family">Arial</CssParameter>
              <CssParameter name="font-family">Sans-Serif</CssParameter>
              <CssParameter name="font-style">bold</CssParameter>
              <CssParameter name="font-size">12</CssParameter>
              <CssParameter name="font-color">#FF0000</CssParameter>
            </Font>
            <LabelPlacement>
              <PointPlacement>
                <AnchorPoint>
                  <AnchorPointX>0.5</AnchorPointX>
                  <AnchorPointY>0.5</AnchorPointY>
                </AnchorPoint>
              </PointPlacement>
            </LabelPlacement>
            <Halo></Halo>
          </TextSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor> 


