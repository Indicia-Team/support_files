jQuery(document).ready(function($) {
  //Hide redlist fields as these won't be edited
  $('#ctrl-wrap-taxAttr-1076').hide();
  $('#ctrl-wrap-taxAttr-1077').hide();

  //Position Journal/book at top of sub-areas
  $('#ctrl-wrap-taxAttr-942').insertBefore('#ctrl-wrap-taxAttr-898');
  $('#ctrl-wrap-taxAttr-945').insertBefore('#ctrl-wrap-taxAttr-901');
  $('#ctrl-wrap-taxAttr-23').insertBefore('#ctrl-wrap-taxAttr-25');
  $('#ctrl-wrap-taxAttr-833').insertBefore('#ctrl-wrap-taxAttr-904');
  $('#ctrl-wrap-taxAttr-836').insertBefore('#ctrl-wrap-taxAttr-741');
  
  //Place title field after Journal/Book
  $('#ctrl-wrap-taxAttr-794').insertAfter('#ctrl-wrap-taxAttr-942');
  $('#ctrl-wrap-taxAttr-944').insertAfter('#ctrl-wrap-taxAttr-945');
  $('#ctrl-wrap-taxAttr-22').insertAfter('#ctrl-wrap-taxAttr-23');
  $('#ctrl-wrap-taxAttr-832').insertAfter('#ctrl-wrap-taxAttr-833');
  $('#ctrl-wrap-taxAttr-835').insertAfter('#ctrl-wrap-taxAttr-836');
  
  //Place Length and Width at top of sub-areas for English
  $('#range-wrap-taxAttr-908').insertAfter("legend:contains('Basidium'),legend:contains('Basidien'),legend:contains('bazidie')");
  $('#range-wrap-taxAttr-951').insertAfter('#range-wrap-taxAttr-908');
  $('#range-wrap-taxAttr-369').insertAfter("legend:contains('chlamydospores'),legend:contains('Chlamydosporen'),legend:contains('chlamydospóry')");
  $('#range-wrap-taxAttr-978').insertAfter('#range-wrap-taxAttr-369');
  $('#range-wrap-taxAttr-411').insertAfter("legend:contains('cystidioles'),legend:contains('Cystidiolen'),legend:contains('cystidioly')");
  $('#range-wrap-taxAttr-410').insertAfter('#range-wrap-taxAttr-411');
  $('#range-wrap-taxAttr-454').insertAfter("legend:contains('gloeocystidium'),legend:contains('Gloeocystiden'),legend:contains('gloeocystidy')");
  $('#range-wrap-taxAttr-990').insertAfter('#range-wrap-taxAttr-454');
  $('#range-wrap-taxAttr-477').insertAfter("legend:contains('hairs/setae'),legend:contains('Haare/Setae'),legend:contains('chlupy/sety')");
  $('#range-wrap-taxAttr-458').insertAfter('#range-wrap-taxAttr-477');
  $('#range-wrap-taxAttr-1001').insertAfter("legend:contains('hymenial cystidium'),legend:contains('Hymenialzystiden'),legend:contains('hymeniální cystidy')");
  $('#range-wrap-taxAttr-1000').insertAfter('#range-wrap-taxAttr-1001');
  $('#range-wrap-taxAttr-1005').insertAfter("legend:contains('lagenocystidia'),legend:contains('Lagenozystiden'),legend:contains('lagenocystidy')");
  $('#range-wrap-taxAttr-1004').insertAfter('#range-wrap-taxAttr-1005');
  $('#range-wrap-taxAttr-1011').insertAfter("legend:contains('Lamprocystidia'),legend:contains('Lamprocystiden'),legend:contains('lamprocystidy')");
  $('#range-wrap-taxAttr-1010').insertAfter('#range-wrap-taxAttr-1011');
  $('#range-wrap-taxAttr-29').insertAfter("legend:contains('Leptocystidia'),legend:contains('Leptocystiden'),legend:contains('leptocystidy')");
  $('#range-wrap-taxAttr-1013').insertAfter('#range-wrap-taxAttr-29');
  $('#range-wrap-taxAttr-1016').insertAfter("legend:contains('lyocystidy'),legend:contains('Lyocystiden'),legend:contains('leptocystidy')");
  $('#range-wrap-taxAttr-538').insertAfter('#range-wrap-taxAttr-1016');
  $('#range-wrap-taxAttr-1020').insertAfter("legend:contains('metuloid cystidia'),legend:contains('Metuloide Cystiden'),legend:contains('metuloidní cystidy')");
  $('#range-wrap-taxAttr-1019').insertAfter('#range-wrap-taxAttr-1020');
  $('#range-wrap-taxAttr-1042').insertAfter("legend:contains('septocystidia'),legend:contains('Septocystiden'),legend:contains('septocystidy')");
  $('#range-wrap-taxAttr-1041').insertAfter('#range-wrap-taxAttr-1042');
  $('#range-wrap-taxAttr-1031').insertAfter("legend:contains('Pleurocystidia'),legend:contains('Pleurocystiden'),legend:contains('pleurocystidy')");
  $('#range-wrap-taxAttr-1030').insertAfter('#range-wrap-taxAttr-1031');
  $('#range-wrap-taxAttr-1062').insertAfter("legend:contains('trama cystidia'),legend:contains('Tramacystiden'),legend:contains('tramální cystidy')");
  $('#range-wrap-taxAttr-1061').insertAfter('#range-wrap-taxAttr-1062');
  //$('#ctrl-wrap-taxAttr-999').insertAfter("legend:contains('Trama of cap')");
  //$('#ctrl-wrap-taxAttr-998').insertAfter('#ctrl-wrap-taxAttr-999');


  //Position comment fields
  //Note for each array element, the first item is the main attribute id, the second id is the comment field
  
  var comment_field_selectors = [
  	[1082,1326],[1083,1382], [1084,39],[1085,40],[1086,41],[1087,47],[1088,48],[1089,55],[1090,57],
  	[1091,58],[1092,59],[1093,62],
    [1094,63],[1095,69],[1096,70],[1103,84],[1104,85],[1105,86],[1106,87],[1107,88],[1108,89],[1109,90],
    [1110,93],[1111,94],[1112,96],[1113,97],[1114,98],[1115,99],[1116,100],[1117,102],[1118,103],
    [1119,105],[1120,111],[1121,113],[1122,114],[1123,115],[1124,116],[1125,117],[1126,119],[1127,120],
    [1128,121],[1129,122],[1130,123],[1131,126],[1132,128],[1133,131],[1134,132],[1135,133],[1136,134],
    [1137,135],[1138,136],[1139,137],[1140,138],[1141,139],[1142,140],[1143,144],[1144,151],[1146,153],
    [1147,154],[1148,156],[1149,167],[1150,171],[1151,172],[1152,173],[1155,185],[1156,187],[1157,188],
    [1158,190],[1159,191],[1160,192],[1161,195],[1162,196],[1163,205],[1164,206],[1165,207],[1166,209],
    [1167,210],[1168,211],[1169,212],[1170,213],[1171,214],[1173,216],[1174,217],[1175,221],[1176,222],
    [1177,225],[1178,226],[1179,227],[1180,228],[1181,229],[1182,232],[1183,233],[1184,234],[1185,236],
    [1186,238],[1187,239],[1188,247],[1189,248],[1190,251],[1191,252],[1192,253],[1193,255],[1194,256],
    [1195,258],[1196,269],[1197,270],[1198,274],[1199,277],[1200,278],[1201,279],[1202,280],[1203,283],
    [1204,292],[1205,293],[1206,294],[1207,296],[1208,300],[1209,302],[1210,305],[1211,306],[1212,307],
    [1213,309],[1214,321],[1215,327],[1216,339],[1217,340],[1218,341],[1219,342],[1220,354],[1221,362],
    [1222,366],[1223,367],[1224,377],[1225,390],[1226,391],[1227,392],[1228,399],[1229,426],[1230,429],
    [1231,432],[1232,440],[1234,444],[1235,445],[1236,446],[1237,449],[1238,452],[1239,459],[1240,466],
    [1241,468],[1242,469],[1243,474],[1244,475],[1245,481],[1246,484],[1247,486],[1248,489],[1249,491],
    [1250,503],[1251,508],[1252,510],[1253,513],[1254,525],[1255,529],[1256,530],[1257,533],[1258,542],
    [1259,545],[1260,546],[1261,549],[1262,567],[1263,568],[1264,569],[1265,578],[1266,579],[1267,580],
    [1268,581],[1269,586],[1270,589],[1271,590],[1272,600],[1273,602],[1274,607],[1276,620],[1277,622],
    [1278,626],[1279,628],[1280,630],[1281,632],[1282,634],[1283,639],[1284,641],[1285,642],[1286,644],
    [1287,646],[1288,648],[1289,650],[1290,652],[1291,656],[1292,658],[1293,670],[1294,676],[1295,693],
    [1297,701],[1298,703],[1299,704],[1300,712],[1301,713],[1303,717],[1304,728],[1305,750],[1306,751],[1307,756],
    [1308,758],[1309,759],[1310,760],[1311,763],[1312,767],[1313,768]/*,[1316,1315]*/,[1564,1326],[1565,1329],
    [1566,1330],[1567,1332],[1568,1073],[1569,1074],[1570,1335],[1571,1341],[1572,731],[1573,1344],[1574,71],[1575,72],
    [1576,79],[1577,1349],[1578,1350],[1579,75],[1580,76],[1581,1066],[1582,91],[1583,738],[1584,349],[1585,1353],
    [1586,18],[1587,1355],[1588,1356],[1589,775],[1590,145],[1591,558],[1592,146],[1593,1360],[1594,1361],[1595,805],
    [1596,807],[1597,288],[1598,438],[1599,439],[1600,1367],[1601,1368],[1602,1369],[1603,1370],[1604,1378],
    [1605,219],[1606,809],[1607,810],[1608,814],[1609,313],[1610,350],[1611,1382],[1612,436],[1613,781],[1614,180],
    [1616,181],[1617,182],[1618,183],[1619,78],[1620,1398],[1621,147],[1622,220],[1623,1412],[1624,615],[1625,244],
    [1626,245],[1627,1072],[1628,19],[1629,815],[1630,289],[1631,285],[1632,1431],[1633,286],[1634,1433],[1635,287],
    [1636,314],[1637,336],[1638,811],[1639,808],[1640,397],[1641,1434],[1642,1435],[1643,396],[1644,1436],[1645,1437],
    [1646,1438],[1647,1439],[1648,735],[1649,1442],[1650,35],[1651,817],[1652,559],[1653,875],[1654,596],[1655,597],
    [1656,604],[1657,736],[1658,1462],[1659,737],[1660,1477],[1661,1482],[1662,1485],[1663,885],[1664,243],
    [1665,890],[1666,1504],[1667,265],[1668,51],[1669,726],[1671,782],[1672,1523],[1673,1527],[1674,80],[1675,1067],
    [1676,1068],[1677,1069],[1678,1070],[1679,125],[1680,1071],[1681,780],[1682,266],[1683,1528],[1684,1529],
    [1686,806],[1687,242],[1688,816],[1689,437],[1690,818],[1691,819],[1692,820],[1693,821],[1694,1530],[1695,823],
    [1696,500],[1697,501],[1698,1531],[1699,1532],[1700,826],[1701,827],[1702,828],[1703,539],[1704,540],[1706,873],
    [1707,874],[1708,616],[1709,617],[1710,682],[1711,877],[1712,878],[1713,879],[1714,881],[1715,882],[1716,883],
    [1717,884],[1718,1534]
  ];

  $.each(comment_field_selectors, function() {
    $('#ctrl-wrap-taxAttr-'+this[0]).insertAfter('#ctrl-wrap-taxAttr-'+this[1]);
  });
  
  var sitePath = '/';
  var spectrumPath = sitePath + 'sites/default/files/indicia/js/spectrum/';
  var attrs = [
    35,50,51,79,80,91,125,145,146,147,178,179,180,181,182,183,219,220,242,243,244,245,265,266,267,268,285,286,
    287,288,289,313,314,336,349,350,396,397,436,500,501,539,540,558,559,596,597,615,616,617,682,726,731,735,736,
    737,738,775,780,781,782,783,784,785,804,805,806,807,808,809,810,811,814,815,816,817,818,819,820,821,823,826,
    827,828,872,873,874,875,877,878,879,881,882,883,884,885,890,891,1066,1067,1068,1069,1070,1071,1072,1073,1074
  ];
  var selectors = [];
  $.each(attrs, function() {
    selectors.push('#taxAttr\\:' + this);
    selectors.push('[id^="taxAttr\\:' + this + ':"]');
  });
  $('<link/>', {
    rel: 'stylesheet',
    type: 'text/css',
    href: spectrumPath + 'spectrum.css'
  }).appendTo('head');
<<<<<<< HEAD
  $.getScript(spectrumPath + 'spectrum.js', function() {
=======
  jQuery.getScript(spectrumPath + 'spectrum.js', function() {
>>>>>>> 305b16d79b8c48aeea3285a574b8271c7840ba99
    $.each($(selectors.join(',')), function() {
      $(this).hide();
      var values = $(this).val().split(';');
      var value1 = values.length > 0 ? values[0] : '';
      var value2 = values.length > 1 ? values[1] : '';
      $(this).after(
        '<br/> ' +
        '<label>1: <input type="text" class="spectrum-input" value="' + value1 + '" data-for="' + this.id + '" data-idx="1"/></label> ' +
        '<label>2: <input type="text" class="spectrum-input" value="' + value2 + '" data-for="' + this.id + '" data-idx="2"/></label>'
      );
    });
    $('.spectrum-input').spectrum({
      showPaletteOnly: true,
      showSelectionPalette: true,
      showInput: true,
      allowEmpty: true,
      togglePaletteOnly: true,
      hideAfterPaletteSelect: true,
      togglePaletteMoreText: '+',
      togglePaletteLessText: '-',
      chooseText: '✓',
      cancelText: '✗',
      localStorageKey: 'colours',
      preferredFormat: "hex",
      palette: [
          ["#000","#444","#666","#999","#ccc","#eee","#f3f3f3","#fff"],
          ["#f00","#f90","#ff0","#0f0","#0ff","#00f","#90f","#f0f"],
          ["#f4cccc","#fce5cd","#fff2cc","#d9ead3","#d0e0e3","#cfe2f3","#d9d2e9","#ead1dc"],
          ["#ea9999","#f9cb9c","#ffe599","#b6d7a8","#a2c4c9","#9fc5e8","#b4a7d6","#d5a6bd"],
          ["#e06666","#f6b26b","#ffd966","#93c47d","#76a5af","#6fa8dc","#8e7cc3","#c27ba0"],
          ["#c00","#e69138","#f1c232","#6aa84f","#45818e","#3d85c6","#674ea7","#a64d79"],
          ["#900","#b45f06","#bf9000","#38761d","#134f5c","#0b5394","#351c75","#741b47"],
          ["#600","#783f04","#7f6000","#274e13","#0c343d","#073763","#20124d","#4c1130"]
      ]
    });
    $('.spectrum-input').change(function() {
      var idSafe = $(this).attr('data-for').replace(':', '\\:');
      var input = $('#' + idSafe);
      $(input).val(
        $('input[data-for="' + idSafe + '"][data-idx="1"]').val() + ';' +
        $('input[data-for="' + idSafe + '"][data-idx="2"]').val()
      );
    });
  });
});
