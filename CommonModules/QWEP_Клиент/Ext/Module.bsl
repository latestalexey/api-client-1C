﻿// Получает или обновляет элементы справочника Регионы из QWEP API
Процедура ПолучитьРегионы() Экспорт
	
	ТокенДоступа = ПолучитьТокенДоступа();
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Возврат;
	КонецЕсли;
	ПараметрыЗапроса = Новый Структура;
	АдресРесурса = "/geo/regions";
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "RegionsResponse");
    ПроверитьВывестиОшибки(ОтветОбъект);
	МассивЭлементов = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.regions");
	Если НЕ ТипЗнч(МассивЭлементов) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	Если МассивЭлементов.Количество() > 0 Тогда
		QWEP_Сервер.СоздатьОбновитьРегионы(МассивЭлементов);
	КонецЕсли;
	
КонецПроцедуры

// Возвращает ТокенДоступа для возможности отпаравки запросов на сервер 
Функция ПолучитьТокенДоступа() Экспорт
	
	Возврат QWEP_Сервер.ПолучитьТокенДоступа();			
	
КонецФункции

// Получает новый Access Token по указанному authorizationCode и добавляет запись в рс
Процедура ПолучитьAccessToken(authorizationCode, ДополнительныеПараметры) Экспорт
	
	Если ПустаяСтрока(authorizationCode) Тогда
		Возврат;
	КонецЕсли;
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("authorizationCode", authorizationCode);
	ПараметрыЗапроса.Вставить("applicationNum", 1);
	
	АдресРесурса = "/authorization";
	
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса,, "AuthorizationResponse");
	Если ОтветОбъект = Неопределено Тогда
		Возврат;	
    КонецЕсли;
    ПроверитьВывестиОшибки(ОтветОбъект);
	//Добавить проверку на наличие ошибок
    //СписокОшибок = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "errors");    
    //Если НЕ СписокОшибок = Неопределено Тогда
    //    Для каждого СтрокаОшибки Из СписокОшибок Цикл
    //        Сообщить("Ошибка: " +  СтрокаОшибки.code + " " + СтрокаОшибки.message);
    //	КонецЦикла;
    //	Возврат;
    //КонецЕсли;				    
    ОтветСтруктура = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity"); 
	Если ОтветСтруктура = Неопределено Тогда
		Возврат;
	КонецЕсли;
    QWEP_Сервер.СоздатьНовуюЗаписьAccessToken(authorizationCode, ОтветСтруктура);     
    
    Если ТипЗнч(ДополнительныеПараметры) = Тип("Структура") И ДополнительныеПараметры.Свойство("ТокенУспешноПолучен") Тогда        	
        ДополнительныеПараметры.ТокенУспешноПолучен = Истина;    
    КонецЕсли; 
    
КонецПроцедуры

// Проверяет ответ на наличие ошибок и выводит их 
Процедура ПроверитьВывестиОшибки(ОтветОбъект)
    
    МассивОшибок = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "errors");
    Если ТипЗнч(МассивОшибок) = Тип("Массив") Тогда        	
        Для каждого Элемент Из МассивОшибок Цикл                	            
            Сообщить("Ошибка: " +  Элемент.code + " " + Элемент.message);
        КонецЦикла; 
    КонецЕсли;	

КонецПроцедуры
 

// Возвращает объект(структуру) ответа от сервера API на запрос
Функция ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа=Неопределено, ИмяОбъектаОтвета)
	
	Формат = QWEP_Сервер.ПолучитьЗначениеКонстанты("QWEP_ФорматОбменаДанными");
	Если ПустаяСтрока(Формат) Тогда
		Сообщить("Заполните константу 'Формат обмена данными' (Разлел Сервис)");
		Возврат Неопределено;
	КонецЕсли;
	
	#Если ВебКлиент Тогда
		
		Возврат QWEP_Сервер.ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, Формат);
		
	#Иначе	
		
		Соединение = Новый HTTPСоединение("userapi.qwep.ru",,,,,,Новый ЗащищенноеСоединениеOpenSSL());
		Запрос = Новый HTTPЗапрос;
		Запрос.АдресРесурса = АдресРесурса + "?" + Формат;
		Если НЕ ПустаяСтрока(ТокенДоступа) Тогда
			Запрос.Заголовки.Вставить("Authorization", ТокенДоступа);
		КонецЕсли;
		ТелоЗапроса = ПолучитьТелоЗапросаUSERAPI(ПараметрыЗапроса, Формат);
		Запрос.УстановитьТелоИзСтроки(ТелоЗапроса);
		Ответ = Соединение.ОтправитьДляОбработки(Запрос);
		ТелоОтвета = Ответ.ПолучитьТелоКакСтроку();
		
		ОтветОбъект = ПолучитьОбъектОтвет(ТелоОтвета, ИмяОбъектаОтвета, Формат);
		
		Возврат ОтветОбъект;
		
	#КонецЕсли
	
КонецФункции

//Возвращет Заполненное тело запроса для отправки на USERAPI
Функция ПолучитьТелоЗапросаUSERAPI(ПараметрыЗапроса, Формат)
	
	Если ПараметрыЗапроса.Количество() = 0 Тогда
		Возврат "";
	КонецЕсли;
	
	Если Формат = "xml" Тогда
		ЗаписьXML = Новый ЗаписьXML;
		ЗаписьXML.УстановитьСтроку();
		ЗаписьXML.ЗаписатьОбъявлениеXML();
		
		ЗаписьXML.ЗаписатьНачалоЭлемента("Request");
		ЗаписьXML.ЗаписатьНачалоЭлемента("RequestData");
		
		ДобавитьСтруктуруАргументовВXML(ЗаписьXML, ПараметрыЗапроса);
		
		ЗаписьXML.ЗаписатьКонецЭлемента();//RequestData
		ЗаписьXML.ЗаписатьКонецЭлемента();//Request
		
		ТелоЗапроса = ЗаписьXML.Закрыть();
	ИначеЕсли Формат = "json" Тогда
		СтуктураЗапроса = Новый Структура;
		СтруктураДанные = Новый Структура;
		СтруктураДанные.Вставить("RequestData", ПараметрыЗапроса);
		СтуктураЗапроса.Вставить("Request", СтруктураДанные);
		
		ЗаписьJSON = Новый ЗаписьJSON;
		ЗаписьJSON.УстановитьСтроку();	
		ЗаписатьJSON(ЗаписьJSON, СтуктураЗапроса);
		ТелоЗапроса = ЗаписьJSON.Закрыть();
	Иначе//Неизвестный формат
		Возврат "";
	КонецЕсли;
	
	Возврат ТелоЗапроса;
	
КонецФункции

Процедура ДобавитьСтруктуруАргументовВXML(ЗаписьXML, СтруктураАргументов)
	
	Для каждого Аргумент Из СтруктураАргументов Цикл
		ЗаписьXML.ЗаписатьНачалоЭлемента(Аргумент.Ключ);
		Если ТипЗнч(Аргумент.Значение) = Тип("Массив") Тогда
			Для каждого СтрокаКоллекции Из Аргумент.Значение Цикл
				ДобавитьСтруктуруАргументовВXML(ЗаписьXML, СтрокаКоллекции);
			КонецЦикла;
		ИначеЕсли ТипЗнч(Аргумент.Значение) = Тип("Структура") Тогда
			ДобавитьСтруктуруАргументовВXML(ЗаписьXML, Аргумент.Значение);
		Иначе
			ЗаписьXML.ЗаписатьТекст(XMLСтрока(Аргумент.Значение));
		КонецЕсли;
		ЗаписьXML.ЗаписатьКонецЭлемента();
	КонецЦикла;
	
КонецПроцедуры

//Возвращает новый(пустой) ОбъектXDTO полученный по имени из схемы XSD
Функция ПолучитьОбъектОтвет(ТелоОтвета, ИмяОбъекта, Формат) Экспорт
	
	//Попытка
	Если Формат = "xml" Тогда
		ТекущаяФабрика = СоздатьФабрикуXDTO("http://soap.userapi.qwep.ru/?wsdl&schemaOnly");
		//ТекущаяФабрика = СоздатьФабрикуXDTO("c:\Downloads\xml1.xml");
		ТипОтвета = ТекущаяФабрика.Тип("http://qwep.ru/soap.php/XSD", ИмяОбъекта);
        ЧтениеXML = Новый ЧтениеXML;
        ЧтениеXML.УстановитьСтроку(ТелоОтвета);
        ОтветОбъект = ТекущаяФабрика.ПрочитатьXML(ЧтениеXML, ТипОтвета);
		ОтветОбъект = ОбъектXDTOвСтруктуру(ОтветОбъект);
	ИначеЕсли Формат = "json" Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(ТелоОтвета);
		ОтветОбъект = ПрочитатьJSON(ЧтениеJSON);
		ОтветОбъект = ОтветОбъект.Response;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	Возврат ОтветОбъект;
	//Исключение
	//	Сообщить("Ошибка получения объекта XDTO: " + ИмяОбъекта);
	//	Возврат Неопределено;
	//КонецПопытки;
	
КонецФункции

//Возвращает структуру полученную из объекта XDTO
Функция ОбъектXDTOвСтруктуру(Знач ОбъектXDTO)

	ОтветСтруктура = Новый Структура;
	Для каждого Свойство Из ОбъектXDTO.Свойства() Цикл
		//Вложенный объект
		Если ТипЗнч(ОбъектXDTO[Свойство.Имя]) = Тип("ОбъектXDTO") Тогда
			Значение = ОбъектXDTOвСтруктуру(ОбъектXDTO[Свойство.Имя]);
			Если ТипЗнч(Значение) = Тип("Структура") И Значение.Количество() = 1 Тогда
				Для каждого СвойствоСтурктуры Из Значение Цикл
					Если ТипЗнч(СвойствоСтурктуры.Значение) = Тип("Массив") И СвойствоСтурктуры.Ключ = "item" Тогда
						Значение = СвойствоСтурктуры.Значение;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
			ОтветСтруктура.Вставить(Свойство.Имя, Значение);
		//Коллекция	
		ИначеЕсли ТипЗнч(ОбъектXDTO[Свойство.Имя]) = Тип("СписокXDTO") Тогда
			мЭлементов = Новый Массив;
			Для каждого Элемент Из ОбъектXDTO[Свойство.Имя] Цикл
				мЭлементов.Добавить(ОбъектXDTOвСтруктуру(Элемент));
			КонецЦикла;
			Если мЭлементов.Количество() > 0 Тогда
				ОтветСтруктура.Вставить(Свойство.Имя, мЭлементов);
			КонецЕсли;
		Иначе//Примитивные типы
			ОтветСтруктура.Вставить(Свойство.Имя, ОбъектXDTO[Свойство.Имя]);	
		КонецЕсли;
	КонецЦикла;
	Возврат ОтветСтруктура;
	
КонецФункции

// Получает или обновляет элементы справочника Города из QWEP API
Процедура ПолучитьГорода() Экспорт
	
	ТокенДоступа = ПолучитьТокенДоступа();
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Возврат;
	КонецЕсли;
	ПараметрыЗапроса = Новый Структура;
	АдресРесурса = "/geo/cities";
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "CitiesResponse");
    ПроверитьВывестиОшибки(ОтветОбъект);
    МассивЭлементов = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.cities");
	Если НЕ ТипЗнч(МассивЭлементов) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	Если МассивЭлементов.Количество() > 0 Тогда
		QWEP_Сервер.СоздатьОбновитьГорода(МассивЭлементов);
	КонецЕсли;
	
КонецПроцедуры

// Получает или обновляет элементы справочника Поставщики из QWEP API
Процедура ПолучитьПоставщиков() Экспорт
	
	ТокенДоступа = ПолучитьТокенДоступа();
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Возврат;
	КонецЕсли;
	ПараметрыЗапроса = Новый Структура;
	АдресРесурса = "/vendors";
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "VendorsResponse");
	Если ОтветОбъект = Неопределено Тогда
		Возврат;	
    КонецЕсли;
    ПроверитьВывестиОшибки(ОтветОбъект);
	МассивЭлементов = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.vendors");
	//МассивЭлементов = ОтветСтруктура.vendors;
	Если НЕ ТипЗнч(МассивЭлементов) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	Если МассивЭлементов.Количество() > 0 Тогда
		QWEP_Сервер.СоздатьОбновитьПоставщиков(МассивЭлементов);
	КонецЕсли;
	
КонецПроцедуры

// Активирует аккаунт и получает код аккаунта на QWEP AP 
Функция ПолучитьКодАктивированногоАккаунта(ВхСтруктураПараметров=Неопределено) Экспорт
	
	Если ВхСтруктураПараметров = Неопределено Тогда
		Возврат "";
	КонецЕсли;
	ТокенДоступа = ПолучитьТокенДоступа();
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Возврат "";
	КонецЕсли;
	мАккаунтов = Новый Массив();
	мАккаунтов.Добавить(ВхСтруктураПараметров);
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("accounts", мАккаунтов);
	АдресРесурса = "accounts/add";
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "AccountsAddResponse");
	//Если ОтветОбъект = Неопределено Тогда
	//	Возврат;	
	//КонецЕсли;
	//Добавить проверку на наличие ошибок
    ПроверитьВывестиОшибки(ОтветОбъект);
	ОтветМассив = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.accounts"); 
	Если НЕ ТипЗнч(ОтветМассив) = Тип("Массив") ИЛИ ОтветМассив.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	ОтветСтруктура = ОтветМассив[0];
	//Если НЕ ОтветСтруктура.Свойство("id") Тогда
	//	Возврат;
	//КонецЕсли;
	
	Возврат ОтветСтруктура.id;	
	
КонецФункции

// Получает или обновляет элементы справочника Аккаунты из QWEP API
Процедура ПолучитьАккаунты() Экспорт
	
	ТокенДоступа = ПолучитьТокенДоступа();
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Возврат;
	КонецЕсли;
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("excludePromo", Истина);
	ПараметрыЗапроса.Вставить("excludeDisabled", Истина);
	АдресРесурса = "/accounts/get";
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "AccountsGetResponse");
	Если ОтветОбъект = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	//Добавить проверку на наличие ошибок
    ПроверитьВывестиОшибки(ОтветОбъект);
	МассивЭлементов = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.accounts");
	Если НЕ ТипЗнч(МассивЭлементов) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	Если МассивЭлементов.Количество() > 0 Тогда
		QWEP_Сервер.СоздатьОбновитьАккаунты(МассивЭлементов);
	КонецЕсли;
	
КонецПроцедуры

// Возвращает значение свойства объекта XDTO по полному имени свойства (старый вариант), актуальная процедура ПолучитьЗначениеСвойстваОбъектаСтруктуры
Функция ПолучитьЗначениеСвойстваОбъектаXDTO(ОбъектXDTO, ПолноеИмяСвойства)
	
	Если НЕ ТипЗнч(ОбъектXDTO) = Тип("ОбъектXDTO") Тогда
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
	СвойствоОбъектаXDTO = ОбъектXDTO.Свойства().Получить(ИмяСвойства);
	Если СвойствоОбъектаXDTO = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	НовыйОбъектXDTO = ОбъектXDTO[ИмяСвойства];
	Если ПустаяСтрока(ИмяСвойстваХвост) Тогда
		Если ТипЗнч(НовыйОбъектXDTO) = Тип("Строка") Тогда
			Если НовыйОбъектXDTO = "true" Тогда
				НовыйОбъектXDTO = Истина;
			ИначеЕсли НовыйОбъектXDTO = "false" Тогда
				НовыйОбъектXDTO = Ложь;
			КонецЕсли;
		КонецЕсли;
		Возврат НовыйОбъектXDTO;
	Иначе
		Возврат ПолучитьЗначениеСвойстваОбъектаXDTO(НовыйОбъектXDTO, ИмяСвойстваХвост);
	КонецЕсли;
	
КонецФункции

// Возвращает значение свойства структуры по полному имени свойства
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

// Выплняет поиск на API QWEP
Процедура ВыполнитьПоиск(ПараметрыЗапроса, ИдентификаторПоиска, НетТокена=Ложь) Экспорт	    
    
    ТокенДоступа = ПолучитьТокенДоступа();
    Если ПустаяСтрока(ТокенДоступа) Тогда
        НетТокена = Истина; 
        Возврат;
    КонецЕсли;
	
	УдалитьПустыеЗначенияВСтуктуре(ПараметрыЗапроса);
    
    Состояние("Идет поиск по поставщикам", 0);
	//На текущий момент нет возможности включить/выключить аккаунт на сервере, поэтому состояние храним на клиенте(в базе)
	мАкканутовДляПоиска = QWEP_Сервер.ПолучитьМассивАккаунтовДляПоиска();
	Если мАкканутовДляПоиска.Количество() > 0 Тогда
		ПараметрыЗапроса.Вставить("accounts", мАкканутовДляПоиска);
	КонецЕсли;
	
	АдресРесурса = "/search";
    
    Состояние("Идет поиск по поставщикам", 25);
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "SearchResponse");
	Если ОтветОбъект = Неопределено Тогда
		Возврат;	
    КонецЕсли;
    ПроверитьВывестиОшибки(ОтветОбъект); 
    
    Состояние("Идет поиск по поставщикам", 50);
	ИдентификаторПоиска = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.searchId");
	Если ИдентификаторПоиска = Неопределено Тогда
		Возврат;	
	КонецЕсли;
    
    Состояние("Идет поиск по поставщикам", 75);
	//МассивЭлементов = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.flatResults.items");
	QWEP_Сервер.СоздатьЗаписиРСРезультатыПоиска(ОтветОбъект, ИдентификаторПоиска, ПараметрыЗапроса);
    Состояние("Идет поиск по поставщикам", 100);
    
КонецПроцедуры

// Раскрывает уточнение
Процедура РаскрытьУточнение(ПараметрыЗапроса) Экспорт

    ТокенДоступа = ПолучитьТокенДоступа();
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Возврат;
	КонецЕсли;
	
	УдалитьПустыеЗначенияВСтуктуре(ПараметрыЗапроса);		
	
	АдресРесурса = "/search";
	
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "SearchResponse");
	Если ОтветОбъект = Неопределено Тогда
		Возврат;	
    КонецЕсли;
    ПроверитьВывестиОшибки(ОтветОбъект);
    
    ИдентификаторПоиска = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.searchId");
	Если ИдентификаторПоиска = Неопределено Тогда
		Возврат;	
	КонецЕсли;
    
    QWEP_Сервер.СоздатьЗаписиРСРезультатыПоиска(ОтветОбъект, ИдентификаторПоиска, ПараметрыЗапроса, Ложь);

КонецПроцедуры

// Добавляет в корзину поставщика на сайте
Функция ДобавитьВКорзину(ПараметрыЗапроса) Экспорт
    
    ТокенДоступа = ПолучитьТокенДоступа();
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Возврат Неопределено;
	КонецЕсли;
    
    УдалитьПустыеЗначенияВСтуктуре(ПараметрыЗапроса);
    
    АдресРесурса = "/cart/add";
    
    ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "CartAddResponse");
    ПроверитьВывестиОшибки(ОтветОбъект);
    
    СтатусДобавления = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.status");
    Если СтатусДобавления = Неопределено Тогда
        Возврат Неопределено;
    КонецЕсли;
    
    Возврат СтатусДобавления;
    
КонецФункции

// Удаляет элементы структуры с пустым значением
Процедура УдалитьПустыеЗначенияВСтуктуре(Структура)            
    
    Для каждого Строка Из Структура Цикл
        Если НЕ ЗначениеЗаполнено(Строка.Значение) Тогда
            Структура.Удалить(Строка.Ключ);
        КонецЕсли;
    КонецЦикла;
    
КонецПроцедуры 
 
// Возвращает часть готовых результатов, подготовленных на API QWEP после поиска
Процедура ПолучитьГотовуюПорциюРезультатов(ПараметрыЗапроса, ИдентификаторПоиска, ОчищатьРезультаты, ПоискЗавершен) Экспорт
	
	ТокенДоступа = ПолучитьТокенДоступа();
	Если ПустаяСтрока(ТокенДоступа) Тогда
		Возврат;
	КонецЕсли;
	
	АдресРесурса = "/search/updates";
	
	ОтветОбъект = ПолучитьОтветНаЗапросОтAPI(АдресРесурса, ПараметрыЗапроса, ТокенДоступа, "SearchUpdatesResponse");
	Если ОтветОбъект = Неопределено Тогда
		Возврат;	
    КонецЕсли;
    ПроверитьВывестиОшибки(ОтветОбъект);
	
	ИдентификаторПоиска = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.searchId");
	Если ИдентификаторПоиска = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	
	ПоискЗавершен = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.finished"); 
	
	//МассивЭлементов = ПолучитьЗначениеСвойстваОбъектаСтруктуры(ОтветОбъект, "entity.flatResults.items");
	QWEP_Сервер.СоздатьЗаписиРСРезультатыПоиска(ОтветОбъект, ИдентификаторПоиска, ПараметрыЗапроса, ОчищатьРезультаты);
	Если ПоискЗавершен Тогда
		ИдентификаторПоиска = "";
	КонецЕсли;
	
КонецПроцедуры
