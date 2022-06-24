// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

#Использовать logos
#Использовать tempfiles
#Использовать fs

Перем ЛогПриложения;            // Объект                 - объект записи лога приложения
Перем КаталогПриложения;        // Строка                 - текущий каталог приложения
Перем ЭтоПриложениеEXE;         // Булево                 - Истина - выполняется скомпилированный скрипт
Перем ЭтоWindows;               // Булево                 - Истина - скрипт выполняется в среде Windows

// Функция - проверяет, что скрипт выполняется в среде Windows
//
// Возвращаемое значение:
//	Булево     - Истина - скрипт выполняется в среде Windows
//
Функция ЭтоWindows() Экспорт

	Если ЭтоWindows = Неопределено Тогда
		СистемнаяИнформация = Новый СистемнаяИнформация;
		ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
	КонецЕсли;

	Возврат ЭтоWindows;

КонецФункции // ЭтоWindows()

// Функция - проверяет, что выполняется скомпилированный скрипт
//
// Возвращаемое значение:
//	Булево     - Истина - выполняется скомпилированный скрипт
//
Функция ЭтоСборкаEXE() Экспорт
	
	Если ЭтоПриложениеEXE = Неопределено Тогда
		ДлинаРасширения = 3;
		ЭтоПриложениеEXE = ВРег(Прав(ТекущийСценарий().Источник, ДлинаРасширения)) = "EXE";
	КонецЕсли;

	Возврат ЭтоПриложениеEXE;

КонецФункции // ЭтоСборкаEXE()

// Функция - при необходтимости, определяет и возвращает текущий каталог приложения
//
// Возвращаемое значение:
//  Строка      - текущий каталог приложения
//
Функция КаталогПриложения() Экспорт
	
	Если Не КаталогПриложения = Неопределено Тогда
		Возврат КаталогПриложения;
	КонецЕсли;

	ПутьККаталогу = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "..", "..");

	ФайлКаталога = Новый Файл(ПутьККаталогу);
	
	Возврат ФайлКаталога.ПолноеИмя;

КонецФункции // КаталогПриложения()

// Функция - возвращает текущий уровень лога приложения
//
// Возвращаемое значение:
//  Строка      - текущий уровень лога приложения
//
Функция УровеньЛога() Экспорт

	Возврат ЛогПриложения.Уровень();

КонецФункции // УровеньЛога()

// Процедура - включает режим отладки
//
// Параметры:
//	РежимОтладки    - Булево     - Истина - включить режим отладки
//
Процедура УстановитьРежимОтладки(Знач РежимОтладки) Экспорт
	
	Если РежимОтладки Тогда
		
		Лог().УстановитьУровень(УровниЛога.Отладка);

	КонецЕсли;
	
КонецПроцедуры // УстановитьРежимОтладки()

// Функция - при необходимости, инициализирует и возвращает объект управления логированием
//
// Возвращаемое значение:
//  Объект      - объект управления логированием
//
Функция Лог() Экспорт
	
	Если ЛогПриложения = Неопределено Тогда
		ЛогПриложения = Логирование.ПолучитьЛог(ИмяЛогаПриложения());
	КонецЕсли;

	Возврат ЛогПриложения;

КонецФункции // Лог()

// Функция - возвращает имя лога приложения
//
// Возвращаемое значение:
//  Строка      - имя лога приложения
//
Функция ИмяЛогаПриложения() Экспорт

	Возврат "oscript.app." + ИмяПриложения();

КонецФункции // ИмяЛогаПриложения()

// Функция - возвращает имя приложения
//
// Возвращаемое значение:
//  Строка      - имя приложения
//
Функция ИмяПриложения() Экспорт

	Возврат "cpdb";

КонецФункции // ИмяПриложения()

// Функция - возвращает версию приложения
//
// Возвращаемое значение:
//  Строка      - версия приложения
//
Функция Версия() Экспорт
	
	Возврат "1.3.1";
	
КонецФункции // Версия()
