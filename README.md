# 1C Database copier (cpdb)
[![GitHub release](https://img.shields.io/github/release/ArKuznetsov/cpdb.svg?style=flat-square)](https://github.com/ArKuznetsov/cpdb/releases)
[![GitHub license](https://img.shields.io/github/license/ArKuznetsov/cpdb.svg?style=flat-square)](https://github.com/ArKuznetsov/cpdb/blob/develop/LICENSE.md)
[![GitHub Releases](https://img.shields.io/github/downloads/ArKuznetsov/cpdb/latest/total?style=flat-square)](https://github.com/ArKuznetsov/cpdb/releases)
[![GitHub All Releases](https://img.shields.io/github/downloads/ArKuznetsov/cpdb/total?style=flat-square)](https://github.com/ArKuznetsov/cpdb/releases)

[![Build Status](https://travis-ci.org/arkuznetsov/cpdb.svg?branch=develop)](https://travis-ci.org/arkuznetsov/cpdb)
[![Quality Gate](https://open.checkbsl.org/api/project_badges/measure?project=cpdb&metric=alert_status)](https://open.checkbsl.org/dashboard/index/cpdb)
[![Coverage](https://open.checkbsl.org/api/project_badges/measure?project=cpdb&metric=coverage)](https://open.checkbsl.org/dashboard/index/cpdb)
[![Tech debt](https://open.checkbsl.org/api/project_badges/measure?project=cpdb&metric=sqale_index)](https://open.checkbsl.org/dashboard/index/cpdb)

Набор скриптов oscript для копирования баз данных 1C / MS SQL и развертывания на целевой системе.
Типичный сценарий работы:
1. Сформировать резервную копию базы
2. Передать резервную копию на целевую систему
    - Через общую папку / С использованием Yandex-Диск 
    - Возможно разбиение больших файлов на части (используется 7-zip)
5. Восстановить резервную копию в новую или существующую базу
6. Подключить базу к хранилищу конфигурации

Требуются следующие библиотеки и инструменты:
- [1commands](https://github.com/artbear/1commands)
- [logos](https://github.com/oscript-library/logos)
- [v8runner](https://github.com/oscript-library/v8runner)
- [v8storage](https://github.com/oscript-library/v8storage)
- [cli](https://github.com/Stepa86/cli)
- [yadisk](https://github.com/kuntashov/oscript-yadisk)
- [7-zip](http://www.7-zip.org/)
- [MS Command Line Utilities for SQL Server (sqlcmd)](https://www.microsoft.com/en-us/download/details.aspx?id=53591)


## Возможные команды
---

||||
|-|-|-|
|**database** | Группа команд работы с СУБД||
|| **backup** | - Создание резервной копии базы MS SQL ||
|| **restore** | - Восстановление базы MS SQL из резервной копии |
|| **compress** | - Выполнить компрессию страниц таблиц и индекстов в базе MS SQL |
|| **script** | - Выполнить произвольный скрипт на сервере MS SQL |
|**infobase** | Группа команд работы с информационными базами 1С||
|| **create** | - Создать информационную базу на сервере 1С |
|| **dump** | - Выгрузить информационную базу в файл |
|| **restore** | - Загрузить информационную базу из файла |
|| **uconstorage** | - Отключить информационную базу от хранилища конфигураций |
|| **constorage** | - Подключить информационную базу к хранилищу конфигураций |
|**file** | Группа команд работы с файлами||
|| **copy** | - копировать/переместить файлы |
|| **split** | - Архивировать файл с разбиением на части указанного размера (используется 7-Zip) |
|| **merge** | - Разархивировать файл (используется 7-Zip) |
|| **putyadisk** | - Помещение файла на Yandex-Диск |
|| **getyadisk** | - Получение файла из Yandex-Диска |
|| **mapdrive** | - подключить сетевой диск |
|| **umapdrive** | - отключить сетевой диск |
| **batch** | - Последовательное выполнение команд по сценариям, заданным в файлах (json) |
||||

Для подсказки по конкретной команде наберите **<команда> --help**

## database - Группа команд работы с СУБД

| Общие параметры для команд группы: ||
|-|-|
| **--sql-srvr** | - Адрес сервера MS SQL |
| **--sql-user** | - Пользователь сервера |
| **--sql-pwd** | - Пароль пользователя сервера |
----------------------------------------------------------------

## backup - Создание резервной копии базы MS SQL

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--sql-db** | - Имя базы для восстановления |
| **--bak-path** | - Путь к резервной копии |

#### Пример:

```bat
cpdb database --sql-srvr MySQLName --sql-user sa --sql-pwd 12345 backup --sql-db MyDatabase --bak-path "d:\MSSQL\Backup\MyDatabase_copy.bak"
```

## restore - Восстановление базы MS SQL из резервной копии

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--sql-db** | - Имя базы для восстановления |
| **--bak-path** | - Путь к резервной копии |
| **--create-db** | - Создать базу в случае отсутствия |
| **--db-owner** | - Имя владельца базы после восстановления |
| **--compress-db** | - Включить компрессию страниц таблиц и индексов после восстановления |
| **--shrink-db** | - Сжать файлы данных после восстановления |
| **--shrink-log** | - Сжать файлы журнала транзакций после восстановления |
| **--db-path** | - Путь к каталогу файлов данных базы после восстановления |
| **--db-logpath** | - Путь к каталогу файлов журнала после восстановления |
| **--db-recovery** | - Установить модель восстановления (RECOVERY MODEL), возможные значения "FULL", "SIMPLE", "BULK_LOGGED" |
| **--db-changelfn** | - Изменить логические имена файлов (LFN) базы, в соответствии с именем базы |
| **--delsrc** | - Удалить файл резервной копии после восстановления |

#### Пример:

```bat
cpdb database --sql-srvr MyNewSQLServer --sql-user SQLUser --sql-pwd 123456 restore --sql-db MyDatabase_copy --bak-path "d:\data\MyBackUpfile.bak" --create-db --shrink-db --db-owner SQLdbo --db-path "d:\MSSQL\data" --db-logpath "e:\MSSQL\logs" --db-recovery SIMPLE --delsrc
```

## compress - Выполнить компрессию страниц таблиц и индекстов в базе MS SQL

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--sql-db** | - Имя базы для восстановления |
| **--shrink-db** | - Сжать базу после выполнения компрессии |
| **--shrink-log** | - Сжать файлы журнала транзакций после восстановления |

#### Пример:

```bat
cpdb database --sql-srvr MyNewSQLServer --sql-user SQLUser --sql-pwd 123456 compress --sql-db MyDatabase_copy --shrink-db
```

## script - Выполнить скрипты из файла(ов)

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--sql-files** | - Файлы SQL, содержащие текст скрипта, могут быть указаны несколько файлов, разделённые ";" |
| **--sql-vars** | - Строка переменных (без пробелов) для скриптов SQL, имя переменной и значение разделены "=", переменные разделены ";" |

#### Пример:

```bat
cpdb database --sql-srvr MyNewSQLServer --sql-user SQLUser --sql-pwd 123456 script --params "./JSON/cpdb_env.json" --sql-files "./tools/config_error.sql;./tools/print_message.sql" --sql-vars "varBase=MyDB;message=\"Hello world\""
```

#### Пример config_error.sql:

```sql
use $(varBase)
go
truncate table [dbo].[ConfigSave]
go
UPDATE SchemaStorage SET Status = 100
```

#### Пример print_message.sql:

```sql
PRINT N'$(message)'
```

## infobase - Группа команд работы с информационной базой 1С
| Общие параметры для команд группы: ||
|-|-|
| **--v8version** | - маска версии платформы 1С (например: 8.3.8, 8.3.17.1851) |
---

## create - Создать информационную базу на сервере 1С

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--ib-srvr** | - Адрес кластера серверов 1С ([<протокол>://]<адрес>[:<порт>]) |
| **--ib-ref** | - Имя базы в кластере 1С |
| **--errifexist** | - Сообщить об ошибке если ИБ в кластере 1С существует |
| **--dbms** | - Тип сервера СУБД (MSSQLServer <по умолчанию>; PostgreSQL; IBMDB2; OracleDatabase) |
| **--db-srvr** | - Адрес/имя сервера СУБД |
| **--db-user** | - Пользователь сервера СУБД" |
| **--db-pwd** | - Пароль пользователя сервера СУБД" |
| **--db-name** | - Имя базы на сервере СУБД (если не указано, используется имя базы 1С)" |
| **--sql-offs** | - Смещение дат на сервере MS SQL (0; 2000 <по умолчанию>) |
| **--createdb** | - Создавать базу данных в случае отсутствия |
| **--allowschjob** | - Разрешить регламентные задания |
| **--allowlicdstr** | - Разрешить выдачу лицензий сервером 1С |
| **--cadm-user** | - Имя администратора кластера |
| **--cadm-pwd** | - Пароль администратора кластера |
| **--nameinlist** | - Имя в списке баз пользователя (если не задано, то ИБ в список не добавляется) |
| **--tmplt-path** | - Путь к шаблону для создания информационной базы (*.cf; *.dt). Если шаблон не указан, то будет создана пустая ИБ |

#### Пример:

```bat
cpdb infobase --v8version 8.3.8 create --ib-srvr My1CServer --ib-ref TST_DB_MyDomain --db-srvr MySQLServer --db-user _1CSrvUsr1 --db-pwd p@ssw0rd --db-name TST_DB_MyDomain --createdb --nameinlist "My test base" --errifexist
```

## dump - Выгрузить информационную базу в файл

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--ib-path** | - Строка подключения к ИБ |
| **--ib-user** | - Пользователь ИБ |
| **--ib-pwd** | - Пароль пользователя ИБ |
| **--dt-path** | - Путь к файлу для выгрузки ИБ |
| **--uccode** | - Ключ разрешения запуска ИБ |

#### Пример:

```bat
cpdb infobase --v8version 8.3.8 dump --ib-path "/FD:/data/MyDatabase" --dt-path "d:\data\1Cv8.dt" --ib-user Администратор --ib-pwd 123456 --uccode 1234
```

## restore - Загрузить информационную базу из файла

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--ib-path** | - Строка подключения к ИБ |
| **--ib-user** | - Пользователь ИБ |
| **--ib-pwd** | - Пароль пользователя ИБ |
| **--dt-path** | - Путь к файлу для загрузки в ИБ |
| **--uccode** | - Ключ разрешения запуска ИБ |
| **--delsrc** | - Удалить файл после загрузки |

#### Пример:

```bat
cpdb infobase --v8version 8.3.8 restore --ib-path "/FD:/data/MyDatabase" --dt-path "d:\data\1Cv8.dt" --ib-user Администратор --ib-pwd 123456 --uccode 1234 -delsrc
```

## uconstorage - Отключить информационную базу от хранилища конфигурации

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--ib-path** | - Строка подключения к ИБ");
| **--ib-user** | - Пользователь ИБ");
| **--ib-pwd** | - Пароль пользователя ИБ");
| **--extension** | - Имя отключаемого расширения конфигурации |
| **--uccode** | - Ключ разрешения запуска ИБ");

#### Пример:

```bat
cpdb infobase --v8version 8.3.8 uconstorage --ib-path "/FD:/data/MyDatabase" --ib-user Администратор --ib-pwd 123456 --uccode 1234
```

## constorage - Подключить информационую базу к хранилищу конфигурации

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--ib-path** | - Строка подключения к ИБ |
| **--ib-user** | - Пользователь ИБ |
| **--ib-pwd** | - Пароль пользователя ИБ |
| **--extension** | - Имя подключаемого расширения конфигурации |
| **--storage-path** | - Адрес хранилища конфигурации |
| **--storage-user** | - Пользователь хранилища конфигурации |
| **--storage-pwd** | - Пароль пользователя хранилища конфигурации |
| **--update-ib** | - Выполнить обновление ИБ (применить полученную из хранилища конфигурацию к ИБ) |
| **--uccode** | - Ключ разрешения запуска ИБ |

#### Пример:

```bat
cpdb infobase --v8version 8.3. constorage --ib-path "/FD:/data/MyDatabase" --ib-user Администратор --ib-pwd 123456 --storage-path "tcp://MyServer/MyRepository" --storage-user MyDatabase_usr1 --storage-pwd 123456 --uccode 12348
```

## file - Группа команд работы с файлами
---

## copy - Скопировать/переместить файлы

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--src** | - Файл источник |
| **--dst** | - Файл/каталог приемник (если оканчивается на "\", то каталог) |
| **--move** | - Выполнить перемещение файлов (удалить источник после копирования) |
| **--lastonly** | - Копирование файлов, измененных не ранее текущей даты |

#### Простой пример. Копирование файла в каталог:

```bat
cpdb file copy --src "d:\MSSQL\Backup\MyDatabase_copy.bak" --dst "N:\NewDestination\" --replace --move
```
#### Сложный пример. В каталоге-источнике имеется несколько резервных копий с датой в имени файла. Необходимо скопировать только свежий файл (созданный сегодня). Новое имя файла не должно содержать дату:

```bat
cpdb file copy --src "d:\MSSQL\Backup\MyDatabase_copy*.bak" --dst "N:\NewDestination\MyDatabase_copy.bak*" --replace --move --lastonly
```

## split - Архивировать файл с разбиением на части указанного размера

Используется 7-zip

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет) |
| **--src** | - Путь к исходному локальному файлу для разбиения |
| **--arch** | - Имя файла архива (не обязательный, по умолчанию <имя исходного файла>.7z) |
| **--list** | - Имя файла, списка томов архива (не обязательный, по умолчанию <имя исходного файла>.split) |
| **--vol-size** | - Размер части {\<g>, \<m>, \<b>} (по умолчанию 50m) |
| **--compress-level** | - Уровень сжатия частей архива {0 - 9} (по умолчанию 0 - не сжимать) |
| **--delsrc** | - Удалить исходный файл после выполнения операции |

#### Пример:

```bat
cpdb file split "d:\MSSQL\Backup\MyDatabase_copy.bak" --list "d:\MSSQL\Backup\MyDatabase_copy.split" --vol-size 40m --delsrc
```

## merge - Разархивировать файл

Используется 7-zip

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--arch** | - Имя первого файла архива |
| **--list** | - Имя файла, списка файлов архива (параметр -arch игнорируется) |
| **--delsrc** | - Удалить исходные файлы после выполнения операции |

#### Пример:

```bat
cpdb file merge --file "d:\MSSQL\Backup\MyDatabase_copy.7z.001" --delsrc
```

```bat
cpdb file merge --list "d:\MSSQL\Backup\MyDatabase_copy.split" --delsrc
```

## putyadisk - Помещение файла на Yandex-Диск

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--file** | - Путь к локальному файлу для помещения на Yandex-Диск |
| **--list** | - Путь к локальному файлу со списком файлов, которые будут помещены на Yandex-Диск (параметр -file игнорируется) |
| **--token** | - Token авторизации |
| **--path** | - Путь к каталогу на Yandex-Диск, куда помещать загружаемые файлы |
| **--replace** | - Перезаписать файл на Яндекс-диске при загрузке |
| **--delsrc** | - Удалить исходные файлы после отправки |

#### Пример:

```bat
cpdb file putyadisk --file "d:\MSSQL\Backup\MyDatabase_copy.bak" --token XXXXXXXXXXXXXXXXXXXXXXXXXXXXX --path "/transfer" --delsrc
```

```bat
cpdb file putyadisk --list "d:\MSSQL\Backup\MyDatabase_copy.split" --token XXXXXXXXXXXXXXXXXXXXXXXXXXXXX --path "/transfer" --delsrc
```

## getyadisk - Получение файла из Yandex-Диска

### Параметры:

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет)|
| **--path** | - Путь к локальному каталогу для сохранения загруженных файлов|
| **--token** | - Token авторизации |
| **--file** | - Путь к файлу на Yandex-Диск для загрузки |
| **--list** | - Путь к файлу на Yandex-Диск со списком файлов, которые будут загружены (параметр -ya-file игнорируется) |
| **--delsrc** | - Удалить файлы из Yandex-Диск после получения |

#### Пример:

```bat
cpdb file getyadisk --path "d:\MSSQL\Backup\MyDatabase_copy.bak" --token XXXXXXXXXXXXXXXXXXXXXXXXXXXXX --file "/transfer/MyDatabase_copy.bak" --delsrc
```

```bat
cpdb file getyadisk --path "d:\MSSQL\Backup\MyDatabase_copy.bak" --token XXXXXXXXXXXXXXXXXXXXXXXXXXXXX --list "/transfer/MyDatabase_copy.split" -delsrc
```

##### Для получения токена авторизации Яндекс-диска:

* Зарегистрировать приложение: https://oauth.yandex.ru/client/new
	* Название приложения, например "OScript.YaDisk"
	* Платформы "Веб-сервисы"
	* Callback URI #1:  https://oauth.yandex.ru/verification_code
* Дать нужные права для приложения
	* Сервис Яндекс.Диск REST API
	  	* Запись в любом месте на Диске
	  	  	* Чтение всего Диска
	  	  	* Доступ к информации о Диске 
* Нажать "Создать приложение" внизу формы: после этого будет показан ID пароль, прочие параметры созданного приложения
* Получить токен для приложения: перейти по ссылке https://oauth.yandex.ru/authorize?response_type=token&client_id=<ВАШ ID (ID: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)>
* На вопрос "Приложение OScript.YaDisk запрашивает доступ к вашим данным на Яндексе" ответить "Разрешить": после этого на экране появится сформированный токен

## mapdrive - Подключить сетевой диск

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет) |
| **--drive** | - Имя устройства (буква диска) |
| **--res** | - Путь к подключаемому ресурсу |
| **--user** | - Пользователь для подключения |
| **--pwd** | - Пароль для подключения |

#### Пример:

```bat
cpdb file mapdrive --drive N --res "\\MyServer\MyFolder" --user superuser --pwd P@$$w0rd
```

## umapdrive - Отключить сетевой диск

| Параметры: ||
|-|-|
| **--params** | - Файлы JSON содержащие значения параметров, могут быть указаны несколько файлов разделенные ";" (параметры командной строки имеют более высокий приоритет) |
| **--drive** | - Имя устройства (буква диска) |

#### Пример:

```bat
cpdb file umapdrive --drive N
```

## batch - Выполнить сценарий

Последовательно выполняет команды указнные в файле JSON

| Параметры: ||
|-|-|
| **\<Сценарии\>** | - Файлы JSON содержащие команды и значения параметров, могут быть указаны несколько файлов разделенные "";"" (обработка файлов выполняется в порядке следования) |

#### Пример:

```bat
cpdb batch "./rest_TST_DB_MyDomain.json"
```

#### Пример сценария:

```json
{
    "params": {},
    "stages": {
        "Восстановление": {
            "description": "Восстановление из резервной копии",
            "tool": "cpdb",
            "command": "database restore",
            "params": {
                "sql-srvr": "MySQLServer",
                "sql-user": "_1CSrvUsr1",
                "sql-pwd": "p@ssw0rd",
                "bak-path": "d:\\tmp\\PRD_DB_MyDomain.bak",
                "sql-db": "TST_DB_MyDomain",
                "db-owner": "_1CSrvUsr1",
                "db-path": "D:\\sqldata",
                "db-logpath": "D:\\sqldata",
                "db-recovery": "SIMPLE",
                "db-changelfn": true
            }
        },
        "Отключение": {
            "description": "Отключение от хранилища",
            "tool": "cpdb",
            "command": "infobase uconstorage",
            "params": {
                "ib-path": "/SSport1\\TST_DB_MyDomain",
                "ib-user": "\"1C User\"",
                "ib-pwd": "p@ssw0rd"
            }
        },
        "Сжатие": {
            "description": "Сжатие базы данных",
            "tool": "cpdb",
            "command": "database compress",
            "params": {
                "sql-srvr": "Sport1",
                "sql-user": "_1CSrvUsr1",
                "sql-pwd": "p@ssw0rd",
                "sql-db": "TST_DB_MyDomain",
                "shrink-db": true
            }
        }
    }
}
```

## Использование c Jenkins

В jenkinsfile описан конвейер, выполняющий следующий сценарий:
* Создание резервной копии указанной базы на системе-источнике
* Разбиение резервной копии на части (используется 7-Zip)
* Копирование частей файла на Yandex-Диск (в указанный каталог)
* Получение файла резервной копии из Yandex-Диск на системе-приемнике
* Восстановление указанной базы из резервной копии
* Подключает базу к хранилищу конфигурации

| Переменные окружения конвейера ||
|-|-|
| **src_db_cred** | - Идентификатор credentials для доступа к MS SQL в системе, где расположена база-источник |
| **src_agent_label** | - Метка агента Jenkins в системе, где расположена база-источник |
| **src_server_name** | - Имя сервера MS SQL в системе-источнике |
| **src_db_name** | - Имя базы-источника |
| **src_bak_path** | - Путь к каталогу резервной копии в системе-источнике |
|||
| **bak_file_name** | - Имя файла резервной копии |
| **list_file_name** | - Имя файла списка томов архива |
|||
| **storage_token** | - Token для доступа к Yandex-Диску |
| **storage_path** | - Путь к каталогу на Yandex-Диск для передачи файлов в систему-приемник |
|||
| **dst_db_cred** | - Идентификатор credentials для доступа к MS SQL в системе-приемнике |
| **dst_agent_label** | - Метка агента Jenkins в системе, где расположена база-приемник |
| **dst_bak_path** | - Путь к каталогу резервной копии в системе-приемнике, в который будут загружены файлы из Yandex-Диска |
| **dst_server_name** | - Имя сервера MS SQL в системе-приемнике |
| **dst_db_name** | - Имя базы-приемника |
| **dst_dbo** | - Имя пользователя-владельца базы в системе-приемнике (dbowner) |
| **dst_db_path** | - Путь к каталогу размещения файлов данных базы-приемника
| **dst_log_path** | - Путь к каталогу размещения файлов журнала базы-приемника |
| **dst_ib_agent_label** | - Метка агента Jenkins в системе, где выполняется подключение к хранилищу конфигурации |
| **dst_ib_con_string** | - Строка подключения к информационной базе, подключаемой к хранилищу |
| **dst_ib_cred** | - Идентификатор credentials для доступа к информационной базе |
| **dst_ib_storage_adr** | - Адрес хранилища конфигурации |
| **dst_ib_storage_cred** | - Идентификатор credentials для подключения к хранилищу конфигурации |
