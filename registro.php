<?php
// Permitir solicitudes desde cualquier origen
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");


	$db = mysqli_connect('localhost', 'devapps', 'D3v4pp5%', 'devapps_comando');
	if (!$db) {
		echo "Database connection faild";
	}

	$username = $_POST['username'];
	$password = $_POST['password'];

	$sql = "SELECT username FROM login WHERE username = '".$username."'";

	$result = mysqli_query($db,$sql);
	$count = mysqli_num_rows($result);

	if ($count == 1) {
		echo json_encode("Error");
	}else{
		$insert = "INSERT INTO login(username,password)VALUES('".$username."','".$password."')";
		$query = mysqli_query($db,$insert);
		if ($query) {
			echo json_encode("Success");
		}
	}

?>