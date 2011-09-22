<?php
// Glued this together from the example give at:
// http://www.w3schools.com/php/php_secure_mail.asp
//
// ini_set('error_reporting', E_ALL);

function spamcheck($field)
  {
  //filter_var() sanitizes the e-mail
  //address using FILTER_SANITIZE_EMAIL
  $field=filter_var($field, FILTER_SANITIZE_EMAIL);

  //filter_var() validates the e-mail
  //address using FILTER_VALIDATE_EMAIL
  if(filter_var($field, FILTER_VALIDATE_EMAIL))
    {
    return TRUE;
    }
  else
    {
    return FALSE;
    }
  }

if (isset($_REQUEST['EmailAddress']))
  {//if "email" is filled out, proceed

 //check if the email address is invalid
  $mailcheck = spamcheck($_REQUEST['EmailAddress']);
  $code = $_REQUEST['Code'] ;

  if ($mailcheck==FALSE || $code == "Code")
    {
    echo "Invalid input";
    }
  elseif ($code == "Code")
  // This never runs with current logic
    {
        echo "Please input a valid code.";
    }
  else
    {//send email

      // echo "Getting data . . . ";

    $firstName = $_REQUEST['FirstName'] ;
    $lastName  = $_REQUEST['LastName'] ;
    $address = $_REQUEST['PostalAddress'] ;
    $city = $_REQUEST['City'] ;
    $province = $_REQUEST['Province'] ;
    $postalCode = $_REQUEST['PostalCode'] ;
    $phoneNumber = $_REQUEST['PhoneNumber'] ;
    $email = $_REQUEST['EmailAddress'] ;
    
    $message = $firstName . "," . $lastName . "," . $address . "," . $city . "," . $province . "," . $postalCode . "," . $phoneNumber . "," . $email . "," . $code;


    mail("user@somehere.com", "Subject: Offer Code: $code", $message, "From: $email" );
    echo "Thank you for using our mail form";
    }
  }

?>

