# SQL Database copier (cpdb)

Копирование баз данных MS SQL и развертывание на целевой системе.


## Возможные команды

* help       - Вывод справки по параметрам
* backup     - Создание резервной копии базы MS SQL
* restore    - Восстановление базы MS SQL из резервной копии
* putyadisk  - Помещение файла на Yandex-Диск
* getyadisk  - Получение файла из Yandex-Диска

Для подсказки по конкретной команде наберите help <команда>

## backup - Создание резервной копии базы MS SQL

### Параметры:
* <Сервер> - Адрес сервера MS SQL
* <База> - Имя базы для резервного копирования
* -user - Пользователь сервера
* -pwd - Пароль пользователя сервера
* -path - Путь к резервной копии

#### Пример:
```
cpdb backup MySQLName MyDatabase -user sa -pwd 12345 -path "d:\MSSQL\Backup\MyDatabase_copy.bak"
```

## restore - Восстановление базы MS SQL из резервной копии

### Параметры:

* <Сервер> - Адрес сервера MS SQL
* <База> - Имя базы для восстановления
* -user - Пользователь сервера
* -pwd - Пароль пользователя сервера
* -path - Путь к резервной копии
* -create-db - Создать базу в случае отсутствия
* -db-owner - Имя владельца базы после восстановления
* -shrink-db - Сжать базу после восстановления
* -db-bakname - Имя базы в файле резервной копии
* -db-path - Путь к каталогу файлов данных базы после восстановления
* -db-logpath - Путь к каталогу файлов журнала после восстановления
* -delsource - Удалить файл резервной копии после восстановления

```
cpdb restore MyNewSQLServer MyDatabase_copy -user SQLUser -pwd 123456 -path "d:\data\MyBackUpfile.bak" -create-db -shrink-db -db-owner SQLdbo -db-bakname MyDatabase -db-path "d:\MSSQL\data" -db-logpath "e:\MSSQL\logs" -delsource
```

## putyadisk - Помещение файла на Yandex-Диск

### Параметры:

* <ПутьКФайлу> - Путь к локальному файлу для помещения на Yandex-Диск
* -ya-token    - Token авторизации
* -ya-path     - Путь к файлу на Yandex-Диск
* -delsource   - Удалить исходный файл после отправки

#### Пример:
```
cpdb putyadisk "d:\MSSQL\Backup\MyDatabase_copy.bak" -ya-token XXXXXXXXXXXXXXXXXXXXXXXXXXXXX -ya-path "/transfer/MyDatabase_copy.bak" -delsource
```


## getyadisk  - Получение файла из Yandex-Диска

### Параметры:

* <ПутьКФайлу> - Путь к локальному файлу для сохранения
* -ya-token    - Token авторизации
* -ya-path     - Путь к файлу на Yandex-Диск
* -delsource   - Удалить файл из Yandex-Диск после получения

#### Пример:
```
cpdb getyadisk "d:\MSSQL\Backup\MyDatabase_copy.bak" -ya-token XXXXXXXXXXXXXXXXXXXXXXXXXXXXX -ya-path "/transfer/MyDatabase_copy.bak" -delsource
```


## Использование c Jenkins
В jenkinsfile описан конвейр выполняющий следующий сценарий:
* Создание резервной копии указанной базы на системе-источнике
* Копирование файла резервной копии на Yandex-Диск
* Получение файла резервной копии из Yandex-Диск на системе-приемнике
* Восстановление указанной базы из резервной копии

### Переменные окружения конвейера

* src_db_cred     - Идентификатор credentials для доступа к MS SQL в системе, где расположена база-источник
* src_agent_label - Метка агента Jenkins в системе, где расположена база-источник
* src_server_name - Имя сервера MS SQL в системе-источнике
* src_db_name     - Имя базы-источника
* src_bak_path    - Путь к файлу резервной копии в системе-источнике
* storage_token   - Token для доступа к Yandex-Диску
* storage_path    - Путь к файлу на Yandex-Диск для передачи в систему-приемник
* dst_db_cred     - Идентификатор credentials для доступа к MS SQL в системе-приемнике
* dst_agent_label - Метка агента Jenkins в системе, где расположена база-приемник
* dst_bak_path    - Путь к файлу резервной копии в системе-приемнике, в который будет загружен файл из Yandex-Диска
* dst_server_name - Имя сервера MS SQL в системе-приемнике
* dst_db_name     - Имя базы-приемника
* dst_dbo         - Имя пользователя-владельца базы в системе-приемнике (dbowner)
* dst_db_path     - Путь к каталогу размещения файлов данных базы-приемника
* dst_log_path    - Путь к каталогу размещения файлов журнала базы-приемника
