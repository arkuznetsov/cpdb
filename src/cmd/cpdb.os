// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

#Использовать cli
#Использовать "."

Перем Лог;     // Объект       - объект записи лога приложения

Процедура ВыполнитьПриложение()

	Приложение = Новый КонсольноеПриложение(ПараметрыСистемы.ИмяПриложения(),
	                                        "приложение для загрузки и подготовки релизов 1С");
	Приложение.Версия("version", ПараметрыСистемы.Версия());

	Приложение.ДобавитьКоманду("batch b",
                               "выполнить пакет команд",
                               Новый КомандаВыполнитьПакет());

	Приложение.ДобавитьКоманду("database d",
                               "команды работы с СУБД",
                               Новый КомандыРаботыССУБД());

	Приложение.ДобавитьКоманду("infobase i",
                               "команды работы с информационными базами 1С",
                               Новый КомандыРаботыСИБ());

	Приложение.ДобавитьКоманду("file f",
                               "команды работы с файлами",
                               Новый КомандыРаботыСФайлами());

	Приложение.ДобавитьКоманду("yadisk y",
                               "команды обмена файлами с Yandex-диском",
                               Новый КомандыРаботыСЯндексДиск());

	Приложение.ДобавитьКоманду("nextcloud n",
                               "команды обмена файлами с сервисом NextCloud",
                               Новый КомандыРаботыСNextCloud());

	Приложение.ДобавитьКоманду("sftp s",
                               "команды обмена файлами с SFTP-сервером",
                               Новый КомандыРаботыСSFTP());

	Приложение.Опция("v verbose", Ложь, "вывод отладочной информации в процессе выполнения")
	          .Флаговый()
	          .ВОкружении("CPDB_VERBOSE");

	Приложение.Запустить(АргументыКоманднойСтроки);
	
КонецПроцедуры // ВыполнитьПриложение()

// Функция - проверяет, что приложение запущено в режиме тестирования
//
// Возвращаемое значение:
//   Булево  - Истина - приложение запущено в режиме тестирования
//
Функция ЭтоТест()
	
	Попытка
		Возврат ЭтотОбъект.ЭтоТест;
	Исключение
		Возврат Ложь;
	КонецПопытки;

КонецФункции // ЭтоТест()

///////////////////////////////////////////////////////

Лог = ПараметрыСистемы.Лог();

Попытка

	ВыполнитьПриложение();

Исключение

	Лог.КритичнаяОшибка(ОписаниеОшибки());
	ВременныеФайлы.Удалить();

	Если ЭтоТест() Тогда
		ВызватьИсключение ОписаниеОшибки();
	Иначе
		ЗавершитьРаботу(1);
	КонецЕсли;

КонецПопытки;
