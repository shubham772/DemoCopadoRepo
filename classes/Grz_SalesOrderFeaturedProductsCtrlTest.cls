@isTest
public class Grz_SalesOrderFeaturedProductsCtrlTest {
    private Static String  SO_id='';
    @testSetup static void setup() {
        Test.startTest();
        Id recordTypeId1 = Schema.SObjectType.Sales_Order__c.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId(); 
        Id recordTypeId = Schema.SObjectType.Sales_Order__c.getRecordTypeInfosByName().get('Simulation').getRecordTypeId();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        
        Profile p =  [SELECT Id FROM Profile WHERE Name = 'Brazil Sales Person' LIMIT 1];
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Brazil Sales Office Manager' LIMIT 1];
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Brazil Sales Director' LIMIT 1];
        Profile p3 = [SELECT Id FROM Profile WHERE Name = 'Brazil Sales District Manager' LIMIT 1];
        Profile p4 = [SELECT Id FROM Profile WHERE Name = 'Brazil Customer Service User' LIMIT 1];
        Profile p5 = [SELECT Id FROM Profile WHERE Name = 'Brazil Barter Manager' LIMIT 1]; 
        Profile p6 = [SELECT Id FROM Profile WHERE Name = 'Brazil Sales Price Admin' LIMIT 1];
        
        Trigger_Settings__c newtri = new Trigger_Settings__c();
        newtri.Name = 'SOLICombKeyTrigger';
        newtri.isActive__c = true;
        insert newtri;
        
        Trigger_Settings__c trig = new Trigger_Settings__c();
        trig.Name = 'salesOrderShareTriger';
        trig.isActive__c = true;
        insert trig;
        
        Sales_Org__c sorg = new Sales_Org__c();
        sorg.Name = 'Brazil';
        sorg.Sales_Org_Code__c = '5191';
        insert sorg;
        
        Crop_Year_Brazil__c cy = new Crop_Year_Brazil__c();
        cy.Crop_Year__c = '25/26';
        insert cy;
        
        Depot__c dep = new Depot__c(
            Name = 'UPL Do Brasil - Aparecida de Goiania',   // Depot Name
            Country__c = 'Brazil',                           // Country
            Depot_Code__c = 'BR04',                          // Depot Code
            Active__c = true,                                // Active
            SalesOrg__c = sorg.Id                           // Sales Org
        );
        insert dep;
        
        
        
        Auto_Number__c auto = new Auto_Number__c();
        auto.Name = 'FarmerCode';
        auto.Sequence__c = '11';
        insert auto;
        Brazil_Margin_Block__c bmb=new Brazil_Margin_Block__c (name='Margin Block Values',Block_Date__c=System.TODAY().addDays(20),Margin__c=10);
        insert bmb;
        User SBUuser = new User(
            Alias = 'CASSIO',                                                            
            Email = 'shama@skinternational.com',                                          
            ProfileId = p2.Id,                                                           
            Username = '20005676@uniphos5.com.upltest',                                  
            IsActive = true,                                                             
            CommunityNickname = 'XCASSIO',     
            LastName = 'DIRETOR DE', 
            Title = 'DIRETOR DE NEGOCIOS NORTE',                                         
            TimeZoneSidKey = 'America/Sao_Paulo',                      
            LocaleSidKey = 'en_IN',                                                       
            LanguageLocaleKey = 'pt_BR',                                                  
            ForecastEnabled = false,                                                     
            EmailEncodingKey = 'ISO-8859-1',                                            
            Territory__c = 'GESTÃO NORTE',                                               
            EnableDepot__c = false,                                                      
            Show_List_Value__c = true,                                                  
            Show_Credit_LIMIT__c = false,                                               
            Show_Inventory__c = false,                                                 
            Show_Pricing__c = false,                                                     
            Show_Inventory_Column__c = false,                                          
            Show_InTransit__c = false,                                                  
            Show_InTransit_Values__c = false,                                           
            Is_Test_Running__c = true
        );
        
        insert SBUuser;
        
        SBU__c sbu = new SBU__c(
            SBUUser__c = SBUuser.Id,                                                   
            Brazil_SBU_Name__c = 'GESTÃO NORTE',                                       
            SBUCode__c = 'BR1',
            GSD__c =SBUuser.Id,
            REH__c = SBUuser.Id,
            SalesOrg__c = sorg.Id                                                   
        );
        insert sbu;
        
        
        User testUser = new User(
            Alias = 'WES',                                                           
            Email = 'shama786@skinternational.com',                                       
            ProfileId = p6.Id,                                                           
            Username = 'shama786@uniphos3.com.upltest',                                  
            IsActive = true,                                                             
            LastName = 'test', 
            Title = 'RuiR',                                                          
            TimeZoneSidKey = 'America/Sao_Paulo',      
            LocaleSidKey = 'en_IN',                                            
            LanguageLocaleKey = 'pt_BR',                                               
            ForecastEnabled = false,                                                     
            EmailEncodingKey = 'ISO-8859-1',   
            Territory__c = 'Araxá',                                           
            EnableDepot__c = false,                                                  
            Show_List_Value__c = false,                                              
            Show_Credit_LIMIT__c = false,                                              
            Show_Inventory__c = false,                                                
            Show_Pricing__c = false,                                                  
            Show_Inventory_Column__c = false,                                        
            Show_InTransit__c = false,                                                 
            Show_InTransit_Values__c = false , 
            country = 'Brazil',
            Is_Test_Running__c = true
        );
        insert testUser;    
        
        User userTerMan1 = new User(
            Alias = 'WES',                                                            
            Email = 'shama11@skinternational.com',                                         
            ProfileId = p.Id,                                                            
            Username = '20205489@uniphos3.com.upltest',                                   
            IsActive = true,                                                             
            LastName = 'BARBOSA DErCAMARGO', 
            CommunityNickname = 'Xyu ',                                               
            Title = 'RuiR',                                                             
            TimeZoneSidKey = 'America/Sao_Paulo',      
            LocaleSidKey = 'en_IN',                                            
            LanguageLocaleKey = 'pt_BR',                                            
            ForecastEnabled = false,                                                   
            EmailEncodingKey = 'ISO-8859-1',   
            Territory__c = 'Araxá',                                             
            EnableDepot__c = false,                                                  
            Show_List_Value__c = false,                                                  
            Show_Credit_LIMIT__c = false,                                                
            Show_Inventory__c = false,                                                  
            Show_Pricing__c = false,                             
            Show_Inventory_Column__c = false,                                 
            Show_InTransit__c = false,                                               
            Show_InTransit_Values__c = false , 
            country = 'Brazil',
            Is_Test_Running__c = true
        );
        insert userTerMan1;
        
        User userTerManTerri = new User(
            Alias = 'WES',                                                           
            Email = 'userTerManTerri@skinternational.com',                                   
            ProfileId = p.Id,                                                            
            Username = '12320205489@uniphos3.com.upltest',                                  
            IsActive = false,                                                          
            LastName = 'BARBOSA DErCAMARGO Test7', 
            CommunityNickname = 'Xyu Test7 ',                                             
            Title = 'RuiR',                                                          
            TimeZoneSidKey = 'America/Sao_Paulo',      
            LocaleSidKey = 'en_IN',                                            
            LanguageLocaleKey = 'pt_BR',                                         
            ForecastEnabled = false,                                                
            EmailEncodingKey = 'ISO-8859-1',   
            Territory__c = 'Araxá',                                           
            EnableDepot__c = false,                                               
            Show_List_Value__c = false,                                          
            Show_Credit_LIMIT__c = false,                                             
            Show_Inventory__c = false,                                            
            Show_Pricing__c = false,                                            
            Show_Inventory_Column__c = false,                                      
            Show_InTransit__c = false,                                            
            Show_InTransit_Values__c = false , 
            country = 'Brazil',
            Is_Test_Running__c = true
        );
        insert userTerManTerri;
        
        User BarterUser = new User(
            Alias = 'MARCELO',                                                                     
            Email = 'ganesh.chaurasia@skinternational.com',                                         
            ProfileId = p5.Id,                                                                
            Username = '200054786@uniphos.com.upltest',                                           
            IsActive = true,   
            LastName = 'Gavazi', 
            CommunityNickname = 'XMARCELO',   // Nickname
            TimeZoneSidKey = 'America/Sao_Paulo',           
            LocaleSidKey = 'en_IN',                                                
            LanguageLocaleKey = 'pt_BR',                                                     
            ForecastEnabled = false,                                                             
            EmailEncodingKey = 'ISO-8859-1',            
            EnableDepot__c = false,                                                            
            Show_List_Value__c = false,                                                          
            Show_Credit_LIMIT__c = false,                                                        
            Show_Inventory__c = false,                                                          
            Show_Pricing__c = false,                                                              
            Show_Inventory_Column__c = false,                                                     
            Show_InTransit__c = false,                                                           
            Show_InTransit_Values__c = false,
            Is_Test_Running__c = true
        );
        insert BarterUser;
        
        User ZonalHeadUser = new User(
            Alias = 'GERSON',                                                            
            Email = 'shama@skinternational.com',                                         
            ProfileId = p1.Id,                                                            
            Username = '20000679@uniphos6.com.upltest',                                   
            IsActive = true,                                                              
            LastName = 'LUIZ LEVANDOWSKI', 
            CommunityNickname = 'XGERSON ',  
            Title = 'GERENTE SR DE NEGOCIOS',                                          
            TimeZoneSidKey = 'America/Sao_Paulo',      
            LocaleSidKey = 'en_IN',                                      
            LanguageLocaleKey = 'pt_BR',                                                
            ForecastEnabled = false,                                                      
            EmailEncodingKey = 'ISO-8859-1',  
            Zone__c = 'BU MATO GROSSO',                                                 
            EnableDepot__c = false,                                                       
            Show_List_Value__c = true,                                                   
            Show_Credit_LIMIT__c = false,                                                
            Show_Inventory__c = false,                                                 
            Show_Pricing__c = false,                                                     
            Show_Inventory_Column__c = false,                                            
            Show_InTransit__c = false,                                                    
            Show_InTransit_Values__c = false,
            Is_Test_Running__c = true
        );
        insert ZonalHeadUser;
        
        Inventory_Control__c Ic = new Inventory_Control__c();
        Ic.BU__c = '5191';
        Ic.Fiscal_Year__c = '00/00';
        Insert Ic;
        
        
        Zone__c zone =  new Zone__c();
        zone.SalesOrg__c = sorg.Id;
        zone.Name = 'BU MATO GROSSO';
        zone.ZoneCode__c = 'BR10';              
        zone.ZonalHead__c = ZonalHeadUser.Id;
        insert zone;
        
        User regioHeadUser = new User(
            Alias = 'ALEXANDE',                                                            
            Email = 'shama@skinternational.com',                                            
            ProfileId = p3.Id,                                                             
            Username = '20004449@uniphos1.com.upltest',                                      
            IsActive = true,                                                                
            CommunityNickname = 'XALEXANDER',                                                
            LastName = 'PARAGUACU MONTEIRO DE OLIVEIRA', 
            Title = 'GERENTE COMERCIAL',                                                  
            TimeZoneSidKey = 'America/Sao_Paulo',         
            LocaleSidKey = 'en_IN',                                          
            LanguageLocaleKey = 'pt_BR',                                                  
            ForecastEnabled = false,                                                       
            EmailEncodingKey = 'ISO-8859-1',      
            Region__c = 'MATO GROSSO DO SUL',                                               
            EnableDepot__c = false,                                                        
            Show_List_Value__c = true,                                                      
            Show_Credit_LIMIT__c = false,                                                   
            Show_Inventory__c = false,                                                 
            Show_Pricing__c = false,                                                        
            Show_Inventory_Column__c = false,                                               
            Show_InTransit__c = false,                                                    
            Show_InTransit_Values__c = false,
            Is_Test_Running__c = true
        );
        insert regioHeadUser;
        
        User BrazilAnaUser = new User(
            Alias = 'MILENI',                                                                           
            Email = 'shama@skinternational.com',                                                           
            ProfileId = p4.Id,                                                                             
            Username = '20004688@uniphos2.com.upltest',                                                      // Username
            IsActive = true,                                                                                // Active
            CommunityNickname = 'XMILENI .PEREIRA DA SILVA',                                                 // Nickname
            LastName = 'PEREIRA DA SILVA', 
            Title = 'ANALISTA DE CUSTOMER SERVICE PL',                                                      // Title
            TimeZoneSidKey = 'America/Sao_Paulo',                       
            LocaleSidKey = 'en_IN',                                                          
            LanguageLocaleKey = 'pt_BR',                                                                  // Language
            ForecastEnabled = false,                                                                        // Allow Forecasting
            EmailEncodingKey = 'ISO-8859-1',                     
            Territory__c = 'ADMINISTRAÇÃO DE VENDAS',                                                       // Territory
            EnableDepot__c = false,                                                                         // Enable Depot
            Show_List_Value__c = false,                                                                     // Show List Value (Brazil)
            Show_Credit_LIMIT__c = false,                                                                   // Show Credit LIMIT
            Show_Inventory__c = false,                                                                      // Show Inventory
            Show_Pricing__c = false,                                                                        // Show Pricing
            Show_Inventory_Column__c = false,                                                               // Show Inventory Column
            Show_InTransit__c = false,                                                                      // Show InTransit
            Show_InTransit_Values__c = false,                                                              // Show InTransit Values
            Is_Test_Running__c = true
        );
        insert BrazilAnaUser;
        
        Region__c region = new Region__c();
        region.Name = 'MATO GROSSO DO SUL';
        region.RegionCode__c =  'BR1010';
        region.SalesOrg__c = sorg.Id;
        region.Zone__c = zone.Id;
        region.RegionHead__c = regioHeadUser.Id;
        region.BrazilAnalyst__c = BrazilAnaUser.Id;    
        region.SBU__c = sbu.Id;                                                                           
        insert region;
        
        User userTerMan = new User(
            Alias = 'wflav',                                                             // Alias
            Email = 'shama@skinternational.com',                                           // Email
            ProfileId = p.Id,                                                              // Profile
            Username = '20005489@uniphos3.com.upltest',                                     // Username
            IsActive = true,                                                               // Active
            LastName = 'FLAVIO DA SILVA', 
            CommunityNickname = 'XWEDERSON ',                                                // Nickname
            Title = 'RTV JR',                                                              // Title
            TimeZoneSidKey = 'America/Sao_Paulo',      
            LocaleSidKey = 'en_IN',                                            
            LanguageLocaleKey = 'pt_BR',                                                 // Language
            ForecastEnabled = false,                                                       // Allow Forecasting
            EmailEncodingKey = 'ISO-8859-1',   
            Territory__c = 'Araxá',                                              // Territory
            EnableDepot__c = false,                                                        // Enable Depot
            Show_List_Value__c = false,                                                    // Show List Value (Brazil)
            Show_Credit_LIMIT__c = false,                                                  // Show Credit LIMIT
            Show_Inventory__c = false,                                                     // Show Inventory
            Show_Pricing__c = false,                                                       // Show Pricing
            Show_Inventory_Column__c = false,                                              // Show Inventory Column
            Show_InTransit__c = false,                                                     // Show InTransit
            Show_InTransit_Values__c = false,                                             // Show InTransit Values
            Is_Test_Running__c = true
        );
        insert userTerMan;
        
        Territory_Distributor__c territory =  new Territory_Distributor__c();
        territory.Name = 'Araxá';
        territory.TerritoryCode__c = 'BR165';
        territory.SBU__c = sbu.Id;     
        territory.Region__c = region.id;
        territory.SalesOrg__c = sorg.Id;
        territory.RegionDesciption__c = 'BR1001102 CHPS';                       
        territory.Zone__c = zone.Id;
        territory.TerritoryManager__c = userTerMan.Id; //userTerMan
        //territory.TerritoryManagerActive__c = true;
        insert territory;
        
        Territory_Distributor__c territory1 =  new Territory_Distributor__c();
        territory.Name = 'Regional P';
        territory.TerritoryCode__c = 'BR166';
        territory.SBU__c = sbu.Id;     
        territory.Region__c = region.id;
        territory.SalesOrg__c = sorg.Id;
        territory.RegionDesciption__c = 'BR1001103 CHPS';                       
        territory.Zone__c = zone.Id;
        territory.TerritoryManager__c = userTerMan1.Id;
        //territory.TerritoryManagerActive__c = true;
        insert territory1;
        
        Territory_Distributor__c territory2 =  new Territory_Distributor__c();
        territory2.Name = 'Regional P';
        territory2.TerritoryCode__c = 'BR166';
        territory2.SBU__c = sbu.Id;     
        territory2.Region__c = region.id;
        territory2.SalesOrg__c = sorg.Id;
        territory2.RegionDesciption__c = 'BR1001103 CHPS';                       
        territory2.Zone__c = zone.Id;
        territory2.TerritoryManager__c = userinfo.getUserId();
        insert territory2;
        
        Division__c div = new Division__c();
        div.Name = 'Decco';
        div.Description__c = 'Decco';
        div.Division_Code__c = '10';
        insert div;      
        
        Price_Book__c pbook =  new Price_Book__c();
        pbook.Name = 'BRL : Price List [DO NOT MODIFY]';
        pbook.Division__c = div.Id;
        pbook.Valid_FROM__c = system.today();
        pbook.Expiry_Date__c = system.today()+360;
        pbook.Is_New_Pricebook_Flow__c = true;
        pbook.Crop_Year__c = '24/25';
        pbook.isActive__c = true;
        pbook.Price_Book_Type__c = 'AVEC';
        insert pbook;
        
        Product_Mix__c mix = new Product_Mix__c();
        mix.Name = 'SAFRA AVEC 24/25';
        mix.Type_Of_Mix__c ='AVEC' ;
        mix.Status__c = 'Active';
        mix.Price_Book__c = pbook.id;
        mix.Interest_Date_Type__c = 'Running Days';
        mix.Interest_Date_Value__c = '90';
        mix.Interest_Rate_BRL__c = 2;
        mix.Interest_Rate_USD__c = 2;
        mix.Crop_Year__c = '24/25';
        insert mix;
        
        Distribution_Channel__c dChannel =  new Distribution_Channel__c();
        dChannel.Name = '10';
        dChannel.Distribution_Channel_Code__c = '10';
        insert dChannel;
        
        Payment_Method__c pMethod = new Payment_Method__c();
        pMethod.Name = 'Credit Rule';
        pMethod.Payment_Method_Code__c = 'I';
        //  pMethod.Distribution_Channel__c = dChannel.id;
        //  pMethod.Division__c = div.Id;
        pMethod.Sales_Org__c = sorg.Id;
        pMethod.Active__c = True;
        insert pMethod;
        
        Inco_Term__c inco = new Inco_Term__c();
        inco.Name = 'CIF';
        inco.IncoTerm_Code__c = 'CIF';
        inco.IncoTerm_Desc__c = 'Custo,  seguro & frete';
        inco.Sales_Org__c = sorg.Id;
        inco.Division__c = div.Id;
        inco.Distribution_Channel__c = dChannel.Id;
        inco.Active__c = true;
        insert inco;
        
        Price_Book_Sales_District__c pbsd = new Price_Book_Sales_District__c();
        pbsd.Price_Book__c = pbook.Id;
        pbsd.Sales_District1__c = region.Id;
        insert pbsd;
        
        //account details  
        Account acc = new Account();
        acc.Name = 'LEONARDO PASSINATO';
        acc.Email__c = 'ganesh039@gmail.com';
        acc.Last_Name__c = 'PASSINATO';
        acc.SAP_Code__c = '2028844343';
        acc.RecordTypeId = devRecordTypeId;
        acc.Mobile__c = '9967341643';
        acc.Phone = '01234567765';
        acc.Sales_Org__c = sorg.Id;
        acc.Division__c = Div.Id;
        acc.Distribution_Channel__c = dChannel.Id;
        acc.BillingCity = 'MINEIROS';
        acc.Depot_Code__c = dep.Id;
        acc.Tax_Number_3__c = '114415455';
        acc.Tax_Number_1__c = '114414523';
        acc.Customer_Region__c = 'AC';
        acc.Customer_Group__c = '001';
        acc.Program_Margin_Discount__c = 0.00;
        acc.Active__c = true;
        acc.Search_Terms_1__c = 'LEONARDO PASSINATO';
        acc.Search_Terms_2__c = 'FAZ SEUBAK';
        acc.key_account_manager__c = userTerMan1.Id;
        acc.Price_Conversion_Group__c = 'A';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'LEONARDO DICAPRIO';
        acc1.Email__c = 'ganesh0539@gmail.com';
        acc1.Last_Name__c = 'DECAPRIO';
        acc1.SAP_Code__c = '2028844321';
        acc1.RecordTypeId = devRecordTypeId;
        acc1.Mobile__c = '9967341742';
        acc1.Phone = '01234567633';
        acc1.Sales_Org__c = sorg.Id;
        acc1.Division__c = Div.Id;
        acc1.Distribution_Channel__c = dChannel.Id;
        acc1.BillingCity = 'MINEIROS';
        acc1.Depot_Code__c = dep.Id;
        acc1.Tax_Number_3__c = '114415456';
        acc1.Tax_Number_1__c = '114445896';
        acc1.Customer_Region__c = 'AC';
        acc1.Customer_Group__c = '001';
        acc1.Program_Margin_Discount__c = 0.00;
        acc1.Active__c = true;
        acc1.Search_Terms_1__c = 'LEONARDO DICAPRIO';
        acc1.Search_Terms_2__c = 'FAZ SEUBAK1';
        acc1.key_account_manager__c = userTerMan1.Id;
        acc1.Price_Conversion_Group__c = 'A';
        insert acc1;
        
        
        Account acc2 = new Account();
        acc2.Name = 'SK INTERNATIONAL';
        acc2.Email__c = 'ganesh0339@gmail.com';
        acc2.Last_Name__c = 'INTERNATIONAL';
        acc2.SAP_Code__c = '2028844532';
        acc2.RecordTypeId = devRecordTypeId;
        acc2.Mobile__c = '9967341759';
        acc2.Phone = '01234567891';
        acc2.Sales_Org__c = sorg.Id;
        acc2.Division__c = Div.Id;
        acc2.Distribution_Channel__c = dChannel.Id;
        acc2.BillingCity = 'MINEIROS';
        acc2.Depot_Code__c = dep.Id;
        acc2.Tax_Number_3__c = '114415457';
        acc2.Tax_Number_1__c = '114411425';
        acc2.Customer_Region__c = 'AC';
        acc2.Customer_Group__c = '001';
        acc2.Program_Margin_Discount__c = 0.00;
        acc2.Active__c = true;
        acc2.Search_Terms_1__c = 'SK INTERNATIONAL';
        acc2.Search_Terms_2__c = 'FAZ SEUBAK2';
        //acc2.Customer_Region__c = 'BA';
        acc2.key_account_manager__c = userTerMan1.Id;
        acc2.Price_Conversion_Group__c = 'A';
        acc2.Active__c = true;
        insert acc2;
        
        Shipping_Location__c shippLoc =new Shipping_Location__c();
        shippLoc.Location_Name__c ='Same as Billing Address'; 
        shippLoc.Region__c='Pune';
        shippLoc.Distributor__c=acc2.Id;
        shippLoc.City__c='Pune';
        shippLoc.Sold_To_Party_SAP_Code__c = acc2.SAP_Code__c;
        shippLoc.SAP_Code__c='SAP0001';
        shippLoc.State__c='13';
        shippLoc.Sales_Org__c = sOrg.id;
        Insert shippLoc;
        
        contact con= new contact();
        con.accountId=acc2.id;
        con.Brazil_Approval_Contact__c=true;
        con.LastName='test contact';
        con.Email='test@gmail.com';
        insert con;
        
        //Account and region mapping record
        Customer_and_Region_Mapping__c custRegMap = new Customer_and_Region_Mapping__c(
            Customer_Name__c = acc2.Id,  // Customer Name
            CustomerRegion__c = territory.Id,   // Customer Region
            Active__c = true
            
        );
        insert custRegMap;
        Delivery_Time__c dtt=new Delivery_Time__c();
        dtt.name='123';
        dtt.Depot_Code__c='BR02';
        dtt.Days__c=20;
        insert dtt;
        Business_Rule__c BusinessRule = new Business_Rule__c(
            Name = 'ACTT',               // Business Rule Name
            Sales_Org__c = sorg.Id,             // Sales Org
            Taxes__c = 30.00,                   // Taxes
            Total_Order_Margin__c = 45.00,      // Total Order Margin > = 
            Freight__c = 6.90,                  // Freight
            List_Price_Discount__c = 5.00,
            Delivery_Time__c=dtt.id
            // Default__c = true                    // List Price Discount < = 
        );
        insert BusinessRule;
        
        Associate_Group__c asGroup = new Associate_Group__c(
            Name = 'Sales Person',                // Name
            Business_Rule__c = BusinessRule.Id  // Business Rule
        );
        insert asGroup;
        
        Employee_Details__c EmpDetail = new Employee_Details__c(
            User__c = userTerMan.Id,           
            Associate_Group__c = asGroup.Id 
        );
        insert EmpDetail;
        
        Associate_Group__c asGroupSDM = new Associate_Group__c(
            Name = 'Sales District',                // Name
            Business_Rule__c = BusinessRule.Id  // Business Rule
        );
        insert asGroupSDM;
        
        Employee_Details__c EmpDetailSDM = new Employee_Details__c(
            User__c = regioHeadUser.Id,           
            Associate_Group__c = asGroup.Id  
        );
        insert EmpDetailSDM;
        
        Employee_Details__c EmpDetailSOM = new Employee_Details__c(
            User__c = ZonalHeadUser.Id,           
            Associate_Group__c = asGroup.Id 
        );
        insert EmpDetailSOM;
        
        Employee_Details__c EmpDetailSD = new Employee_Details__c(
            User__c = SBUuser.Id,           
            Associate_Group__c = asGroup.Id  
        );
        insert EmpDetailSD;
        
        
        //default business Rule.
        Business_Rule__c bRuleSD = new Business_Rule__c(
            Name = 'Director',                 // Business Rule Name
            Taxes__c = 2.14,                    // Taxes (%)
            Total_Order_Margin__c = 0.00,       // Total Order Margin > = 
            Freight__c = 1.29,                  // Freight (%)
            List_Price_Discount__c = 100.00,    // List Price Discount < = 
            Default__c = true,                  // Default
            AppliedFor__c = 'Sales Director'  // Applied For
        );
        insert bRuleSD;
        
        Business_Rule__c bRuleSOM = new Business_Rule__c(
            Name = 'BU Gerente',                    // Business Rule Name
            Taxes__c = 2.14,                          // Taxes (%)
            Total_Order_Margin__c = 40.00,            // Total Order Margin > = 
            Freight__c = 1.29,                        // Freight (%)
            List_Price_Discount__c = 5.00,            // List Price Discount < = 
            Default__c = true,                        // Default
            AppliedFor__c = 'Sales Office Manager'  // Applied For
        );
        insert bRuleSOM;
        
        Business_Rule__c bRuleSDM = new Business_Rule__c(
            Name = 'AC',                         // Business Rule Name
            Taxes__c = 20.00,                           // Taxes (%)
            Total_Order_Margin__c = 20.00,              // Total Order Margin > = 
            Freight__c = 20.00,                         // Freight (%)
            List_Price_Discount__c = 20.00,             // List Price Discount < = 
            Default__c = true,                          // Default
            AppliedFor__c = 'Sales District Manager'  // Applied For
        );
        insert bRuleSDM;
        
        Business_Rule__c bRuleSP = new Business_Rule__c(
            Name = 'AC',              // Business Rule Name
            Taxes__c = 52.00,                 // Taxes (%)
            Total_Order_Margin__c = 60.00,    // Total Order Margin > = 
            Freight__c = 12.00,               // Freight (%)
            List_Price_Discount__c = 85.00,   // List Price Discount < = 
            Default__c = true,                // Default
            AppliedFor__c = 'Sales Person'  // Applied For
        );
        insert bRuleSP;
        
        ExchangeRate__c ExchngRte = new ExchangeRate__c(
            FROMCurrency__c = 'USD',                                  // FROM Currency
            ToCurrency__c = 'BRL',                                    // To Currency
            ExchangeRate__c = 3.45 ,                                  // Exchange Rate
            UpdatedDate__c = system.today()+45                       // Updated Date
        );
        insert ExchngRte;
        //===================== Added by SKI Start Here===========
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        //==+================= Added by SKI End Here===========
        List<SKU__c> skuList = new List<SKU__c>();
        SKU__c skuRecord = new SKU__c(
            Name = 'a1C0k000000A1ug',                                 // SKU Name
            SKU_Code__c = '000000000006302802',                       // SKU Code
            SKU_Description__c = 'MANZATE 800WP 25KG PAPER BAG_BR',   // SKU Description
            UOM__c = 'KG', 
            Division__c = div.Id,                                     // Division
            Sales_Org__c = sorg.Id,                                  // Sales Org
            Multiple_of__c = 25.00,                                   // Multiple Of
            Combination_Key__c = '519110000000000006302802',          // Combination Key
            Active__c = true,
            brand_name__c = 'MANZATE',// Active
            Unit_Cost__c = 10.00
        );
        skuList.add(skuRecord);
        SKU__c skuRecord1 = new SKU__c(
            Name = 'a1C0k000000A1ug',                                 // SKU Name
            SKU_Code__c = '000000000006302803',                       // SKU Code
            SKU_Description__c = 'Kit ',   // SKU Description
            UOM__c = 'KG', 
            Division__c = div.Id,                                     // Division
            Sales_Org__c = sorg.Id,                                  // Sales Org
            Multiple_of__c = 25.00,                                   // Multiple Of
            Combination_Key__c = '519110000000000006302803',          // Combination Key
            Active__c = true,
            Kit_Product__c = true,
            brand_name__c = 'MANZATE Kit',// Active
            Unit_Cost__c = 10.00
        );
        skuList.add(skuRecord1);
        
        SKU__c skuRecord2 = new SKU__c(
            Name = 'a1C0k000000A1ue',                                 // SKU Name
            SKU_Code__c = '000000000006302804',                       // SKU Code
            SKU_Description__c = 'MANZATE 800WP 25KG PAPER BAG_BR 1',   // SKU Description
            UOM__c = 'KG', 
            Division__c = div.Id,                                     // Division
            Sales_Org__c = sorg.Id,                                  // Sales Org
            Multiple_of__c = 25.00,                                   // Multiple Of
            Combination_Key__c = '519110000000000006302804',          // Combination Key
            Active__c = true,
            brand_name__c = 'MANZATE1',// Active
            Unit_Cost__c = 10.00
        );
        skuList.add(skuRecord2);
        insert skuList;
        
        discount_matrix__c d = new discount_matrix__c();
        d.Brand_Name__c = 'MANZATE'; 
        d.Combination_key__c = 'MANZATE5191';
        d.Sales_Director__c = 5;
        d.Sales_District_Manager__c = 5;
        d.Sales_Person__c = 5;
        d.BU_Manager__c = 5;
        insert d;
        
        customer_conversion_factor__c cf = new customer_conversion_factor__c();
        cf.Conversion_Factor__c = 3;
        cf.Minimum_Price_Conversion_Factor__c = 2;
        cf.Unit_Price_Conversion_Factor_Campaign__c = 3;
        cf.Min_Price_Conversion_Factor_Campaign__c = 2;
        cf.Unit_Price_Conversion_Factor_AVEC__c = 3;
        cf.Min_Price_Conversion_Factor_AVEC__c = 2;
        cf.Customer_Group__c = 'A';
        cf.Combination_Key__c = 'A5191';
        cf.Brand_Name__c='MANZATE';
        insert cf;
        
        Market_Variation__c MV = new Market_Variation__c();
        MV.Market_Variation__c = 5;
        MV.Region_Code__c = 'BR165';
        MV.SKU_Brand__c = 'MANZATE';
        MV.Combination_Key__c = 'BR165MANZATE5191';
        insert MV;
        
        Sales_District_Cost__c SDC = new Sales_District_Cost__c();
        SDC.Region_Code__c = 'BR165';
        SDC.Sales_District_Cost__c = 5;
        SDC.Combination_Key__c = 'BR1655191';
        insert SDC;
        
        Material_Plant_Relation__c MPRelation = new Material_Plant_Relation__c(
            Name = 'MANZATE 800WP 25KG PAPER BAG_BR',               // Material Plant Relation Name
            Material_Code__c = '000000000006302802',                // Material Code
            Active__c = true,                                       // Active
            Material_Desc__c = 'MANZATE 800WP 25KG PAPER BAG_BR',   // Material Desc
            Depot__c = dep.Id,                         
            Material_Ledger_Cost__c = 13.26,                        // Material Ledger Cost
            MC_Currency__c = 'BRL',                                 // MC Currency
            Replacement_Cost__c = 2.10,                             // Replacement Cost
            RC_Currency__c = 'USD',                                 // RC Currency
            SKU__c = skuRecord.Id,                         
            Sales_Org__c = sorg.Id                      
        );
        insert MPRelation;
        
        Culture__c culture = new Culture__c(
            Name = 'Algodão',                   // Culture Name
            Culture_Code__c = 'B01',            // Culture Code
            Culture_Desc__c = 'Algodão',        // Culture Desc
            Distribution_Channel__c = dChannel.Id,     // Distribution Channel
            Active__c = true,                  
            Division__c = div.Id,                 // Division
            Sales_Org__c = sorg.Id 
        );
        insert culture;
        
        Payment_Term__c payTerm = new Payment_Term__c(
            Payment_Term_Code__c = 'BR71',                        
            Payterms_Desc__c = 'INFORMAR VENCIMENTO',  
            Sales_Org__c = sorg.Id,                             
            Days_to_calc_interest__c = 0,                      
            Maturity_Date_Mandatory__c = 'Yes',                  
            Active__c = true                                   
        );
        
        insert payTerm;
        
        Material_Registration__c matReg = new Material_Registration__c(
            Name = '2, 4-D NORTOX 1X20L',                    
            Effective_FROM__c =  Date.newInstance(2010, 10, 10),   
            Effective_To__c = Date.newInstance(2020, 10, 10),     
            Sales_Org__c = sorg.Id,                         
            State__c = 'AC',                                
            SKU__c = skuRecord.Id,                          
            SKU_Reg_Code__c = '5250109'                     
        );
        insert matReg;
        
        Product_Mix_Details__c mixDetail = new Product_Mix_Details__c(
            SKU__c = skuRecord.Id,
            Product_Mix__c = mix.Id
        );
        insert mixDetail;
        
        Price_Book_Details__c PBdetails = new Price_Book_Details__c(
            SKU__c = skuRecord.Id,                     
            Monthly_Interest_Rate__c = 1.00,          
            Price_Book__c = pbook.Id,                
            Exchange_Rate__c = 3.00,                 
            Unit_Price__c = 120.00,                  
            Minimum_Price__c = 75.00,                
            Sales_District1__c = region.Id, 
            Minimum_Price_R__c = 5.00,        // Minimum Price R $
            Minimum_Price_U__c =2.00,        // Minimum Price U $
            Unit_Price_R__c = 28.14,          // Unit Price R $
            Unit_Price_U__c = 8.54,           // Unit Price U $
            Future_Sales_Price_R__c = 25.00,  // Future Sales Price R $
            Future_Sales_Price_U__c = 30.00,  // Future Sales Price U $
            Volume__c = 3000.00,             // Volume
            Equivalence__c = 0.00,            // % Equivalence
            Group__c = '001',                   // Group
            Sub_Group__c = 'Orthene',           // Sub Group
            Anchor__c = 'SIM',                  // Anchor
            Sub_Group_Required__c = 'SIM',
            Active__c = true,
            Exceptions_to_Multiples__c=20
        );
        insert PBdetails;
        
        Campaign_Group__c campaignGroupObj = new Campaign_Group__c(
            Campaign__c = pbook.Id,            // Campaign
            Do_not_generate_group_discount__c = false,    // Do not generate group discount
            Will_you_have_a_sub_product_group__c = 'No',  // Will you have a sub product group?
            Group_Discount__c = 2.00,                     // Group Discount
            Name_of_the_group__c = '001',                 // Name of the group
            Limited_volume__c = false                    // Limited volume ?
        );
        insert campaignGroupObj;
        test.stopTest();
        
        
        Sales_Order__c sobj = new Sales_Order__c(
            OwnerId = userTerMan.Id, 
            SFDC_Order_Number__c = '83602334',                     // SFDC Order Number
            SAP_Order_Number__c = '7009090604',                 // SAP Order Number
            Order_Cancel__c = false,     
            Sales_Org_lk__c = sorg.Id,                             // Order Cancel
            SDM_Approval_On_Order_Cancellation__c = 1,
            Order_Status__c = 'Pending', // Order Status
            OrderSubStatus__c = 'Approved',                     // Order Sub-Status
            Region_Territory__c = territory.Id,                  // Region / Territory
            RequestforCancellationCheck__c = false,  
            BudgetApprovalCheck__c = false,// Request for Cancellation
            //  BarterManager__c = BarterUser.Id, 
            Flag_Status__c = 'dislike\n',                       // Flag Status
            BrazilOrderSubmittedforApproval__c = true,          // Brazil Order Submitted for Approval
            SalesOfficeManager__c = ZonalHeadUser.Id,          // Sales Office Manager
            Price_Book__c = pbook.Id,                          // Price Book
            SalesDistrictManager__c =  regioHeadUser.Id,    
            Inco_Term__c = inco.Id, 
            Currency_Brazil__c = 'Billing USD / Payment USD',   // Currency (Brazil)
            Key_Account__c = false,                             // Key Account
            Sold_to_Party__c = acc1.Id,                         // Sold to Party
            Valid_FROM__c = system.today(), 
            //  PaymentMethod__c = pMethod.Id, // Valid FROM
            Valid_To__c = system.today()+350,                   // Valid To
            Payment_Term__c = payTerm.Id, 
            isTestRunningOrder__c=true,// Payment Term
            Type_of_Order__c = 'CONTRATO MÃE'                 // Type of Order
        );
        insert sobj;
        SO_id=sobj.Id;
        Sales_Order__c sobj1 = new Sales_Order__c(
            OwnerId = userTerMan1.Id, 
            
            Order_Cancel__c = false,     
            Sales_Org_lk__c = sorg.Id,                             // Order Cancel
            Order_Status__c = 'Not yet processed',              // Order Status
            OrderSubStatus__c = 'Pending',                     // Order Sub-Status
            Region_Territory__c = territory.Id,                  // Region / Territory
            RequestforCancellationCheck__c = false,  
            BudgetApprovalCheck__c = false,// Request for Cancellation
            //  BarterManager__c = BarterUser.Id, 
            Flag_Status__c = 'dislike\n',                       // Flag Status
            BrazilOrderSubmittedforApproval__c = true,          // Brazil Order Submitted for Approval
            //SalesOfficeManager__c = ZonalHeadUser.Id,          // Sales Office Manager
            Price_Book__c = pbook.Id,                          // Price Book
            //SalesDistrictManager__c =  regioHeadUser.Id,    
            Inco_Term__c = inco.Id, 
            Currency_Brazil__c = 'Billing USD / Payment USD',   // Currency (Brazil)
            Key_Account__c = false,                             // Key Account
            Sold_to_Party__c = acc.Id,                         // Sold to Party
            Valid_FROM__c = system.today(), 
            Sales_Order__c =  sobj.Id,                  
            Payment_Term__c = payTerm.Id,                     // Payment Term
            Type_of_Order__c = 'BONIFICAÇÃO'                 // Type of Order
        );
        insert sobj1;
        Sales_Order__c so2 = new Sales_Order__c();
        so2.Sales_Order__c = SO_id;
        so2.Type_of_Order__c = 'ORDEM FILHA';                 // Type of Order
        so2.Currency_Brazil__c = 'Billing USD / Payment USD';  // Currency (Brazil)
        so2.Valid_FROM__c = System.today();          // Valid FROM
        so2.BrazilOrderSubmittedforApproval__c = true;         // Brazil Order Submitted for Approval
        so2.Valid_To__c = System.today()+365;          // Valid To
        //so2.PONumber__c = 'qweet1';   
        so2.BudgetApprovalCheck__c = false;
        so2.Inco_Term__c = inco.Id;
        so2.Key_Account__c = false;  
        so2.Purchase_Order_Date__c = System.today()+5;
        so2.Business_Discount__c = 0.00;                      // Business Discount
        so2.Financial_Discount__c = 0.00;                     // Financial Discount
        so2.Sold_to_Party__c = acc2.Id;       // Sold to Party
        so2.Sales_Org_lk__c = sorg.Id;
        so2.CurrencyIsoCode = 'BRL';
        so2.Punctuality_Discount__c=1.2;
        so2.Price_Book__c=pbook.id;
        so2.Payment_Term__c = payTerm.Id;                   // Payment Term
        so2.PaymentMethod__c= pMethod.Id;
        insert so2;
        
        Sales_Order__c soChild = new Sales_Order__c();
        soChild.RecordTypeId = recordTypeId;
        soChild.Parent_Order_Simulated__c=sobj.id;
        soChild.Type_of_Order__c = 'VENDA NORMAL';                 // Type of Order
        soChild.Currency_Brazil__c = 'Billing USD / Payment USD';  // Currency (Brazil)
        soChild.Valid_FROM__c = System.today();          // Valid FROM
        soChild.BrazilOrderSubmittedforApproval__c = true;         // Brazil Order Submitted for Approval
        soChild.Valid_To__c = System.today()+365;          // Valid To
        soChild.PONumber__c = 'qweet';
        soChild.BudgetApprovalCheck__c = false;
        soChild.Inco_Term__c = inco.Id;
        soChild.Key_Account__c = false;  
        soChild.Purchase_Order_Date__c = System.today()+5;
        soChild.Business_Discount__c = 0.00;                      // Business Discount
        soChild.Financial_Discount__c = 0.00;                     // Financial Discount
        soChild.Sold_to_Party__c = acc.Id;       // Sold to Party
        soChild.Sales_Org_lk__c = sorg.Id;
        soChild.SDM_Approval_On_Order_Item_Edit_Cancel__c=false;
        insert soChild;
        List<Sales_Order_Line_Item__c> soLineList= new List<Sales_Order_Line_Item__c>();
        Sales_Order_Line_Item__c soLineItm = new Sales_Order_Line_Item__c(
            Sale_Order__c = sobj.Id,          // Sale Order
            SKU_Name__c = skuRecord.Id,            // SKU Name
            Item_Number__c = 10,                        // Item Number
            Item_Status__c = 'Active',       // Item Status
            Item_Cancel__c = false,                     // Item Cancel
            Order_Item_Key__c = '836010453',               // OrderNumber_Item_Key
            Sales_Org__c = sorg.Id,           // Sales Org
            PriceBookDetail__c = PBdetails.Id,  // Price Book Detail
            Approval_Flag__c = 0,                       // Approval Flag
            ExchangeRate__c = ExchngRte.id,        // Exchange Rate
            OrderQuantityEdited__c = false,             // Order Quantity Edited
            Time_in_months__c = 0,                      // Time in months
            Days__c = 0,                                // Days
            DateofFAT__c =  system.today()+1, 
            Quantity__c = 450.00,                       // Quantity
            UnitValue__c = 100.00,                      // Unit Value
            UnitValuewithInterest__c = 100.00,          // Unit Value with Interest
            InterestRate__c = 0.00,                     // Interest Rate
            TotalTax__c = 0.00,                         // Total Tax
            TotalFreight__c = 0.00,                     // Total Freight
            TotalPunctuality__c = 0.00,                 // Total Punctuality
            TotalLedgerCost__c = 0.00,                  // Total Ledger Cost
            TotalReplacementCost__c = 0.00 ,
            Tax__c=0.00,
            Freight__c=0.00,
            Customer_Conversion_Factor__c = 1,// Total Replacement Cost
            Marketing_Ops_Manager__c = userInfo.getUserId(),
            SalesDistrictManager__c = userInfo.getUserId(),
            SalesOfficeManager__c = userInfo.getUserId(),
            SalesDirector__c = userInfo.getUserId(),
            REH__c = userInfo.getUserId()
        );
        soLineList.add(soLineItm);
        
        Sales_Order_Line_Item__c soLineItm1 = new Sales_Order_Line_Item__c(
            Sale_Order__c = sobj1.Id,          // Sale Order
            SKU_Name__c = skuRecord.Id,            // SKU Name
            Item_Number__c = 20,                        // Item Number
            Item_Status__c = 'Active',      // Item Status
            Item_Cancel__c = false,                     // Item Cancel
            Order_Item_Key__c = '836010434',               // OrderNumber_Item_Key
            Sales_Org__c = sorg.Id,           // Sales Org
            PriceBookDetail__c = PBdetails.Id,  // Price Book Detail
            Approval_Flag__c = 0,                       // Approval Flag
            ExchangeRate__c = ExchngRte.id,        // Exchange Rate
            OrderQuantityEdited__c = false,             // Order Quantity Edited
            Time_in_months__c = 0,                      // Time in months
            Days__c = 0,                                // Days
            DateofFAT__c =  system.today()+1, 
            Batch__c = 'BATCH001',
            Quantity__c = 450.00,
            Tax__c=0.00,
            UnitValue__c = 100.00,                      // Unit Value
            UnitValuewithInterest__c = 100.00,          // Unit Value with Interest
            InterestRate__c = 0.00,                     // Interest Rate
            TotalTax__c = 0.00,                         // Total Tax
            TotalFreight__c = 0.00,                     // Total Freight
            TotalPunctuality__c = 0.00,                 // Total Punctuality
            TotalLedgerCost__c = 0.00,                  // Total Ledger Cost
            TotalReplacementCost__c = 0.00 ,
            Freight__c=0.00,
            Customer_Conversion_Factor__c = 1// Total Replacement Cost
        );
        soLineList.add(soLineItm1);
        insert soLineList;
        
        Admin_MPT_Colombia__c adminMPT = new Admin_MPT_Colombia__c();
        adminMPT.Active__c = true;
        adminMPT.Approval_Level__c = 'Level 2';
        adminMPT.Sales_Org__c = sorg.Id;
        adminMPT.Level_3_below__c = 15;
        adminMPT.Level_2_min__c = 15.01;    
        adminMPT.Level_2_max__c = 20.00;
        adminMPT.Level_1_min__c = 20.01;
        adminMPT.Level_1_max__c = 30.00;
        insert adminMPT;
        
        Brazil_Region_SKU_Combination__c newRec1 = new Brazil_Region_SKU_Combination__c(
            Sales_District__c = region.Id,
            SKU__c = skuList[0].Id,
            Date__c = System.today(),
            Availability__c = 'No'
        );
        insert newRec1;
        
        AvecTypeMonthValue__c avtm = new AvecTypeMonthValue__c();
        avtm.Region_Value__c='re';
        insert avtm;
    }
    @isTest public static void createm1(){
        User userTerMan123 = [select id from user where Email = 'userTerManTerri@skinternational.com' limit 1]; 
        User userTerMan1 = [select id from user where Email = 'shama11@skinternational.com' limit 1];
        Sales_Order__c sobj=[SELECT OwnerId,SFDC_Order_Number__c,SAP_Order_Number__c,Order_Cancel__c,Sales_Org_lk__c,Order_Status__c,OrderSubStatus__c,Region_Territory__c,RequestforCancellationCheck__c,BudgetApprovalCheck__c,Flag_Status__c,BrazilOrderSubmittedforApproval__c,Price_Book__c,Inco_Term__c,Currency_Brazil__c,Key_Account__c,Sold_to_Party__c,Valid_FROM__c,Kit_Order__c,Valid_To__c,Payment_Term__c,Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c = 'CONTRATO MÃE' LIMIT 1];
        Sales_Order__c soChild=[SELECT OwnerId,SFDC_Order_Number__c,SAP_Order_Number__c,Order_Cancel__c,Sales_Org_lk__c,Order_Status__c,OrderSubStatus__c,Region_Territory__c,RequestforCancellationCheck__c,BudgetApprovalCheck__c,Flag_Status__c,BrazilOrderSubmittedforApproval__c,Price_Book__c,Inco_Term__c,Currency_Brazil__c,Key_Account__c,Sold_to_Party__c,Valid_FROM__c,Kit_Order__c,Valid_To__c,Payment_Term__c,Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c ='VENDA NORMAL' LIMIT 1];
        Sales_Order_Line_Item__c soLineItm3=[SELECT Sale_Order__c,SKU_Name__c,Item_Number__c,Item_Status__c,Item_Cancel__c,Order_Item_Key__c,Sales_Org__c,PriceBookDetail__c,Approval_Flag__c,ExchangeRate__c,OrderQuantityEdited__c,Time_in_months__c,Days__c,DateofFAT__c,Quantity__c,UnitValue__c,UnitValuewithInterest__c,InterestRate__c,TotalTax__c,TotalFreight__c,TotalPunctuality__c,TotalLedgerCost__c,TotalReplacementCost__c,Customer_Conversion_Factor__c FROM Sales_Order_Line_Item__c WHERE Sale_Order__c = : sobj.Id limit 1 ];
        Sales_org__c sorg = [SELECT Id FROM Sales_org__c WHERE Sales_Org_Code__c = '5191'];
        Price_Book__c pricebook = [SELECT Id FROM Price_Book__c LIMIT 1];
        Product_Mix__c mix = [SELECT Id FROM Product_Mix__c LIMIT 1];
        Sales_Order__c soMother = [SELECT id, Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c = 'CONTRATO MÃE' LIMIT 1];
        Depot__c dep = [SELECT Id FROM Depot__c WHERE SalesOrg__c = :sorg.Id LIMIT 1]; 
        Account acc2 = [SELECT id, Customer_Group__c, Customer_Region__c FROM Account WHERE Sales_Org__c = :sorg.id AND Last_Name__c = 'INTERNATIONAL' LIMIT 1]; 
        Sales_Order__c so2=[SELECT Id,Sales_Order__c,PaymentMethod__c,Region_Territory__c,Call_Process_Builder_Flow__c,BudgetApprovalCheck__c,BrazilSalesOrderApproved__c,KeyAccountDesOwnerBrazil__c,TM_Code__c,Type_of_Order__c,Currency_Brazil__c,Valid_FROM__c,BrazilOrderSubmittedforApproval__c,Valid_To__c,Inco_Term__c,Key_Account__c,Ship_To_Party__c,Campaign_pricebook__c,Purchase_Order_Date__c,Business_Discount__c,Financial_Discount__c,Sold_to_Party__c,Sales_Org_lk__c,CurrencyIsoCode,Punctuality_Discount__c,Price_Book__c
                            FROM Sales_Order__c  where SalesOrgCode__c = '5191'AND Type_of_Order__c ='ORDEM FILHA' limit 1
                           ];
        Account acc = [SELECT id, Customer_Group__c, Customer_Region__c FROM Account WHERE Sales_Org__c = :sorg.id AND Last_Name__c = 'PASSINATO' LIMIT 1];
        Payment_Term__c pt =  [select id from Payment_Term__c Limit 1];
        SKU__c skurec = [SELECT Id, SKU_Description__c, SKU_Code__c, Multiple_of__c FROM SKU__c LIMIT 1];
        Culture__c culture = [SELECT Id FROM Culture__c LIMIT 1];
        Price_Book_Details__c pbdetails1 =  [SELECT Id,SKU__r.id, Unit_Price__c, Monthly_Interest_Rate__c,Future_Sales_Price_R__c, Future_Sales_Price_U__c, Unit_Price_R__c,
                                             Unit_Price_U__c, Minimum_Price_U__c, Minimum_Price_R__c, Volume__c, SKU__c FROM Price_Book_Details__c LIMIT 1];
        SKU__c skuRecord = [select id ,Name,SKU_Code__c,SKU_Description__c,UOM__c,Division__c,brand_name__c,Kit_Product__c,Active__c,Sales_Org__c,Combination_Key__c,Multiple_of__c from SKU__c where SKU_Code__c = '000000000006302803'  limit 1];
        Division__c div = [select id from Division__c limit 1];	
        
        Component__c compRecord = new Component__c(
            Component_Item_Category__c = 'CTCV',                       
            Component_Quantity__c = 10,   
            Component_SKU__c = pbdetails1.SKU__r.id, 
            Division__c = div.Id,                             
            Sales_Org__c = sorg.Id,                      
            Kit_SKU__c = skuRecord.id,                                   
            Combination_Key__c = '519110000000000006302803'        
        );
        insert compRecord;
        List<Grz_SalesOrderFeaturedProductsController.SalesOrderItem> solst = new List<Grz_SalesOrderFeaturedProductsController.SalesOrderItem>(); 
        Grz_SalesOrderFeaturedProductsController.SalesOrderItem wrapObj = new Grz_SalesOrderFeaturedProductsController.SalesOrderItem();
        wrapObj.productId = skurec.id;
        wrapObj.fatDate = '02/05/2018';
        wrapObj.qty = 50;
        wrapObj.listValue = 50;
        wrapObj.unitValue = 32;
        wrapObj.unitValueWithInterest = 32;
        wrapObj.productCode =  skurec.SKU_Code__c;
        wrapObj.totalValue = 12816;
        wrapObj.interestRate = 0;
        wrapObj.days = 0;
        wrapObj.cultureDesc = culture.Id;
        wrapObj.priceBookDetailId = pbdetails1.Id;
        wrapObj.productName = '';
        wrapObj.inventory = 0;
        wrapObj.discount = 16.35;
        wrapObj.replacementMargin = 0;
        wrapObj.ledgerMargin = 63.1;
        wrapObj.totalValueWithInterest = 0;
        wrapObj.timeInMonths = 0;
        wrapObj.multipleOf = 0;
        solst.add(wrapObj);
        String serlizeStr = JSON.serialize(solst); 
        Map<String,Decimal> mapofsales = new Map<String,Decimal>();
        mapofsales.put(soLineItm3.Id,90);
        Grz_OrderRequestViewController.validateSAPResponse(true,sobj.id,'Test','isSOItemsEditProcess');
        Grz_OrderRequestViewController.getInventory('VENDA NORMAL',false);
        User u = [SELECT id FROM user WHERE profile.name='Brazil Sales Person' LIMIT 1];
        acc2.key_account_manager__c = userinfo.getUserId();
        Test.StartTest();
        update acc2;
        Grz_SalesOrderFeaturedProductsController.getSeller();
        Grz_SalesOrderFeaturedProductsController.getLoggedInUserInfo();
        /* Grz_SalesOrderCreationRequest.getCurrency();
Grz_SalesOrderCreationRequest.getCultureDesc(mix.Id,'CONTRATO MÃE',soMother.Id);
Grz_SalesOrderCreationRequest.getRegionCode('','');
Grz_SalesOrderCreationRequest.customerExist('');*/
        pt.Active__c = true;
        pt.Payment_Term_Code__c = 'BR71';
        update pt;
        Grz_SalesOrderFeaturedProductsController.getPBPaymentTerms(mix.Id,null);
        Grz_SalesOrderCreationRequest.getKeyAccountManager('');
        Price_Book__c pbc = [select id from Price_Book__c limit 1];
        pbc.Kit_Price_Book__c = true;
        pbc.Apply_Increase_Decrease_Percentage__c = true;
        update pbc;
        try{Grz_SalesOrderCreationRequest.getPriceBookDetails(userTerMan123.Id,pricebook.Id,mix.Id,'Billing BRL / Payment BRL',dep.id,  acc.Customer_Region__c,acc.Id,false);}
        catch(exception e){}
        Grz_SalesOrderCreationRequest.getCustomerTaxFreight('AC');
        List<Grz_SalesOrderCreationRequest.PriceDetail> lstPriceDetail = new List<Grz_SalesOrderCreationRequest.PriceDetail>();
        Grz_SalesOrderCreationRequest.PriceDetail oPD = new Grz_SalesOrderCreationRequest.PriceDetail();
        oPD.pricebookId = pricebook.Id;
        oPD.skuId = pbdetails1.SKU__r.id;
        oPD.kitSKU =  pbdetails1.SKU__r.id;
        lstPriceDetail.add(oPD);
        List<Id> kitSKUs = new List<Id>();
        kitSKUs.add(skuRecord.id);
        Grz_SalesOrderFeaturedProductsController.getCustomers('Brazil Sales Price Admin',userTerMan123.Id,userTerMan1.Id,  soChild.Type_of_Order__c,  acc.Customer_Group__c,  acc.Id,'null');
        Grz_SalesOrderFeaturedProductsController.getPriceListValues('25/26','AVEC');
        List<Sales_Order_Line_Item__c> soitemlist = new List<Sales_Order_Line_Item__c>();
        soitemlist.add(soLineItm3);
        Map<id,List<Sales_Order_Line_Item__c>> soitemmap = new Map<id,List<Sales_Order_Line_Item__c>>();
        soitemmap.put(pbdetails1.SKU__r.id,soitemlist);
        kitSKUs = new List<Id>();
        kitSKUs.add(skuRecord.id);
        Test.StopTest();
    }  
    
    
    @isTest public static void createm3(){
        Sales_org__c sorg = [SELECT Id FROM Sales_org__c WHERE Sales_Org_Code__c = '5191'];
        Account acc = [SELECT id, Customer_Group__c, Customer_Region__c FROM Account WHERE Sales_Org__c = :sorg.id AND Last_Name__c = 'PASSINATO' LIMIT 1];
        Account acc2 = [SELECT id, Customer_Group__c, Customer_Region__c FROM Account WHERE Sales_Org__c = :sorg.id AND Last_Name__c = 'INTERNATIONAL' LIMIT 1]; 
        Grz_SalesOrderFeaturedProductsController.getCustomers('Brazil Sales District Manager',UserInfo.getUserId(),'',  '',  acc.Customer_Group__c,  acc.Id,'BR');
        acc2.Key_Account_Manager__c = UserInfo.getUserId();
        update acc2;
    } 
    @isTest
    public static void testGetSelectedProductData() {
        Price_Book_Details__c pbdetails1 =  [SELECT Id,SKU__r.id, Unit_Price__c,Price_Book__c, Monthly_Interest_Rate__c,Future_Sales_Price_R__c, Future_Sales_Price_U__c, Unit_Price_R__c,
                                             Unit_Price_U__c, Minimum_Price_U__c, Minimum_Price_R__c, Volume__c, SKU__c FROM Price_Book_Details__c LIMIT 1];
        BrAvecSO__c settings = new BrAvecSO__c();
        settings.PricebookId__c = pbdetails1.Price_Book__c;
        settings.ProductMixId__c = 'someValue';
        settings.UPL__c = 'https://test.salesforce.com/upl/';
        insert settings;
        
        Test.setMock(HttpCalloutMock.class, new Grz_SalesOrderFeaturedProductsMock());
        
        Test.startTest();
        //
        account accc=[select id from account ][0];
        user uss=[select id from user where username='20005489@uniphos3.com.upltest'];
        Map<String, Object> result = (Map<String, Object>) Grz_SalesOrderFeaturedProductsController.getSelectedProductData('MANZATE',accc.id,uss.id,accc.id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('logo'), 'Result should contain logo key');
        System.assert(result.containsKey('description'), 'Result should contain description key');
        System.assert(result.containsKey('type'), 'Result should contain type key');
        System.assert(result.containsKey('pdfs'), 'Result should contain pdfs key');
        System.assert(result.containsKey('inventory'), 'Result should contain inventory key');
    }
    @isTest
    public static void testGetSelectedProductDataF() {
        Price_Book_Details__c pbdetails1 =  [SELECT Id,SKU__r.id, Unit_Price__c,Price_Book__c, Monthly_Interest_Rate__c,Future_Sales_Price_R__c, Future_Sales_Price_U__c, Unit_Price_R__c,
                                             Unit_Price_U__c, Minimum_Price_U__c, Minimum_Price_R__c, Volume__c, SKU__c FROM Price_Book_Details__c LIMIT 1];
        BrAvecSO__c settings = new BrAvecSO__c();
        settings.PricebookId__c = pbdetails1.Price_Book__c;
        settings.ProductMixId__c = 'someValue';
        settings.UPL__c = 'https://test.salesforce.com/upl/';
        insert settings;
        
        // 1. Get Record Type
        Id recordTypeId = Schema.SObjectType.Featured_Product__c
            .getRecordTypeInfosByDeveloperName()
            .get('Order')
            .getRecordTypeId();

        // 2. Create Featured Product
        Featured_Product__c product = new Featured_Product__c(
            Name = 'TestBrand',
            Title__c = 'Test Title',
            Description__c = 'Test Desc',
            Image_Name__c='iccc',
            RecordTypeId = recordTypeId
        );
        insert product;

        // 3. Create ContentVersion (creates ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'Icon',
            PathOnClient = 'TestFile.jpg',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert cv;

        // 4. Get ContentDocumentId
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ];

        // 5. Link file to product
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = product.Id,
            ContentDocumentId = insertedCV.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;

        // 6. Create ContentDistribution (if allowed)
        try {
            ContentDistribution dist = new ContentDistribution(
                Name = 'Test Dist',
                ContentVersionId = cv.Id,
                PreferencesAllowViewInBrowser = true,
                PreferencesAllowOriginalDownload = true
            );
            insert dist;
        } catch (Exception e) {
            System.debug('ContentDistribution not allowed in test context');
        }

        Test.setMock(HttpCalloutMock.class, new Grz_SalesOrderFeaturedProductsMockF());
        
        Test.startTest();
        //
        account accc=[select id from account ][0];
        user uss=[select id from user where username='20005489@uniphos3.com.upltest'];
        Map<String, Object> result = (Map<String, Object>) Grz_SalesOrderFeaturedProductsController.getSelectedProductData('MANZATE',accc.id,uss.id,accc.id);
        Test.stopTest();
    }
  
     @isTest
    static void test_getBrandData() {

        // 1. Get Record Type
        Id recordTypeId = Schema.SObjectType.Featured_Product__c
            .getRecordTypeInfosByDeveloperName()
            .get('Order')
            .getRecordTypeId();

        // 2. Create Featured Product
        Featured_Product__c product = new Featured_Product__c(
            Name = 'TestBrand',
            Title__c = 'Test Title',
            Description__c = 'Test Desc',
            RecordTypeId = recordTypeId
        );
        insert product;

        // 3. Create ContentVersion (creates ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'Icon',
            PathOnClient = 'TestFile.jpg',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert cv;

        // 4. Get ContentDocumentId
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ];

        // 5. Link file to product
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = product.Id,
            ContentDocumentId = insertedCV.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;

        // 6. Create ContentDistribution (if allowed)
        try {
            ContentDistribution dist = new ContentDistribution(
                Name = 'Test Dist',
                ContentVersionId = cv.Id,
                PreferencesAllowViewInBrowser = true,
                PreferencesAllowOriginalDownload = true
            );
            insert dist;
        } catch (Exception e) {
            System.debug('ContentDistribution not allowed in test context');
        }

        Test.startTest();

        Map<String, Object> result = 
            Grz_SalesOrderFeaturedProductsController.getBrandData('TestBrand');
		system.debug('::::::::::::::::'+JSON.serializePretty(result));
        Test.stopTest();

    }

    /*@isTest
    static void testFilterExpire() {
        Sales_org__c sorg = [SELECT Id FROM Sales_org__c WHERE Sales_Org_Code__c = '5191'];
        Account acc2 = [SELECT id, Customer_Group__c, Customer_Region__c FROM Account WHERE Sales_Org__c = :sorg.id AND Last_Name__c = 'INTERNATIONAL' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new Grz_SalesOrderFeaturedProductsMock());
        Test.startTest();
        Object result = Grz_SalesOrderFeaturedProductsController.filterExpire(acc2.Id);
        
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null if callout succeeds');
    }*/
    public class Grz_SalesOrderFeaturedProductsMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().contains('upl')) { 
                res.setBody('{"data":{"productDetailsResponse":{"product_logo_image":"logoUrl","description":"desc","type":"typeValue"},"productOtherFilesResponse":[{"file_link":"pdfLink1","file_display_name":"PDF File 1"}],"productLabelFileResponse":{"file_link":"labelLink","file_display_name":"Label File"},"productMsdsFileResponse":{"file_link":"msdsLink","file_display_name":"MSDS File"}}}');
            } else {
                res.setBody('{"root":{"item":[{"Sku_Code":"000000000006302803"}]}}');
            }
            
            return res;
        }
    }
    
    public class Grz_SalesOrderFeaturedProductsMockF implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            if (req.getEndpoint().contains('upl')) { 
                res.setBody('{"data":{"productDetailsResponse":{"product_logo_image":"logoUrl","description":"desc","type":"typeValue"},"productOtherFilesResponse":[{"file_link":"pdfLink1","file_display_name":"PDF File 1"}],"productLabelFileResponse":{"file_link":"labelLink","file_display_name":"Label File"},"productMsdsFileResponse":{"file_link":"msdsLink","file_display_name":"MSDS File"}}}');
            } else {
                res.setBody('{"root":{"item":[{"Sku_Code":"000000000006302803"}]}}');
            }
            
            return res;
        }
    }
    @isTest public static void viewm2(){
        
        Sales_Order__c sobj=[SELECT OwnerId,SFDC_Order_Number__c,SAP_Order_Number__c,Order_Cancel__c,Sales_Org_lk__c,Order_Status__c,OrderSubStatus__c,Region_Territory__c,RequestforCancellationCheck__c,BudgetApprovalCheck__c,Flag_Status__c,BrazilOrderSubmittedforApproval__c,Price_Book__c,Inco_Term__c,Currency_Brazil__c,Key_Account__c,Sold_to_Party__c,Valid_FROM__c,Kit_Order__c,Valid_To__c,Payment_Term__c,Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c = 'CONTRATO MÃE' LIMIT 1];
        Sales_Order__c soChild=[SELECT CurrencyIsoCode,RecordTypeId,Parent_Order_Simulated__c,AVEC_Order__c,OwnerId,SFDC_Order_Number__c,SAP_Order_Number__c,Order_Cancel__c,Sales_Org_lk__c,Order_Status__c,OrderSubStatus__c,Region_Territory__c,RequestforCancellationCheck__c,BudgetApprovalCheck__c,Flag_Status__c,BrazilOrderSubmittedforApproval__c,Price_Book__c,Inco_Term__c,Currency_Brazil__c,Key_Account__c,Sold_to_Party__c,Valid_FROM__c,Kit_Order__c,Valid_To__c,Payment_Term__c,Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c ='VENDA NORMAL' LIMIT 1];
        Sales_Order_Line_Item__c soLineItm3=[SELECT Sale_Order__c,SKU_Name__c,Item_Number__c,Item_Status__c,Item_Cancel__c,Order_Item_Key__c,Sales_Org__c,PriceBookDetail__c,Approval_Flag__c,ExchangeRate__c,OrderQuantityEdited__c,Time_in_months__c,Days__c,DateofFAT__c,Quantity__c,UnitValue__c,UnitValuewithInterest__c,InterestRate__c,TotalTax__c,TotalFreight__c,TotalPunctuality__c,TotalLedgerCost__c,TotalReplacementCost__c,Customer_Conversion_Factor__c FROM Sales_Order_Line_Item__c WHERE Sale_Order__c = : sobj.Id limit 1 ];
        Sales_org__c sorg = [SELECT Id FROM Sales_org__c WHERE Sales_Org_Code__c = '5191'];
        Price_Book__c pricebook = [SELECT Id FROM Price_Book__c LIMIT 1];
        Sales_Order__c soMother = [SELECT id, Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c = 'CONTRATO MÃE' LIMIT 1];
        Depot__c dep = [SELECT Id FROM Depot__c WHERE SalesOrg__c = :sorg.Id LIMIT 1]; 
        Account acc2 = [SELECT id, Customer_Group__c, Customer_Region__c FROM Account WHERE Sales_Org__c = :sorg.id AND Last_Name__c = 'INTERNATIONAL' LIMIT 1]; 
        
        Sales_Order__c so2=[SELECT Id,Sales_Order__c,PaymentMethod__c,Region_Territory__c,Call_Process_Builder_Flow__c,BudgetApprovalCheck__c,BrazilSalesOrderApproved__c,KeyAccountDesOwnerBrazil__c,TM_Code__c,Type_of_Order__c,Currency_Brazil__c,Valid_FROM__c,BrazilOrderSubmittedforApproval__c,Valid_To__c,Inco_Term__c,Key_Account__c,Ship_To_Party__c,Campaign_pricebook__c,Purchase_Order_Date__c,Business_Discount__c,Financial_Discount__c,Sold_to_Party__c,Sales_Org_lk__c,CurrencyIsoCode,Punctuality_Discount__c,Price_Book__c
                            FROM Sales_Order__c  where SalesOrgCode__c = '5191'AND Type_of_Order__c ='ORDEM FILHA' limit 1
                           ];
        sobj.Kit_Order__c = true;
        update sobj;
        soChild.Kit_Order__c = true;
        update soChild;
        SKU__c skurec = [SELECT Id, SKU_Description__c, SKU_Code__c, Multiple_of__c FROM SKU__c LIMIT 1];
        Culture__c culture = [SELECT Id FROM Culture__c LIMIT 1];
        Price_Book_Details__c pbdetails1 =  [SELECT Id, Unit_Price__c, Monthly_Interest_Rate__c,Future_Sales_Price_R__c, Future_Sales_Price_U__c, Unit_Price_R__c,
                                             Unit_Price_U__c, Minimum_Price_U__c, Minimum_Price_R__c, Volume__c, SKU__c FROM Price_Book_Details__c LIMIT 1];
        
        List<Grz_SalesOrderFeaturedProductsController.SalesOrderItem> solst = new List<Grz_SalesOrderFeaturedProductsController.SalesOrderItem>(); 
        Grz_SalesOrderFeaturedProductsController.SalesOrderItem wrapObj = new Grz_SalesOrderFeaturedProductsController.SalesOrderItem();
        wrapObj.productId = skurec.id;
        wrapObj.fatDate = '02/05/2018';
        wrapObj.qty = 50;
        wrapObj.listValue = 50;
        wrapObj.unitValue = 32;
        wrapObj.unitValueWithInterest = 32;
        wrapObj.productCode =  skurec.SKU_Code__c;
        wrapObj.totalValue = 12816;
        wrapObj.interestRate = 0;
        wrapObj.days = 0;
        wrapObj.cultureDesc = culture.Id;
        wrapObj.priceBookDetailId = pbdetails1.Id;
        wrapObj.productName = '';
        wrapObj.inventory = 0;
        wrapObj.discount = 16.35;
        wrapObj.replacementMargin = 0;
        wrapObj.ledgerMargin = 63.1;
        wrapObj.totalValueWithInterest = 0;
        wrapObj.timeInMonths = 0;
        wrapObj.multipleOf = 0;
        wrapObj.priceBookDetailId = '';
        wrapObj.kitProduct = true;
        solst.add(wrapObj);
        String serlizeStr = JSON.serialize(solst); 
        
        Map<String,Decimal> mapofsales = new Map<String,Decimal>();
        mapofsales.put(soLineItm3.Id,90);
        test.startTest();
        Grz_SalesOrderFeaturedProductsController.saveSalesOrder(soChild,  serlizeStr,  false,'','');
        User u = [SELECT id FROM user WHERE profile.name='Brazil Sales Person' LIMIT 1];
        Brazil_Customer_Email_Set_Days__c bcs = new Brazil_Customer_Email_Set_Days__c();
        bcs.Sap_Integration_Old_Version__c = true;
        bcs.Email_sent_after_days__c = 1;
        insert bcs;
        so2.TM_Code__c = '123';
        so2.KeyAccountDesOwnerBrazil__c = u.id;
        so2.Order_Status__c = '';
        List<Sales_Org__c> sorgList=new List<Sales_Org__c>();
        
        sorgList.add(sorg);
        
        Grz_SalesOrderFeaturedProductsController.saveOrderItems(soChild,solst,sorgList,true);
        Grz_SalesOrderFeaturedProductsController.getSalesOrderItems(sobj.id);
        test.stoptest(); 
    } 
    @isTest
    static void test_saveSalesOrder_newOrder() {
        Test.startTest();
        Sales_Order__c so2=[SELECT Id,Sales_Order__c,PaymentMethod__c,Region_Territory__c,Call_Process_Builder_Flow__c,BudgetApprovalCheck__c,BrazilSalesOrderApproved__c,KeyAccountDesOwnerBrazil__c,TM_Code__c,Type_of_Order__c,Currency_Brazil__c,Valid_FROM__c,BrazilOrderSubmittedforApproval__c,Valid_To__c,Inco_Term__c,Key_Account__c,Ship_To_Party__c,Campaign_pricebook__c,Purchase_Order_Date__c,Business_Discount__c,Financial_Discount__c,Sold_to_Party__c,Sales_Org_lk__c,CurrencyIsoCode,Punctuality_Discount__c,Price_Book__c
                            FROM Sales_Order__c  where SalesOrgCode__c = '5191'AND Type_of_Order__c ='VENDA NORMAL' limit 1
                           ];
        SKU__c skurec = [SELECT Id, SKU_Description__c, SKU_Code__c, Multiple_of__c FROM SKU__c LIMIT 1];
        Price_Book_Details__c pbdetails1 =  [SELECT Id, Unit_Price__c, Monthly_Interest_Rate__c,Future_Sales_Price_R__c, Future_Sales_Price_U__c, Unit_Price_R__c,
                                             Unit_Price_U__c, Minimum_Price_U__c, Minimum_Price_R__c, Volume__c, SKU__c FROM Price_Book_Details__c LIMIT 1];
        // Mock SalesOrderItem JSON string
        List<Grz_SalesOrderFeaturedProductsController.SalesOrderItem> solst = new List<Grz_SalesOrderFeaturedProductsController.SalesOrderItem>(); 
        Grz_SalesOrderFeaturedProductsController.SalesOrderItem wrapObj = new Grz_SalesOrderFeaturedProductsController.SalesOrderItem();
        wrapObj.productId = skurec.id;
        wrapObj.fatDate = '02/05/2018';
        wrapObj.qty = 50;
        wrapObj.listValue = 50;
        wrapObj.unitValue = 32;
        wrapObj.unitValueWithInterest = 32;
        wrapObj.productCode =  skurec.SKU_Code__c;
        wrapObj.totalValue = 12816;
        wrapObj.interestRate = 0;
        wrapObj.days = 0;
        wrapObj.priceBookDetailId = pbdetails1.Id;
        wrapObj.productName = '';
        wrapObj.inventory = 0;
        wrapObj.discount = 16.35;
        wrapObj.replacementMargin = 0;
        wrapObj.ledgerMargin = 63.1;
        wrapObj.totalValueWithInterest = 0;
        wrapObj.timeInMonths = 0;
        wrapObj.multipleOf = 0;
        wrapObj.priceBookDetailId = '';
        wrapObj.kitProduct = true;
        solst.add(wrapObj);
        String serlizeStr = JSON.serialize(solst); 
        
        Grz_SalesOrderFeaturedProductsController.OrderWrapper ow = Grz_SalesOrderFeaturedProductsController.saveSalesOrder(
            so2, 
            serlizeStr,
            false,
            '', // TCforBarterManagerProcess
            ''
        );
        
        Test.stopTest();
    }
    @isTest
    static void test_getFeaturedProducts() {
        SKU__c skurec = [SELECT Id, SKU_Description__c, SKU_Code__c, Multiple_of__c FROM SKU__c LIMIT 1];
        Price_Book__c priceBook = [SELECT Id FROM Price_Book__c LIMIT 1];
        Product_Mix__c prodMix = [SELECT Id FROM Product_Mix__c LIMIT 1];
        BrAvecSO__c settings = new BrAvecSO__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                               pricebookid__c=priceBook.Id, 
                                               productmixid__c=prodMix.Id,
                                               UPL__c = 'https://test.salesforce.com/upl/');
        insert settings;
        Price_Book_Details__c PBdetails = new Price_Book_Details__c(
            SKU__c = skurec.Id,                     
            Monthly_Interest_Rate__c = 1.00,          
            Price_Book__c = settings.pricebookid__c,                
            Exchange_Rate__c = 3.00,                 
            Unit_Price__c = 120.00,                  
            Minimum_Price__c = 75.00,                
            Minimum_Price_R__c = 5.00,        // Minimum Price R $
            Minimum_Price_U__c =2.00,        // Minimum Price U $
            Unit_Price_R__c = 28.14,          // Unit Price R $
            Unit_Price_U__c = 8.54,           // Unit Price U $
            Future_Sales_Price_R__c = 25.00,  // Future Sales Price R $
            Future_Sales_Price_U__c = 30.00,  // Future Sales Price U $
            Volume__c = 3000.00,             // Volume
            Equivalence__c = 0.00,            // % Equivalence
            Group__c = '001',                   // Group
            Sub_Group__c = 'Orthene',           // Sub Group
            Anchor__c = 'SIM',                  // Anchor
            Sub_Group_Required__c = 'SIM',
            Active__c = true,
            Exceptions_to_Multiples__c=20
        );
        insert PBdetails;
        Product_Mix_Details__c mixDetail = new Product_Mix_Details__c(
            SKU__c = skurec.Id,
            Product_Mix__c = settings.productmixid__c
        );
        insert mixDetail;
       Test.setMock(HttpCalloutMock.class, new Grz_SalesOrderFeaturedProductsMock());
        Test.startTest();
        //change
        account accc=[select id from account][0];
        try{Object result = Grz_SalesOrderFeaturedProductsController.getFeaturedProducts(userInfo.getUserId(),accc.id,null);}
        catch(exception e){}
        Test.stopTest();
    }
    
    @isTest
    static void test_getFeaturedProductsFail() {
        SKU__c skurec = [SELECT Id, SKU_Description__c, SKU_Code__c, Multiple_of__c FROM SKU__c LIMIT 1];
        Price_Book__c priceBook = [SELECT Id FROM Price_Book__c LIMIT 1];
        Product_Mix__c prodMix = [SELECT Id FROM Product_Mix__c LIMIT 1];
        BrAvecSO__c settings = new BrAvecSO__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                               pricebookid__c=priceBook.Id, 
                                               productmixid__c=prodMix.Id,
                                               UPL__c = 'https://test.salesforce.com/upl/');
        insert settings;
        Price_Book_Details__c PBdetails = new Price_Book_Details__c(
            SKU__c = skurec.Id,                     
            Monthly_Interest_Rate__c = 1.00,          
            Price_Book__c = settings.pricebookid__c,                
            Exchange_Rate__c = 3.00,                 
            Unit_Price__c = 120.00,                  
            Minimum_Price__c = 75.00,                
            Minimum_Price_R__c = 5.00,        // Minimum Price R $
            Minimum_Price_U__c =2.00,        // Minimum Price U $
            Unit_Price_R__c = 28.14,          // Unit Price R $
            Unit_Price_U__c = 8.54,           // Unit Price U $
            Future_Sales_Price_R__c = 25.00,  // Future Sales Price R $
            Future_Sales_Price_U__c = 30.00,  // Future Sales Price U $
            Volume__c = 3000.00,             // Volume
            Equivalence__c = 0.00,            // % Equivalence
            Group__c = '001',                   // Group
            Sub_Group__c = 'Orthene',           // Sub Group
            Anchor__c = 'SIM',                  // Anchor
            Sub_Group_Required__c = 'SIM',
            Active__c = true,
            Exceptions_to_Multiples__c=20
        );
        insert PBdetails;
        Product_Mix_Details__c mixDetail = new Product_Mix_Details__c(
            SKU__c = skurec.Id,
            Product_Mix__c = settings.productmixid__c
        );
        insert mixDetail;
       Test.setMock(HttpCalloutMock.class, new Grz_SalesOrderFeaturedProductsMockF());
        Test.startTest();
        //change
        account accc=[select id from account][0];
        try{
        Object result = Grz_SalesOrderFeaturedProductsController.getFeaturedProducts(userInfo.getUserId(),accc.id,null);
        }catch(exception e){}
        Test.stopTest();
    }
   
    @isTest
    static void test_getBannerData() {
        Id bannerRecordTypeId = Schema.SObjectType.Featured_Product__c.getRecordTypeInfosByDeveloperName().get('Banner').getRecordTypeId();
        SKU__c existingSKU = [SELECT Id, Brand_Name__c FROM SKU__c WHERE brand_name__c != null LIMIT 1];
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true, Combination_Key__c = '519110000000000006302804');
        insert prod;
        Featured_Product__c bannerProduct = new Featured_Product__c(
            Title__c = 'Banner Test Title',
            Description__c = 'Banner Test Description',
            SKU__c = existingSKU.Id,
            RecordTypeId = bannerRecordTypeId,
            Products__c  = prod.Id
        );
        insert bannerProduct;  
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'banner.jpg',
            VersionData = Blob.valueOf('dummy image content')
        );
        insert contentVersion;

        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id
        ];
        Id contentDocId = insertedVersion.ContentDocumentId;
        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = bannerProduct.Id,
            ContentDocumentId = contentDocId,
            ShareType = 'V'
        );
        insert link;
        ContentDistribution dist = new ContentDistribution(
            Name = 'Test Distribution',
            ContentVersionId = insertedVersion.Id,
            PreferencesAllowViewInBrowser = true
        );
        insert dist;
        Test.startTest();
        Grz_SalesOrderFeaturedProductsController.getBannerData(); // Replace YourClassName
        Test.stopTest();
        
    }
    @isTest
    static void testSummarizeByBrand() {
        String jsonInput = '{ "root": { "item": [ ' +
            '{ "Brand": "Brand A", "Batch_Expire_date": "2099-12-31", "Available_Quantity": 10, "Total_Quantity": 20, "Transfer": 1, "Quality_control": 2, "Restrict": 1, "Blocked": 1, "Returns": 1 },' +
            '{ "Brand": "Brand A", "Batch_Expire_date": "2099-12-31", "Available_Quantity": 0, "Total_Quantity": 20, "Transfer": 1, "Quality_control": 2, "Restrict": 1, "Blocked": 1, "Returns": 1 },' +
            '{ "Brand": "Brand B", "Batch_Expire_date": "2000-01-01", "Available_Quantity": 5, "Total_Quantity": 15, "Transfer": 1, "Quality_control": 2, "Restrict": 1, "Blocked": 1, "Returns": 1 },' +
            '{ "Brand": null, "Batch_Expire_date": "2099-12-31", "Available_Quantity": 10 },' +
            '{ "Brand": "Brand C", "Batch_Expire_date": "invalid-date", "Available_Quantity": 10 }' +
            '] } }';
        
        Test.startTest();
       // Set<String> result = Grz_SalesOrderFeaturedProductsController.summarizeByBrand(jsonInput);
        Test.stopTest();
        
       // System.assert(result.contains('Brand A'), 'Expected Brand A to be in the result');
       // System.assertEquals(1, result.size(), 'Only 1 brand should be valid and not expired');
    }
    
    @isTest public static void viewm7(){
        test.startTest();
        Grz_SalesOrderFeaturedProductsController.getEstimatedDeliveryDate('ACTT');
            test.stopTest();
    }
    
    @isTest public static void viewm3(){
        
        Sales_Order__c sobj=[SELECT OwnerId,SFDC_Order_Number__c,SAP_Order_Number__c,Order_Cancel__c,Sales_Org_lk__c,Order_Status__c,OrderSubStatus__c,Region_Territory__c,RequestforCancellationCheck__c,BudgetApprovalCheck__c,Flag_Status__c,BrazilOrderSubmittedforApproval__c,Price_Book__c,Inco_Term__c,Currency_Brazil__c,Key_Account__c,Sold_to_Party__c,Valid_FROM__c,Kit_Order__c,Valid_To__c,Payment_Term__c,Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c = 'CONTRATO MÃE' LIMIT 1];
        Sales_Order__c soChild=[SELECT CurrencyIsoCode,RecordTypeId,Parent_Order_Simulated__c,AVEC_Order__c,OwnerId,SFDC_Order_Number__c,SAP_Order_Number__c,Order_Cancel__c,Sales_Org_lk__c,Order_Status__c,OrderSubStatus__c,Region_Territory__c,RequestforCancellationCheck__c,BudgetApprovalCheck__c,Flag_Status__c,BrazilOrderSubmittedforApproval__c,Price_Book__c,Inco_Term__c,Currency_Brazil__c,Key_Account__c,Sold_to_Party__c,Valid_FROM__c,Kit_Order__c,Valid_To__c,Payment_Term__c,Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c ='VENDA NORMAL' LIMIT 1];
        Sales_Order_Line_Item__c soLineItm3=[SELECT Sale_Order__c,SKU_Name__c,Item_Number__c,Item_Status__c,Item_Cancel__c,Order_Item_Key__c,Sales_Org__c,PriceBookDetail__c,Approval_Flag__c,ExchangeRate__c,OrderQuantityEdited__c,Time_in_months__c,Days__c,DateofFAT__c,Quantity__c,UnitValue__c,UnitValuewithInterest__c,InterestRate__c,TotalTax__c,TotalFreight__c,TotalPunctuality__c,TotalLedgerCost__c,TotalReplacementCost__c,Customer_Conversion_Factor__c FROM Sales_Order_Line_Item__c WHERE Sale_Order__c = : sobj.Id limit 1 ];
        Sales_org__c sorg = [SELECT Id FROM Sales_org__c WHERE Sales_Org_Code__c = '5191'];
        Price_Book__c pricebook = [SELECT Id FROM Price_Book__c LIMIT 1];
        Sales_Order__c soMother = [SELECT id, Type_of_Order__c FROM Sales_Order__c WHERE SalesOrgCode__c = '5191' AND Type_of_Order__c = 'CONTRATO MÃE' LIMIT 1];
        Depot__c dep = [SELECT Id FROM Depot__c WHERE SalesOrg__c = :sorg.Id LIMIT 1]; 
        Account acc2 = [SELECT id, Customer_Group__c, Customer_Region__c FROM Account WHERE Sales_Org__c = :sorg.id AND Last_Name__c = 'INTERNATIONAL' LIMIT 1]; 
        
        Sales_Order__c so2=[SELECT Id,Sales_Order__c,PaymentMethod__c,Region_Territory__c,Call_Process_Builder_Flow__c,BudgetApprovalCheck__c,BrazilSalesOrderApproved__c,KeyAccountDesOwnerBrazil__c,TM_Code__c,Type_of_Order__c,Currency_Brazil__c,Valid_FROM__c,BrazilOrderSubmittedforApproval__c,Valid_To__c,Inco_Term__c,Key_Account__c,Ship_To_Party__c,Campaign_pricebook__c,Purchase_Order_Date__c,Business_Discount__c,Financial_Discount__c,Sold_to_Party__c,Sales_Org_lk__c,CurrencyIsoCode,Punctuality_Discount__c,Price_Book__c
                            FROM Sales_Order__c  where SalesOrgCode__c = '5191'AND Type_of_Order__c ='ORDEM FILHA' limit 1
                           ];
        
        SKU__c skurec = [SELECT Id, SKU_Description__c, SKU_Code__c, Multiple_of__c FROM SKU__c LIMIT 1];
        Culture__c culture = [SELECT Id FROM Culture__c LIMIT 1];
        Price_Book_Details__c pbdetails1 =  [SELECT Id, Unit_Price__c, Monthly_Interest_Rate__c,Future_Sales_Price_R__c, Future_Sales_Price_U__c, Unit_Price_R__c,
                                             Unit_Price_U__c, Minimum_Price_U__c, Minimum_Price_R__c, Volume__c, SKU__c FROM Price_Book_Details__c LIMIT 1];
        
        List<Grz_SalesOrderFeaturedProductsController.SalesOrderItem> solst = new List<Grz_SalesOrderFeaturedProductsController.SalesOrderItem>(); 
        Grz_SalesOrderFeaturedProductsController.SalesOrderItem wrapObj = new Grz_SalesOrderFeaturedProductsController.SalesOrderItem();
        wrapObj.productId = skurec.id;
        wrapObj.fatDate = '02/05/2018';
        wrapObj.qty = 50;
        wrapObj.listValue = 50;
        wrapObj.unitValue = 32;
        wrapObj.unitValueWithInterest = 32;
        wrapObj.productCode =  skurec.SKU_Code__c;
        wrapObj.totalValue = 12816;
        wrapObj.interestRate = 0;
        wrapObj.days = 0;
        wrapObj.cultureDesc = culture.Id;
        wrapObj.priceBookDetailId = pbdetails1.Id;
        wrapObj.productName = '';
        wrapObj.inventory = 0;
        wrapObj.discount = 16.35;
        wrapObj.replacementMargin = 0;
        wrapObj.ledgerMargin = 63.1;
        wrapObj.totalValueWithInterest = 0;
        wrapObj.timeInMonths = 0;
        wrapObj.multipleOf = 0;
        wrapObj.priceBookDetailId = '';
        wrapObj.kitProduct = true;
        solst.add(wrapObj);
        String serlizeStr = JSON.serialize(solst); 
        
        Map<String,Decimal> mapofsales = new Map<String,Decimal>();
        mapofsales.put(soLineItm3.Id,90);
        User u = [SELECT id FROM user WHERE profile.name='Brazil Sales Person' LIMIT 1];
        so2.KeyAccountDesOwnerBrazil__c = u.id;
        so2.OwnerId = null;
        so2.Order_Status__c = 'Draft';
        so2.BarterManager__c = null;
        test.starttest();
        soChild.Parent_Order_Simulated__c = null;
        List<Sales_Org__c> sorgList=new List<Sales_Org__c>();
        sorgList.add(sorg);
        soChild.Kit_Order__c = true;
        Grz_SalesOrderFeaturedProductsController.saveOrderItems(soChild,solst,sorgList,true);
        Sales_Order_Line_Item__c Sitm = [SELECT Id,Approval_Flag__c FROM Sales_Order_Line_Item__c WHERE Sale_Order__c =:sobj.Id];
        Sitm.Approval_Flag__c = 1.0;
        update Sitm;
        test.stoptest();
    }   
    @isTest
    static void testIndegenous() {
        test.starttest();
        Grz_SalesOrderFeaturedProductsController.getSOListCreated();
        Grz_SalesOrderFeaturedProductsController.getProductMixData();
        test.stoptest();
    }  
    @isTest
    static void testSharingRec() {
        sales_order__c so=[select id,ownerId from sales_order__c][0];
        user usObj=[select id from user where id !=: so.ownerId][0];
        Shipping_Location__c shipToParty = [SELECT Id,Distributor__c
                           FROM Shipping_Location__c][0];
        test.starttest();
       Grz_SalesOrderFeaturedProductsController.sharingRecordToOwner(so.id,usObj.id);
       Grz_SalesOrderFeaturedProductsController.getShippingLoations(shipToParty.Distributor__c);
        test.stoptest();
    }
     @isTest
    static void testMapSortByIntegerKey() {
        
        // Create test data
        List<Map<String, Object>> testList = new List<Map<String, Object>>();
        
        testList.add(new Map<String, Object>{ 'order' => 3, 'name' => 'C' });
        testList.add(new Map<String, Object>{ 'order' => 1, 'name' => 'A' });
        testList.add(new Map<String, Object>{ 'order' => 2, 'name' => 'B' });
        
        // Instantiate comparator
        Grz_SalesOrderFeaturedProductsController.MapSortByIntegerKey comparator =
            new Grz_SalesOrderFeaturedProductsController.MapSortByIntegerKey('order');
        
        // Sort the list
        testList.sort(comparator);
        
        // Assertions to verify sorting
        System.assertEquals(1, testList[0].get('order'));
        System.assertEquals(2, testList[1].get('order'));
        System.assertEquals(3, testList[2].get('order'));
        
        // Additional assertions for completeness
        System.assertEquals('A', testList[0].get('name'));
        System.assertEquals('B', testList[1].get('name'));
        System.assertEquals('C', testList[2].get('name'));
    }
    
     @isTest
    static void testReorderParallelList_AllScenarios() {
        
        // -------- Normal Case --------
        Map<String, Object> json = new Map<String, Object>();
        List<Object> data = new List<Object>{ 'A', 'B', 'C', 'D' };
        json.put('items', data);

        Grz_SalesOrderFeaturedProductsController.reorderParallelList(json, 'items', 2);

        List<Object> result = (List<Object>) json.get('items');
        System.assertEquals('C', result[0]);
        System.assertEquals(4, result.size());

        // -------- Key Not Present --------
        Map<String, Object> json2 = new Map<String, Object>();
        Grz_SalesOrderFeaturedProductsController.reorderParallelList(json2, 'missing', 1);
        System.assertEquals(0, json2.size());

        // -------- Single Element --------
        Map<String, Object> json3 = new Map<String, Object>();
        json3.put('items', new List<Object>{ 'X' });

        Grz_SalesOrderFeaturedProductsController.reorderParallelList(json3, 'items', 0);
        List<Object> result3 = (List<Object>) json3.get('items');
        System.assertEquals('X', result3[0]);

        // -------- Null List --------
        Map<String, Object> json4 = new Map<String, Object>();
        json4.put('items', null);

        Grz_SalesOrderFeaturedProductsController.reorderParallelList(json4, 'items', 0);
        System.assertEquals(null, json4.get('items'));
    }
}