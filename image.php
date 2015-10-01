<?php
$cur_xml_path = '/home/bitrix/www/site.ru/upload/1c_catalog/import.xml';
$old_xml_path = '/home/bitrix/www/site.ru/upload/1c_catalog/import-old.xml';
$new_xml_path = '/home/bitrix/www/site.ru/upload/1c_catalog/import-new.xml';
$xml_file = fopen($cur_xml_path, 'r');
$xml_res_file = fopen($new_xml_path, 'w');
$target_dir = '/home/bitrix/www/site.ru/upload/downloaded_images/';
$start_search = false;
$tmp_image_array = array();
while ($cur_line = fgets($xml_file)) {
    if (preg_match('/(<Значение>)(http:\/\/[^\/]*)(\/[^<]*)(<\/Значение>)?/', $cur_line, $matches)) {
        $url = $matches[2] . $matches[3];
        $path_parts = explode('/', $matches[3]);
        $last_index = sizeof($path_parts) - 1;
        $dir = $target_dir;

        for ($i = 0; $i < $last_index; $i++) {
            $dir .= $path_parts[$i] . "/";
        }
        if (!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }
        $target_file = $target_dir . $path_parts[$last_index];
        #изменения
        #сравниваем даты файлов в downloaded_images и из xml
        $download_image = false;
        if (is_file($target_file)) { #старая картинка
            $last_file = filemtime($target_file);
        } else {
            $last_file = 0;
        }
        $headers = get_headers($url, 1);
        if ($headers[0] == 'HTTP/1.1 200 OK') { #новая картинка
            $new_file = strtotime($headers["Last-Modified"]);
        } else {
            $new_file = 0;
        }
        if ($last_file < $new_file) {
            $download_image = true;
        }
        #изменения
        if ($download_image) { #надо ли качать?
            if ($headers[0] == 'HTTP/1.1 200 OK') {
                $ch = curl_init($url);
                $fp = fopen($target_file, 'wb');
                curl_setopt($ch, CURLOPT_FILE, $fp);
                curl_setopt($ch, CURLOPT_HEADER, 0);
                curl_exec($ch);
                curl_close($ch);
                fclose($fp);
                $start_search = true;
                $tmp_image_array[] = $target_file;
            } else {
                echo "$url not found\n";
            }
        } else {
            if (is_file($target_file)) { #есть ли такая картинка в папке downloaded_images
                $start_search = true;
                $tmp_image_array[] = $target_file;
            }
        }

    }
    if ($start_search) {
        if (strpos($last_line, '</ЗначенияРеквизитов>')) {
            $start_search = false;
            foreach ($tmp_image_array as $image) {
                fwrite($xml_res_file, "<Картинка>$image</Картинка>\n");
            }
            $tmp_image_array = array();
        }
    }
    $last_line = $cur_line;
    fwrite($xml_res_file, $cur_line);
}
fclose($xml_res_file);
fclose($xml_file);

rename($cur_xml_path, $old_xml_path);
rename($new_xml_path, $cur_xml_path);

?>
