<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Packages DTI</title>
<style>
body {color: #666;}
ul#list {margin: 1.5em;}
ul#liste li {border-bottom:1px solid #ccc;padding: .2em 0 .2em .5em;font-weight:bold;color: #666;}
ul#liste li:hover {cursor:pointer;background-color:#f2f2f2;color:#000;}
.software {padding-right:10px;}
</style>
</head>
<body>
<?php
if ($_GET['access'] == 'RestrictedAccess'){
        echo "<h1>Information</h1>";
        echo "<b>Hostname:</b> ".shell_exec('hostname');
        echo "<br><b>Uname:</b> ".shell_exec('uname -a');
        echo "<br><b>SELinux:</b> ".shell_exec("/usr/sbin/sestatus | grep mode | awk -F': ' '{print $2}'");
        $data=shell_exec("yum list | grep 'dti-' | awk -F' ' '{print \"<li><b><font class='software'>\" $1 \":</font><font color=#0000CC> \" $2 \"</font></b></li>\"}'");
        $data=str_replace('dti-','', $data);
        $data=str_replace('.el6','', $data);
        echo "<h1>Packages</h1>";
        echo "<ul id='liste'>";
        echo $data;
        echo "</ul>";
}
?>
</body>
</html>
