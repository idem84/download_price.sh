<?php
$done=false;
#Почта на которую будут отправляться письма со статусом выгрузки.
$target_emails=array('user1@mail.ru', 'user2@mail.ru');
#Логин и пароль в админку (полный доступ)
$login='root';
$password='пароль';
$host="127.0.0.1:8887";
$url="http://$host/bitrix/admin/";
$login_url="http://$host/bitrix/admin/?login=yes";


$import_urls=array('import'=>"http://$host/bitrix/admin/1c_exchange.php?type=catalog&mode=import&filename=import.xml&Interval=30",
                   'offers'=>"http://$host/bitrix/admin/1c_exchange.php?type=catalog&mode=import&filename=offers.xml&Interval=30");

$s = curl_init();
$message='';
$site=0;
if(isset($argv)){
    $site = $argv[1];
}

curl_setopt($s, CURLOPT_COOKIEFILE, __DIR__.'/cookie.txt');
curl_setopt($s, CURLOPT_COOKIEJAR, __DIR__.'/cookie.txt');
curl_setopt($s, CURLOPT_URL, $url);
curl_setopt($s, CURLOPT_RETURNTRANSFER, true);
$res=curl_exec($s);
$post_fields = array('AUTH_FORM' => 'Y', 'TYPE' => 'AUTH',  'USER_LOGIN' => $login, 'USER_PASSWORD' => $password,  'Login' => '', 'captcha_sid'=>'','captcha_word'=>'');
if($res) {
    if(preg_match('/(<input type="hidden" name="sessid" id="sessid" value=")([^"].*)(" \/>)/',$res,$matches)){
        $post_fields['sessid'] = $matches[2];
        curl_setopt($s, CURLOPT_URL, $login_url);
        curl_setopt($s, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($s, CURLOPT_POST, true);
        curl_setopt($s, CURLOPT_POSTFIELDS, $post_fields);
        $admin_page = curl_exec($s);
        sleep(10);
        $admin_page = curl_exec($s);
    }

    foreach ($import_urls as $name=>$import_url) {
        curl_setopt($s, CURLOPT_URL, $import_url);

        if(isset($site)){
            if($site==1){
                $message.="<h2>[SITE1.RU] Начало обработки $name.xml</h2>\n";
            }elseif($site==2){
                $message.="<h2>[SITE2.RU] Начало обработки $name.xml</h2>\n";
            }elseif($site==0){
                $message.="<h2>[Сайт не определен] Начало обработки $name.xml</h2>\n";
            } else {
                $message.="<h2>[Сайт не определен] Начало обработки $name.xml</h2>\n";
            }
        }

        do {
            $import_html = curl_exec($s);
            if (!$import_html) {
                echo "Скрипт не может открыть ссылку $import_url\n";
                break;
            }
            $import_html = iconv('CP1251', 'UTF-8', $import_html);
            ob_start();
            $import_html = str_replace('progress', '', $import_html);
            echo "$import_html<br />\n";
            $content = ob_get_contents();
            $message .= $content;
            ob_end_clean();
            echo $content;
        } while (strpos($import_html, 'success') === false && strpos($import_html, 'failure') === false);
        $done = true;
    }
}
curl_close($s);
if($done){
    $result='success';
    if(!strpos($import_html,'failure')===false){
        $result='failure';
    }
    $headers = 'Content-type: text/html; charset=utf-8' . "\r\n";
    foreach($target_emails as $email){
        if(isset($site)){
            if($site==1){
                mail($email,"[SITE1.RU] Price import result ($result)",$message,$headers);
            }elseif($site==2){
                mail($email,"[SITE2.RU] Price import result($result)",$message,$headers);
            }elseif($site==0){
                mail($email,"[Site not found] Price import result ($result)",$message,$headers);
            }
        } else {
            mail($email,"[Site not found] Price import result ($result)",$message,$headers);
        }
    }
}


?>
