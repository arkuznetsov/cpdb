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

	Лог.Отладка("Получение версии формата конфигурации 1С базы ""%1\%2""",
	            ТекущийСервер,
	            База);

	ТекстЗапроса = СтрШаблон("""SET NOCOUNT ON;
	                         | SELECT
	                         | [IBVersion],
	                         | [PlatformVersionReq]
	                         | FROM %1.[dbo].[IBVersion];
	                         |SET NOCOUNT OFF;"" ",
	                         База);

	РезультатЗапроса = "";

	Попытка
		КодВозврата = ПодключениеКСУБД.ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса, "|", Истина);
		Если КодВозврата = 0 Тогда
			Лог.Отладка("Получена версия формата конфигурации 1С базы ""%1\%2""",
			            ТекущийСервер,
			            База);
		Иначе
			ТекстОшибки = СтрШаблон("Ошибка получения версия формата конфигурации 1С базы ""%1\%2"":%3%4",
			                        ТекущийСервер,
			                        База,
			                        Символы.ПС,
			                        РезультатЗапроса); 
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения версия формата конфигурации 1С базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Разделитель = "---";
	Поз = СтрНайти(РезультатЗапроса, Разделитель, НаправлениеПоиска.FromEnd);
	Если Поз > 0 Тогда
		РезультатЗапроса = СокрЛП(Сред(РезультатЗапроса, Поз + СтрДлина(Разделитель)));
	КонецЕсли;

	СтруктураРезультата = Новый Структура();

	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(РезультатЗапроса);
	
	МассивЗначений = СтрРазделить(Текст.ПолучитьСтроку(1), "|", Ложь);

	СтруктураРезультата.Вставить("Версия", Число(МассивЗначений[0]));
	СтруктураРезультата.Вставить("ТребуемаяВерсияПлатформы", МассивЗначений[1]);

	Возврат СтруктураРезультата;

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

	Если ВРег(ОписаниеОбъектаБазы.Префикс) = "FLD" Тогда
		КолонкиБазыДанных = КолонкиБазыДанных(, СтрШаблон("%%%1%%", ИмяОбъекта));
		Если КолонкиБазыДанных.Количество() > 0 Тогда
			ОписаниеОбъектаБазы = КолонкиБазыДанных[ИмяОбъекта];
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		ДобавлятьКолонки = Истина;
	КонецЕсли;

	СоответствиеИдМетаданныхИменамТаблиц = СоответствиеИдМетаданныхИменамТаблиц(ДобавлятьКолонки);

	ОписаниеВладельца = ОписаниеОбъектаБазы;
	Пока ЗначениеЗаполнено(ОписаниеВладельца.Владелец) Цикл
		ОписаниеВладельца.Вставить("Ид", СоответствиеИдМетаданныхИменамТаблиц[ОписаниеВладельца.Имя].Ид);
		ОписаниеВладельца = ОписаниеВладельца.Владелец;
	КонецЦикла;
	ОписаниеВладельца.Вставить("Ид", СоответствиеИдМетаданныхИменамТаблиц[ОписаниеВладельца.Имя].Ид);

	СоответствиеИменМетаданных = СоответствиеИменМетаданных(ОписаниеВладельца.Ид);

	ОписаниеВладельца.Вставить("ИмяМетаданных", СоответствиеИменМетаданных[ОписаниеВладельца.Ид].ИмяМетаданных);

	ТекОписание = ОписаниеОбъектаБазы;
	Пока ЗначениеЗаполнено(ТекОписание.Владелец) Цикл
		ИмяМетаданных = ИмяМетаданных(СоответствиеИменМетаданных[ОписаниеВладельца.Ид].Содержимое, ТекОписание.Ид);
		ТекОписание.Вставить("ИмяМетаданных", ИмяМетаданных);
		ТекОписание = ТекОписание.Владелец;
	КонецЦикла;

	Возврат ОписаниеОбъектаБазы;

КонецФункции // ОписаниеМетаданныхОбъектаБД1С()

// Функция - возвращает описание метаданных 1С для таблиц СУБД
//
// Параметры:
//   ИмяОбъекта          - Строка    - Имя таблицы СУБД
//   ДобавлятьКолонки    - Строка    - Истина - будет добавлена информация для колонок таблиц
//
// Возвращаемое значение:
//    Соответствие    - соответствия имен таблиц СУБД и описаний метаданных
//
Функция ОписаниеМетаданныхОбъектовБД1С(ДобавлятьКолонки = Ложь) Экспорт

	ОписанияМетаданных = Новый Соответствие();

	СоответствиеИдМетаданныхИменамТаблиц = СоответствиеИдМетаданныхИменамТаблиц(ДобавлятьКолонки);

	ТабличныеЧасти = ТабличныеЧастиИВладельцы();

	СоответствиеИменМетаданных = СоответствиеИменМетаданных();

	КолонкиБазыДанных = Новый Соответствие();
	Если ДобавлятьКолонки Тогда
		КолонкиБазыДанных = КолонкиБазыДанных();
	КонецЕсли;

	Для Каждого ТекЭлемент Из СоответствиеИдМетаданныхИменамТаблиц Цикл

		Имя = СтрШаблон("%1%2", ТекЭлемент.Значение.Префикс, Формат(ТекЭлемент.Значение.Индекс, "ЧРГ=; ЧГ="));

		Если НЕ ОписанияМетаданных[Имя] = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Если ВРег(ТекЭлемент.Значение.Префикс) = "FLD" Тогда
			ОписаниеОбъектаБазы = КолонкиБазыДанных[Имя];
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
			ОписаниеВладельца.Ид = СоответствиеИдМетаданныхИменамТаблиц[ОписаниеВладельца.Имя].Ид;
			ОписанияМетаданных.Вставить(ОписаниеВладельца.Имя, ОписаниеВладельца);
			Если ОписаниеВладельца.Префикс = "VT" Тогда
				ОписанияМетаданных.Вставить(СтрШаблон("%1_%2", ОписаниеВладельца.Владелец.Имя, ОписаниеВладельца.Имя),
				                            ОписаниеВладельца);
			КонецЕсли;
			ОписаниеВладельца = ОписаниеВладельца.Владелец;
		КонецЦикла;
		
		Если СоответствиеИдМетаданныхИменамТаблиц[ОписаниеВладельца.Имя] = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ОписаниеВладельца.Ид = СоответствиеИдМетаданныхИменамТаблиц[ОписаниеВладельца.Имя].Ид;
		
		Если НЕ СоответствиеИменМетаданных[ОписаниеВладельца.Ид] = Неопределено Тогда
			ОписаниеВладельца.ИмяМетаданных = СоответствиеИменМетаданных[ОписаниеВладельца.Ид].ИмяМетаданных;
		КонецЕсли;
		ОписанияМетаданных.Вставить(ОписаниеВладельца.Имя, ОписаниеВладельца);

		ТекОписание = ОписаниеОбъектаБазы;
		Пока ЗначениеЗаполнено(ТекОписание.Владелец) Цикл
			ТекОписание.ИмяМетаданных =
				ИмяМетаданных(СоответствиеИменМетаданных[ОписаниеВладельца.Ид].Содержимое, ТекОписание.Ид);
			ТекОписание = ТекОписание.Владелец;
		КонецЦикла;

	КонецЦикла;

	Возврат ОписанияМетаданных;

КонецФункции // ОписаниеМетаданныхОбъектовБД1С()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Функция - возвращает количество записей в таблице конфигурации информационной базы 1С
//
// Параметры:
//   Ид              - Число      - идентификатор объекта метаданных,
//                                  если не указан, считываются все записи
//
// Возвращаемое значение:
//   Число    - Истина - количество записей в таблице конфигурации информационной базы 1С
//
Функция КоличествоЗаписейВТаблицеКонфигурации(Ид = "")

	Лог.Отладка("Получение количества записей в таблице ""Config"" базы ""%1\%2""",
	            ТекущийСервер,
	            База);

	ОтборПоИд = "";
	Если ЗначениеЗаполнено(Ид) Тогда
		ОтборПоИд = СтрШаблон("AND [FileName] = '%1'", Ид);
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""SET NOCOUNT ON;
	                         | SELECT
	                         | COUNT([FileName])
	                         | FROM %1.[dbo].[Config]
	                         | WHERE CHARINDEX('.', [FileName]) = 0 %2
	                         | SET NOCOUNT OFF;"" ",
	                         База,
	                         ОтборПоИд);

	РезультатЗапроса = "";

	Попытка
		КодВозврата = ПодключениеКСУБД.ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса);
		Если КодВозврата = 0 Тогда
			Лог.Отладка("Получено количество записей в таблице ""Config"" базы ""%1\%2"": %3",
			            ТекущийСервер,
			            РезультатЗапроса,
			            База);
		Иначе
			ТекстОшибки = СтрШаблон("Ошибка получения количества записей в таблице ""Config"" базы ""%1\%2"":%3%4",
			                        ТекущийСервер,
			                        База,
			                        Символы.ПС,
			                        РезультатЗапроса); 
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения количества записей в таблице ""Config"" базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Возврат Число(РезультатЗапроса);

КонецФункции // КоличествоЗаписейВТаблицеКонфигурации()

// Функция - читает соответствия UUID объектов метаданных конфигурации 1С именам объектов базы
// из таблицы Params из записи где "[FileName] = 'DBNames'"
//
// Параметры:
//   ДобавлятьКолонки    - Строка    - Истина - будет добавлена информация для колонок таблиц
//
// Возвращаемое значение:
//    Соответствие    - соответствия UUID объектов метаданных конфигурации 1С именам объектов СУБД
//
Функция СоответствиеИдМетаданныхИменамТаблиц(ДобавлятьКолонки = Ложь)

	Лог.Отладка("Получение соответствия UUID объектов метаданных конфигурации 1С именам объектов базы ""%1\%2""",
	            ТекущийСервер,
	            База);

	ТекстЗапроса = СтрШаблон("""SET NOCOUNT ON;
	                         | SELECT
	                         | [BinaryData]
	                         | FROM %1.[dbo].[Params]
	                         | WHERE [FileName] = 'DBNames'
	                         | FOR XML RAW, BINARY BASE64
	                         | SET NOCOUNT OFF;"" ",
	                         База);

	РезультатЗапроса = "";

	Попытка
		КодВозврата = ПодключениеКСУБД.ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса);
		Если КодВозврата = 0 Тогда
			Лог.Отладка("Получено соответствия UUID объектов метаданных конфигурации 1С именам объектов базы ""%1\%2""",
			            ТекущийСервер,
			            База);
		Иначе
			ТекстОшибки = СтрШаблон("Ошибка получения соответствия UUID объектов метаданных конфигурации 1С
			                        | именам объектов базы ""%1\%2"":%3%4",
			                        ТекущийСервер,
			                        База,
			                        Символы.ПС,
			                        РезультатЗапроса); 
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
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

	НормализоватьXML(РезультатЗапроса);

	ЗначенияАтрибутов = Новый Соответствие();

	Парсер = Новый ЧтениеXML;
	Парсер.УстановитьСтроку(РезультатЗапроса);
 
	Пока Парсер.Прочитать() Цикл
		Если Парсер.ТипУзла = ТипУзлаXML.НачалоЭлемента И ВРег(Парсер.Имя) = "ROW" Тогда
			ЗначенияАтрибутов = ЗначенияАтрибутов(Парсер);
			Прервать;
		КонецЕсли;
	КонецЦикла;
 
	Парсер.Закрыть();

	Данные = ЗначенияАтрибутов["BINARYDATA"];

	Если НЕ ЗначениеЗаполнено(Данные) Тогда
		Данные = "";
	КонецЕсли;

	Данные = ПрочитатьУпакованныеДанные(Данные);

	Чтение = Новый ЧтениеТекста(Данные.ОткрытьПотокДляЧтения(), КодировкаТекста.UTF8, Символы.ПС, Символы.ПС + Символы.ВК);

	СоответствиеИменБД = Новый Соответствие();

	ТекСтрока = Чтение.ПрочитатьСтроку();

	Пока НЕ ТекСтрока = Неопределено Цикл

		ТекСтрока = СтрЗаменить(ТекСтрока, "{", "");
		ТекСтрока = СтрЗаменить(ТекСтрока, "}", "");

		ЧастиСтроки = СтрРазделить(ТекСтрока, ",", Ложь);

		Если ЧастиСтроки.Количество() < 3 Тогда
			ТекСтрока = Чтение.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;

		СтрокаСоответствия = Новый Структура();
		СтрокаСоответствия.Вставить("Ид"     , ПривестиСтроку(ЧастиСтроки[0]));
		СтрокаСоответствия.Вставить("Префикс", ПривестиСтроку(ЧастиСтроки[1]));
		СтрокаСоответствия.Вставить("Индекс" , ПривестиСтроку(ЧастиСтроки[2]));

		Если НЕ ДобавлятьКолонки И ВРег(СтрокаСоответствия.Префикс) = "FLD" Тогда
			ТекСтрока = Чтение.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;

		СоответствиеИменБД.Вставить(СтрШаблон("%1%2", СтрокаСоответствия.Префикс, ЧастиСтроки[2]), СтрокаСоответствия);

		ТекСтрока = Чтение.ПрочитатьСтроку();
	КонецЦикла;

	Возврат СоответствиеИменБД;

КонецФункции // СоответствиеИдМетаданныхИменамТаблиц()

// Процедура - читает атрибуты узлов ROW из переданной XML-строки
// и добавляет соответствия UUID метаданных и имен метаданных
//
// Параметры:
//   СоответствиеИменМетаданных    - Соответствие    - соответствия UUID метаданных и имен метаданных
//   ТекстXML                      - Строка          - XML-строка для чтения
//
Процедура ДополнитьСоответствиеИменМетаданных(СоответствиеИменМетаданных, ТекстXML)

	Если НЕ ТипЗнч(СоответствиеИменМетаданных) = Тип("Соответствие") Тогда
		СоответствиеИменМетаданных = Новый Соответствие();
	КонецЕсли;

	Парсер = Новый ЧтениеXML;
	Парсер.УстановитьСтроку(ТекстXML);
 
	Пока Парсер.Прочитать() Цикл

		ЗначенияАтрибутов = Новый Соответствие();

		Если Парсер.ТипУзла = ТипУзлаXML.НачалоЭлемента И ВРег(Парсер.Имя) = "ROW" Тогда
			ЗначенияАтрибутов = ЗначенияАтрибутов(Парсер);
		Иначе
			Продолжить;
		КонецЕсли;

		Ид = ЗначенияАтрибутов["FILENAME"];
		Данные = ЗначенияАтрибутов["BINARYDATA"];

		Если ЗначенияАтрибутов.Количество() = 0 ИЛИ Ид = Неопределено
		 ИЛИ Данные = Неопределено ИЛИ СтрДлина(Ид) <> 36 Тогда
			Продолжить;
		КонецЕсли;

		Данные = ПрочитатьУпакованныеДанные(Данные, Истина);

		ОписаниеФайла = Новый Структура();
		ОписаниеФайла.Вставить("Ид"            , Ид);
		ОписаниеФайла.Вставить("Содержимое"    , Данные);
		ОписаниеФайла.Вставить("ИмяМетаданных", ИмяМетаданных(Данные, ОписаниеФайла.Ид));

		СоответствиеИменМетаданных.Вставить(ОписаниеФайла.Ид, ОписаниеФайла);

	КонецЦикла;
 
	Парсер.Закрыть();

КонецПроцедуры // ДополнитьСоответствиеИменМетаданных()

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

	ВсегоЗаписей = КоличествоЗаписейВТаблицеКонфигурации(Ид);
	Прочитано = 0;
	
	ОтборПоИд = "";
	Если ЗначениеЗаполнено(Ид) Тогда
		ОтборПоИд = СтрШаблон("AND [FileName] = '%1'", Ид);
	КонецЕсли;
	
	Пока Прочитано < ВсегоЗаписей Цикл
	
		ТекстЗапроса = СтрШаблон("""SET NOCOUNT ON;
		                         | SELECT
		                         | [FileName],
		                         | [BinaryData]
		                         | FROM %1.[dbo].[Config]
		                         | WHERE CHARINDEX('.', [FileName]) = 0 %2
		                         | ORDER BY [FileName] OFFSET %3 ROWS FETCH NEXT %4 ROWS ONLY
		                         | FOR XML RAW, BINARY BASE64
		                         | SET NOCOUNT OFF;"" ",
		                         База,
		                         ОтборПоИд,
		                         Прочитано,
		                         ПорцияЧтения);
	
		РезультатЗапроса = "";

		Попытка
			КодВозврата = ПодключениеКСУБД.ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса);
			Если КодВозврата = 0 Тогда
				Лог.Отладка("Получено соответствие имен метаданных базы ""%1\%2"": %3",
				            ТекущийСервер,
				            РезультатЗапроса,
				            База);
			Иначе
				ТекстОшибки = СтрШаблон("Ошибка получения соответствия имен метаданных базы ""%1\%2"":%3%4",
				                        ТекущийСервер,
				                        База,
				                        Символы.ПС,
				                        РезультатЗапроса); 
				ВызватьИсключение ТекстОшибки;
			КонецЕсли;
		Исключение
			ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ТекстОшибки = СтрШаблон("Ошибка получения соответствия имен метаданных базы ""%1\%2"":%3%4",
			                        ТекущийСервер,
			                        База,
			                        Символы.ПС,
			                        ТекстОшибки);
			ВызватьИсключение ТекстОшибки;
		КонецПопытки;
	
		НормализоватьXML(РезультатЗапроса);
	
		ДополнитьСоответствиеИменМетаданных(СоответствиеИменМетаданных, РезультатЗапроса);
	
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
	
	Возврат ПрочитатьJSON(Чтение, Ложь);

КонецФункции // НазначенияОбъектовБазы()

// Функция - возвращает список таблиц базы, соответствующих фильтру
//
// Параметры:
//  ФильтрТаблицПоИмени     - Строка    - фильтр имен таблиц в формате для оператора "LIKE"
// 
// Возвращаемое значение:
//  Соответствие    - список таблиц базы
//
Функция ТаблицыБазыДанных(ФильтрТаблицПоИмени = "")

	Лог.Отладка("Получение списка таблиц базы ""%1\%2"": %3", ТекущийСервер, База);

	ШаблонЗапроса = """SET NOCOUNT ON;
	                | SELECT
	                | T.Name AS [Table]
	                | FROM %1.sys.tables T
	                | %2
	                | SET NOCOUNT OFF;"" ";

	Условие = "";
	Если ЗначениеЗаполнено(ФильтрТаблицПоИмени) Тогда
		Условие = СтрШаблон("WHERE T.Name LIKE '%1'", ФильтрТаблицПоИмени);
	КонецЕсли;

	ТекстЗапроса = СтрШаблон(ШаблонЗапроса, База, Условие);

	РезультатЗапроса = "";

	Попытка
		КодВозврата = ПодключениеКСУБД.ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса);
		Если КодВозврата = 0 Тогда
			Лог.Отладка("Получен список таблиц базы ""%1\%2"": %3",
			            ТекущийСервер,
			            РезультатЗапроса,
			            База);
		Иначе
			ТекстОшибки = СтрШаблон("Ошибка получения списка таблиц базы ""%1\%2"":%3%4",
			                        ТекущийСервер,
			                        База,
			                        Символы.ПС,
			                        РезультатЗапроса); 
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения списка таблиц базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Разделитель = "---";
	Поз = СтрНайти(РезультатЗапроса, Разделитель, НаправлениеПоиска.FromEnd);
	Если Поз > 0 Тогда
		РезультатЗапроса = СокрЛП(Сред(РезультатЗапроса, Поз + СтрДлина(Разделитель)));
	КонецЕсли;

	Результат = Новый Соответствие();

	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(РезультатЗапроса);
	
	Для й = 1 По Текст.КоличествоСтрок() Цикл
		ИмяТаблицы = СокрЛП(Текст.ПолучитьСтроку(й));
		УбратьЛидирующееПодчеркивание(ИмяТаблицы);

		Результат.Вставить(ИмяТаблицы, ИмяТаблицы);
	КонецЦикла;

	Возврат Результат;

КонецФункции // ТаблицыБазыДанных()

// Функция - список таблиц, хранящих данные табличных частей объектов 1С
// с указанием таблиц объектов-владельцев
//
// Возвращаемое значение:
//  Соответствие    - список таблиц, хранящих данные табличных частей объектов 1С
//
Функция ТабличныеЧастиИВладельцы()

	ТаблицыБазы = ТаблицыБазыДанных("%_VT%");

	ТабличныеЧастиИВладельцы = Новый Соответствие();

	Для Каждого ТекЭлемент Из ТаблицыБазы Цикл
		ОписаниеОбъектаБазы = ОписаниеОбъектаБазыПоИмени(ТекЭлемент.Значение);

		ТабличныеЧастиИВладельцы.Вставить(СтрШаблон("%1%2", ОписаниеОбъектаБазы.Префикс, ОписаниеОбъектаБазы.Индекс), ОписаниеОбъектаБазы);
	КонецЦикла;

	Возврат ТабличныеЧастиИВладельцы;

КонецФункции // ТабличныеЧастиИВладельцы()

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
//  Структура    - имя объекта базы, префикс, индекс, владелец и суффикс
//
Функция ОписаниеОбъектаБазыПоИмени(Знач ИмяОбъектаБазы)

	ОписаниеОбъектаБазы = СтруктураОписанияОбъектаБазы();

	УбратьЛидирующееПодчеркивание(ИмяОбъектаБазы);

	Символ = Сред(ИмяОбъектаБазы, 1, 1);

	ПрефиксОбъекта = "";

	Пока НЕ ЭтоЧисло(Символ) Цикл
		ПрефиксОбъекта = ПрефиксОбъекта + Символ;
		Если СтрДлина(ИмяОбъектаБазы) = 1 Тогда
			ИмяОбъектаБазы = "";
			Символ = "";
			Прервать;
		КонецЕсли;
		ИмяОбъектаБазы = Сред(ИмяОбъектаБазы, 2);
		Символ = Сред(ИмяОбъектаБазы, 1, 1);
	КонецЦикла;

	ПозицияИмениТЧ = СтрНайти(ИмяОбъектаБазы, "_VT");
	Если ПозицияИмениТЧ > 0 Тогда
		ОписаниеОбъектаВладельца = ОписаниеОбъектаБазыПоИмени(ПрефиксОбъекта + Лев(ИмяОбъектаБазы, ПозицияИмениТЧ - 1));
		ОписаниеОбъектаБазы.Владелец   = ОписаниеОбъектаВладельца;
		ОписаниеОбъектаБазы.Тип        = "ТабличнаяЧасть";
		ОписаниеОбъектаБазы.ТипАнгл    = "TabularSection";
		ОписаниеОбъектаБазы.Назначение = "ТабличнаяЧасть";
		ПрефиксОбъекта = "VT";
		ИмяОбъектаБазы = Сред(ИмяОбъектаБазы, ПозицияИмениТЧ + 3);
		Символ = Сред(ИмяОбъектаБазы, 1, 1);
	ИначеЕсли ВРег(ПрефиксОбъекта) = "FLD" Тогда
		ОписаниеОбъектаБазы.Тип        = "Поле";
		ОписаниеОбъектаБазы.ТипАнгл    = "Field";
		ОписаниеОбъектаБазы.Назначение = "Поле";
	Иначе
		НазначенияОбъектовБазы = НазначенияОбъектовБазы();

		Если НазначенияОбъектовБазы.Свойство(ВРег(ПрефиксОбъекта)) Тогда
			ОписаниеКоллекции = НазначенияОбъектовБазы[ВРег(ПрефиксОбъекта)];
			ОписаниеОбъектаБазы.Тип        = ОписаниеКоллекции.Тип;
			ОписаниеОбъектаБазы.ТипАнгл    = ОписаниеКоллекции.ТипАнгл;
			ОписаниеОбъектаБазы.Назначение = ОписаниеКоллекции.Назначение;
		КонецЕсли;
	КонецЕсли;

	// состав и имена таблицы итогов по счету зависит от количества субконто,
	// поэтому добавляем еще 1 цифру
	Если ПрефиксОбъекта = "AccRgAT" Тогда
		ПрефиксОбъекта = ПрефиксОбъекта + Символ;
		ИмяОбъектаБазы = Сред(ИмяОбъектаБазы, 2);
		Символ = Сред(ИмяОбъектаБазы, 1, 1);
	КонецЕсли;

	ОписаниеОбъектаБазы.Префикс = ПрефиксОбъекта;

	ИндексОбъекта = "";

	Пока ЭтоЧисло(Символ) Цикл
		ИндексОбъекта = ИндексОбъекта + Символ;
		Если СтрДлина(ИмяОбъектаБазы) = 1 Тогда
			ИмяОбъектаБазы = "";
			Символ = "";
			Прервать;
		КонецЕсли;
		ИмяОбъектаБазы = Сред(ИмяОбъектаБазы, 2);
		Символ = Сред(ИмяОбъектаБазы, 1, 1);
	КонецЦикла;

	Если ЗначениеЗаполнено(ИндексОбъекта) Тогда
		ОписаниеОбъектаБазы.Индекс = Число(ИндексОбъекта);
	КонецЕсли;

	ОписаниеОбъектаБазы.Имя = СтрШаблон("%1%2", ОписаниеОбъектаБазы.Префикс, Формат(ОписаниеОбъектаБазы.Индекс, "ЧРГ=; ЧГ="));

	Если ЗначениеЗаполнено(Символ) Тогда
		ОписаниеОбъектаБазы.Суффикс = ИмяОбъектаБазы;
	КонецЕсли;

	Возврат ОписаниеОбъектаБазы;

КонецФункции // ОписаниеОбъектаБазыПоИмени()

// Функция - возвращает список колонок базы, соответствующих фильтру
//
// Параметры:
//  ФильтрТаблицПоИмени      - Строка    - фильтр имен таблиц в формате для оператора "LIKE"
//  ФильтрКолонокПоИмени     - Строка    - фильтр имен колонок в формате для оператора "LIKE"
//
// Возвращаемое значение:
//  Соответствие    - список колонок базы
//
Функция КолонкиБазыДанных(ФильтрТаблицПоИмени = "", ФильтрКолонокПоИмени = "")

	Лог.Отладка("Получение списка колонок базы ""%1\%2"": %3", ТекущийСервер, База);

	ШаблонЗапроса = """SET NOCOUNT ON;
	                | SELECT
	                | T.Name AS [Table],
	                | C.name AS Field
	                |
	                | FROM %1.sys.tables T
	                | LEFT JOIN %1.sys.columns C
	                | ON T.object_id = C.object_id
	                | %2
	                | SET NOCOUNT OFF;"" ";

	Условие = "";
	Если ЗначениеЗаполнено(ФильтрТаблицПоИмени) Тогда
		Условие = СтрШаблон("WHERE T.Name LIKE '%1'", ФильтрТаблицПоИмени);
	КонецЕсли;

	Если ЗначениеЗаполнено(ФильтрКолонокПоИмени) Тогда
		Если ЗначениеЗаполнено(Условие) Тогда
			Условие = СтрШаблон("%1 AND C.Name LIKE '%2'", Условие, ФильтрКолонокПоИмени);
		Иначе
			Условие = СтрШаблон("WHERE C.Name LIKE '%1'", ФильтрКолонокПоИмени);
		КонецЕсли;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон(ШаблонЗапроса, База, Условие);

	РезультатЗапроса = "";

	Попытка
		КодВозврата = ПодключениеКСУБД.ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса, "|", Истина);
		Если КодВозврата = 0 Тогда
			Лог.Отладка("Получен список колонок базы ""%1\%2"": %3",
			            ТекущийСервер,
			            РезультатЗапроса,
			            База);
		Иначе
			ТекстОшибки = СтрШаблон("Ошибка получения списка колонок базы ""%1\%2"":%3%4",
			                        ТекущийСервер,
			                        База,
			                        Символы.ПС,
			                        РезультатЗапроса); 
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения списка колонок базы ""%1\%2"":%3%4",
		                        ТекущийСервер,
		                        База,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Разделитель = "---";
	Поз = СтрНайти(РезультатЗапроса, Разделитель, НаправлениеПоиска.FromEnd);
	Если Поз > 0 Тогда
		РезультатЗапроса = СокрЛП(Сред(РезультатЗапроса, Поз + СтрДлина(Разделитель)));
	КонецЕсли;

	Результат = Новый Соответствие();

	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(РезультатЗапроса);

	Для й = 1 По Текст.КоличествоСтрок() Цикл
		Значения = СтрРазделить(Текст.ПолучитьСтроку(й), "|", Ложь);

		ОписаниеОбъектаВладельца = ОписаниеОбъектаБазыПоИмени(Значения[0]);
		ОписаниеОбъектаКолонки = ОписаниеОбъектаБазыПоИмени(Значения[1]);
		ОписаниеОбъектаКолонки.Владелец = ОписаниеОбъектаВладельца;

		Результат.Вставить(ОписаниеОбъектаКолонки.Имя, ОписаниеОбъектаКолонки);
	КонецЦикла;

	Возврат Результат;

КонецФункции // КолонкиБазыДанных()

// Функция - находит в тестовом описании объекта метаданных его имя
//
// Параметры:
//   Описание     - Строка     - описание объекта метаданных (скобкотекст)
//   Ид           - Строка     - UUID объекта метаданных
//
// Возвращаемое значение:
//   Строка    - имя объекта метаданных
//
Функция ИмяМетаданных(Описание, Ид)

	ИмяМетаданных = "";
	Позиция = СтрНайти(Описание, Ид);
	Если Позиция = 0 Тогда
		Возврат "";
	КонецЕсли;
	Позиция = Позиция + СтрДлина(Ид) + 3;

	Символ = Сред(Описание, Позиция, 1);
	Пока НЕ Символ = """" Цикл
		ИмяМетаданных = ИмяМетаданных + Символ;
		Позиция = Позиция + 1;
		Символ = Сред(Описание, Позиция, 1);
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
		ВызватьИсключение СтрШаблон("Некорректный тип параметра ""УпакованныеДанные"" ""%1"",
		                            | ожидается ""ДвоичныеДанные"" или ""Строка""",
		                            ТипЗнч(УпакованныеДанные));
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

// Функция - читает атрибуты узла XML
//
// Параметры:
//   Парсер    - ЧтениеXML    - парсер, спозиционированный на начало элемента XML
//
// Возвращаемое значение:
//    Соответствие    - прочитанные значения атрибутов узла XML
//
Функция ЗначенияАтрибутов(Парсер)

	Результат = Новый Соответствие();

	КоличествоАтрибутов = Парсер.КоличествоАтрибутов();

	Для й = 0 По КоличествоАтрибутов -1 Цикл
		Результат.Вставить(ВРег(Парсер.ИмяАтрибута(й)), Парсер.ЗначениеАтрибута(й))
	КонецЦикла;

	Возврат Результат;

КонецФункции // ЗначенияАтрибутов()

// Процедура - добавляет стандартный заголовок XML и корневой элемент
//
// Параметры:
//  ТекстXML     - Строка    - дополняемый техт XML
// 
Процедура НормализоватьXML(ТекстXML)

	ТекстXML = СтрЗаменить(ТекстXML, Символы.ПС, "");
	ТекстXML = СтрЗаменить(ТекстXML, Символы.ВК, "");

	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(ТекстXML);
	Текст.ВставитьСтроку(1, "<?xml version=""1.0"" encoding=""utf-8""?>");
	Текст.ВставитьСтроку(2, "<data>");
	Текст.ДобавитьСтроку("</data>");

	ТекстXML = Текст.ПолучитьТекст();

КонецПроцедуры // НормализоватьXML()

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
		ВызватьИсключение СтрШаблон("Некоректный тип ""%1"" параметра ""Данные"",
		                            | ожидается ""Base64Строка, Поток, ДвоичныеДанные""",
		                            ТипЗнч(Данные));
	КонецЕсли;

	Поток.Перейти(0, ПозицияВПотоке.Начало);

	Буфер = Новый БуферДвоичныхДанных(3);

	Поток.Прочитать(Буфер, 0, 3);

	Возврат НЕ (Буфер[0] = 239 И Буфер[1] = 187 И Буфер[2] = 191);

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

	Если Лев(Результат, 1) = """" И Прав(Результат, 1) = """" Тогда
		Результат = Сред(Результат, 2, СтрДлина(Результат) - 2);
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

	Если Лев(Имя, 1) = "_" Тогда
		Имя = Сред(Имя, 2);
	КонецЕсли;

КонецПроцедуры // УбратьЛидирующееПодчеркивание()

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

	Для й = 1 По СтрДлина(Строка) Цикл
		Если СтрНайти(Цифры, Сред(Строка, й, 1)) = 0 Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;

	Возврат Истина;

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

	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий
