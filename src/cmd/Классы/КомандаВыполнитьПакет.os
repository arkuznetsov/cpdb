// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем КомандаПриложения;    // КомандаПриложения    - основная команда приложения
Перем Лог;    // логгер

#Область СлужебныйПрограммныйИнтерфейс

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт

	Команда.Аргумент("SCENARIOS", "", "пути к файлам JSON содержащим последовательность команд и значения параметров,
	                                  | могут быть указаны несколько файлов разделенные "";""
	                                  | (обработка файлов выполняется в порядке следования)")
	       .ТСтрока()
	       .ВОкружении("CPDB_SCENARIOS");

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	КомандаПриложения = Команда.Приложение.ПолучитьКоманду();

	ВыводОтладочнойИнформации = Команда.ЗначениеОпции("verbose");

	ПараметрыСистемы.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	ФайлыСценариев = Команда.ЗначениеАргумента("SCENARIOS");

	Сценарии = Новый Массив();

	ПрочитатьСценарииИзФайлов(Сценарии, ФайлыСценариев);
	
	Для Каждого ТекСценарий Из Сценарии Цикл
		ВыполнитьСценарий(ТекСценарий);
	КонецЦикла;

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Выполняет чтение сценариев из переданного списка файлов JSON
//
// Параметры:
//   Сценарии            - Массив Из Структура    - (возвр.) массив сценариев, прочитанный из переданных файлов
//     *ИмяФайла           - Строка                 - имя файла сценария
//     *НомерСценария      - Число                  - порядковый номер сценария в файле
//     *Сценарий           - Структура              - сценарий для выполнения
//   ФайлыСценариев      - Строка                 - пути к файлам JSON содержащим последовательность команд
//                                                  и значения параметров, могут быть указаны
//                                                  несколько файлов разделенные "";""
//
Процедура ПрочитатьСценарииИзФайлов(Сценарии, Знач ФайлыСценариев)

	Если НЕ ТипЗнч(Сценарии) = Тип("Массив") Тогда
		Сценарии = Новый Массив();
	КонецЕсли;

	ФайлыСценариев = СтрРазделить(ФайлыСценариев, ";", Ложь);

	Для Каждого ТекФайл Из ФайлыСценариев Цикл

		Лог.Отладка("Чтение файла сценариев ""%1""", ТекФайл);

		ВремФайл = Новый Файл(ТекФайл);

		Если НЕ (ВремФайл.Существует() И ВремФайл.ЭтоФайл()) Тогда
			ТекстОшибки = СтрШаблон("Не найден файл сценариев ""%1"".", ТекФайл);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;

		Попытка
			ПрочитатьСценарииИзФайла(Сценарии, ТекФайл)
		Исключение
			ТекстОшибки = СтрШаблон("Ошибка чтения файла сценариев ""%1"":%2%3",
			                        ТекФайл,
			                        Символы.ПС,
			                        ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ВызватьИсключение ТекстОшибки;
		КонецПопытки;

	КонецЦикла;

	Если Сценарии.Количество() = 0 Тогда
		ТекстОшибки = СтрШаблон("Не найдены сценарии в файлах ""%1"" или рабочем каталоге ""%2"".",
		                        ФайлыСценариев,
		                        ТекущийКаталог());
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

КонецПроцедуры // ПрочитатьСценарииИзФайлов()

// Выполняет чтение сценариев из переданного файла JSON
//
// Параметры:
//   Сценарии            - Массив Из Структура    - (возвр.) массив сценариев, прочитанный из переданных файлов
//     *ИмяФайла           - Строка                 - имя файла сценария
//     *НомерСценария      - Число                  - порядковый номер сценария в файле
//     *Сценарий           - Структура              - сценарий для выполнения
//   ФайлСценариев       - Строка                 - путь к файлу JSON содержащему последовательность команд
//                                                  и значения параметров
//
Процедура ПрочитатьСценарииИзФайла(Сценарии, Знач ФайлСценариев)

	Если НЕ ТипЗнч(Сценарии) = Тип("Массив") Тогда
		Сценарии = Новый Массив();
	КонецЕсли;

	Чтение = Новый ЧтениеJSON();
	Чтение.ОткрытьФайл(ФайлСценариев, КодировкаТекста.UTF8);
	
	РезультатЧтения = ПрочитатьJSON(Чтение, Истина);

	СценарииВФайле = Новый Массив();

	Если ТипЗнч(РезультатЧтения) = Тип("Соответствие") Тогда
		СценарииВФайле.Добавить(РезультатЧтения);
	ИначеЕсли ТипЗнч(РезультатЧтения) = Тип("Массив") Тогда
		СценарииВФайле = РезультатЧтения;
	Иначе
		ТекстОшибки = СтрШаблон("Некорректная структура файла сценариев ""%1"" - %2,
		                        | ожидалось ""Массив"" или ""Соответствие"".",
		                        ФайлСценариев,
		                        ТипЗнч(СценарииВФайле));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Для й = 0 По СценарииВФайле.ВГраница() Цикл
		ОписаниеСценария = Новый Структура("ИмяФайла, НомерСценария, Сценарий");
		ОписаниеСценария.ИмяФайла = ФайлСценариев;
		ОписаниеСценария.НомерСценария = й;
		ОписаниеСценария.Сценарий = СценарииВФайле[й];

		Сценарии.Добавить(ОписаниеСценария);
	КонецЦикла;

КонецПроцедуры // ПрочитатьСценарииИзФайла()

// Выполняет переданный сценарий
//   
// Параметры:
//   ОписаниеСценария    - Структура     - Последовательность команд с параметрами для выполнения
//     *ИмяФайла           - Строка        - имя файла сценария
//     *НомерСценария      - Число         - порядковый номер сценария в файле
//     *Сценарий           - Структура     - сценарий для выполнения
//
Процедура ВыполнитьСценарий(ОписаниеСценария)
	
	Лог.Информация("Выполняется сценарий (%1) из файла ""%2""",
	               ОписаниеСценария.НомерСценария,
	               ОписаниеСценария.ИмяФайла);

	ОбщиеПараметры = ОписаниеСценария.Сценарий["params"];

	Если НЕ (ТипЗнч(ОбщиеПараметры) = Тип("Структура")
		ИЛИ ТипЗнч(ОбщиеПараметры) = Тип("Соответствие")) Тогда
		ОбщиеПараметры = Новый Соответствие();
	Иначе
		Лог.Отладка("Прочитаны общие параметры");
	КонецЕсли;

	ШагиСценария = ОписаниеСценария.Сценарий["stages"];

	Если НЕ (ТипЗнч(ШагиСценария) = Тип("Структура")
		ИЛИ ТипЗнч(ШагиСценария) = Тип("Соответствие")) Тогда
		ТекстОшибки = СтрШаблон("Не найдены шаги ""stages"" сценария (%1) из файла ""%2""",
		                        ОписаниеСценария.НомерСценария,
		                        ОписаниеСценария.ИмяФайла);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Для Каждого ТекШаг Из ШагиСценария Цикл
		Если НЕ ЗначениеЗаполнено(ТекШаг.Значение["description"]) Тогда
			ТекШаг.Значение.Вставить("description", ТекШаг.Ключ);
		КонецЕсли;
		Лог.Информация("Выполняется шаг ""%1"" сценария (%2) из файла ""%3""",
		               ТекШаг.Ключ,
		               ОписаниеСценария.НомерСценария,
		               ОписаниеСценария.ИмяФайла);
		ВыполнитьШагСценария(ТекШаг.Значение, ОбщиеПараметры);
	КонецЦикла;
	
КонецПроцедуры // ВыполнитьСценарий()

// Выполняет шаг сценария
//   
// Параметры:
//   Шаг               - Соответствие    - описание шага сценария
//   ОбщиеПараметры    - Соответствие    - значения общих параметров сценария
//
Процедура ВыполнитьШагСценария(Шаг, Знач ОбщиеПараметры)
	
	ОписаниеШага = Шаг["description"];

	Параметры = Новый Соответствие();

	Для Каждого ТекПараметр Из ОбщиеПараметры Цикл
		Параметры.Вставить(ТекПараметр.Ключ, ТекПараметр.Значение);
	КонецЦикла;

	ПараметрыШага = Шаг["params"];

	Если НЕ (ТипЗнч(ПараметрыШага) = Тип("Структура")
		ИЛИ ТипЗнч(ПараметрыШага) = Тип("Соответствие")) Тогда
		ПараметрыШага = Новый Соответствие();
	Иначе
		Лог.Отладка("Прочитаны параметры шага ""%1""", ОписаниеШага);
	КонецЕсли;

	Для Каждого ТекПараметр Из ПараметрыШага Цикл
		Параметры.Вставить(ТекПараметр.Ключ, ТекПараметр.Значение);
	КонецЦикла;

	КомандаСтрокой = Шаг["command"];

	Если НЕ ТипЗнч(КомандаСтрокой) = Тип("Строка") Тогда
		ТекстОшибки = СтрШаблон("Не указана команда шага ""%1""", ОписаниеШага);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	ЧастиКоманды = СтрРазделить(КомандаСтрокой, " ");

	Подкоманды = КомандаПриложения.ПолучитьПодкоманды();

	КомандаДляЗапуска = Неопределено;

	ПараметрыЗапуска = Новый Массив();

	Для й = 0 По ЧастиКоманды.ВГраница() Цикл
		
		Если й > 0 Тогда
			ПараметрыЗапуска.Добавить(ЧастиКоманды[й]);
		КонецЕсли;

		НайденнаяКоманда = Неопределено;

		Для Каждого ТекКоманда Из Подкоманды Цикл
			Если НРег(СокрЛП(ЧастиКоманды[й])) = НРег(СокрЛП(ТекКоманда.ПолучитьИмяКоманды())) Тогда
				НайденнаяКоманда = ТекКоманда;
				Прервать;
			КонецЕсли;
		КонецЦикла;

		Если НЕ ТипЗнч(КомандаСтрокой) = Тип("Строка") Тогда
			ТекстОшибки = СтрШаблон("Не найдена часть команды ""%1"" команды ""%2"" шага ""%3""",
			                        ЧастиКоманды[й],
			                        КомандаСтрокой,
			                        ОписаниеШага);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;

		НайденнаяКоманда.НачалоЗапуска();

		Если й = 0 Тогда
			Лог.Отладка("Найдена запускаемая команда ""%1"" шага ""%2""",
			            ТекКоманда.ПолучитьИмяКоманды(),
			            ОписаниеШага);
			КомандаДляЗапуска = НайденнаяКоманда;
		КонецЕсли;

		Для Каждого ТекПараметр Из Параметры Цикл
			ФорматированноеИмя = СтрШаблон(?(СтрДлина(ТекПараметр.Ключ) = 1, "-%1", "--%1"), ТекПараметр.Ключ);
			НайденнаяОпция = НайденнаяКоманда.ОпцияИзИндекса(ФорматированноеИмя);
			Если НайденнаяОпция = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			Если ПараметрыЗапуска.Найти(ФорматированноеИмя) = Неопределено Тогда
				Лог.Отладка("Добавлен параметр ""%1"" = ""%2"" команды ""%3"" шага ""%4""",
				            ФорматированноеИмя,
				            ТекПараметр.Значение,
				            ТекКоманда.ПолучитьИмяКоманды(),
				            ОписаниеШага);
				Если НЕ НайденнаяОпция.ТипОпции = Тип("Булево") Тогда
					ПараметрыЗапуска.Добавить(ФорматированноеИмя);
					ПараметрыЗапуска.Добавить(ТекПараметр.Значение);
				ИначеЕсли ТекПараметр.Значение = Истина Тогда
					ПараметрыЗапуска.Добавить(ФорматированноеИмя);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;

		Подкоманды = ТекКоманда.ПолучитьПодкоманды();
	КонецЦикла;

	КомандаДляЗапуска.Запуск(ПараметрыЗапуска);

КонецПроцедуры // ВыполнитьШагСценария()

#КонецОбласти // СлужебныеПроцедурыИФункции

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта()

	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий
