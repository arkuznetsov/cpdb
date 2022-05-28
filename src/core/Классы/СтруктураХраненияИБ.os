// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

#Использовать deflator

Перем ПодключениеКСУБД;          // - ПодключениеКСУБД    - объект подключения к СУБД
Перем ТекущийСервер;             // - Строка              - адрес сервера СУБД
Перем База;                      // - Строка              - адрес сервера СУБД
Перем НазначенияОбъектовБазы;    // - Структура           - соответствие назначений объектов префиксам имен объектов БД

Перем Лог;                       // - Объект              - объект записи лога приложения

#Область ПрограммныйИнтерфейс

// Функция - возвращает версию формата конфигурации
//
// Возвращаемое значение:
//   Структура            - описание версии формата конфигурации
//     *Версия                      - Число     - номер версии формата конфигурации
//     *ТребуемаяВерсияПлатформы    - Строка    - минимальная версия платформы 1С
//
Функция ВерсияФорматаКонфигурации() Экспорт

	Лог.Отладка("Начало получения версии формата конфигурации 1С базы ""%1\%2""",
	            ТекущийСервер,
	            База);

	Попытка
		Результат = ПодключениеКСУБД.ВерсияФорматаКонфигурации1С(База);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения версия формата конфигурации 1С базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Лог.Отладка("Получена версии формата конфигурации 1С базы ""%1\%2"": %3",
	            ТекущийСервер,
	            База,
	            Результат.Версия);

	Возврат Результат;

КонецФункции // ВерсияФорматаКонфигурации()

// Функция - возвращает описание метаданных 1С для объекта СУБД по его имени
//
// Параметры:
//   ИмяОбъекта          - Строка    - Имя таблицы или поля таблицы СУБД
//
// Возвращаемое значение:
//    Структура    - описание метаданных 1С по имени объекта СУБД
//
Функция ОписаниеМетаданныхОбъектаБД1С(Знач ИмяОбъекта) Экспорт

	УбратьЛидирующееПодчеркивание(ИмяОбъекта);

	ОписаниеОбъектаБазы = ОписаниеОбъектаБазыПоИмени(ИмяОбъекта);

	ДобавлятьКолонки = Ложь;

	Если НазначениеОбъектаБазы(ОписаниеОбъектаБазы).Назначение = "Поле" Тогда
		КолонкиБазы = КолонкиБазы(, СтрШаблон("%%%1%%", ИмяОбъекта));
		Если КолонкиБазы.Количество() > 0 Тогда
			ОписаниеОбъектаБазы = КолонкиБазы[ИмяОбъекта];
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		ДобавлятьКолонки = Истина;
	КонецЕсли;

	ИменаТаблицОбъектовКонфигурации1С = ИменаТаблицОбъектовКонфигурации1С(ДобавлятьКолонки);

	ОписаниеВладельца = ОписаниеОбъектаБазы;
	Пока ЗначениеЗаполнено(ОписаниеВладельца.Владелец) Цикл
		ОписаниеВладельца.Вставить("Ид", ИменаТаблицОбъектовКонфигурации1С[ОписаниеВладельца.Имя].Ид);
		ОписаниеВладельца = ОписаниеВладельца.Владелец;
	КонецЦикла;
	ОписаниеВладельца.Вставить("Ид", ИменаТаблицОбъектовКонфигурации1С[ОписаниеВладельца.Имя].Ид);

	СоответствиеИменМетаданных = СоответствиеИменМетаданных(ОписаниеВладельца.Ид);

	ОписаниеВладельца.Вставить("ИмяМетаданных", СоответствиеИменМетаданных[ОписаниеВладельца.Ид].ИмяМетаданных);

	ТекОписание = ОписаниеОбъектаБазы;
	Пока ЗначениеЗаполнено(ТекОписание.Владелец) Цикл
		ИмяМетаданных = ИмяМетаданных(СоответствиеИменМетаданных[ОписаниеВладельца.Ид].Данные, ТекОписание);
		ТекОписание.Вставить("ИмяМетаданных", ИмяМетаданных);
		ТекОписание = ТекОписание.Владелец;
	КонецЦикла;

	ЗаполнитьПолныеИменаМетаданныхВОписанииОбъектаБазы(ОписаниеОбъектаБазы);

	Возврат ОписаниеОбъектаБазы;

КонецФункции // ОписаниеМетаданныхОбъектаБД1С()

// Функция - возвращает описание метаданных 1С для таблиц СУБД
//
// Параметры:
//   ДобавлятьКолонки    - Строка    - Истина - будет добавлена информация для колонок таблиц
//
// Возвращаемое значение:
//    Соответствие    - соответствия имен таблиц СУБД и описаний метаданных
//
Функция ОписаниеМетаданныхОбъектовБД1С(ДобавлятьКолонки = Ложь) Экспорт

	ОписанияМетаданных = Новый Соответствие();

	ИменаТаблицОбъектовКонфигурации1С = ИменаТаблицОбъектовКонфигурации1С(ДобавлятьКолонки);

	ТабличныеЧасти = ТабличныеЧастиИВладельцы();

	СоответствиеИменМетаданных = СоответствиеИменМетаданных();

	КолонкиБазы = Новый Соответствие();
	Если ДобавлятьКолонки Тогда
		КолонкиБазы = КолонкиБазы();
	КонецЕсли;

	Для Каждого ТекЭлемент Из ИменаТаблицОбъектовКонфигурации1С Цикл

		Имя = СтрШаблон("%1%2", ТекЭлемент.Значение.Префикс, Формат(ТекЭлемент.Значение.Индекс, "ЧРГ=; ЧГ="));

		Если НЕ ОписанияМетаданных[Имя] = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Если НазначениеОбъектаБазы(ТекЭлемент.Значение).Назначение = "Поле" Тогда
			ОписаниеОбъектаБазы = КолонкиБазы[Имя];
			Если ОписаниеОбъектаБазы = Неопределено Тогда
				Продолжить;
			КонецЕсли;
		ИначеЕсли ТабличныеЧасти[Имя] = Неопределено Тогда
			ОписаниеОбъектаБазы = ОписаниеОбъектаБазыПоИмени(Имя);
		Иначе
			ОписаниеОбъектаБазы = ТабличныеЧасти[Имя];
		КонецЕсли;

		ОписаниеОбъектаБазы.Ид = ТекЭлемент.Значение.Ид;

		ОписаниеВладельца = ОписаниеОбъектаБазы;
		Пока ЗначениеЗаполнено(ОписаниеВладельца.Владелец) Цикл
			ОписаниеВладельца.Ид = ИменаТаблицОбъектовКонфигурации1С[ОписаниеВладельца.Имя].Ид;
			ОписанияМетаданных.Вставить(ОписаниеВладельца.Имя, ОписаниеВладельца);
			Если НазначениеОбъектаБазы(ОписаниеВладельца).Подчиненный Тогда
				ОписанияМетаданных.Вставить(СтрШаблон("%1_%2", ОписаниеВладельца.Владелец.Имя, ОписаниеВладельца.Имя),
				                            ОписаниеВладельца);
			КонецЕсли;
			ОписаниеВладельца = ОписаниеВладельца.Владелец;
		КонецЦикла;
		
		Если ИменаТаблицОбъектовКонфигурации1С[ОписаниеВладельца.Имя] = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ОписаниеВладельца.Ид = ИменаТаблицОбъектовКонфигурации1С[ОписаниеВладельца.Имя].Ид;
		
		Если НЕ СоответствиеИменМетаданных[ОписаниеВладельца.Ид] = Неопределено Тогда
			ОписаниеВладельца.ИмяМетаданных = СоответствиеИменМетаданных[ОписаниеВладельца.Ид].ИмяМетаданных;
		КонецЕсли;
		ОписанияМетаданных.Вставить(ОписаниеВладельца.Имя, ОписаниеВладельца);

		ТекОписание = ОписаниеОбъектаБазы;
		Пока ЗначениеЗаполнено(ТекОписание.Владелец) Цикл
			ТекОписание.ИмяМетаданных =
				ИмяМетаданных(СоответствиеИменМетаданных[ОписаниеВладельца.Ид].Данные, ТекОписание);
			ТекОписание = ТекОписание.Владелец;
		КонецЦикла;

		ЗаполнитьПолныеИменаМетаданныхВОписанииОбъектаБазы(ОписаниеОбъектаБазы);
	КонецЦикла;

	Возврат ОписанияМетаданных;

КонецФункции // ОписаниеМетаданныхОбъектовБД1С()

// Функция - возвращает описание занимаеиого места в базе MS SQL Server
//
// Возвращаемое значение:
//  Структура                            - описание занимаего места
//     * РазмерБазы        - Число          - размер текущей базы данных в байтах, включает файлы данных и журналов
//     * Свободно          - Число          - место в базе данных, не зарезервированное для объектов базы данных
//     * Зарезервировано   - Число          - общий объем, выделенный объектам в базе данных
//     * Данные            - Число          - общий объем, используемый данными
//     * Индексы           - Число          - общий объем, используемый индексами
//     * НеИспользуется    - Число          - общий объем, зарезервированный для объектов в базе данных,
//                                            но пока не используемый
//
Функция ЗанимаемоеМесто() Экспорт

	Результат = Новый Структура();
	Результат.Вставить("РазмерБазы");
	Результат.Вставить("Свободно");
	Результат.Вставить("Зарезервировано");
	Результат.Вставить("Данные");
	Результат.Вставить("Индексы");
	Результат.Вставить("НеИспользуется");

	Лог.Отладка("Начало получения информации о занимаемом месте для базы ""%1\%2""",
	            ТекущийСервер,
	            База);

	Попытка
		Результат = ПодключениеКСУБД.ЗанимаемоеБазойМесто(База);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения информации о занимаемом месте для базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Лог.Отладка("Получена информация о занимаемом месте для базы ""%1\%2""", ТекущийСервер, База);

	СимволовРазмерности = 2;

	Для Каждого ТекЭлемент Из Результат Цикл

		Размерность = ВРег(Прав(ТекЭлемент.Значение, СимволовРазмерности));
		РазмерСтрокой = СокрЛП(Лев(ТекЭлемент.Значение, СтрДлина(ТекЭлемент.Значение) - СтрДлина(Размерность)));

		Если ЭтоЧисло(РазмерСтрокой) Тогда
			Результат[ТекЭлемент.Ключ] = Число(РазмерСтрокой);
			Множитель = 1024;
			Если ВРег(Размерность) = "KB" Тогда
				Результат[ТекЭлемент.Ключ] = Результат[ТекЭлемент.Ключ] * Множитель;
			ИначеЕсли ВРег(Размерность) = "MB" Тогда
				Результат[ТекЭлемент.Ключ] = Результат[ТекЭлемент.Ключ] * Множитель * Множитель;
			КонецЕсли;
		Иначе
			Результат[ТекЭлемент.Ключ] = Неопределено;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;

КонецФункции // ЗанимаемоеМесто()

// Функция - возвращает список таблиц в базе MS SQL Server и их показатели использования
//
// Параметры:
//   ФильтрТаблицПоИмени    - Строка    - фильтр имен таблиц в формате для оператора "LIKE"
//
// Возвращаемое значение:
//  Массив из Структура                   - таблицы и показатели использования
//     *Таблица                 - Строка    - имя таблицы
//     *КоличествоСтрок         - Число     - количество строк в таблице
//     *ВсегоЗанято             - Число     - общий объем заниаемого места (байт)
//     *Используется            - Число     - объем, используемый данными (байт)
//     *НеИспользуется          - Число     - не используемый объем (байт)
//     *ОперацийЧтения          - Число     - количество операций чтения (read)
//     *ОперацийВыборки         - Число     - количество операций выборки (select)
//     *ОперацийСканирования    - Число     - количество операций сканирования (scan)
//     *ОперацийПоиска          - Число     - количество операций поиска (seek)
//     *ОперацийЗаписи          - Число     - количество операций записи (write)
//
Функция ПоказателиИспользованияТаблицБазы(ФильтрТаблицПоИмени = "") Экспорт

	Лог.Отладка("Начало получения информации о показателях использования таблиц для базы ""%1\%2""",
	            ТекущийСервер,
	            База);

	Попытка
		ПоказателиТаблиц = ПодключениеКСУБД.ПоказателиИспользованияТаблицБазы(База, ФильтрТаблицПоИмени);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения информации о показателях использования таблиц
		                        | для базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Лог.Отладка("Получена информация о показателях использования таблиц для базы ""%1\%2""", ТекущийСервер, База);

	Для Каждого ТекТаблица Из ПоказателиТаблиц Цикл

		Для Каждого ТекПоказатель Из ТекТаблица Цикл

			Если ВРег(ТекПоказатель.Ключ) = "ТАБЛИЦА" Тогда
				Продолжить;
			КонецЕсли;

			Если ЭтоЧисло(ТекПоказатель.Значение) Тогда
				ТекТаблица[ТекПоказатель.Ключ] = Число(ТекПоказатель.Значение);
			Иначе
				ТекТаблица[ТекПоказатель.Ключ] = Неопределено;
			КонецЕсли;
		КонецЦикла;

	КонецЦикла;

	Возврат ПоказателиТаблиц;

КонецФункции // ПоказателиИспользованияТаблицБазы()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Функция - читает соответствия UUID объектов метаданных конфигурации 1С именам объектов базы
// из таблицы Params из записи где "[FileName] = 'DBNames'"
//
// Параметры:
//   ДобавлятьКолонки    - Строка    - Истина - будет добавлена информация для колонок таблиц
//
// Возвращаемое значение:
//    Соответствие    - соответствия UUID объектов метаданных конфигурации 1С именам объектов СУБД
//
Функция ИменаТаблицОбъектовКонфигурации1С(ДобавлятьКолонки = Ложь)

	Лог.Отладка("Начало получения соответствия UUID объектов метаданных конфигурации 1С
	            | именам объектов базы ""%1\%2""",
	            ТекущийСервер,
	            База);

	Попытка
		Данные = ПодключениеКСУБД.ИменаТаблицОбъектовКонфигурации1С(База);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения соответствия UUID объектов метаданных конфигурации 1С
		                        | именам объектов базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Данные = ПрочитатьУпакованныеДанные(Данные);

	Чтение = Новый ЧтениеТекста(Данные.ОткрытьПотокДляЧтения(), КодировкаТекста.UTF8, Символы.ПС, Символы.ПС + Символы.ВК);

	ИменаТаблицОбъектовКонфигурации1С = Новый Соответствие();

	КоличествоПолей = 3;

	ТекСтрока = Чтение.ПрочитатьСтроку();

	Пока НЕ ТекСтрока = Неопределено Цикл

		ТекСтрока = СтрЗаменить(ТекСтрока, "{", "");
		ТекСтрока = СтрЗаменить(ТекСтрока, "}", "");

		ЧастиСтроки = СтрРазделить(ТекСтрока, ",", Ложь);

		Если ЧастиСтроки.Количество() < КоличествоПолей Тогда
			ТекСтрока = Чтение.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;

		ИндексСтрокой = ЧастиСтроки[2];

		СтрокаСоответствия = Новый Структура();
		СтрокаСоответствия.Вставить("Ид"     , ПривестиСтроку(ЧастиСтроки[0]));
		СтрокаСоответствия.Вставить("Префикс", ПривестиСтроку(ЧастиСтроки[1]));
		СтрокаСоответствия.Вставить("Индекс" , ПривестиСтроку(ИндексСтрокой));
		СтрокаСоответствия.Вставить("Суффикс", "");

		Если НЕ ДобавлятьКолонки И НазначениеОбъектаБазы(СтрокаСоответствия).Назначение = "Поле" Тогда
			ТекСтрока = Чтение.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;

		ИмяОбъекта = СтрШаблон("%1%2", СтрокаСоответствия.Префикс, ИндексСтрокой);
		ИменаТаблицОбъектовКонфигурации1С.Вставить(ИмяОбъекта, СтрокаСоответствия);

		ТекСтрока = Чтение.ПрочитатьСтроку();
	КонецЦикла;

	Возврат ИменаТаблицОбъектовКонфигурации1С;

КонецФункции // ИменаТаблицОбъектовКонфигурации1С()

// Функция - читает таблицу Config базы 1С и возвращает соответствия UUID метаданных и имен метаданных
//
// Параметры:
//   Ид              - Число      - идентификатор объекта метаданных,
//                                  если не указан, считываются все записи
//   ПорцияЧтения    - Число      - количество строк таблицы Config читаемое за 1 запрос
//
// Возвращаемое значение:
//   Соответствие    - соответствия UUID метаданных и имен метаданных
//
Функция СоответствиеИменМетаданных(Ид = "", ПорцияЧтения = 1000)

	Лог.Отладка("Получение соответствия имен метаданных базы ""%1\%2"": %3",
	            ТекущийСервер,
	            База);

	СоответствиеИменМетаданных = Новый Соответствие();

	ВсегоЗаписей = ПодключениеКСУБД.КоличествоОбъектовКонфигурацииБазы1С(База, Ид);
	Прочитано = 0;
	
	Пока Прочитано < ВсегоЗаписей Цикл
	
		Попытка
			ОбъектыКонфигурации = ПодключениеКСУБД.ОбъектыКонфигурацииБазы1С(База, Ид, Прочитано, ПорцияЧтения);
		Исключение
			ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ТекстОшибки = СтрШаблон("Ошибка получения соответствия имен метаданных базы ""%1\%2"":%3%4",
			                        ТекущийСервер,
			                        База,
			                        Символы.ПС,
			                        ТекстОшибки);
			ВызватьИсключение ТекстОшибки;
		КонецПопытки;
	
		Для Каждого ТекЭлемент Из ОбъектыКонфигурации Цикл
			Данные = ПрочитатьУпакованныеДанные(ТекЭлемент.Значение.Данные, Истина);
			ТекЭлемент.Значение.Вставить("Данные", Данные);
			ТекЭлемент.Значение.Вставить("ИмяМетаданных", ИмяМетаданных(Данные, ТекЭлемент.Значение.Ид));
			СоответствиеИменМетаданных.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
		КонецЦикла;

		Прочитано = Прочитано + ПорцияЧтения;
	
	КонецЦикла;
	
	Возврат СоответствиеИменМетаданных;

КонецФункции // СоответствиеИменМетаданных()

// Функция - возвращает соответствие имен объектов базы данных Типм и именам объектов 1С
//
// Возвращаемое значение:
//   Соответствие    - назначения объектов базы
//
Функция НазначенияОбъектовБазы()

	ИмяМакета = "НазначенияОбъектовБД1С.json";
	ПутьКМакету = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "Макеты", ИмяМакета);
	ФайлМакета = Новый Файл(ПутьКМакету);

	Чтение = Новый ЧтениеJSON();
	Чтение.ОткрытьФайл(ФайлМакета.ПолноеИмя, КодировкаТекста.UTF8);
	
	Результат = ПрочитатьJSON(Чтение, Ложь);

	Для Каждого ТекЭлемент Из Результат Цикл
		Если НЕ ТекЭлемент.Значение.Свойство("Подчиненный") Тогда
			ТекЭлемент.Значение.Вставить("Подчиненный", Ложь);
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;

КонецФункции // НазначенияОбъектовБазы()

// Функция - возвращает описание назначения объекта базы
//
// Параметры:
//   ОписаниеОбъектаБазы    - Структура    - описание объекта базы
//
// Возвращаемое значение:
//   Структура    - назначения объектов базы
//
Функция НазначениеОбъектаБазы(ОписаниеОбъектаБазы)

	Если НЕ ТипЗнч(НазначенияОбъектовБазы) = Тип("Структура") Тогда
		НазначенияОбъектовБазы = НазначенияОбъектовБазы();
	КонецЕсли;

	ОписаниеНазначения = Новый Структура();

	Для Каждого ТекЭлемент Из НазначенияОбъектовБазы.Config Цикл
		ОписаниеНазначения.Вставить(ТекЭлемент.Ключ, "");
	КонецЦикла;

	Если НазначенияОбъектовБазы.Свойство(ОписаниеОбъектаБазы.Префикс) Тогда
		ЗаполнитьЗначенияСвойств(ОписаниеНазначения, НазначенияОбъектовБазы[ОписаниеОбъектаБазы.Префикс]);
	КонецЕсли;

	Если ОписаниеОбъектаБазы.Свойство("Владелец")
	   И ЗначениеЗаполнено(ОписаниеОбъектаБазы.Владелец)
	   И ОписаниеОбъектаБазы.Владелец.Тип = "ТабличнаяЧасть"
	   И ОписаниеОбъектаБазы.Суффикс = "_IDRRef" Тогда
		ОписаниеНазначения.Тип = "Ссылка";
		ОписаниеНазначения.ТипАнгл = "Ref";
		ОписаниеНазначения.Назначение = "Поле";
	КонецЕсли;

	Возврат ОписаниеНазначения;

КонецФункции // НазначениеОбъектаБазы()

// Функция - возвращает список таблиц базы, соответствующих фильтру
//
// Параметры:
//  ФильтрТаблицПоИмени     - Строка    - фильтр имен таблиц в формате для оператора "LIKE"
//
// Возвращаемое значение:
//  Соответствие    - список таблиц базы
//
Функция ТаблицыБазы(ФильтрТаблицПоИмени = "")

	Лог.Отладка("Получение списка таблиц базы ""%1\%2"": %3", ТекущийСервер, База);

	Попытка
		Таблицы = ПодключениеКСУБД.ТаблицыБазы(База, ФильтрТаблицПоИмени);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения списка таблиц базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Лог.Отладка("Получен список таблиц базы ""%1\%2""", ТекущийСервер, База);

	Результат = Новый Соответствие();

	Для Каждого ТекТаблица Из Таблицы Цикл
		УбратьЛидирующееПодчеркивание(ТекТаблица);
		Результат.Вставить(ТекТаблица, ТекТаблица);
	КонецЦикла;

	Возврат Результат;

КонецФункции // ТаблицыБазы()

// Функция - список таблиц, хранящих данные табличных частей объектов 1С
// с указанием таблиц объектов-владельцев
//
// Возвращаемое значение:
//  Соответствие    - список таблиц, хранящих данные табличных частей объектов 1С
//
Функция ТабличныеЧастиИВладельцы()

	ТабличныеЧастиИВладельцы = Новый Соответствие();

	Для Каждого ТекНазначение Из НазначенияОбъектовБазы Цикл

		Если НЕ ТекНазначение.Значение.Подчиненный Тогда
			Продолжить;
		КонецЕсли;

		ТаблицыБазы = ТаблицыБазы(СтрШаблон("%%_%1%%", ТекНазначение.Значение.ПрефиксВБазе));

		Для Каждого ТекТаблица Из ТаблицыБазы Цикл
			ОписаниеОбъектаБазы = ОписаниеОбъектаБазыПоИмени(ТекТаблица.Значение);

			ИмяОбъектаБазы = СтрШаблон("%1%2", ОписаниеОбъектаБазы.Префикс, ОписаниеОбъектаБазы.Индекс);
			ТабличныеЧастиИВладельцы.Вставить(ИмяОбъектаБазы, ОписаниеОбъектаБазы);
		КонецЦикла;

	КонецЦикла;

	Возврат ТабличныеЧастиИВладельцы;

КонецФункции // ТабличныеЧастиИВладельцы()

// Функция - возвращает список колонок базы, соответствующих фильтру
//
// Параметры:
//  ФильтрТаблицПоИмени      - Строка    - фильтр имен таблиц в формате для оператора "LIKE"
//  ФильтрКолонокПоИмени     - Строка    - фильтр имен колонок в формате для оператора "LIKE"
//
// Возвращаемое значение:
//  Соответствие    - список колонок базы
//
Функция КолонкиБазы(ФильтрТаблицПоИмени = "", ФильтрКолонокПоИмени = "")

	Лог.Отладка("Получение списка колонок базы ""%1\%2"": %3", ТекущийСервер, База);

	Попытка
		Колонки = ПодключениеКСУБД.КолонкиБазы(База, ФильтрТаблицПоИмени, ФильтрКолонокПоИмени);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения списка колонок базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Лог.Отладка("Получен список колонок базы ""%1\%2""", ТекущийСервер, База);

	КэшВладельцев = Новый Соответствие();

	Результат = Новый Соответствие();

	Для Каждого ТекКолонка Из Колонки Цикл

		Если КэшВладельцев[ТекКолонка.Таблица] = Неопределено Тогда
			ОписаниеОбъектаВладельца = ОписаниеОбъектаБазыПоИмени(ТекКолонка.Таблица);
			КэшВладельцев.Вставить(ТекКолонка.Таблица, ОписаниеОбъектаВладельца);
		КонецЕсли;

		ОписаниеОбъектаКолонки = ОписаниеОбъектаБазыПоИмени(ТекКолонка.Колонка);
		ОписаниеОбъектаКолонки.Владелец = КэшВладельцев[ТекКолонка.Таблица];

		// Проверка, что поле является ссылкой из табличной части
		Если ЗначениеЗаполнено(ОписаниеОбъектаКолонки.Владелец.Владелец)
		   И ОписаниеОбъектаКолонки.Имя = ОписаниеОбъектаКолонки.Владелец.Владелец.Имя Тогда
			ОписаниеОбъектаКолонки.Тип = "Ссылка";
			ОписаниеОбъектаКолонки.ТипАнгл = "Ref";
			ОписаниеОбъектаКолонки.Назначение = "Поле";
		КонецЕсли;

		Результат.Вставить(ОписаниеОбъектаКолонки.Имя, ОписаниеОбъектаКолонки);

	КонецЦикла;

	Возврат Результат;

КонецФункции // КолонкиБазы()

// Функция - возвращает структуру описания объекта базы данных 1С
//
// Возвращаемое значение:
//  Структура       - структура описания объекта базы
//    *Владелец         - Структура    - структура описания объекта владельца
//    *Тип              - Строка       - тип объекта или коллекция
//                                       (например: Справочник, Документ, ТабличнаяЧасть, Поле)
//    *ТипАнгл          - Строка       - тип объекта или коллекция на английском
//                                       (например: Reference, Document, TabularSection, Field)
//    *Назначение       - Строка       - назначение таблицы БД (например: Основная, Итоги, Обороты)
//    *Имя              - Строка       - имя объекта в БД (Префикс + Индекс)
//    *Префикс          - Строка       - префикс объекта (например: Reference, Document, VT, Fld))
//    *Индекс           - Число        - числовой индекс объекта
//    *Суффикс          - Строка       - дополнительный суффикс имени объекта (например: "_RRef")
//    *Ид               - Строка       - UUID объекта 1С
//    *ИмяМетаданных    - Строка       - имя метаданных 1С
//
Функция СтруктураОписанияОбъектаБазы()

	СтруктураОписания = Новый Структура();
	СтруктураОписания.Вставить("Владелец");
	СтруктураОписания.Вставить("Тип"          , "");
	СтруктураОписания.Вставить("ТипАнгл"      , "");
	СтруктураОписания.Вставить("Назначение"   , "");
	СтруктураОписания.Вставить("Имя"          , "");
	СтруктураОписания.Вставить("Префикс"      , "");
	СтруктураОписания.Вставить("Индекс");
	СтруктураОписания.Вставить("Суффикс"      , "");
	СтруктураОписания.Вставить("Ид"           , "");
	СтруктураОписания.Вставить("ИмяМетаданных", "");

	Возврат СтруктураОписания;

КонецФункции // СтруктураОписанияОбъектаБазы()

// Функция - раскладывает имя объекта базы на префикс, индекс, владельца и суффикс
//
// Параметры:
//  ИмяОбъектаБазы     - Строка    - имя объекта базы
// 
// Возвращаемое значение:
//  Структура    - имя объекта базы, префикс, индекс, владелец и суффикс (см. СтруктураОписанияОбъектаБазы())
//
Функция ОписаниеОбъектаБазыПоИмени(Знач ИмяОбъектаБазы)

	ОписаниеОбъектаБазы = СтруктураОписанияОбъектаБазы();

	УбратьЛидирующееПодчеркивание(ИмяОбъектаБазы);

	ПрефиксОбъекта = ПрочитатьОднотипныеСимволы(ИмяОбъектаБазы);
	ИмяОбъектаБазы = Сред(ИмяОбъектаБазы, СтрДлина(ПрефиксОбъекта) + 1);
	Символ = Сред(ИмяОбъектаБазы, 1, 1);

	ПозицияИмениТЧ = 0;
	ПрефиксИмениТЧ = "";
	Для Каждого ТекЭлемент Из НазначенияОбъектовБазы Цикл
		Если ТекЭлемент.Значение.Подчиненный Тогда
			ПозицияИмениТЧ = СтрНайти(ИмяОбъектаБазы, СтрШаблон("_%1", ТекЭлемент.Значение.ПрефиксВБазе));
			Если ПозицияИмениТЧ > 0 Тогда
				ПрефиксИмениТЧ = ТекЭлемент.Значение.ПрефиксВБазе;
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Если ПозицияИмениТЧ > 0 Тогда
		ОписаниеОбъектаБазы.Владелец =
			ОписаниеОбъектаБазыПоИмени(ПрефиксОбъекта + Лев(ИмяОбъектаБазы, ПозицияИмениТЧ - 1));
		ПрефиксОбъекта = ПрефиксИмениТЧ;
		ИмяОбъектаБазы = Сред(ИмяОбъектаБазы, ПозицияИмениТЧ + СтрДлина(ПрефиксИмениТЧ) + 1);
		Символ = Сред(ИмяОбъектаБазы, 1, 1);
	КонецЕсли;

	// состав и имена таблицы итогов по счету зависит от количества субконто,
	// поэтому добавляем еще 1 цифру
	Если ПрефиксОбъекта = "AccRgAT" Тогда
		ПрефиксОбъекта = ПрефиксОбъекта + Символ;
		ИмяОбъектаБазы = Сред(ИмяОбъектаБазы, 2);
		Символ = Сред(ИмяОбъектаБазы, 1, 1);
	КонецЕсли;

	ОписаниеОбъектаБазы.Префикс = ПрефиксОбъекта;

	ИндексОбъекта = ПрочитатьОднотипныеСимволы(ИмяОбъектаБазы);
	ИмяОбъектаБазы = Сред(ИмяОбъектаБазы, СтрДлина(ИндексОбъекта) + 1);
	Символ = Сред(ИмяОбъектаБазы, 1, 1);

	Если ЗначениеЗаполнено(ИндексОбъекта) Тогда
		ОписаниеОбъектаБазы.Индекс = Число(ИндексОбъекта);
	КонецЕсли;

	ОписаниеОбъектаБазы.Имя = СтрШаблон("%1%2",
	                                    ОписаниеОбъектаБазы.Префикс,
	                                    Формат(ОписаниеОбъектаБазы.Индекс, "ЧРГ=; ЧГ="));

	Если ЗначениеЗаполнено(Символ) Тогда
		ОписаниеОбъектаБазы.Суффикс = ИмяОбъектаБазы;
	КонецЕсли;

	ЗаполнитьЗначенияСвойств(ОписаниеОбъектаБазы, НазначениеОбъектаБазы(ОписаниеОбъектаБазы));

	Возврат ОписаниеОбъектаБазы;

КонецФункции // ОписаниеОбъектаБазыПоИмени()

// Функция - собирает полное имя объекта метаданных по описанию с учетом всех владельцев
// например (Справочник.Справочник1.Реквизит1, Документ.ТабличнаяЧасть2.Реквизит8)
//
// Параметры:
//   ОписаниеОбъектаБазы    - Структура    - описание объекта метаданных (см. ОписаниеОбъектаБазыПоИмени())
//
// Возвращаемое значение:
//   Строка    - полное имя объекта метаданных
//
Функция ПолноеИмяОбъектаМетаданных(Знач ОписаниеОбъектаБазы)

	Если НЕ ЗначениеЗаполнено(ОписаниеОбъектаБазы.ИмяМетаданных) Тогда
		Возврат "";
	КонецЕсли;

	ТекОписание = ОписаниеОбъектаБазы;

	ПолноеИмя = ТекОписание.ИмяМетаданных;

	Пока ЗначениеЗаполнено(ТекОписание.Владелец) Цикл
		ПолноеИмя = СтрШаблон("%1.%2", ТекОписание.Владелец.ИмяМетаданных, ПолноеИмя);
		ТекОписание = ТекОписание.Владелец;
	КонецЦикла;

	Возврат СтрШаблон("%1.%2", ТекОписание.Тип, ПолноеИмя);

КонецФункции // ПолноеИмяОбъектаМетаданных()

// Процедура - заполняет полные имена метаданных в описании объекта базы и его владельцах
//
// Параметры:
//   ОписаниеОбъектаБазы    - Структура    - описание объекта метаданных (см. ОписаниеОбъектаБазыПоИмени())
//
Процедура ЗаполнитьПолныеИменаМетаданныхВОписанииОбъектаБазы(ОписаниеОбъектаБазы)

	ТекОписание = ОписаниеОбъектаБазы;

	Пока ЗначениеЗаполнено(ТекОписание) Цикл
		ТекОписание.Вставить("ПолноеИмяМетаданных", ПолноеИмяОбъектаМетаданных(ТекОписание));
		ТекОписание = ТекОписание.Владелец;
	КонецЦикла;

КонецПроцедуры // ЗаполнитьПолныеИменаМетаданныхВОписанииОбъектаБазы()

// Функция - находит в тестовом описании объекта метаданных его имя
// для отдельных типов объектов возвращает стандартное имя
//
// Параметры:
//   ТекстОписания               - Строка                - описание объекта метаданных (скобкотекст)
//   ИдИлиОписаниеОбъектаБазы    - Структура, Строка     - UUID объекта метаданных
//
// Возвращаемое значение:
//   Строка    - имя объекта метаданных
//
Функция ИмяМетаданных(ТекстОписания, ИдИлиОписаниеОбъектаБазы)

	Если ТипЗнч(ИдИлиОписаниеОбъектаБазы) = Тип("Структура") Тогда
		Если ИдИлиОписаниеОбъектаБазы.Тип = "НомерСтроки" Тогда
			Возврат "НомерСтроки";
		ИначеЕсли ИдИлиОписаниеОбъектаБазы.Тип = "Ссылка" Тогда
			Возврат "Ссылка";
		Иначе
			Ид = ИдИлиОписаниеОбъектаБазы.Ид;
		КонецЕсли;
	Иначе
		Ид = ИдИлиОписаниеОбъектаБазы;
	КонецЕсли;

	СмещениеОтИд = 3;

	ИмяМетаданных = "";
	Позиция = СтрНайти(ТекстОписания, Ид);
	Если Позиция = 0 Тогда
		Возврат "";
	КонецЕсли;
	Позиция = Позиция + СтрДлина(Ид) + СмещениеОтИд;

	Символ = Сред(ТекстОписания, Позиция, 1);
	Пока НЕ Символ = """" Цикл
		ИмяМетаданных = ИмяМетаданных + Символ;
		Позиция = Позиция + 1;
		Символ = Сред(ТекстОписания, Позиция, 1);
	КонецЦикла;

	Возврат ИмяМетаданных;

КонецФункции // ИмяМетаданных()

// Функция - распаковыает переданные данные, упакованные по алгоритму deflate
//
// Параметры:
//   УпакованныеДанные    - Строка, ДвоичныеДАнные    - данные для распаковки
//   КакТекст             - Булево                    - Истина - результат будет возвращет в виде строки
//                                                      Ложь - результат будет возвращет в виде двоичных данных
//
// Возвращаемое значение:
//    Строка, ДвоичныеДанные    - распакованные данные
//
Функция ПрочитатьУпакованныеДанные(УпакованныеДанные, КакТекст = Ложь)

	Если ТипЗнч(УпакованныеДанные) = Тип("ДвоичныеДанные") Тогда
		Данные = УпакованныеДанные;
	ИначеЕсли ТипЗнч(УпакованныеДанные) = Тип("Строка") Тогда
		Данные = Base64Значение(УпакованныеДанные);
	Иначе
		НекорректныйТип = ТипЗнч(УпакованныеДанные);
		ВызватьИсключение СтрШаблон("Некорректный тип параметра ""УпакованныеДанные"" ""%1"",
		                            | ожидается ""ДвоичныеДанные"" или ""Строка""",
		                            НекорректныйТип);
	КонецЕсли;

	Если ДанныеУпакованы(Данные) Тогда
		Упаковщик = Новый УпаковщикDeflate();
		Данные = Упаковщик.РаспаковатьДанные(Данные);
	Иначе
		Лог.Отладка("Данные ""%1"" не упакованы", УпакованныеДанные);
	КонецЕсли;

	Если КакТекст Тогда
		Чтение = Новый ЧтениеТекста(Данные.ОткрытьПотокДляЧтения(), КодировкаТекста.UTF8);
		Данные = Чтение.Прочитать();
	КонецЕсли;

	Возврат Данные;

КонецФункции // ПрочитатьУпакованныеДанные()

// Функция - проверяет, что данные упакованы по алгоритму deflate
// если в начале данных расположен BOM (0xEF (239), 0xBB (187), 0xBF (191)) - данные не упакованы
//
// Параметры:
//  Данные     - Строка, ДвоичныеДанные    - проверяемые данные
// 
// Возвращаемое значение:
//  Булево    - Истина - данные упакованы по алгоритму deflate
//
Функция ДанныеУпакованы(Знач Данные)

	Если ТипЗнч(Данные) = Тип("ДвоичныеДанные") Тогда
		Поток = Данные.ОткрытьПотокДляЧтения();
	ИначеЕсли ТипЗнч(Данные) = Тип("Строка") Тогда
		Данные = Base64Значение(Данные);
		Поток = Данные.ОткрытьПотокДляЧтения();
	ИначеЕсли ТипЗнч(Данные) = Тип("Поток")
	      ИЛИ ТипЗнч(Данные) = Тип("ФайловыйПоток")
	      ИЛИ ТипЗнч(Данные) = Тип("ПотокВПамяти") Тогда
		Данные.СкопироватьВ(Поток);
	Иначе
		НекорректныйТип = ТипЗнч(Данные);
		ВызватьИсключение СтрШаблон("Некорректный тип ""%1"" параметра ""Данные"",
		                            | ожидается ""Base64Строка, Поток, ДвоичныеДанные""",
		                            НекорректныйТип);
	КонецЕсли;

	ДлинаБОМ = 3;
	КодСимволаБОМ1 = 239; // 0xEF
	КодСимволаБОМ2 = 187; // 0xBB
	КодСимволаБОМ3 = 191; // 0xBF

	Поток.Перейти(0, ПозицияВПотоке.Начало);

	Буфер = Новый БуферДвоичныхДанных(ДлинаБОМ);

	Поток.Прочитать(Буфер, 0, ДлинаБОМ);

	Возврат НЕ (Буфер[0] = КодСимволаБОМ1 И Буфер[1] = КодСимволаБОМ2 И Буфер[2] = КодСимволаБОМ3);

КонецФункции // ДанныеУпакованы()

// Функция - убирает из строки начальные и конечные кавычки
// если строка содержит только цифры, то преобразует в число
//
// Параметры:
//   Строка    - Строка     - исходная строка
//
// Возвращаемое значение:
//   Строка, Число    - результат приведения
//
Функция ПривестиСтроку(Знач Строка)

	Результат = СокрЛП(Строка);

	УдалитьСимволов = 2;

	Если Лев(Результат, 1) = """" И Прав(Результат, 1) = """" Тогда
		Результат = Сред(Результат, УдалитьСимволов, СтрДлина(Результат) - УдалитьСимволов);
	КонецЕсли;

	Если ПустаяСтрока(Результат) Тогда
		Возврат Результат;
	КонецЕсли;

	Если ЭтоЧисло(Результат) Тогда
		Результат = Число(Результат);
	КонецЕсли;

	Возврат Результат;

КонецФункции // ПривестиСтроку()

// Процедура - удаляет лидирующий символ "_" из имени объекта
//
// Параметры:
//  Имя      - Строка    - имя объекта
//
Процедура УбратьЛидирующееПодчеркивание(Имя)

	НачальнаяПозиция = 2;

	Если Лев(Имя, 1) = "_" Тогда
		Имя = Сред(Имя, НачальнаяПозиция);
	КонецЕсли;

КонецПроцедуры // УбратьЛидирующееПодчеркивание()

// Функция - возвращает часть строки до первого символа "тип" которого отличается от прочитанных
// т.е. читает все цифры до первого нецифрового символа либо все нецифровые символы до первой цифры
//
// Параметры:
//   ИсходнаяСтрока    - Строка     - исходная строка
//
// Возвращаемое значение:
//   Строка    - Истина - строка не пустая и содержит только цифры
//
Функция ПрочитатьОднотипныеСимволы(Знач ИсходнаяСтрока)

	Если НЕ ЗначениеЗаполнено(ИсходнаяСтрока) Тогда
		Возврат "";
	КонецЕсли;

	НачалоСледующегоСимвола = 2;

	ПрочитанныеСимволы = "";

	Символ = Сред(ИсходнаяСтрока, 1, 1);

	ЧитатьЦифры = ЭтоЧисло(Символ);

	Пока НЕ (ЭтоЧисло(Символ) ИЛИ ЧитатьЦифры)
	 ИЛИ (ЭтоЧисло(Символ) И ЧитатьЦифры) Цикл
	
		ПрочитанныеСимволы = ПрочитанныеСимволы + Символ;

		Если СтрДлина(ИсходнаяСтрока) = 1 Тогда
			ИсходнаяСтрока = "";
			Символ = "";
			Прервать;
		КонецЕсли;

		ИсходнаяСтрока = Сред(ИсходнаяСтрока, НачалоСледующегоСимвола);
		Символ = Сред(ИсходнаяСтрока, 1, 1);
	
	КонецЦикла;

	Возврат ПрочитанныеСимволы;

КонецФункции // ПрочитатьОднотипныеСимволы()

// Функция - проверяет, что строка не пустая и содержит только цифры
//
// Параметры:
//   Строка    - Строка     - исходная строка
//
// Возвращаемое значение:
//   Булево    - Истина - строка не пустая и содержит только цифры
//
Функция ЭтоЧисло(Строка)

	Если НЕ ЗначениеЗаполнено(Строка) Тогда
		Возврат Ложь;
	КонецЕсли;

	Цифры = "0123456789";
	КоличествоТочек = 0;

	Для й = 1 По СтрДлина(Строка) Цикл
		Если Сред(Строка, й, 1) = "." Тогда
			КоличествоТочек = КоличествоТочек + 1;
		ИначеЕсли СтрНайти(Цифры, Сред(Строка, й, 1)) = 0 Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;

	Возврат НЕ (КоличествоТочек > 1);

КонецФункции // ЭтоЧисло()

#КонецОбласти // СлужебныеПроцедурыИФункции

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// Параметры:
//    _ПодключениеКСУБД    - ПодключениеКСУБД    - объект подключения к СУБД
//    _База                - Строка              - имя базы данных
//
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта(Знач _ПодключениеКСУБД, _База)

	ПодключениеКСУБД = _ПодключениеКСУБД;
	ТекущийСервер    = ПодключениеКСУБД.Сервер();
	База             = _База;

	НазначенияОбъектовБазы = НазначенияОбъектовБазы();

	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий
