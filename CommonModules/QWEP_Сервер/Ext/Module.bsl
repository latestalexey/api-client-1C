﻿// Создает новю запись в РС QWEP_AccessToken
Процедура СоздатьНовуюЗаписьAccessToken(authorizationCode, ОтветСтруктура) Экспорт
	
	НоваяЗаписьРС = РегистрыСведений.QWEP_AccessToken.СоздатьМенеджерЗаписи();
	НоваяЗаписьРС.Период = ТекущаяДата();
	НоваяЗаписьРС.applicationNum = 1;
	НоваяЗаписьРС.authorizationCode = authorizationCode;
	НоваяЗаписьРС.token = ОтветСтруктура.token;
	НоваяЗаписьРС.type  = ОтветСтруктура.type;
	НоваяЗаписьРС.Записать();
	
КонецПроцедуры

// Возвращает ТокенДоступа для возможности отпаравки запросов на сервер 
Функция ПолучитьТокенДоступа() Экспорт

	ТокенДоступа = "";
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	QWEP_AccessTokenСрезПоследних.token КАК token,
	               |	QWEP_AccessTokenСрезПоследних.type КАК type
	               |ИЗ
	               |	РегистрСведений.QWEP_AccessToken.СрезПоследних КАК QWEP_AccessTokenСрезПоследних";
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		ТокенДоступа = Выборка.type + " " + Выборка.token;
	КонецЕсли;
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Сообщить("Для выполнения запросов к QWEP API получите токен доступа", СтатусСообщения.Важное);
	КонецЕсли;
	Возврат ТокенДоступа;

КонецФункции

// Создает новые или обновляет по ID элементы справочника Регионы
Процедура СоздатьОбновитьРегионы(МассивРегионов) Экспорт

	//Можно оптимизировать через запрос, в который на вход подать весь массив, но смысла большого нет, так как записей мало
	Для каждого Строка Из МассивРегионов Цикл
		Регион = Справочники.QWEP_Регионы.НайтиПоКоду(Строка.id);
		Если НЕ ЗначениеЗаполнено(Регион) Тогда
			Регион = Справочники.QWEP_Регионы.СоздатьЭлемент();
			Регион.Код = Строка.id;
			Регион.Наименование = Строка.title;
		    Регион.Записать();
		ИначеЕсли НЕ Регион.Наименование = Строка.title Тогда
			Регион = Регион.ПолучитьОбъект();
			Регион.Наименование = Строка.title;
		    Регион.Записать();
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры // СоздатьОбновитьРегионы()


// Создает новые или обновляет по ID элементы справочника Города
Процедура СоздатьОбновитьГорода(МассивГородов) Экспорт

	//Можно оптимизировать через запрос, в который на вход подать весь массив, но смысла большого нет, так как записей мало
	Для каждого Строка Из МассивГородов Цикл
		Город = Справочники.QWEP_Города.НайтиПоКоду(Строка.id);
		Если НЕ ЗначениеЗаполнено(Город) Тогда
			Город = Справочники.QWEP_Города.СоздатьЭлемент();
			Город.Код = Строка.id;
			Город.Наименование = Строка.title;
			Город.Регион = Справочники.QWEP_Регионы.НайтиПоКоду(Строка.rid);
		    Город.Записать();
		ИначеЕсли НЕ Город.Наименование = Строка.title Тогда
			Город = Город.ПолучитьОбъект();
			Город.Наименование = Строка.title;
			Город.Регион = Справочники.QWEP_Регионы.НайтиПоКоду(Строка.rid);
		    Город.Записать();
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры // СоздатьОбновитьРегионы()

// Создает новые или обновляет по ID элементы справочника Поставщики
Процедура СоздатьОбновитьПоставщиков(МассивЭлементов) Экспорт

	Для каждого Строка Из МассивЭлементов Цикл
		Поставщик = Справочники.QWEP_Поставщики.НайтиПоКоду(Строка.id);
		Если НЕ ЗначениеЗаполнено(Поставщик) Тогда
			Поставщик = Справочники.QWEP_Поставщики.СоздатьЭлемент();
		Иначе
			Поставщик = Поставщик.ПолучитьОбъект();
		КонецЕсли;
			Поставщик.Код = Строка.id;
			Поставщик.Наименование = Строка.title;
			Поставщик.Сайт = Строка.site;
			Поставщик.ДопПараметрыАвторизации = Строка.parameters;
			Поставщик.Города.Очистить();
			Если НЕ Строка.cities = Неопределено Тогда
				Для каждого СтрокаГород Из Строка.cities Цикл
					НоваяСтрока = Поставщик.Города.Добавить();
					НоваяСтрока.Город = Справочники.QWEP_Города.НайтиПоКоду(СтрокаГород.id);
				КонецЦикла;
			КонецЕсли;
		    Поставщик.Записать();
			Если НЕ Строка.branches = Неопределено Тогда
				Для каждого СтрокаФилиал Из Строка.branches Цикл
					Филиал = Справочники.QWEP_ФилиалыПоставщиков.НайтиПоКоду(СтрокаФилиал.id);
					Если НЕ ЗначениеЗаполнено(Филиал) Тогда
						Филиал = Справочники.QWEP_ФилиалыПоставщиков.СоздатьЭлемент();
					Иначе
						Филиал = Филиал.ПолучитьОбъект();
					КонецЕсли;
					Филиал.Код = СтрокаФилиал.id;
					Филиал.Наименование = СтрокаФилиал.title;
					Филиал.Сайт = СтрокаФилиал.site;
					Филиал.Поставщик = Поставщик.Ссылка;
					Филиал.Записать();
				КонецЦикла;
			КонецЕсли;
	КонецЦикла;

КонецПроцедуры // СоздатьОбновитьРегионы()

// Создает новые или обновляет по ID элементы справочника Аккаунты
Процедура СоздатьОбновитьАккаунты(МассивЭлементов) Экспорт
	
	Для каждого Строка Из МассивЭлементов Цикл
		Аккаунт = Справочники.QWEP_Аккаунты.НайтиПоКоду(Строка.id);
		Если НЕ ЗначениеЗаполнено(Аккаунт) Тогда
			Аккаунт = Справочники.QWEP_Аккаунты.СоздатьЭлемент();
		Иначе
			Аккаунт = Аккаунт.ПолучитьОбъект();
		КонецЕсли;
		Аккаунт.Код = Строка.id;
		//Аккаунт.Наименование = Строка.title;
		Аккаунт.Поставщик = Справочники.QWEP_Поставщики.НайтиПоКоду(Строка.vid);
		Аккаунт.Филиал = Справочники.QWEP_ФилиалыПоставщиков.НайтиПоКоду(Строка.bid);
		Аккаунт.Логин = Строка.login;
		Аккаунт.ДопПараметрыАвторизации = Строка.parameters;
		Аккаунт.Промо = Строка.promo;
		Аккаунт.Включен = Строка.enabled;
	    Аккаунт.Записать();
	КонецЦикла;
	
КонецПроцедуры

// Добавляет новые записи в рс РезультатыПоиска
Процедура СоздатьЗаписиРСРезультатыПоиска(ОтветОбъект, ИдентификаторПоиска, ПараметрыЗапроса, ОчищатьРезультаты=Истина) Экспорт

	Если ОчищатьРезультаты Тогда
		НаборЗаписей = РегистрыСведений.QWEP_РезультатыПоиска.СоздатьНаборЗаписей();
		НаборЗаписей.Записать();
	КонецЕсли;
	
	МассивРезультатов = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.flatResults.items");
	МассивУточнений   = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.flatResults.clarifications");
	Если МассивРезультатов = Неопределено И МассивУточнений = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ПараметрыЗапроса.Свойство("article") Тогда
		АртикулПоиска = ПараметрыЗапроса.article;
	КонецЕсли;
	Если ПараметрыЗапроса.Свойство("brand") Тогда
		БрендПоиска = ПараметрыЗапроса.brand;	
	КонецЕсли;
	
	ДатаПоиска = ТекущаяДата();
	Если НЕ МассивРезультатов = Неопределено Тогда
		Для каждого Строка Из МассивРезультатов Цикл
			НоваяЗапись = РегистрыСведений.QWEP_РезультатыПоиска.СоздатьМенеджерЗаписи();
			НоваяЗапись.ИдентификаторПоиска = ИдентификаторПоиска;
			НоваяЗапись.АртикулПоиска 	= АртикулПоиска; 
			НоваяЗапись.БрендПоиска 	= БрендПоиска;
			НоваяЗапись.ДатаПоиска 		= ДатаПоиска;
			НоваяЗапись.ИдентификаторСтроки = Строка.itemId;
			
			НоваяЗапись.Артикул = Строка.article;
			НоваяЗапись.Филиал = Строка.branchTitle;
			НоваяЗапись.Бренд = Строка.brand;
			НоваяЗапись.Срок = Строка.delivery;
			НоваяЗапись.ДопИнфо = Строка.notes;
			НоваяЗапись.АртикулПоставщика = Строка.originalArticle;
			НоваяЗапись.Фото = Строка.photo;
			НоваяЗапись.ЦенаЗначение = Строка.price.value;
			НоваяЗапись.НаличиеФормат = Строка.quantity.formatted;
			НоваяЗапись.Состояние = Строка.status;
			НоваяЗапись.Метро = Строка.subway;
			НоваяЗапись.Наименование = Строка.title;
			НоваяЗапись.Поставщик = Строка.vendorTitle;
			НоваяЗапись.Склад = Строка.warehouse;
            НоваяЗапись.Действие = ?(НЕ ПустаяСтрока(Строка.itemId), "Купить", "");
			
			НоваяЗапись.Записать();
		КонецЦикла;
	КонецЕсли;
	                       
	Если НЕ МассивУточнений = Неопределено Тогда
		Для каждого Строка Из МассивУточнений Цикл
			НоваяЗапись = РегистрыСведений.QWEP_РезультатыПоиска.СоздатьМенеджерЗаписи();
			НоваяЗапись.ИдентификаторПоиска = ИдентификаторПоиска;
			НоваяЗапись.АртикулПоиска 	= АртикулПоиска; 
			НоваяЗапись.БрендПоиска 	= БрендПоиска;
			НоваяЗапись.ДатаПоиска 		= ДатаПоиска;
            НоваяЗапись.ИдентификаторСтроки = Строка.clarificationId;
			
			НоваяЗапись.Артикул = Строка.article;
			НоваяЗапись.ИдентификаторУточнения = Строка.clarificationId;
			НоваяЗапись.Бренд = Строка.brand;
			НоваяЗапись.ДопИнфо = Строка.notes;
			НоваяЗапись.Фото = Строка.photo;
			НоваяЗапись.Наименование = Строка.title;
			НоваяЗапись.Поставщик = Строка.vendorTitle;
			НоваяЗапись.ЭтоУточнение = Истина;
			НоваяЗапись.Действие = "Раскрыть уточнение";
			
			НоваяЗапись.Записать();
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры


Функция ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа=Неопределено) Экспорт

	СтуктураЗапроса = Новый Структура;
	СтруктураДанные = Новый Структура;
	СтруктураДанные.Вставить("RequestData", ПараметрыЗапроса);
	СтуктураЗапроса.Вставить("Request", СтруктураДанные);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();	
	ЗаписатьJSON(ЗаписьJSON, СтуктураЗапроса);
	ТелоЗапроса = ЗаписьJSON.Закрыть();
	Соединение = Новый HTTPСоединение("userapi.qwep.ru",,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	Запрос = Новый HTTPЗапрос;
	Запрос.АдресРесурса = АдресРесурса;
	Если НЕ ПустаяСтрока(ТокенДоступа) Тогда
		Запрос.Заголовки.Вставить("Authorization", ТокенДоступа);
	КонецЕсли;
	Запрос.УстановитьТелоИзСтроки(ТелоЗапроса);
	Ответ = Соединение.ОтправитьДляОбработки(Запрос);
	ТелоОтвета = Ответ.ПолучитьТелоКакСтроку();
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(ТелоОтвета);
	ОтветОбъект = ПрочитатьJSON(ЧтениеJSON);
	Возврат ОтветОбъект;

КонецФункции

Функция ПолучитьЗначениеСвойстваОбъектаСтруктуры(Структура, ПолноеИмяСвойства)

	Если НЕ ТипЗнч(Структура) = Тип("Структура") Тогда
		Возврат Неопределено;
	КонецЕсли;
	ПозицияПервойТочки = Найти(ПолноеИмяСвойства, ".");
	Если ПозицияПервойТочки > 0 Тогда
		ИмяСвойства = Лев(ПолноеИмяСвойства, ПозицияПервойТочки - 1);
		ИмяСвойстваХвост = Сред(ПолноеИмяСвойства, ПозицияПервойТочки + 1);
	Иначе
		ИмяСвойства = ПолноеИмяСвойства;
		ИмяСвойстваХвост = "";
	КонецЕсли;
	СвойствоСтруктуры = Структура.Свойство(ИмяСвойства);
	Если СвойствоСтруктуры = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	НовыйСтруктура = Структура[ИмяСвойства];
	Если ПустаяСтрока(ИмяСвойстваХвост) Тогда
		Если ТипЗнч(НовыйСтруктура) = Тип("Строка") Тогда
			Если НовыйСтруктура = "true" Тогда
				НовыйСтруктура = Истина;
			ИначеЕсли НовыйСтруктура = "false" Тогда
				НовыйСтруктура = Ложь;
			КонецЕсли;
		КонецЕсли;
		Возврат НовыйСтруктура;
	Иначе
		Возврат ПолучитьЗначениеСвойстваОбъектаСтруктуры(НовыйСтруктура, ИмяСвойстваХвост);
	КонецЕсли;
	
КонецФункции

Функция ПолучитьЗначениеКонстанты(ИмяКонстанты) Экспорт

	Если ПустаяСтрока(ИмяКонстанты) Тогда
		Возврат Неопределено;
	КонецЕсли;
	Возврат Константы[ИмяКонстанты].Получить();

КонецФункции

Функция ПолучитьМассивАккаунтовДляПоиска() Экспорт
    
    мАккаунтов = Новый Массив;
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
    |	QWEP_Аккаунты.Код КАК Код
    |ИЗ
    |	Справочник.QWEP_Аккаунты КАК QWEP_Аккаунты
    |ГДЕ
    |	QWEP_Аккаунты.УчаствуетВПоиске";
    мКодовАккаунтов = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Код");
    Для каждого КодАккаунта Из мКодовАккаунтов Цикл
        мАккаунтов.Добавить(Новый Структура("id", КодАккаунта));
    КонецЦикла;
    Возврат мАккаунтов;
    
КонецФункции

Процедура УдалитьСтрокуРСРезультатыПоиска(ИдентификаторСтроки) Экспорт
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |   QWEP_РезультатыПоиска.ИдентификаторПоиска КАК ИдентификаторПоиска,
        |   QWEP_РезультатыПоиска.АртикулПоиска КАК АртикулПоиска,
        |   QWEP_РезультатыПоиска.БрендПоиска КАК БрендПоиска,
        |   QWEP_РезультатыПоиска.ДатаПоиска КАК ДатаПоиска,
        |   QWEP_РезультатыПоиска.ИдентификаторСтроки КАК ИдентификаторСтроки
        |ИЗ
        |   РегистрСведений.QWEP_РезультатыПоиска КАК QWEP_РезультатыПоиска
        |ГДЕ
        |   QWEP_РезультатыПоиска.ИдентификаторСтроки = &ИдентификаторСтроки";
    
    Запрос.УстановитьПараметр("ИдентификаторСтроки", ИдентификаторСтроки);
    
    РезультатЗапроса = Запрос.Выполнить();
    
    РезультатЗапроса = РезультатЗапроса.Выгрузить();
    
    Для каждого Запись Из РезультатЗапроса Цикл
    
        СтрокаКУдалению = РегистрыСведений.QWEP_РезультатыПоиска.СоздатьМенеджерЗаписи();            
        ЗаполнитьЗначенияСвойств(СтрокаКУдалению, Запись);
        СтрокаКУдалению.Прочитать();
        Если СтрокаКУдалению.Выбран() Тогда                	
            СтрокаКУдалению.Удалить();        
        КонецЕсли;                     	
    
    КонецЦикла;
        
КонецПроцедуры
 
