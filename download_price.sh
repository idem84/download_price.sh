#!/bin/bash
#Расширенный вывод ошибок
set -e
#Статус HTTP 200 OK
HEADER="200"

#Получаем статусы файлов.
status=$(curl -s --head -w %{http_code} http://93.158.134.3/3WXML.xml -o /dev/null)
status2=$(curl -s --head -w %{http_code} http://93.158.134.3/3WXML_offers.xml -o /dev/null)

#Если статус обоих файлов 200, значит файлы доступны по ссылке, начинаем загрузку файлов если статус файлов 200, если другой статус, то пишется ошибка.
if [ "$status" = "$HEADER" ] && [ "$status2" = "$HEADER" ]
then
	echo "1. Начало выгрузки, проверка файлов!"
	#Получение даты модификации файла находящегося в офисе в формате: Tue, 22 Sep 2015 14:51:56
	OFFICE_FILE_DATE=`/usr/bin/curl -s -I "http://93.158.134.3/3WXML.xml" | awk '/^Last-Modified:/ { DATE=$3 " " $4 " " $5 " " $6 " " $7 ; system( "date -d \""  DATE "\" \"+%a, %d %b %Y %H:%M:%S\"" ) }'`;
	echo "2. Дата модицикации файла из офиса: $OFFICE_FILE_DATE"

	#Путь к файлу в котором хронится дата модицикации предыдущего файла:
	LAST_DATE_FILE='/home/bitrix/ext_www/site.ru/upload/1c_catalog/last_date';

	#Получаем дату последнего добавленого файла в формате: Tue, 22 Sep 2015 12:04:46
	OLD_FILE_DATE=`awk '{print substr($0,1,(length()0))}' $LAST_DATE_FILE`;
	echo "3. Дата модификации последнего загруженного файла с офиса на сервер: $OLD_FILE_DATE"
	echo " " #Пустая строка

	#Проверяем даты модификации обоих файлов, если файлы равны, выдаем сообщение что файл выгрузки старый и прекращаем выгрузку.
	if [ "$OFFICE_FILE_DATE" != "$OLD_FILE_DATE" ]
	then
		echo "4. Даты модификации обоих файлов не равны. Загрузка файлов выгрузки с офиса!"
		echo " " #Пустая строка

		#Загрузка первого файла с проверкой, если во время загрузки произайдет ошибка загрузки файлов, отобразится ошибка
		WGET=`/usr/bin/wget http://93.158.134.3/3WXML.xml -O /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML.xml &> /dev/null`
		EXITCODE=$?
		if [ $? -ne 0 ]
			then
				echo "5. Ошибка загрузки файла 3WXML.xml"
			else
				echo "5. Файл 3WXML.xml загружен без ошибок"
				first_file="1"
		fi

		#Загрузка второго файла с проверкой, если во время загрузки произайдет ошибка загрузки файлов, отобразится ошибка
		WGET2=`/usr/bin/wget http://93.158.134.3/3WXML_offers.xml -O /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML_offers.xml &> /dev/null`
		EXITCODE=$?
		if [ $? -ne 0 ]
			then
				echo "6. Ошибка загрузки файла 3WXML_offers.xml"
			else
				echo "6. Файл 3WXML_offers.xml загружен без ошибок"
				second_file="1"
		fi

		#Если оба файла загружены удачно, идем дальше
		if [ "$first_file" = "1" ] && [ "$second_file" = "1" ]
		then
			echo "7. Оба файла загружены без ошибок!"

			#Путь к файлу в котором хронится дата модификации последнего добавленого файла с офиса:
			#Ссылка в этой переменной критически важна для нормальной выгрузки и используется в нескольких местах в коде ниже!
			LAST_DATE_FILE='/home/bitrix/ext_www/site.ru/upload/1c_catalog/last_date';

			#Получаем дату модицикации последнего добавленого файла с офиса в формате: Tue, 22 Sep 2015 12:04:46
			OLD_FILE_DATE=`awk '{print substr($0,1,(length()0))}' $LAST_DATE_FILE`;

			#Получение даты модицикации загруженного файла из офиса в формате: Tue, 22 Sep 2015 15:04:46
			FILE_DATE=`date -r /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML.xml +'%a, %d %b %Y %H:%M:%S'`
			echo " " #Пустая строка
			echo "8. Дата последнего загруженного файла: $FILE_DATE"
			echo "9. Дата старого файла загруженного из офиса: $OLD_FILE_DATE"

			#Повторная проверка дат модификации обоих файлов, если они не равны, начинается выгрузка!
			if [ "$FILE_DATE" != "$OLD_FILE_DATE" ]
			then
				echo $FILE_DATE>$LAST_DATE_FILE
				echo "10. Даты файлов разные, начинается загрузка!"	

				echo " " #Пустая строка
				#Выводим информацию о том для какого сайта делается выгрузка, поиск по ID сайтв в файле.
				grep -q 00000000-0000-0000-0038-0000000000s2 /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML.xml && echo "11. Выгрузка для сайта SITE1.RU"
				grep -q 00000000-0000-0000-0032-0000000000s1 /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML.xml && echo "11. Выгрузка для сайта SITE2.RU"
		
				#Передача параметра определающего для какого сайта делается выгрузка в файл xml_importer.php. (Чтобы после импорта Bitrix отправлял название сайта для которого сделана выгрузка)
				if grep -q 00000000-0000-0000-0032-0000000000s1 /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML.xml;
				then
					SITE="1"
				else
					if grep -q 00000000-0000-0000-0038-0000000000s2 /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML.xml;
					then
						SITE="2"
					else
						SITE="0"
					fi
				fi

				echo " " #Пустая строка
				echo "Загрузка прайса!"
				cp -p /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML.xml /home/bitrix/ext_www/site.ru/upload/1c_catalog/import.xml
				cp -p /home/bitrix/ext_www/site.ru/upload/1c_catalog/files_from_office/3WXML_offers.xml /home/bitrix/ext_www/site.ru/upload/1c_catalog/offers.xml

				echo " " #Пустая строка				
				echo "Загрузка картинок и запуск импорта в Bitrix"
				/usr/bin/php /home/bitrix/ext_www/site.ru/image.php
				/usr/bin/php /home/bitrix/ext_www/site.ru/xml_importer.php $SITE
			else
				echo " " #Пустая строка
				echo "10. Даты файлов одинаковые! Старые файлы выгрузки."
			fi
		else
			echo "7. Во-время загрузки файлов возникла ошибка!"
		fi
	else
		echo "4. Даты модицикации файлов из офиса и сервера одинаковые! Старые файлы выгрузки."
		echo "5. Конец выгрузки!"
	fi
else
	echo "1. Нет доступа к файлу/файлам:"
	echo "Cтатус первого файла: $status"
	echo "Cтатус второго файла: $status2"
fi
