<?php

// Find GoogleDocs spreadsheet URL and WorksheetID and
// adds a new row consisting of an array of key=>values 
// where key == header / column name.
// Using the Zend classes allows for authentication, vs.
// just using curl to post the data.

// Adapted From: 
// http://stackoverflow.com/questions/9157845/zend-gdata-spreadsheet-invalid-query-parameter-value-for-grid-id
//
// Download Zend Framework From
// http://framework.zend.com/downloads/latest
//
// Other Helpful Refs
// http://framework.zend.com/downloads/latest
// http://www.jazzerup.com/blog/google-spreadsheets-api-php-zend
// http://stackoverflow.com/questions/7455239/error-inserting-row-in-google-spreadsheet-using-zend-gdata

// Include the loader and Google API classes for spreadsheets
// Install Zend Framework from above url, add to php.ini include path
require_once('Zend/Loader.php');
Zend_Loader::loadClass('Zend_Gdata');
Zend_Loader::loadClass('Zend_Gdata_ClientLogin');
Zend_Loader::loadClass('Zend_Gdata_Spreadsheets');
Zend_Loader::loadClass('Zend_Http_Client');

// Set your Google Docs credentials here
$user = 'your@gmail.com';
$pass = 'password';
$service            = Zend_Gdata_Spreadsheets::AUTH_SERVICE_NAME;
$client             = Zend_Gdata_ClientLogin::getHttpClient($user, $pass, $service);
$spreadsheetService = new Zend_Gdata_Spreadsheets($client);
$feed               = $spreadsheetService->getSpreadsheetFeed();


// This is not the url displayed when logged in to Goolge Docs, because
// that would just make sense. Oh, no - instead it has to be abstracted
// away in the object. This is the feed url. 
$sheetName = "Sheet1";
foreach($feed->entries as $entry)
{               
    if($entry->title->text == $sheetName)
    {
      $spreadsheetURL = $entry->id;
      echo "SpreadsheetURL is: $spreadsheetURL <br /> \n";
      break;
    }
}

$spreadsheetKey = basename($spreadsheetURL);

$query = new Zend_Gdata_Spreadsheets_DocumentQuery();
$query->setSpreadsheetKey($spreadsheetKey);
$feed = $spreadsheetService->getWorksheetFeed($query); 

echo "Spreadsheet Key : $spreadsheetKey <br/> \n";

foreach($feed->entries as $entry)
{
    echo "ID of sheet {$entry->title->text} is " . basename($entry->id) . " <br/> \n";
}

//$worksheetId = "Sheet1";
$worksheetId = basename($entry->id);

// Ensure to use all lower case for column (header) names and escape sequences for spaces. 
$spreadsheetService->insertRow(array('header1'=>'Blargity','header2'=>'9001'),$spreadsheetKey,$worksheetId);


?>
