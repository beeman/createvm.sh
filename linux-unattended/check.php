<?php
error_reporting(E_ALL);
flush();

$conf['updateurl']='http://createvm.googlecode.com/svn/linux-unattended/';

function say($msg){
	echo "<li>$msg</li>";
}

function update_software(){
	global $conf, $pwd;
	say("Updating software from <b>".$conf['updateurl']." </b>...");

	$command="svn co ".$conf['updateurl']." $pwd ";
	say($command);
	flush();
	$outp=exec($command);
	
	flush();
	print_r($outp);
	
	$flist=exec('ls -l');
	say($flist);
	sleep(1);
}

echo '<pre>';
echo('Bootux checker');
echo '<ul>';
flush();

$pwd=exec('pwd');

if(file_exists('bootux.conf')){
	say("bootux.conf found.");
} else {
	say("bootux.conf not found in $pwd.");
	echo '<ul>';
	update_software();
	echo '</ul>';
	say('done');
}

echo '</ul></pre>';

?>
