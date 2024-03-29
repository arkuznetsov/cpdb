// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

#Использовать "../../core"

#Область СлужебныйПрограммныйИнтерфейс

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("pp params", "", "Файлы JSON содержащие значения параметров,
	                               | могут быть указаны несколько файлов разделенные "";""")
	       .ТСтрока()
	       .ВОкружении("CPDB_PARAMS");

	Команда.Опция("d db sql-db", "", "имя создаваемой базы")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_SQL_DATABASE");
	
	Команда.Опция("p db-datapath", "", "путь к каталогу расположения файлов базы")
	       .ТСтрока()
	       .ВОкружении("CPDB_SQL_DATABASE_FOLDER");
	
	Команда.Опция("r db-recovery", "SIMPLE", "установить модель восстановления (RECOVERY MODEL),
	                                         |возможные значения ""FULL"", ""SIMPLE"",""BULK_LOGGED""")
	       .ТСтрока()
	       .ВОкружении("CPDB_SQL_DATABASE_RECOVERY_MODEL");
	
КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ЧтениеОпций = Новый ЧтениеОпцийКоманды(Команда);

	ВыводОтладочнойИнформации = ЧтениеОпций.ЗначениеОпции("verbose");

	ПараметрыСистемы.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	Сервер               = ЧтениеОпций.ЗначениеОпции("srvr", Истина);
	Пользователь         = ЧтениеОпций.ЗначениеОпции("user", Истина);
	ПарольПользователя   = ЧтениеОпций.ЗначениеОпции("pwd", Истина);
	База                 = ЧтениеОпций.ЗначениеОпции("db");
	МодельВосстановления = ЧтениеОпций.ЗначениеОпции("db-recovery");
	ПутьККаталогу        = ЧтениеОпций.ЗначениеОпции("db-datapath");

	ПодключениеКСУБД = Новый ПодключениеMSSQL(Сервер, Пользователь, ПарольПользователя);
	
	РаботаССУБД = Новый РаботаССУБД(ПодключениеКСУБД);

	РаботаССУБД.СоздатьБазуДанных(База, МодельВосстановления, ПутьККаталогу);

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс
