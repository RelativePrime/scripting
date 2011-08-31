
<!-- MS SQL Connection Tester
	This requires PHP to be compiled with MS MSQL support. You can verify
	if you have that by looking in a phpinfo.php file for mssql 
	This suport is typically added through the FreeTDS libraries -->

<!-- This script allows you to quickly verify a connection to an MS SQL server,
	 even if it is listenting on a non-default port. It will also display a dump
	 of all databases on the server (if you login as an admin) or will display
	 a list of all tables if a specific database is given.
 -->

<html>
   
<head>
  <title>MS SQL Connect</title>
  
	<style type="text/css">
		body { background-color:#cccccc; }
		p {margin-left:20px}
		.noborder td {border: hidden }
	</style>
</head>

<body>


<?php 
// Check if the form has been submitted: 

if  (isset($_POST['submitted']))  
{

	// Validate the form:
		
	if ( (empty($_POST['user'])) || (empty($_POST['password'])) || (empty($_POST['password'])) ) {
		print "<h1>MS SQL Database Connector</h1>";
		print '<h4 style="color:red;">Please go back and provide the following required fields</h4>';
	}
	
		if (empty($_POST['server'])) {
		
					print '<p>Please enter a server hostname or IP.</p>';
		}
	
	
			if  (empty($_POST['user']))  {
					
			print '<p>Please enter a database user name.</p>';
		
			}
	
				if (empty($_POST['password'])) {
		
					print '<p>Please enter a database password.</p>';
				}
	
						elseif (!empty($_POST['submitted'])) { // Validation okay, so lets run the connection!
						
						echo "Attempting to connect . . . <br />";
		 	
						$myServer = $_POST['server'];
						$myPort = $_POST['port'];
						$myUser = $_POST['user'];
						$myPass = $_POST['password'];
						$myDB = $_POST['database'];

							if (!empty($myPort)) {
								$myServer="$myServer:$myPort";
							}
								
						// if (empty($_POST['database'])) {
						// 	$myDB = $_POST['database'];
						//	} else {
						//		$myDB = null;
						//	}
						
						
						//echo "$myServer<br />";
						//echo "$myPort<br />";
						//echo "$myUser<br />";
						//echo "$myPass<br />";	
						//echo "$myDB<br />";	
							
						// $myServer = "localhost";
						// $myUser = "your_name";
						// $myPass = "your_password";
						// $myDB = "examples";
						
						// Server in this format: <computer>\<instance name> or 
						// <server>:<port> when using a non default port number
						
						//connection to the database
						$dbhandle = mssql_connect($myServer, $myUser, $myPass)
						  or die("<font color=\"red\">ERROR: Couldn't connect to SQL Server on $myServer</font>");
						
						echo "Successfully connected to $myServer <br />";
						
						// If no database specifed it will do the else condition below and show all databases on the server;
						
								if (!empty($myDB))
								{
								
								//select a database to work with
								 $selected = mssql_select_db($myDB, $dbhandle)
								  or die("Couldn't open database $myDB");
								
								//declare the SQL statement that will query the database
								// $query = "SELECT id, name, year ";
								// $query .= "FROM cars ";
								// $query .= "WHERE name='BMW'";
								// $query = "sp_databases";
								
								// $query = "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'";
								// $query = "SELECT * FROM SYS.DATABASES";
								// Will show all databases on server (you still need to have $myDB set above to a specific db first though?
								
								$query = "select name from $myDB..sysobjects where xtype = 'U'"; 
								// Will show all tables in the specified DB
								
								//execute the SQL query and return records
								$result = mssql_query($query);
								
								$numRows = mssql_num_rows($result);
								echo "<h1>" . $numRows . " Row" . ($numRows == 1 ? "" : "s") . " Returned </h1>";
								
								//display the results
								while($row = mssql_fetch_array($result))
								  {
								  echo "<li>" . $row["id"] . $row["name"] . $row["year"] . "</li>";
								  }
								
								} else {
						
									$query = "SELECT * FROM SYS.DATABASES";
									
									$result = mssql_query($query);
									
									$numRows = mssql_num_rows($result);
									echo "<h1>" . $numRows . " Row" . ($numRows == 1 ? "" : "s") . " Returned </h1>";
									
									//display the results
									while($row = mssql_fetch_array($result))
									  {
									  echo "<li>" . $row["id"] . $row["name"] . $row["year"] . "</li>";
									  }
																		
									}
						
						//close the connection
						mssql_close($dbhandle);
						
						//Some functions for listing databases and tables in mysql can be found at
						//http://forums.tizag.com/archive/index.php?t-4497.html
						
						
					} // Ends if statement that runs if validation is okay: if (isset($POST['submitted'])) {

		// if $_POST value for 'server' is empty, then display the form to get all the server informtion.
		// it is included as the embedded php in it will not otherwise run if it were part of this if statement block.
}  else { //ends highest level if statement   
		
		include ('mssql_connection_details.html');

		}

?>
		
</body>
</html>
			
			
			
