<?php 
// Permitir solicitudes desde cualquier origen
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Verificar si es una solicitud OPTIONS y responder con OK
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

	$db = mysqli_connect('localhost', 'devapps', 'D3v4pp5%', 'devapps_comando');

	$username = $_POST['username'];
	$password = $_POST['password'];

	$sql = "SELECT * FROM login WHERE username = '".$username."' AND password = '".$password."'";

	$result = mysqli_query($db,$sql);
	$count = mysqli_num_rows($result);

	if ($count == 1) {
		echo json_encode("Success");
	}else{
		echo json_encode("Error");
	}

?>



