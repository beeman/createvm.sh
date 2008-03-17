<?php
error_reporting(E_ALL);
ob_implicit_flush();

function addform(){
	?><form id="DistroAddForm" method="post">Distro  <input name="distro" type="text" maxlength="50" value="" />
Version <input name="version" type="text" maxlength="10" value="" />
Arch    <select name="arch">
 <option value="i386" selected="selected">i386</option>
 <option value="x86_64">x86_64</option>
</select>
Type    <select name="type">
 <option value="rpm" selected="selected">rpm</option>
 <option value="deb">deb</option>
</select>
Mirrors <input name="mirrors" type="text"/>
        <input type="submit" value="Add" />
</form><?php
}

echo '<pre>';
addform();

if(sizeof($_REQUEST)>0){
	print_r($_REQUEST);
	$distro=$_REQUEST['distro'];
	$version=$_REQUEST['version'];
	$arch=$_REQUEST['arch'];
	$type=$_REQUEST['type'];
	$mirror=$_REQUEST['mirrors'];
	$cmd="/bin/bash -x scripts/addrepo.sh -d $distro -v $version -a $arch -m $mirror";
	echo $cmd;
	echo system($cmd);
	sleep(1);
} else {
	echo 'Nix.';
}

echo '</pre>';
?>
