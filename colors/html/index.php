<html>
<head>
<title>Barracuda Demo Web App</title>
<style>
body { text-align: center; }
table {
  margin: auto; 
}

</style>
</head>

<table>
<?php
$rows = 7;
$cols = 12;
$colspan = 6;
$rowspan = 3;
$colstart = 3;
$rowstart = 2;

for ( $rowcnt = 0 ; $rowcnt < $rows ; $rowcnt++ ) {
	echo '<tr>';
	for ( $colcnt = 0 ; $colcnt < $cols ; $colcnt++ ) {
		if ( $rowcnt==$rowstart && $colcnt==$colstart ) {
			echo "<td colspan=$colspan rowspan=$rowspan >";
			mysql_connect( '172.16.0.5', 'demo', '' ) or die( mysql_error());
			mysql_select_db( 'demo' );
			?>
<form>
<input name="needle"><input type="submit" value="Search color"><br>
</form>
			<?php
			if (!empty( $_GET[ 'needle' ])) {
				$res = mysql_query( "SELECT * FROM colors WHERE name LIKE '%{$_GET[ 'needle' ]}%'" );
				if ( mysql_num_rows( $res ) == 1 ) {
					// just one match - display it
					echo '<div style="background-color: #';
					echo mysql_result( $res, 0, 0 );
					echo '; width: 80px; height: 80px; float: right; border: 1px solid black;">&nbsp;</div>';
					echo '<div style="font-size:4em;float: left;">';
					echo mysql_result( $res, 0, 1 );
					echo '</div>';
				}

				
			}
			echo "</td>";
		}
		if ( $colcnt >= $colstart && $colcnt < ( $colstart + $colspan ) && $rowcnt >= $rowstart && $rowcnt < ( $rowstart+$rowspan )) {
			$colcnt += $colspan;
		}
		echo '<td>';
		echo '<img src="blank.png?' .md5( rand() ). '">';
		echo '</td>';
	}
	echo '</tr>';
}
?>
</table>
</html>

