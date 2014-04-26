push-location;
import-module sqlps;
pop-location;
$apikey = 'AIzaSyAs2AexdldIkdZaypmUVP99rqHx5CM7snw';
$addresslookupURL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=LATCOORD,LONGCOORD&sensor=false&key=$apikey&result_type=street_address&language=en";
$locations = Invoke-Sqlcmd -serverinstance win81 -database cachedb -query "select locationname,latitude,longitude from centerpoints order by locationname";
$results = Invoke-RestMethod -Method Get -uri $addresslookupURL.Replace("LATCOORD",$locations[0].Latitude).Replace("LONGCOORD",$locations[0].Longitude);# |select results| ConvertFrom-Json;
Remove-Module sqlps;

#http://www.verboon.info/2013/10/powershell-script-get-computergeolocation/
$mylocation = new-object –ComObject LocationDisp.LatLongReportFactory;
while ($mylocation.status -ne 4) {
    "Waiting for position"
    start-sleep -Seconds 15;
}
 "Good to go!";
 $locationLatLong = "$($mylocation.LatLongReport.Latitude),$($mylocation.LatLongReport.Longitude)";
 $resultsLocal = Invoke-RestMethod -Method Get -uri $addresslookupURL.Replace("LATCOORD",$mylocation.LatLongReport.Latitude).Replace("LONGCOORD",$mylocation.LatLongReport.Longitude);
 $resultslocal.results.formatted_address;