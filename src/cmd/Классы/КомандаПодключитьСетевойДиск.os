// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

Перем Лог;       // - Объект      - объект записи лога приложения

#Область СлужебныйПрограммныйИнтерфейс

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("d drive map-drive", "", "имя устройства (буква диска)")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_FILE_MAP_DRIVE");
	
	Команда.Опция("r res map-res", "", "путь к подключаемому ресурсу")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_FILE_MAP_RES");
	
	Команда.Опция("u user map-user", "", "пользователь для подключения")
	       .ТСтрока()
	       .ВОкружении("CPDB_FILE_MAP_USER");
	
	Команда.Опция("p pwd map-pwd", "", "пароль пользователя для подключения")
	       .ТСтрока()
	       .ВОкружении("CPDB_FILE_MAP_PWD");

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ВыводОтладочнойИнформации = Команда.ЗначениеОпции("verbose");

	ПараметрыСистемы.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	Если НЕ ПараметрыПриложения.ОбязательныеПараметрыЗаполнены(Команда) Тогда
		Команда.ВывестиСправку();
		Возврат;
	КонецЕсли;

	ИмяУстройства      = Команда.ЗначениеОпции("drive");
	ИмяРесурса         = Команда.ЗначениеОпции("res");
	Пользователь       = Команда.ЗначениеОпции("user");
	ПарольПользователя = Команда.ЗначениеОпции("pwd");

	РаботаСФайлами.ПодключитьДиск(ИмяУстройства, ИмяРесурса, Пользователь, ПарольПользователя);

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта()

	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий
