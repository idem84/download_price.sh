# download_price.sh
Данный скрипт создан для осуществления автоматического импорта товаров, обновления фотографий, цен и остатков сайта на базе **CMS Bitrix**. Данный скрипт поддерживает многосайтовость (В примере XML файла показано как передать ID сайта, а в скрипте настраивается функционал чтобы в письме на почту приходила информация для какого именно сайта сделана выгрузка).

PS.: Если Bitrix настроен в режиме многосайтовности, то одновременно выгрузка может происходить только на один сайт! Не получиться сделать так чтобы выгрузка автоматом одновременно происходила сразу на двух сайтах!

Необходимо хорошо разбираться в настройках админки битрикса чтобы новый импортированый каталог с товарами заработал. В админке нужно настраивать инфоблоки, пути, указывать в настройках компонентов ID каталога или выбирать из списка нужный каталог по названию и т.д.

## Для кого подойдет этот скрипт:

1.  Для тех, у кого в компании учет товаров, цен и остатков ведется не в **1С**, а какой ни будь другой программе, например самопиской на Microsoft Access, МойСклад и т.д.

2.  Для тех, у кого вообще нет базы товаров. Кто хочет наполнить свой магазин товарами быстро из файла и после дополнять или изменять товары, цены, остатки при помощи правки файлов XML.

## Что нужно для правильной работы скрипта?

1.  Прежде всего, сам **Bitrix**.
2.  Далее правильно сгенерированные XML файлы для импорта. Примеры файлов можно будет скачать в списке файлов репозитория.
3.  Сам скрипт настроен на получение этих файлов с удаленного адреса, с другого сайта или FTP. По умолчанию Вам необходимо выкладывать в открытый доступ или на FTP файлы и прописать ссылки на эти файлы в скрипте.
4.  Консольный доступ на сервер по SSH.

## Инструкция:

### Шаг первый 1:

Загрузите файл **download_price.sh** на сервер по следующему пути `/home/bitrix/www/site.ru/1c_catalog/`

PS.: Указан путь к конечной папке по умолчанию в BitrixVM.

Установите правильные права на выполнение файла:

````html
chmod +x /home/bitrix/www/site.ru/1c_catalog/download_price.sh
````
Убедитесь что файл имеет правильного владельца и группу, а именно те же что и у сайта. И cron задача должна быть прописана у того же пользователя.


### Шаг второй 2:

В файле **download_price.sh** везде измените пути к удаленным файлам для импорта на свои. 
Вот эти: `http://93.158.134.3/3WXML.xml` и `http://93.158.134.3/3WXML_offers.xml`

Далее везде в коде замените путь `/home/bitrix/www/site.ru/` на Ваш путь к конечной папке.

### Шаг третий 3:

Создайте папку **files_from_office** внутри папки **1c_catalog**

### Шаг четвертый 4:

Создайте cron задачу для запуска файла **download_price.sh** под нужным пользователем или через панель управления сервером.

````html
crontab -u bitrix -e
i
*/3 * * * * /home/bitrix/ext_www/podarki-v-mode.ru/upload/1c_catalog/download_price.sh
Esc
:wq
````

В данном примере указано что скрипт будет запускаться каждые 3 минуты. Если все настроено правильно, то в папке **files_from_office** должны появится 2 файла 3WXML.xml и 3WXML_offers.xml, далее в папке **1c_catalog** должны появится 3 новых файла: import.xml, offers.xml и last_date.

Если Все прошло как надо, в админке битрикса Вы увидите что создался каталог с товарами:
PS.: Вы так же можете импортировать товары в существующий каталог, для этого необходимо в файлах XML указать ID каталога (Внешний код в админке битрикса в настройках инфоблока созданого ранее каталога). Внимание! Этот ID может указываться в файле несколько раз!

Пример:

![Фотография XML файла с товарами](https://raw.githubusercontent.com/idem84/download_price.sh/master/3.jpg)

Фотографии админки битрикса:

![Фотография админки битрикса](https://raw.githubusercontent.com/idem84/download_price.sh/master/1.jpg)

![Фотография админки битрикса 2](https://raw.githubusercontent.com/idem84/download_price.sh/master/2.jpg)
