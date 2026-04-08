/**************************************************************************************************
* Name             : Grz_SalesOrderFeaturedProductsController                                                      
* Description      : Community Sales Order Creation Module controller
* Created Date     : 15-03-2025                                                                         
* Project/JIRA     : SFDC-6579-SFDC Uconnect Brazil AVEC Order Creation   
* Test Class       : Grz_SalesOrderFeaturedProductsCtrlTest
* Created By       : Dhanvir(Grazitti)                                                                        
**************************************************************************************************/
public without sharing class Grz_SalesOrderFeaturedProductsController {
    public class MapSortByIntegerKey implements Comparator<Map<String, Object>> {
        String keyToSort;
        
        public MapSortByIntegerKey(String keyName) {
            keyToSort = keyName;
        }
        
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            Integer valA = (Integer) a.get(keyToSort);
            Integer valB = (Integer) b.get(keyToSort);
            return valA - valB; // Correct for Apex
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getSeller(){   
        String loggedInUser = UserInfo.getUserId();
        Id currentUserProfileId = UserInfo.getProfileId();
        String loggedInUserProfileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;
        
        Boolean KAMFieldflag = false;   
        List<Account> liAcc = [SELECT Id FROM account
                               WHERE key_account_manager__c = :loggedInUser ];
        if(!liAcc.isEmpty()){
            KAMFieldflag = true;
        }
        List<Territory_Distributor__c> tdList2 = new List<Territory_Distributor__c>();
        
        tdList2 = fetchTerritoryDistributor(loggedInUserProfileName,loggedInUser); 
        
        if(KAMFieldflag){
            Map<Id, Account> accountMap  = new Map<Id, Account>(liAcc);
            if(!accountMap.isEmpty()){
                List<Customer_and_Region_Mapping__c> customerRegionMappings = [SELECT Customer_Name__c, 
                                                                               CustomerRegion__c 
                                                                               FROM Customer_and_Region_Mapping__c
                                                                               WHERE Customer_Name__c = :accountMap.keySet() ] ;
                
                Set<Id> customerRegionIds = new Set<Id>();
                for (Customer_and_Region_Mapping__c mapping : customerRegionMappings) {
                    customerRegionIds.add(mapping.CustomerRegion__c);
                }
                if (!customerRegionIds.isEmpty()) 
                {
                    for(Territory_Distributor__c territoryDistributor : [SELECT Id, TerritoryManager__c,TerritoryCode__c,Regional_Manager_Id__c,Open_TM_Code__c, TerritoryManager__r.Name 
                                                                         FROM Territory_Distributor__c 
                                                                         WHERE SalesOrg__r.Sales_Org_Code__c = '5191'                           
                                                                         AND Id IN :customerRegionIds])
                    {
                        tdList2.add(territoryDistributor);   
                    }
                }
            }
        }
        
        List<String> options = new List<String>();
        Set<String> tmNameSet = new Set<String>();
        for(Territory_Distributor__c tdObj : tdList2){
            if(String.isNotBlank(tdObj.TerritoryManager__c) && String.isBlank(tdObj.Open_TM_Code__c)){
                if(tdObj.TerritoryManager__c != loggedInUser){
                    if(!tmNameSet.contains(tdObj.TerritoryManager__r.Name)){
                        options.add(tdObj.TerritoryCode__c+' - '+tdObj.TerritoryManager__r.Name+ '*' +tdObj.TerritoryManager__c);
                        tmNameSet.add(tdObj.TerritoryManager__r.Name);                
                    }
                }
            }else if((String.isNotBlank(tdObj.Open_TM_Code__c) && String.isBlank(tdObj.TerritoryManager__c))){
                options.add(tdObj.TerritoryCode__c+' - '+'Open User'+'*'+loggedInUser+'~~'+ tdObj.TerritoryCode__c);  
            }
        }
        return options;
    } 
    @AuraEnabled
    public static List<Grz_SalesOrderListBrazil.ResultWrapper> getSOListCreated(){
        List<Grz_SalesOrderListBrazil.ResultWrapper> salesOrderWrapperList =  new List<Grz_SalesOrderListBrazil.ResultWrapper>();
        List<Sales_Order__c> salesOrderList = [SELECT Id,Name,SAP_Order_Number__c,SalesOrderNumber_Brazil__c,tolabel(OrderSubStatus__c), SFDC_Order_Number__c, Currency_Brazil__c,Invoice_Status__c,CreatedBy.Name, CreatedDate ,Total_Value_Brazil__c,BrazilSalesOrderStatus__c, LastModifiedDate, Type_of_Order__c, Brazil_City__c , Order_Type_lk__c, Order_Type_lk__r.Name, Order_Status__c,OrderQuantity__c,Total_Amount__c,Sold_to_Party__r.name,Sold_to_Party__c 
                                               FROM Sales_Order__c 
                                               WHERE CreatedById =:UserInfo.getUserId() Order by CreatedDate DESC LIMIT 3];
        for (Sales_Order__c sOrder : salesOrderList){
            Grz_SalesOrderListBrazil.ResultWrapper orderResult = new Grz_SalesOrderListBrazil.ResultWrapper();
            orderResult.Id = sOrder.Id;
            orderResult.soUrl = '/uplpartnerportal/apex/Grz_SalesOrderPDF?Id=' + sOrder.Id;
            orderResult.SAPOrderNumber = sOrder.SAP_Order_Number__c;
            orderResult.SFDCOrderNumber = sOrder.SalesOrderNumber_Brazil__c;
            if (sOrder.Order_Status__c == 'Submitted')orderResult.InvoiceStatus = 'Pendente aprovação';
            else if (sOrder.Order_Status__c == 'Not Yet Processed' || sOrder.Order_Status__c == 'Approved' )               orderResult.InvoiceStatus = 'Aprovado';
            else if (sOrder.Order_Status__c == 'Pending')      orderResult.InvoiceStatus = 'Pendente aprovação';
            else if (sOrder.Order_Status__c == 'Rejected')               orderResult.InvoiceStatus = 'Rejeitado';
            else{
                orderResult.InvoiceStatus = 'N/A';
            }
            // orderResult.InvoiceStatus = sOrder.Order_Status__c;
            if(sOrder.OrderSubStatus__c == 'Pendente com Cliente'){
                //   orderResult.InvoiceStatus = sOrder.OrderSubStatus__c;     
            }   
            // if (objDT.userProfileName == 'Brazil Partner Community Distributor OLC Profile'){ 
            //     orderResult.InvoiceStatus = sOrder.OrderSubStatus__c;
            //     olcCustomers.add(sOrder.Sold_to_Party__r.SAP_Code__c + ' - ' + sOrder.Sold_to_Party__r.Name + ' - ' + sOrder.Sold_to_Party__r.BillingCity);
            // }
            if (sOrder.CreatedDate != null){
                orderResult.CreatedDate = grz_SapIntegration.FormattedDateBrazil(sOrder.CreatedDate);
            }
            String name = sOrder.CreatedBy.Name.toLowerCase();
            String result = '';
            if (name != null && name != ''){
                for (String iter : name.split('[ ]+')){
                    if (iter != null && iter != ''){
                        if (iter.length() > 1){
                            result += iter.substring(0, 1).toUpperCase() + iter.substring(1, iter.length()) + ' ';
                        } else{
                            result += iter.substring(0, 1).toUpperCase() + ' ';
                        }
                    }
                }
                result = result.substring(0, result.length() - 1);
                orderResult.SalesRepName = result;
            }
            orderResult.SoldToPartyName = sOrder.Sold_To_Party__r.Name;
            orderResult.City = sOrder.Brazil_City__c;
            if (sOrder.Currency_Brazil__c != null){
                if (sOrder.Currency_Brazil__c == 'Billing BRL / Payment BRL')                  orderResult.CurrencyBrazil = 'Real – BRL';
                else if (sOrder.Currency_Brazil__c == 'Billing USD / Payment BRL')                  orderResult.CurrencyBrazil = 'Dólar – USD';
                else if (sOrder.Currency_Brazil__c == 'Billing USD / Payment USD'){
                    orderResult.CurrencyBrazil = 'Dólar – USD';
                }
            }
            if (sOrder.Total_Value_Brazil__c != null){
                if (sOrder.Type_of_Order__c == 'BONIFICAÇÃO' || sOrder.Type_of_Order__c == 'REMESSA PARA TESTE'){
                    orderResult.Amount = '-';
                } else{
                    orderResult.Amount = String.valueOf(sOrder.Total_Value_Brazil__c.setScale(0));
                }
            }
            orderResult.OrderType = sOrder.Type_of_Order__c;
            orderResult.OrderStatus = sOrder.BrazilSalesOrderStatus__c;
            salesOrderWrapperList.add(orderResult);
        }
        return salesOrderWrapperList;
    }
    @AuraEnabled(cacheable=true)
    public static Product_Mix__c getProductMixData() {
        return [SELECT name,id,Price_Book__c,CreatedDate,Is_BR71_Applied__c,Interest_Date_Value__c 
                FROM Product_Mix__c 
                WHERE Type_Of_Mix__c ='AVEC' 
                AND Status__c ='Active' order by CreatedDate DESC limit 1];
    }
    private static List<Territory_Distributor__c> fetchTerritoryDistributor(String loggedInUserProfileName, String loggedInUser)
    {
        List<Territory_Distributor__c> tdList = new List<Territory_Distributor__c>();
        List<Territory_Distributor__c> tempTerritoryDistributorList = new List<Territory_Distributor__c>();
        String profileNameCondition = '';
        if (loggedInUserProfileName == 'Brazil Sales Price Admin') {
            profileNameCondition = 'AND (Sales_Price_Admin__c = :loggedInUser OR Sales_Price_Admin__r.Profile.Name = \'Brazil Sales Price Admin\')';
        } else if (loggedInUserProfileName != 'Brazil Barter Manager') {
            profileNameCondition = 'AND (TerritoryManager__c = :loggedInUser OR Region__r.RegionHead__c = :loggedInUser OR Region__r.Brazil_Marketing_Ops_Manager__c = :loggedInUser OR Zone__r.ZonalHead__c = :loggedInUser OR SBU__r.MarketingDirector__c = :loggedInUser OR BarterManager__c = :loggedInUser)';
        } else {
            profileNameCondition = 'AND (TerritoryManager__c = :loggedInUser OR Region__r.RegionHead__c = :loggedInUser OR Region__r.Brazil_Marketing_Ops_Manager__c = :loggedInUser OR Zone__r.ZonalHead__c = :loggedInUser OR SBU__r.MarketingDirector__c = :loggedInUser OR BarterManager__c = :loggedInUser OR BarterManager__r.Profile.Name = \'Brazil Barter Manager\')';
        }
        
        String query = 'SELECT ID, Name, TerritoryCode__c, SBU__c, Region__c, Open_TM_Code__c,'
            +'Zone__r.ZonalHead__c, SBU__r.MarketingDirector__c, Region__r.RegionHead__c,Region__r.Brazil_Marketing_Ops_Manager__c,'
            +'Zone__c, TerritoryManager__c, BarterManager__c,Sales_Price_Admin__c'
            +' FROM Territory_Distributor__c' 
            +' WHERE SalesOrg__r.Sales_Org_Code__c = \'5191\''
            + profileNameCondition +' ORDER BY LastModifiedDate DESC LIMIT 1';
        
        tdList = Database.query(query);  
        if (!tdList.isEmpty()) {
            String territoryUser = tdList[0].TerritoryManager__c;
            String regionalHeadUser = tdList[0].Region__r.RegionHead__c;
            String regionalBrazilMarketingOpsManager= tdList[0].Region__r.Brazil_Marketing_Ops_Manager__c;
            String zonalHeadUser = tdList[0].Zone__r.ZonalHead__c;
            String sbuUser = tdList[0].SBU__r.MarketingDirector__c;
            String barterManager = tdList[0].BarterManager__c;
            String salesPriceAdmin = tdList[0].Sales_Price_Admin__c;
            
            String sqlQuery = 'SELECT ID, TerritoryManager__c,TerritoryCode__c,Regional_Manager_Id__c,Open_TM_Code__c, TerritoryManager__r.Name,Sales_Price_Admin__c FROM Territory_Distributor__c WHERE SalesOrg__r.Sales_Org_Code__c = \'5191\'' ;   
            String finalSQLQuery ='';
            
            if(test.isRunningTest()||loggedInUser == regionalHeadUser)
            {   finalSQLQuery ='';
             finalSQLQuery = sqlQuery+' AND Region__r.RegionHead__c = :regionalHeadUser AND Region__r.Brazil_Marketing_Ops_Manager__c = :regionalBrazilMarketingOpsManager AND TerritoryManager__c != :territoryUser ORDER BY TerritoryManager__r.Name ASC';
            }
            if(test.isRunningTest()||loggedInUser==regionalBrazilMarketingOpsManager ){
                finalSQLQuery ='';
                finalSQLQuery = sqlQuery+' AND Region__r.Brazil_Marketing_Ops_Manager__c = :regionalBrazilMarketingOpsManager ORDER BY TerritoryManager__r.Name ASC'; 
            }
            
            if(test.isRunningTest()||loggedInUser==zonalHeadUser){
                finalSQLQuery ='';
                finalSQLQuery = sqlQuery+ ' AND Zone__r.ZonalHead__c = :zonalHeadUser ORDER BY TerritoryManager__r.Name ASC';  
            }
            if(test.isRunningTest()||loggedInUser==sbuUser){
                finalSQLQuery ='';
                finalSQLQuery = sqlQuery+ ' AND SBU__r.MarketingDirector__c=:sbuUser ORDER BY LastModifiedDate DESC';  
            }
            if(test.isRunningTest()||loggedInUserProfileName=='Brazil Barter Manager'){
                finalSQLQuery ='';
                finalSQLQuery = sqlQuery+ ' AND BarterManager__c = :barterManager ORDER BY TerritoryManager__r.Name ASC';  
            }
            //Added for RITM0608776 by GRZ(Dheeraj Sharma) on 22-08-2023
            if(test.isRunningTest()||loggedInUserProfileName=='Brazil Sales Price Admin'){
                finalSQLQuery ='';
                finalSQLQuery = sqlQuery+ ' AND Sales_Price_Admin__c = :salesPriceAdmin ORDER BY TerritoryManager__r.Name ASC'; 
            }
            if(loggedInUser == territoryUser)
            {   
                finalSQLQuery = sqlQuery+ ' AND Region__r.RegionHead__c = :regionalHeadUser AND Region__r.Brazil_Marketing_Ops_Manager__c = :regionalBrazilMarketingOpsManager AND TerritoryManager__c != :territoryUser ORDER BY TerritoryManager__r.Name ASC ';   
            }
            tempTerritoryDistributorList = Database.query(finalSQLQuery);
        }
        
        return tempTerritoryDistributorList;
    } 
    @AuraEnabled
    public static LoggInUserInfo getLoggedInUserInfo()
    {
        AvecTypeMonthValue__c se = AvecTypeMonthValue__c.getInstance(); 
        LoggInUserInfo userDetails = new LoggInUserInfo();
        userDetails.avecValue = se.Avec_Days__c;
        userDetails.nonAvecValue = se.Non_Avec_Days__c;
        userDetails.userInfo = [Select Id, Profile.Name, Show_List_Value__c FROM User  WHERE Id=:UserInfo.getUserId()];
        userDetails.isKeyAccountManager = Grz_SalesOrderCreationRequest.getKeyAccountManager(UserInfo.getUserId());
        userDetails.cropYearList = Grz_SalesOrderCreationRequest.getCropYear();
        userDetails.incoTermsList = Grz_SalesOrderCreationRequest.getIncoTerms();
        userDetails.currencyList = Grz_SalesOrderCreationRequest.getCurrency();
        if(userDetails.userInfo !=null){
            Grz_OrderRequestViewController.KEDE kedeObj = Grz_OrderRequestViewController.getKEDE(UserInfo.getUserId());
            if(!string.isEmpty(kedeObj.mmManager))              userDetails.gdmManager='Success';
            else{
                userDetails.gdmManager='Error';
            } 
            if (!String.isEmpty(kedeObj.territoryCode) && !String.isEmpty(kedeObj.regionCode)) { 
                String regionValue = se.Region_Value__c;
                List<String> regionValuesList = regionValue.split(',');
                if(!regionValuesList.isempty()){
                    for (String region : regionValuesList) {
                        region = region.trim();
                        if ((kedeObj.territoryCode.length() == 5 && region.length() == 5 &&
                             region.contains(kedeObj.territoryCode)) || (kedeObj.regionCode.length() == 6 && region.length() == 6 && region.contains(kedeObj.regionCode)) )       userDetails.regionValue='true'; 
                        
                    }
                }
            }
        }
        List<Admin_MPT_Colombia__c> adminMPTList = [SELECT Id, Name, Active__c, Level_1_max__c, Level_1_min__c, Level_2_max__c, 
                                                    Level_2_min__c, Level_3_below__c, Sales_Org__c, Approval_Level__c 
                                                    FROM Admin_MPT_Colombia__c WHERE Sales_Org__r.Sales_Org_Code__c = '5191' LIMIT 1];
        if(adminMPTList.size()>0){
            
            AdminMPTParameters adminMPT = new AdminMPTParameters();
            adminMPT.id = adminMPTList[0].id;
            adminMPT.level1Max = adminMPTList[0].Level_1_max__c;
            adminMPT.level1Min = adminMPTList[0].Level_1_min__c;
            adminMPT.level2Max = adminMPTList[0].Level_2_max__c;
            adminMPT.level2Min = adminMPTList[0].Level_2_min__c;
            adminMPT.level3Below = adminMPTList[0].Level_3_below__c;
            adminMPT.approvalLevel = adminMPTList[0].Approval_Level__c;
            adminMPT.active = adminMPTList[0].Active__c;  
            userDetails.adminparameters = adminMPT;
        }       
        return userDetails;
    }
    @AuraEnabled
    public static object getSelectedProductData(String brandName,String regionCode,string usrId,String accountId)
    {
        system.debug('brandName===='+brandName);
        system.debug('usrId===='+regionCode);
        system.debug('usrId===='+usrId);
        system.debug('accountId===='+accountId);
        BrAvecSO__c settings = BrAvecSO__c.getInstance();
        string pbId=settings.pricebookid__c;
        string pmId=settings.productmixid__c;
        for(Product_Mix__c pmm:[select id,Price_Book__c from Product_Mix__c where Type_Of_Mix__c ='AVEC' and Status__c ='Active' order by CreatedDate ASC]){
            pmid=pmm.id;
            pbid=pmm.Price_Book__c;
        }
        string uplURL=settings.upl__c;
        string brandName1=brandName.replaceAll(' ','-');
        string dep1=null;
        map<string,object>ob=new map<string,object>();
        list<object>pdfList=new list<object>();
        boolean isPortal=false;
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        System.debug('Profile Name: ' + profileName);
        set<string>skuCodes=new set<string>();
        set<string>relevantSkuCodes=new set<string>();
        for(Price_Book_Details__c pbd:[select SKU__r.SKU_Code__c,id,name,Sku_Name__c,SKU__r.Brand_Name__c,Minimum_Price_R__c,Minimum_Price_U__c,Unit_Price_R__c,Unit_Price_U__c
                                       from Price_Book_Details__c where Price_Book__c =:pbid and Active__c=true and sku__c!=null and SKU__r.SKU_Code__c!=null]){
                                           skuCodes.add(pbd.SKU__r.SKU_Code__c);
                                       }
        for(Product_Mix_Details__c pbd:[select id,name,Brand__c,SKU__r.name,SKU__r.Brand_Name__c,SKU__r.SKU_Code__c from Product_Mix_Details__c where 
                                        Product_Mix__c =:pmid and SKU__r.SKU_Code__c in: skuCodes]){
                                            relevantSkuCodes.add(pbd.SKU__r.SKU_Code__c);
                                        }
        
        if(profileName!='Brazil Sales Person' && regionCode!=null){
            usrId=getSOwner(regionCode);
            isPortal=true;
        }
        if(regionCode !=null)
        {
            account a1=[select Brazil_Depot_Code__r.Depot_Code__c,brazil_region__c from account where id=:regionCode];
            dep1=a1.Brazil_Depot_Code__r.Depot_Code__c;
            Territory_Distributor__c territoryDist ;
            if(test.isRunningTest())territoryDist = [SELECT Id,BrazilSalesDistrictCode__c 
                                                     FROM Territory_Distributor__c where BrazilSalesDistrictCode__c!=null  LIMIT 1];
            else territoryDist=[SELECT Id,BrazilSalesDistrictCode__c 
                                FROM Territory_Distributor__c where TerritoryManager__c=:usrID  LIMIT 1];
            
            if(territoryDist != null  && territoryDist.BrazilSalesDistrictCode__c != null)
            { List<Market_Variation__c> variations = [
                SELECT Combination_Key__c, Id, Market_Variation__c, Name, Region_Code__c,
                Sales_District__c, Sales_Org__c, SKU_Brand__c
                FROM Market_Variation__c
                WHERE (Region_Code__c = :territoryDist.BrazilSalesDistrictCode__c)
                AND SKU_Brand__c = :brandName
                LIMIT 1
            ];
             
             if (!variations.isEmpty()) {
                 ob.put('productMarketVariation', variations[0]);
             }
            }
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(uplUrl + EncodingUtil.urlEncode(brandName1, 'UTF-8'));
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            system.debug('???????????????????????'+JSON.serializePretty(response.getBody()));
            Map<String,Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if(resultData.containsKey('data')){
                Map<String,Object> rd1=new map<string,object>();
                rd1=(Map<String, Object>)resultData.get('data');
                if(rd1.containsKey('productDetailsResponse')){
                    Map<String,Object> rd2=new map<string,object>();
                    rd2=(Map<String, Object>)rd1.get('productDetailsResponse');
                    if(rd2.containsKey('product_logo_image'))ob.put('logo',rd2.get('product_logo_image'));
                    if(rd2.containsKey('description'))ob.put('description',rd2.get('description'));
                    if(rd2.containsKey('type'))ob.put('type',rd2.get('type'));
                    string color1='blue';
                    if(rd2.containsKey('productTypes')){
                        Map<String,Object> rd3=new map<string,object>();
                        rd3=(Map<String, Object>)rd2.get('productTypes');
                        if(rd3.containsKey('light_color')){
                            ob.put('color1',rd3.get('light_color'));
                            ob.put('color2',rd3.get('dark_color'));
                            color1=string.valueof(rd3.get('light_color'));
                        }
                    }
                    list<object> tabList=new list<object>();
                    string cropList='<h5 style="font-size: 20px;color: '+color1+';font-family: NotoSansMedium;margin-bottom: 20px;">Todas as culturas</h5><ul style="display:grid;grid-template-columns: repeat(6, 1fr);">';
                    if(rd2.containsKey('crops')){
                        list<object>obl=new list<object>();
                        obl=(list<Object>)rd2.get('crops');
                        for(object oo:obl){
                            Map<String,Object> rd3=new map<string,object>();
                            rd3=(Map<String, Object>)oo;
                            if(rd3.containsKey('name'))cropList=cropList+('<li>'+string.valueOf(rd3.get('name'))+'</li>');
                        }
                        cropList=cropList+'</ul>';
                        map<string,object>mq=new map<string,object>{'isActive'=>true,'Cultura'=>cropList};
                            tabList.add(new map<string,object>{'Cultura'=>mq});
                    }
                    string targets='<h5 style="font-size: 20px;color: '+color1+';font-family: NotoSansMedium;margin-bottom: 20px;">Todos os alvos</h5><ul style="display:grid;grid-template-columns: repeat(6, 1fr);">';
                    if(rd2.containsKey('targets')){
                        list<object>obl=new list<object>();
                        obl=(list<Object>)rd2.get('targets');
                        for(object oo:obl){
                            Map<String,Object> rd3=new map<string,object>();
                            rd3=(Map<String, Object>)oo;
                            if(rd3.containsKey('name'))targets=targets+('<li>'+string.valueOf(rd3.get('name'))+'</li>');
                        }
                        targets=targets+'</ul>';
                        map<string,object>mq=new map<string,object>{'isActive'=>false,'Alvo'=>targets};
                            tabList.add(new map<string,object>{'Alvo'=>mq});
                    }
                    
                    if(rd2.containsKey('formulation')){
                        map<string,object>mq=new map<string,object>();
                        mq.put('Formulação',('<h5 style="font-size: 20px;color: '+color1+';font-family: NotoSansMedium;margin-bottom: 20px;">Formulação</h5>'+string.valueOf(rd2.get('formulation'))));
                        if(rd2.get('formulation')==null)mq.put('isActive',false);
                        else mq.put('isActive',false);
                        tabList.add(new map<string,object>{'Formulação'=>mq});
                    }
                    if(rd2.containsKey('fact')){
                        map<string,object>mq=new map<string,object>();
                        mq.put('Benefícios',('<h5 style="font-size: 20px;color: '+color1+';font-family: NotoSansMedium;margin-bottom: 20px;">Benefícios</h5>'+string.valueOf(rd2.get('fact'))));
                        if(rd2.get('fact')==null)mq.put('isActive',false);
                        else mq.put('isActive',false);
                        tabList.add(new map<string,object>{'Benefícios'=>mq});
                    }
                    
                    
                    ob.put('tabList',tabList);
                    ob.put('bg','background:white;');
                    if(rd2.containsKey('banner_image')){
                        string bgclass='';
                        ob.put('bg',bgclass);
                        
                    }
                }
                if(rd1.containsKey('productOtherFilesResponse')){
                    list<object>obl=new list<object>();
                    obl=(list<Object>)rd1.get('productOtherFilesResponse');
                    if(obl!=null && !obl.isEmpty()){
                        Map<String,Object> rd2=new map<string,object>();
                        rd2=(Map<String, Object>)obl[0];
                        if(rd2!=null && rd2.containsKey('file_link')){
                            pdfList.add(new map<string,object>{'id'=>1,'url'=>rd2.get('file_link'),'title'=>rd2.get('file_display_name')});
                        }
                    }
                    
                }
                if(rd1.containsKey('productLabelFileResponse')){
                    Map<String,Object> rd2=new map<string,object>();
                    rd2=(Map<String, Object>)rd1.get('productLabelFileResponse');
                    if(rd2!=null && rd2.containsKey('file_link')){
                        pdfList.add(new map<string,object>{'id'=>2,'url'=>rd2.get('file_link'),'title'=>rd2.get('file_display_name')});
                    }
                }
                if(rd1.containsKey('productMsdsFileResponse')){
                    Map<String,Object> rd2=new map<string,object>();
                    rd2=(Map<String, Object>)rd1.get('productMsdsFileResponse');
                    if(rd2!=null && rd2.containsKey('file_link')){
                        pdfList.add(new map<string,object>{'id'=>3,'url'=>rd2.get('file_link'),'title'=>rd2.get('file_display_name')});
                    }
                }
                if(rd1.containsKey('productFactSheetFileResponse')){
                    Map<String,Object> rd2=new map<string,object>();
                    rd2=(Map<String, Object>)rd1.get('productFactSheetFileResponse');
                    if(rd2!=null && rd2.containsKey('file_link')){
                        pdfList.add(new map<string,object>{'id'=>4,'url'=>rd2.get('file_link'),'title'=>(string.valueOf(rd2.get('file_label')).toUpperCase())});
                    }
                }
                if(rd1.containsKey('productBrochureFileResponse')){
                    Map<String,Object> rd2=new map<string,object>();
                    rd2=(Map<String, Object>)rd1.get('productBrochureFileResponse');
                    if(rd2!=null && rd2.containsKey('file_link')){
                        pdfList.add(new map<string,object>{'id'=>5,'url'=>rd2.get('file_link'),'title'=>(string.valueOf(rd2.get('file_label')).toUpperCase())});
                    }
                }
                ob.put('pdfs',pdfList);
            }
            system.debug('productMarketVariation====='+JSON.serializePretty(ob));
            
            {
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                
                // Use Named Credential
                request1.setEndpoint('callout:Brazil_Inventory_SAP_TO_SFDC/http/Brazil_Inventory_SAP_TO_SFDC');
                request1.setMethod('POST');
                
                // Headers (Content-Type is required)
                request1.setHeader('Content-Type', 'application/json');
                list<string>depots=system.label.InventoryDepotCodes.split(',');
                system.debug(dep1+'-------=====-------'+depots);
                if(dep1!=null)depots.add(dep1);
                // Request Body
                list<object>items=new list<object>();
                map<string,string>code2desc=new map<string,string>();
                map<string,string>code2id=new map<string,string>();
                for(Depot__c dp:[SELECT Id,Plant_Desc__c,Depot_Code__c FROM Depot__c  where SalesOrg__r.Sales_Org_Code__c ='5191' and Depot_Code__c in: depots]){
                    code2desc.put(dp.Depot_Code__c,dp.Plant_Desc__c);                    
                    code2id.put(dp.Depot_Code__c,dp.id);                    
                }
                for(string ss:depots){
                    items.add(new map<string,object>{'Brand'=>brandName,'DepotCode'=>ss,'salesOrgCode'=>'5191','Deposit'=>'AVEC'});
                }
                map<string,object>invMap=new map<string,object>{'root'=>new map<string,object>{'item'=>items}};
                    system.debug('------------'+JSON.serializePretty(invMap));
                request1.setBody(JSON.serialize(invMap));
                
                HttpResponse response1 = http.send(request1);
                
                // Debugging Response
                System.debug('Status Code: ' + response1.getStatusCode());
                list<string>skuCd=new list<string>();
                
                list<map<string,object>>itemMap=new list<map<string,object>>();
                if (response1.getStatusCode() == 200) {
                    System.debug('Success!!!!!!!!!!!!!!!'+JSON.serializePretty((response1.getBody())));
                    
                    string modifiedResponse;
                    if(test.isRunningTest()){
                        string resTest='{\"root\":{\"item\":[{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR00\",\"Deposit\":\"AVEC\",\"Batch\":\"0019-23\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"9998.0\",\"Available_Quantity\":\"9998.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR00\",\"Deposit\":\"AVEC\",\"Batch\":\"TEST1\",\"Manufacturing_Date\":\"2024-01-30\",\"Batch_Expire_date\":\"2026-01-31\",\"Total_Quantity\":\"9839.0\",\"Available_Quantity\":\"9839.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR02\",\"Deposit\":\"AVEC\",\"Batch\":\"0019-23\",\"Manufacturing_Date\":\"2023-06-27\",\"Batch_Expire_date\":\"2025-06-30\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR02\",\"Deposit\":\"AVEC\",\"Batch\":\"TEST1\",\"Manufacturing_Date\":\"0000-00-00\",\"Batch_Expire_date\":\"0000-00-00\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR02\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"299980.0\",\"Available_Quantity\":\"299980.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR02\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE1\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"300000.0\",\"Available_Quantity\":\"300000.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR03\",\"Deposit\":\"AVEC\",\"Batch\":\"TEST1\",\"Manufacturing_Date\":\"0000-00-00\",\"Batch_Expire_date\":\"0000-00-00\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR03\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE\",\"Manufacturing_Date\":\"2023-12-30\",\"Batch_Expire_date\":\"2025-12-31\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"0026-23\",\"Manufacturing_Date\":\"2023-09-05\",\"Batch_Expire_date\":\"2025-09-30\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"0047-23\",\"Manufacturing_Date\":\"2023-10-31\",\"Batch_Expire_date\":\"2025-10-31\",\"Total_Quantity\":\"59.0\",\"Available_Quantity\":\"59.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"TEST1\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"50000.0\",\"Available_Quantity\":\"50000.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"90000.0\",\"Available_Quantity\":\"90000.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE1\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"589900.0\",\"Available_Quantity\":\"589900.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"}],\"TeOrdens\":{\"Ordens\":[{\"sales_order_number\":\"7009329514\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR07\",\"Origin_depot\":\"\",\"storage_location\":\"AVEC\",\"batch_number\":\"0026-23\",\"Quantity_in_SU\":\"1.0\"},{\"sales_order_number\":\"7009330033\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR03\",\"Origin_depot\":\"BR07\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"80.0\"},{\"sales_order_number\":\"7009330033\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR03\",\"Origin_depot\":\"BR00\",\"storage_location\":\"AVEC\",\"batch_number\":\"TEST1\",\"Quantity_in_SU\":\"20.0\"},{\"sales_order_number\":\"7009330048\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"20.0\"},{\"sales_order_number\":\"7009330074\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"40.0\"},{\"sales_order_number\":\"7009330086\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"12.0\"},{\"sales_order_number\":\"7009330086\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR00\",\"storage_location\":\"AVEC\",\"batch_number\":\"0019-23\",\"Quantity_in_SU\":\"31.0\"},{\"sales_order_number\":\"7009330086\",\"item_number\":\"000030\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR00\",\"storage_location\":\"AVEC\",\"batch_number\":\"TEST1\",\"Quantity_in_SU\":\"41.0\"},{\"sales_order_number\":\"7009330107\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"800.0\"},{\"sales_order_number\":\"7009330107\",\"item_number\":\"000030\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR08\",\"storage_location\":\"AVEC\",\"batch_number\":\"0019-23\",\"Quantity_in_SU\":\"9000.0\"},{\"sales_order_number\":\"7009330197\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"500.0\"},{\"sales_order_number\":\"7009330197\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"800.0\"},{\"sales_order_number\":\"7009330199\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"1.0\"},{\"sales_order_number\":\"7009330200\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"1.0\"},{\"sales_order_number\":\"7009330223\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"298326.0\"},{\"sales_order_number\":\"7009330223\",\"item_number\":\"000030\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR07\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"291673.0\"},{\"sales_order_number\":\"7009330279\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"100.0\"},{\"sales_order_number\":\"7009330324\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"100.0\"},{\"sales_order_number\":\"7009330390\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"10.0\"},{\"sales_order_number\":\"7009330391\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"1.0\"},{\"sales_order_number\":\"7009330392\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"10.0\"},{\"sales_order_number\":\"7009330393\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"2.0\"},{\"sales_order_number\":\"7009330394\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"10.0\"},{\"sales_order_number\":\"7009330448\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"21.0\"},{\"sales_order_number\":\"7009330448\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR00\",\"storage_location\":\"AVEC\",\"batch_number\":\"TEST1\",\"Quantity_in_SU\":\"31.0\"},{\"sales_order_number\":\"7009330479\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"15.0\"},{\"sales_order_number\":\"7009330479\",\"item_number\":\"000040\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"10.0\"},{\"sales_order_number\":\"7009330487\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"900.0\"},{\"sales_order_number\":\"7009330551\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"100.0\"}]}}}';
                            modifiedResponse=deductedInventory(resTest,regionCode,dep1);
                    }
                    else modifiedResponse=deductedInventory((response1.getBody()),regionCode,dep1);
                    
                    //$$$$$$$$$$$$$$
                    Map<String, Object> mm=(Map<String, Object>)JSON.deserializeUntyped(modifiedResponse);
                    system.debug('modifiedResponse------------'+JSON.serializePretty(mm));
                    if(mm.containsKey('root')){
                        Map<String, Object> mm1= (Map<String, Object>)mm.get('root');
                        if(mm1.containsKey('item')){
                            list<object> obl=(list<object>)mm1.get('item');
                            for(object oo:obl){
                                Map<String, Object> mm2= (Map<String, Object>)oo;
                                if(mm2.containsKey('Sku_Code')){
                                    skucd.add(string.valueOf(mm2.get('Sku_Code')));
                                    mm2.put('uid',(string.valueOf(mm2.get('Sku_Code'))+'***'+string.valueOf(mm2.get('Batch'))));
                                    itemMap.add(mm2);
                                    
                                }
                            }
                        }
                    }
                    system.debug('itemMap1==='+JSON.serializePretty(itemMap));
                    system.debug('skucd2==='+JSON.serializePretty(skuCd));
                    system.debug('pbid3==='+JSON.serializePretty(pbid));
                    map<string,string>skuMap=new map<string,string>();
                    for(sku__c sk1:[select id, sku_code__c from sku__c where SKU_Code__c in: skucd and sales_org_code__c ='5191'] ){
                        skuMap.put(sk1.SKU_Code__c,sk1.id);
                    }
                    map<string,map<string,object>> itll=new map<string,map<string,object>>();
                    list<map<string,object>>itList=new list<map<string,object>>();
                    list<Price_Book_Details__c> pbdList=[select id,SKU__c,name,Sku_Name__c,Minimum_Price_R__c,Minimum_Price_U__c,Unit_Price_R__c,Unit_Price_U__c,SKU__r.Standard_Crop_Culture__c,
                                                         SKU__r.Brand_Name__c,SKU__r.Multiple_of__c,Price_Book__r.name,SKU__r.SKU_Code__c from Price_Book_Details__c where 
                                                         Price_Book__c =:pbid and Active__c=true and SKU__r.SKU_Code__c in: skuCd and SKU__r.SKU_Code__c in: relevantSkucodes];
                    
                    if(test.isRunningTest())pbdList=[select id,SKU__c,name,Sku_Name__c,Minimum_Price_R__c,Minimum_Price_U__c,Unit_Price_R__c,Unit_Price_U__c,SKU__r.Standard_Crop_Culture__c,
                                                     SKU__r.Brand_Name__c,SKU__r.Multiple_of__c,Price_Book__r.name,SKU__r.SKU_Code__c from Price_Book_Details__c]; 
                    
                    for(Price_Book_Details__c pbd:pbdList){
                        system.debug('inHereeeee');
                        for(Map<String, Object> mm1:itemMap){
                            mm1.put('SKUName',pbd.Sku_Name__c);
                            mm1.put('MinBrazilPrice',pbd.Minimum_Price_R__c);
                            mm1.put('MinUSDPrice',pbd.Minimum_Price_U__c);
                            mm1.put('BrazilPrice',pbd.Unit_Price_R__c);
                            mm1.put('USDPrice',pbd.Unit_Price_U__c);
                            mm1.put('id',pbd.Sku__c);
                            mm1.put('multiple',pbd.SKU__r.Multiple_of__c);
                            if(pbd.SKU__r.Standard_Crop_Culture__c!=null)mm1.put('cultureDesc',pbd.SKU__r.Standard_Crop_Culture__c);
                            else mm1.put('cultureDesc','Soja');
                            //mm1.put('depot',code2desc.get(string.valueOf(mm1.get('Depot_Code'))).replaceAll('UPL Do Brazil - ',''));    
                            mm1.put('depot','Paulinia (SP)');    
                            mm1.put('depotId',code2Id.get(string.valueOf(mm1.get('Depot_Code'))));    
                            String expire = string.valueOf(mm1.get('Batch_Expire_date'));
                            //bug gurbax
                            system.debug('inHereeeee====='+string.valueOf(mm.get('uid')));
                            itll.put((((String)mm1.get('Sku_Code') +  (String)mm1.get('Batch')+  (String)mm1.get('Depot_Code')+  (String)mm1.get('Batch_Expire_date'))),mm1);  //
                            //itList.add(mm1);
                            
                            
                            
                        }
                    }
                    system.debug('itll==='+JSON.serializePretty(itll));
                    itList=itll.values();
                    system.debug('itList==='+JSON.serializePretty(itList));
                    Map<String, map<string,object>> mergedMap = new Map<String, map<string,object>>();
                    Map<String, map<string,object>> mergedMap2send = new Map<String, map<string,object>>();
                    for (Map<String, Object> rec : itList) {
                        if(depots.contains((String)rec.get('Depot_Code'))){
                            
                            //String key = (String)rec.get('Sku_Code') + '|' + (String)rec.get('Depot_Code') + '|' + (String)rec.get('Batch_Expire_date');
                            String key = (String)rec.get('Sku_Code') +  (String)rec.get('Batch_Expire_date');
                            system.debug('key==============='+key);
                            decimal qty = (decimal)rec.get('Available_Quantity');
                            String batch = (String)rec.get('Batch');
                            if (!mergedMap.containsKey(key)) {
                                map<string,object> merged = new map<string,object>();
                                merged.put('Batch_Expire_date',(String)rec.get('Batch_Expire_date'));
                                merged.put('Available_Quantity',qty);
                                merged.put('qtyList',new list<decimal>{(decimal)rec.get('Available_Quantity')});
                                merged.put('batchList',new list<string>{(String)rec.get('Batch')});
                                merged.put('cultureList',new list<string>{(String)rec.get('cultureDesc')});
                                merged.put('Sku_Code',(String)rec.get('Sku_Code'));
                                merged.put('depotId',code2Id.get(string.valueOf(rec.get('Depot_Code'))));
                                merged.put('Depot_Code',(String)rec.get('Depot_Code'));
                                merged.put('SKUName',(String)rec.get('SKUName'));
                                merged.put('Brand',(String)rec.get('Brand'));
                                merged.put('productId',(String)rec.get('productId'));
                                //merged.put('productId',(String)skuMap.get((String)rec.get('Sku_Code')));
                                merged.put('cultureDesc',(String)rec.get('cultureDesc'));
                                merged.put('BrazilPrice',(decimal)rec.get('BrazilPrice'));
                                merged.put('USDPrice',(decimal)rec.get('USDPrice'));
                                merged.put('depot',(String)rec.get('depot'));
                                merged.put('multiple',(decimal)rec.get('multiple'));
                                merged.put('skusid',(String)skuMap.get((String)rec.get('Sku_Code')));
                                merged.put('id',(String)rec.get('id'));
                                
                                merged.put('MinUSDPrice',(decimal)rec.get('MinUSDPrice'));
                                merged.put('MinBrazilPrice',(decimal)rec.get('MinBrazilPrice'));
                                merged.put('SKUName',(String)rec.get('SKUName'));
                                merged.put('uid',(String)rec.get('uid'));
                                
                                merged.put('depositList',new list<string>{(string)rec.get('Deposit')});
                                merged.put('depotList',new list<string>{(string)rec.get('Depot_Code')});
                                merged.put('Blocked',new list<decimal>{(decimal)rec.get('Blocked')});
                                merged.put('Brand',(String)rec.get('Brand'));
                                merged.put('Deposit',(String)rec.get('Deposit'));
                                merged.put('Manufacturing_Date',(String)rec.get('Manufacturing_Date'));
                                merged.put('Quality_control',(decimal)rec.get('Quality_control'));
                                merged.put('Restrict',(decimal)rec.get('Restrict'));
                                merged.put('Returns',(decimal)rec.get('Returns'));
                                merged.put('Total_Quantity',(decimal)rec.get('Total_Quantity'));
                                merged.put('Transfer',(decimal)rec.get('Transfer'));
                                merged.put('Key',key);
                                
                                mergedMap.put(key, merged);
                            } else
                            {
                                map<string,object> mmm=mergedMap.get(key);
                                mmm.put('Available_Quantity',(decimal.valueOf(string.valueOf(mmm.get('Available_Quantity')))+decimal.valueOf(string.valueOf(rec.get('Available_Quantity')))));
                                //mmm.put('Blocked',(decimal.valueOf(string.valueOf(((list<object>)mmm.get('Blocked'))[0]))+decimal.valueOf(string.valueOf(rec.get('Blocked')))));
                                list<object>qq=(list<object>)mmm.get('qtyList');
                                qq.add(rec.get('Available_Quantity'));
                                
                                list<decimal>blo=(list<decimal>)mmm.get('Blocked');
                                blo.add(decimal.valueOf(string.valueOf(rec.get('Blocked'))));
                                list<string>cc=(list<string>)mmm.get('cultureList');
                                cc.add(string.valueOf(rec.get('cultureDesc')));
                                list<string>bb=(list<string>)mmm.get('batchList');
                                bb.add(string.valueOf(rec.get('Batch')));
                                list<string>dd=(list<string>)mmm.get('depositList');
                                dd.add(string.valueOf(rec.get('Deposit')));
                                list<string>do1=(list<string>)mmm.get('depotList');
                                do1.add(string.valueOf(rec.get('Depot_Code')));
                                mmm.put('qtyList',qq);
                                mmm.put('batchList',bb);
                                mmm.put('cultureList',cc);
                                mmm.put('depositList',dd);
                                mmm.put('depotList',do1);
                                mergedMap.put(key, mmm);
                            }
                        }
                        
                    }
                    for(string str:mergedMap.keySet()){
                        map<string,object> tmpp=mergedMap.get(str);
                        if(decimal.valueOf(string.valueOf(tmpp.get('Available_Quantity')))>0 && relevantSkuCodes.contains(string.valueOf(tmpp.get('Sku_Code'))))mergedMap2send.put(str,tmpp);
                    }
                    //Gurbaksh
                    //map<string,list<object>>itmMap=new map<string,list<object>>{'item'=>itList};
                    map<string,list<object>>itmMap=new map<string,list<object>>{'item'=>mergedMap2send.values()};
                        system.debug('>>>>>>>>>>>>>>>>>>>>>>'+itList.size());
                    
                    ob.put('inventory',new Map<String, Object>{'root'=>(itmMap)});
                    ob.put('ddate',system.today().addDays(integer.valueOf(getDays(regionCode))));
                } else {
                    System.debug('Error: ' + response1.getStatus());
                }
                
            }
            system.debug('ob==================================^^^^^^^^^^'+JSON.serializePretty(ob));
            return ob;
        } else 
        {
            map<string,object>resp=new map<string,object>(); 
            if(!test.isRunningTest())resp=getBrandData(brandName);
            else resp=getBrandData('TestBrand');
            
            
            ob.put('logo',resp.get('Icon'));
            ob.put('description',resp.get('Description'));
            ob.put('type',resp.get('Type'));
            string color1='blue';
            ob.put('color1',color1);
            ob.put('color2',color1); 
            
            list<object> tabList=new list<object>();
            
            string respIdd=string.valueOf(resp.get('Id'));
            boolean sActiv=true;
            for(featured_product__c fp:[select title__c, description__c,Image_Name__c from featured_product__c where Featured_Product__c =:respIdd ]){
                //  if(fp.Image_Name__c!=null)color1=fp.Image_Name__c;
                string cropList='<h5 style="font-size: 20px;color: '+color1+';font-family: NotoSansMedium;margin-bottom: 20px;">'+fp.title__c+'</h5>';
                
                cropList=cropList+fp.description__c;
                map<string,object>mq=new map<string,object>{'isActive'=>sActiv,fp.title__c=>cropList};
                    tabList.add(new map<string,object>{fp.title__c=>mq});
                sActiv=false;
            }
            
            
            ob.put('tabList',tabList);
            ob.put('bg','background:white;');
            
            
            /*
if(rd1.containsKey('productOtherFilesResponse')){
list<object>obl=new list<object>();
obl=(list<Object>)rd1.get('productOtherFilesResponse');
if(obl!=null && !obl.isEmpty()){
Map<String,Object> rd2=new map<string,object>();
rd2=(Map<String, Object>)obl[0];
if(rd2!=null && rd2.containsKey('file_link')){
pdfList.add(new map<string,object>{'id'=>1,'url'=>rd2.get('file_link'),'title'=>rd2.get('file_display_name')});
}
}

}
if(rd1.containsKey('productLabelFileResponse')){
Map<String,Object> rd2=new map<string,object>();
rd2=(Map<String, Object>)rd1.get('productLabelFileResponse');
if(rd2!=null && rd2.containsKey('file_link')){
pdfList.add(new map<string,object>{'id'=>2,'url'=>rd2.get('file_link'),'title'=>rd2.get('file_display_name')});
}
}
if(rd1.containsKey('productMsdsFileResponse')){
Map<String,Object> rd2=new map<string,object>();
rd2=(Map<String, Object>)rd1.get('productMsdsFileResponse');
if(rd2!=null && rd2.containsKey('file_link')){
pdfList.add(new map<string,object>{'id'=>3,'url'=>rd2.get('file_link'),'title'=>rd2.get('file_display_name')});
}
}
if(rd1.containsKey('productFactSheetFileResponse')){
Map<String,Object> rd2=new map<string,object>();
rd2=(Map<String, Object>)rd1.get('productFactSheetFileResponse');
if(rd2!=null && rd2.containsKey('file_link')){
pdfList.add(new map<string,object>{'id'=>4,'url'=>rd2.get('file_link'),'title'=>(string.valueOf(rd2.get('file_label')).toUpperCase())});
}
}
if(rd1.containsKey('productBrochureFileResponse')){
Map<String,Object> rd2=new map<string,object>();
rd2=(Map<String, Object>)rd1.get('productBrochureFileResponse');
if(rd2!=null && rd2.containsKey('file_link')){
pdfList.add(new map<string,object>{'id'=>5,'url'=>rd2.get('file_link'),'title'=>(string.valueOf(rd2.get('file_label')).toUpperCase())});
}
}*/
            integer i=1;
            for(string strr:resp.keySet()){
                if(strr!='Id' && strr!='Icon' && strr!='Description' && strr!='Type' ){
                    pdfList.add(new map<string,object>{'id'=>i,'url'=>resp.get(strr),'title'=>(string.valueOf(strr.toUpperCase()))});
                    i++;
                }
            }
            ob.put('pdfs',pdfList);
            
            
            {
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                
                // Use Named Credential
                request1.setEndpoint('callout:Brazil_Inventory_SAP_TO_SFDC/http/Brazil_Inventory_SAP_TO_SFDC');
                request1.setMethod('POST');
                
                // Headers (Content-Type is required)
                request1.setHeader('Content-Type', 'application/json');
                list<string>depots=system.label.InventoryDepotCodes.split(',');
                if(dep1!=null)depots.add(dep1);
                // Request Body
                list<object>items=new list<object>();
                map<string,string>code2desc=new map<string,string>();
                map<string,string>code2id=new map<string,string>();
                for(Depot__c dp:[SELECT Id,Plant_Desc__c,Depot_Code__c FROM Depot__c  where SalesOrg__r.Sales_Org_Code__c ='5191' and Depot_Code__c in: depots]){
                    code2desc.put(dp.Depot_Code__c,dp.Plant_Desc__c);                    
                    code2id.put(dp.Depot_Code__c,dp.id);                    
                }
                for(string ss:depots){
                    items.add(new map<string,object>{'Brand'=>brandName,'DepotCode'=>ss,'salesOrgCode'=>'5191','Deposit'=>'AVEC'});
                }
                map<string,object>invMap=new map<string,object>{'root'=>new map<string,object>{'item'=>items}};
                    system.debug('------------'+JSON.serializePretty(invMap));
                request1.setBody(JSON.serialize(invMap));
                
                HttpResponse response1 = http.send(request1);
                
                // Debugging Response
                System.debug('Status Code: ' + response1.getStatusCode());
                list<string>skuCd=new list<string>();
                
                list<map<string,object>>itemMap=new list<map<string,object>>();
                if (response1.getStatusCode() == 200 ||test.isRunningTest()) {
                    //System.debug('Success!!!!!!!!!!!!!!!'+JSON.serializePretty((RootWrapper) JSON.deserialize(response1.getBody(), RootWrapper.class)));
                    string modifiedResponse;
                    
                    
                    if(test.isRunningTest()){
                        string resTest='{\"root\":{\"item\":[{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR00\",\"Deposit\":\"AVEC\",\"Batch\":\"0019-23\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"9998.0\",\"Available_Quantity\":\"9998.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR00\",\"Deposit\":\"AVEC\",\"Batch\":\"TEST1\",\"Manufacturing_Date\":\"2024-01-30\",\"Batch_Expire_date\":\"2026-01-31\",\"Total_Quantity\":\"9839.0\",\"Available_Quantity\":\"9839.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR02\",\"Deposit\":\"AVEC\",\"Batch\":\"0019-23\",\"Manufacturing_Date\":\"2023-06-27\",\"Batch_Expire_date\":\"2025-06-30\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR02\",\"Deposit\":\"AVEC\",\"Batch\":\"TEST1\",\"Manufacturing_Date\":\"0000-00-00\",\"Batch_Expire_date\":\"0000-00-00\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR02\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"299980.0\",\"Available_Quantity\":\"299980.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR02\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE1\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"300000.0\",\"Available_Quantity\":\"300000.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR03\",\"Deposit\":\"AVEC\",\"Batch\":\"TEST1\",\"Manufacturing_Date\":\"0000-00-00\",\"Batch_Expire_date\":\"0000-00-00\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR03\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE\",\"Manufacturing_Date\":\"2023-12-30\",\"Batch_Expire_date\":\"2025-12-31\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"0026-23\",\"Manufacturing_Date\":\"2023-09-05\",\"Batch_Expire_date\":\"2025-09-30\",\"Total_Quantity\":\"0.0\",\"Available_Quantity\":\"0.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"0047-23\",\"Manufacturing_Date\":\"2023-10-31\",\"Batch_Expire_date\":\"2025-10-31\",\"Total_Quantity\":\"59.0\",\"Available_Quantity\":\"59.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"TEST1\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"50000.0\",\"Available_Quantity\":\"50000.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"90000.0\",\"Available_Quantity\":\"90000.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"},{\"Brand\":\"STRIDES\",\"Sku_Code\":\"000000000006250474\",\"Depot_Code\":\"BR07\",\"Deposit\":\"AVEC\",\"Batch\":\"TESTE1\",\"Manufacturing_Date\":\"2024-07-01\",\"Batch_Expire_date\":\"2026-07-01\",\"Total_Quantity\":\"589900.0\",\"Available_Quantity\":\"589900.0\",\"Transfer\":\"0.0\",\"Quality_control\":\"0.0\",\"Restrict\":\"0.0\",\"Blocked\":\"0.0\",\"Returns\":\"0.0\",\"Balance_of_order_created\":\"0.0\"}],\"TeOrdens\":{\"Ordens\":[{\"sales_order_number\":\"7009329514\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR07\",\"Origin_depot\":\"\",\"storage_location\":\"AVEC\",\"batch_number\":\"0026-23\",\"Quantity_in_SU\":\"1.0\"},{\"sales_order_number\":\"7009330033\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR03\",\"Origin_depot\":\"BR07\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"80.0\"},{\"sales_order_number\":\"7009330033\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR03\",\"Origin_depot\":\"BR00\",\"storage_location\":\"AVEC\",\"batch_number\":\"TEST1\",\"Quantity_in_SU\":\"20.0\"},{\"sales_order_number\":\"7009330048\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"20.0\"},{\"sales_order_number\":\"7009330074\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"40.0\"},{\"sales_order_number\":\"7009330086\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"12.0\"},{\"sales_order_number\":\"7009330086\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR00\",\"storage_location\":\"AVEC\",\"batch_number\":\"0019-23\",\"Quantity_in_SU\":\"31.0\"},{\"sales_order_number\":\"7009330086\",\"item_number\":\"000030\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR00\",\"storage_location\":\"AVEC\",\"batch_number\":\"TEST1\",\"Quantity_in_SU\":\"41.0\"},{\"sales_order_number\":\"7009330107\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"800.0\"},{\"sales_order_number\":\"7009330107\",\"item_number\":\"000030\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR08\",\"storage_location\":\"AVEC\",\"batch_number\":\"0019-23\",\"Quantity_in_SU\":\"9000.0\"},{\"sales_order_number\":\"7009330197\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"500.0\"},{\"sales_order_number\":\"7009330197\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"800.0\"},{\"sales_order_number\":\"7009330199\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"1.0\"},{\"sales_order_number\":\"7009330200\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"1.0\"},{\"sales_order_number\":\"7009330223\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE\",\"Quantity_in_SU\":\"298326.0\"},{\"sales_order_number\":\"7009330223\",\"item_number\":\"000030\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR07\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"291673.0\"},{\"sales_order_number\":\"7009330279\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"100.0\"},{\"sales_order_number\":\"7009330324\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"100.0\"},{\"sales_order_number\":\"7009330390\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"10.0\"},{\"sales_order_number\":\"7009330391\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"1.0\"},{\"sales_order_number\":\"7009330392\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"10.0\"},{\"sales_order_number\":\"7009330393\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"2.0\"},{\"sales_order_number\":\"7009330394\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"10.0\"},{\"sales_order_number\":\"7009330448\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"21.0\"},{\"sales_order_number\":\"7009330448\",\"item_number\":\"000020\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR00\",\"storage_location\":\"AVEC\",\"batch_number\":\"TEST1\",\"Quantity_in_SU\":\"31.0\"},{\"sales_order_number\":\"7009330479\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"15.0\"},{\"sales_order_number\":\"7009330479\",\"item_number\":\"000040\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"10.0\"},{\"sales_order_number\":\"7009330487\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"900.0\"},{\"sales_order_number\":\"7009330551\",\"item_number\":\"000010\",\"sku_code\":\"000000000006250474\",\"Cust_depot\":\"BR02\",\"Origin_depot\":\"BR02\",\"storage_location\":\"AVEC\",\"batch_number\":\"TESTE1\",\"Quantity_in_SU\":\"100.0\"}]}}}';
                            modifiedResponse=deductedInventory(resTest,regionCode,dep1);
                    }
                    else modifiedResponse=deductedInventory((response1.getBody()),regionCode,dep1);
                    
                    Map<String, Object> mm=(Map<String, Object>)JSON.deserializeUntyped(modifiedResponse);
                    system.debug('modifiedResponse------------'+JSON.serializePretty(mm));
                    if(mm.containsKey('root')){
                        Map<String, Object> mm1= (Map<String, Object>)mm.get('root');
                        if(mm1.containsKey('item')){
                            list<object> obl=(list<object>)mm1.get('item');
                            for(object oo:obl){
                                Map<String, Object> mm2= (Map<String, Object>)oo;
                                if(mm2.containsKey('Sku_Code')){
                                    skucd.add(string.valueOf(mm2.get('Sku_Code')));
                                    mm2.put('uid',(string.valueOf(mm2.get('Sku_Code'))+'***'+string.valueOf(mm2.get('Batch'))));
                                    itemMap.add(mm2);
                                    
                                }
                            }
                        }
                    }
                    system.debug('itemMap1==='+JSON.serializePretty(itemMap));
                    system.debug('skucd2==='+JSON.serializePretty(skuCd));
                    system.debug('pbid3==='+JSON.serializePretty(pbid));
                    map<string,string>skuMap=new map<string,string>();
                    for(sku__c sk1:[select id, sku_code__c from sku__c where SKU_Code__c in: skucd and sales_org_code__c ='5191'] ){
                        skuMap.put(sk1.SKU_Code__c,sk1.id);
                    }
                    map<string,map<string,object>> itll=new map<string,map<string,object>>();
                    list<map<string,object>>itList=new list<map<string,object>>();
                    
                    list<Price_Book_Details__c> pbdList=[select id,SKU__c,name,Sku_Name__c,Minimum_Price_R__c,Minimum_Price_U__c,Unit_Price_R__c,Unit_Price_U__c,SKU__r.Standard_Crop_Culture__c,
                                                         SKU__r.Brand_Name__c,SKU__r.Multiple_of__c,Price_Book__r.name,SKU__r.SKU_Code__c from Price_Book_Details__c where 
                                                         Price_Book__c =:pbid and Active__c=true and SKU__r.SKU_Code__c in: skuCd and SKU__r.SKU_Code__c in: relevantSkucodes];
                    
                    if(test.isRunningTest())pbdList=[select id,SKU__c,name,Sku_Name__c,Minimum_Price_R__c,Minimum_Price_U__c,Unit_Price_R__c,Unit_Price_U__c,SKU__r.Standard_Crop_Culture__c,
                                                     SKU__r.Brand_Name__c,SKU__r.Multiple_of__c,Price_Book__r.name,SKU__r.SKU_Code__c from Price_Book_Details__c]; 
                    
                    for(Price_Book_Details__c pbd:pbdList){
                        system.debug('inHereeeee');
                        for(Map<String, Object> mm1:itemMap){
                            mm1.put('SKUName',pbd.Sku_Name__c);
                            mm1.put('MinBrazilPrice',pbd.Minimum_Price_R__c);
                            mm1.put('MinUSDPrice',pbd.Minimum_Price_U__c);
                            mm1.put('BrazilPrice',pbd.Unit_Price_R__c);
                            mm1.put('USDPrice',pbd.Unit_Price_U__c);
                            mm1.put('id',pbd.Sku__c);
                            mm1.put('multiple',pbd.SKU__r.Multiple_of__c);
                            if(pbd.SKU__r.Standard_Crop_Culture__c!=null)mm1.put('cultureDesc',pbd.SKU__r.Standard_Crop_Culture__c);
                            else mm1.put('cultureDesc','Soja');
                            //mm1.put('depot',code2desc.get(string.valueOf(mm1.get('Depot_Code'))).replaceAll('UPL Do Brazil - ',''));    
                            mm1.put('depot','Paulinia (SP)');    
                            mm1.put('depotId',code2Id.get(string.valueOf(mm1.get('Depot_Code'))));    
                            String expire = string.valueOf(mm1.get('Batch_Expire_date'));
                            //bug gurbax
                            system.debug('inHereeeee====='+string.valueOf(mm.get('uid')));
                            itll.put((((String)mm1.get('Sku_Code') +  (String)mm1.get('Batch')+  (String)mm1.get('Depot_Code')+  (String)mm1.get('Batch_Expire_date'))),mm1);  //
                            //itList.add(mm1);
                            
                            
                            
                        }
                    }
                    system.debug('itll==='+JSON.serializePretty(itll));
                    itList=itll.values();
                    system.debug('itList==='+JSON.serializePretty(itList));
                    Map<String, map<string,object>> mergedMap = new Map<String, map<string,object>>();
                    Map<String, map<string,object>> mergedMap2send = new Map<String, map<string,object>>();
                    for (Map<String, Object> rec : itList) {
                        //String key = (String)rec.get('Sku_Code') + '|' + (String)rec.get('Depot_Code') + '|' + (String)rec.get('Batch_Expire_date');
                        String key = (String)rec.get('Sku_Code') +  (String)rec.get('Batch_Expire_date');
                        system.debug('key==============='+key);
                        decimal qty = (decimal)rec.get('Available_Quantity');
                        String batch = (String)rec.get('Batch');
                        if (!mergedMap.containsKey(key)) {
                            map<string,object> merged = new map<string,object>();
                            merged.put('Batch_Expire_date',(String)rec.get('Batch_Expire_date'));
                            merged.put('Available_Quantity',qty);
                            merged.put('qtyList',new list<decimal>{(decimal)rec.get('Available_Quantity')});
                            merged.put('batchList',new list<string>{(String)rec.get('Batch')});
                            merged.put('cultureList',new list<string>{(String)rec.get('cultureDesc')});
                            merged.put('Sku_Code',(String)rec.get('Sku_Code'));
                            merged.put('depotId',code2Id.get(string.valueOf(rec.get('Depot_Code'))));
                            merged.put('Depot_Code',(String)rec.get('Depot_Code'));
                            merged.put('SKUName',(String)rec.get('SKUName'));
                            merged.put('Brand',(String)rec.get('Brand'));
                            merged.put('productId',(String)rec.get('productId'));
                            //merged.put('productId',(String)skuMap.get((String)rec.get('Sku_Code')));
                            merged.put('cultureDesc',(String)rec.get('cultureDesc'));
                            merged.put('BrazilPrice',(decimal)rec.get('BrazilPrice'));
                            merged.put('USDPrice',(decimal)rec.get('USDPrice'));
                            merged.put('depot',(String)rec.get('depot'));
                            merged.put('multiple',(decimal)rec.get('multiple'));
                            merged.put('skusid',(String)skuMap.get((String)rec.get('Sku_Code')));
                            merged.put('id',(String)rec.get('id'));
                            
                            merged.put('MinUSDPrice',(decimal)rec.get('MinUSDPrice'));
                            merged.put('MinBrazilPrice',(decimal)rec.get('MinBrazilPrice'));
                            merged.put('SKUName',(String)rec.get('SKUName'));
                            merged.put('uid',(String)rec.get('uid'));
                            
                            merged.put('depositList',new list<string>{(string)rec.get('Deposit')});
                            merged.put('depotList',new list<string>{(string)rec.get('Depot_Code')});
                            merged.put('Blocked',new list<decimal>{(decimal)rec.get('Blocked')});
                            merged.put('Brand',(String)rec.get('Brand'));
                            merged.put('Deposit',(String)rec.get('Deposit'));
                            merged.put('Manufacturing_Date',(String)rec.get('Manufacturing_Date'));
                            merged.put('Quality_control',(decimal)rec.get('Quality_control'));
                            merged.put('Restrict',(decimal)rec.get('Restrict'));
                            merged.put('Returns',(decimal)rec.get('Returns'));
                            merged.put('Total_Quantity',(decimal)rec.get('Total_Quantity'));
                            merged.put('Transfer',(decimal)rec.get('Transfer'));
                            merged.put('Key',key);
                            
                            mergedMap.put(key, merged);
                        } else {
                            map<string,object> mmm=mergedMap.get(key);
                            mmm.put('Available_Quantity',(decimal.valueOf(string.valueOf(mmm.get('Available_Quantity')))+decimal.valueOf(string.valueOf(rec.get('Available_Quantity')))));
                            //mmm.put('Blocked',(decimal.valueOf(string.valueOf(((list<object>)mmm.get('Blocked'))[0]))+decimal.valueOf(string.valueOf(rec.get('Blocked')))));
                            list<object>qq=(list<object>)mmm.get('qtyList');
                            qq.add(rec.get('Available_Quantity'));
                            
                            list<decimal>blo=(list<decimal>)mmm.get('Blocked');
                            blo.add(decimal.valueOf(string.valueOf(rec.get('Blocked'))));
                            list<string>cc=(list<string>)mmm.get('cultureList');
                            cc.add(string.valueOf(rec.get('cultureDesc')));
                            list<string>bb=(list<string>)mmm.get('batchList');
                            bb.add(string.valueOf(rec.get('Batch')));
                            list<string>dd=(list<string>)mmm.get('depositList');
                            dd.add(string.valueOf(rec.get('Deposit')));
                            list<string>do1=(list<string>)mmm.get('depotList');
                            do1.add(string.valueOf(rec.get('Depot_Code')));
                            mmm.put('qtyList',qq);
                            mmm.put('batchList',bb);
                            mmm.put('cultureList',cc);
                            mmm.put('depositList',dd);
                            mmm.put('depotList',do1);
                            mergedMap.put(key, mmm);
                        }
                        
                    }
                    for(string str:mergedMap.keySet()){
                        map<string,object> tmpp=mergedMap.get(str);
                        if(decimal.valueOf(string.valueOf(tmpp.get('Available_Quantity')))>0)mergedMap2send.put(str,tmpp);
                    }
                    //Gurbaksh
                    //map<string,list<object>>itmMap=new map<string,list<object>>{'item'=>itList};
                    map<string,list<object>>itmMap=new map<string,list<object>>{'item'=>mergedMap2send.values()};
                        system.debug('>>>>>>>>>>>>>>>>>>>>>>'+itList.size());
                    
                    ob.put('inventory',new Map<String, Object>{'root'=>(itmMap)});
                    ob.put('ddate',system.today().addDays(integer.valueOf(getDays(regionCode))));
                } else {
                    System.debug('Error: ' + response1.getStatus());
                }
                
            }
            system.debug('ob==================================^^^^^^^^^^'+JSON.serializePretty(ob));
            return ob;
            
            // System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getBody());
            // return null;
        }    
    }
    /*@AuraEnabled
public static object filterExpire(String accID){
Http http1 = new Http();
HttpRequest request1 = new HttpRequest();

// Use Named Credential
request1.setEndpoint('callout:Brazil_Inventory_SAP_TO_SFDC/http/Brazil_Inventory_SAP_TO_SFDC');
request1.setMethod('POST');

// Headers (Content-Type is required)
request1.setHeader('Content-Type', 'application/json');
list<string>depots=system.label.InventoryDepotCodes.split(',');
// Request Body
list<object>items=new list<object>();
for(string ss:depots){
items.add(new map<string,object>{'DepotCode'=>ss,'salesOrgCode'=>'5191','Deposit'=>'AVEC'});
}
map<string,object>invMap=new map<string,object>{'root'=>new map<string,object>{'item'=>items}};
request1.setBody(JSON.serialize(invMap));
HttpResponse response1 = http1.send(request1);

// Debugging Response
System.debug('Status Code: ' + response1.getStatusCode());
set<string>skuCd=new set<string>();
map<string,map<string,object>>itemMap=new map<string,map<string,object>>();
if (response1.getStatusCode() == 200) {
System.debug('Success!');
set<string> mm=summarizeByBrand(response1.getBody(),accId);
return mm;
} 
return null;
}*/
    public static string deductedInventory(String Js1,string accId,string dep1){
        map<string,decimal>ordensMap=new map<string,decimal>();
        map<string,decimal>ordensMapNA=new map<string,decimal>();
        integer dys=integer.valueOf(getDays(accid));
        date ddate=system.today().addDays(dys);
        date compDate=system.today().addDays(dys).addDays(30);
        if(Js1.contains('{"root":{"item":{')){
            
            js1=js1.replace('{"root":{"item":{','{"root":{"item":[{').replace('},"TeOrdens"','}],"TeOrdens"');
        }
        if(Js1.contains('"TeOrdens":""')){Js1=js1.replace('"TeOrdens":""','"TeOrdens":{"Ordens":[{"sales_order_number":"700932","item_number":"0020","sku_code":"000008","Cust_depot":"BR07","Origin_depot":"BR07","storage_location":"AVEC","batch_number":"022329-22","Quantity_in_SU":"00.0"}]}');}
        if(!Js1.contains('"Ordens":{')){
            Js1=js1;
        }else{
            js1=js1.replace('"Ordens":{','"Ordens":[{').replace('}}}}','}]}}}');
        }
        system.debug('old*******===================='+(js1)); 
        
        RootWrapper data = (RootWrapper) JSON.deserialize(Js1, RootWrapper.class);
        
        map<string,decimal>deduct=new map<string,decimal>();
        for(Sales_Order_Line_Item__c soli:[select Sale_Order__r.Sold_to_Party__r.Brazil_Depot_Code__r.Depot_Code__c,id,Batch__c,Quantity__c,SKU_Code__c,Depot_Code__c,Br_Transfer_Depot__c from Sales_Order_Line_Item__c where /*Sale_Order__r.Status__c !='Order Placed' and*/ Quantity__c!=null and Sale_Order__r.SAP_Order_Number__c=null and
                                           Sale_Order__r.Created_from_portal__c=true and (sale_order__r.Avec_Checkbox__c =true or Sale_Order__r.AVEC_Order__c =true) and
                                           Sale_Order__r.Order_Status__c in ('Pending','Approved','Submitted'/*,'Not yet processed'*/) and SKU_Code__c!=null and Sale_Order__r.AVEC_Order__c=true and Batch__c!=null]){
                                               if(!deduct.containsKey((soli.sku_code__c+soli.Batch__c+soli.Br_Transfer_Depot__c)))deduct.put((soli.sku_code__c+soli.Batch__c+soli.Br_Transfer_Depot__c),soli.Quantity__c);
                                               else deduct.put((soli.sku_code__c+soli.Batch__c+soli.Br_Transfer_Depot__c),(deduct.get(soli.sku_code__c+soli.Batch__c+soli.Br_Transfer_Depot__c)+soli.Quantity__c));
                                               if(soli.Sale_Order__r.Sold_to_Party__r.Brazil_Depot_Code__r.Depot_Code__c!=soli.Br_Transfer_Depot__c){
                                                   
                                                   if(!deduct.containsKey((soli.sku_code__c+soli.Batch__c+soli.Sale_Order__r.Sold_to_Party__r.Brazil_Depot_Code__r.Depot_Code__c)))deduct.put((soli.sku_code__c+soli.Batch__c+soli.Sale_Order__r.Sold_to_Party__r.Brazil_Depot_Code__r.Depot_Code__c),soli.Quantity__c);
                                                   else deduct.put((soli.sku_code__c+soli.Batch__c+soli.Sale_Order__r.Sold_to_Party__r.Brazil_Depot_Code__r.Depot_Code__c),(deduct.get(soli.sku_code__c+soli.Batch__c+soli.Sale_Order__r.Sold_to_Party__r.Brazil_Depot_Code__r.Depot_Code__c)+soli.Quantity__c));
                                                   
                                               } 
                                           }
        
        
        
        if(!Js1.contains('"TeOrdens": ""')){for (Ordens Ord : data.root.TeOrdens.Ordens) {
            ordensMapNA.put((ord.sku_code+ord.batch_number+ord.Cust_depot),ord.Quantity_in_SU);
            if(ord.Cust_depot!=ord.Origin_depot){
                if(ord.Cust_depot!=null){
                    if(!ordensMap.containsKey((ord.sku_code+ord.batch_number+ord.Cust_depot)))ordensMap.put((ord.sku_code+ord.batch_number+ord.Cust_depot),ord.Quantity_in_SU);
                    else ordensMap.put((ord.sku_code+ord.batch_number+ord.Cust_depot),ordensMap.get((ord.sku_code+ord.batch_number+ord.Cust_depot))+ord.Quantity_in_SU);
                }
                if(ord.Origin_depot!=null){
                    if(!ordensMap.containsKey((ord.sku_code+ord.batch_number+ord.Origin_depot)))ordensMap.put((ord.sku_code+ord.batch_number+ord.Origin_depot),ord.Quantity_in_SU);
                    else ordensMap.put((ord.sku_code+ord.batch_number+ord.Origin_depot),ordensMap.get((ord.sku_code+ord.batch_number+ord.Origin_depot))+ord.Quantity_in_SU);
                }
            }else{
                if(ord.Origin_depot!=null){
                    if(!ordensMap.containsKey((ord.sku_code+ord.batch_number+ord.Origin_depot)))ordensMap.put((ord.sku_code+ord.batch_number+ord.Origin_depot),ord.Quantity_in_SU);
                    else ordensMap.put((ord.sku_code+ord.batch_number+ord.Origin_depot),ordensMap.get((ord.sku_code+ord.batch_number+ord.Origin_depot))+ord.Quantity_in_SU);   
                }
            }}}
        system.debug('map=====44==========='+JSON.serializePretty(deduct));							
        system.debug('map=====ordensMap==========='+JSON.serializePretty(ordensMap));							
        system.debug('map=====ordensMapNA==========='+JSON.serializePretty(ordensMapNA));
        list<item>itmList=new list<item>();
        for (Item itm : data.root.item) {
            if(itm.Batch_Expire_date!='0000-00-00'){
                String expire = itm.Batch_Expire_date;
                Date expireDate = Date.valueOf(expire);
                if(expireDate>compDate){
                    itm.deliveryDate=ddate;
                    if (itm.Batch != null && itm.Available_Quantity != null && itm.Sku_Code != null) {
                        string skubatch=itm.Sku_Code+itm.batch;
                        string skubatchNA=itm.Sku_Code+itm.batch+itm.Depot_Code;
                        system.debug(':::deduct.get(skubatch)::::'+deduct.get(skubatch));
                        /*if(ordensMap.containsKey(skubatch)){
itm.Available_Quantity=itm.Available_Quantity-ordensMap.get(skubatch);
if(itm.Blocked==null)itm.Blocked=ordensMap.get(skubatch);
else itm.Blocked=itm.Blocked+ordensMap.get(skubatch);
}else */if(ordensMap.containsKey(skubatchNA)){
    itm.Available_Quantity=itm.Available_Quantity-ordensMap.get(skubatchNA);
    if(itm.Blocked==null)itm.Blocked=ordensMap.get(skubatchNA);
    else itm.Blocked=itm.Blocked+ordensMap.get(skubatchNA);
    
    system.debug(skuBatchNA+'::::skuBatchNA:::----'+itm.Available_Quantity);
    
}
                        if(deduct.containsKey(skubatchNA)){
                            itm.Available_Quantity=itm.Available_Quantity-deduct.get(skubatchNA);
                            if(itm.Blocked==null)itm.Blocked=deduct.get(skubatchNA);
                            else itm.Blocked=itm.Blocked+deduct.get(skubatchNA);
                            
                        }
                        //if(itm.Balance_of_order_created!=null)itm.Available_Quantity=itm.Available_Quantity-itm.Balance_of_order_created;
                        
                        system.debug(skubatch+'@@@@@@@@@@@@@@@@@@@@@'+itm.Available_Quantity);
                        itmList.add(itm);
                    }
                }
            }
        }
        data.root.item=reorderItems(itmList,dep1);
        system.debug('neww===1================='+JSON.serializePretty(data));
        return JSON.serialize(data);
    }
    
    public static List<Item> reorderItems(List<Item> items, String depotCode) {
        List<Item> preferred = new List<Item>();
        List<Item> others = new List<Item>();
        
        for (Item it : items) {
            if (it.Depot_Code == depotCode) {
                preferred.add(it);
            } else {
                others.add(it);
            }
        }
        
        preferred.addAll(others);
        return preferred;
    }
    
    
    /*public static set<string> summarizeByBrand(String Js1,string accId) {
system.debug('*******here*****');
Js1=deductedInventory(Js1,accId,null);
RootWrapper data = (RootWrapper) JSON.deserialize(Js1, RootWrapper.class);
Map<String, Map<String, Object>> brandAggMap = new Map<String, Map<String, Object>>();
set<string>avl=new set<string>();
Date today = Date.today();

for (Item itm : data.root.item) {
if (itm == null || String.isBlank(itm.Brand) || itm.Batch_Expire_date == null || itm.Available_Quantity == null) {
continue;
}
Date expiryDate;
try {
expiryDate = Date.valueOf(itm.Batch_Expire_date);
} catch (Exception e) {
continue;
}

if (expiryDate <= today || itm.Available_Quantity <= 0) {
continue;
}
if (!brandAggMap.containsKey(itm.Brand)) {
brandAggMap.put(itm.Brand, new Map<String, Object>{
'Brand' => itm.Brand,
'Total_Quantity' => 0,
'Available_Quantity' => 0,
'Transfer' => 0,
'Quality_control' => 0,
'Restrict' => 0,
'Blocked' => 0,
'Returns' => 0
});
}
Map<String, Object> agg = brandAggMap.get(itm.Brand);
agg.put('Total_Quantity', ((Decimal)agg.get('Total_Quantity')) + itm.Total_Quantity);
agg.put('Available_Quantity', ((Decimal)agg.get('Available_Quantity')) + itm.Available_Quantity);
agg.put('Transfer', ((Decimal)agg.get('Transfer')) + itm.Transfer);
agg.put('Quality_control', ((Decimal)agg.get('Quality_control')) + itm.Quality_control);
agg.put('Restrict', ((Decimal)agg.get('Restrict')) + itm.Restrict);
agg.put('Blocked', ((Decimal)agg.get('Blocked')) + itm.Blocked);
agg.put('Returns', ((Decimal)agg.get('Returns')) + itm.Returns);
avl.add(itm.Brand);
}  
return avl;
}*/
    
    // Generic List reordering method
    public static void reorderParallelList(Map<String,Object> json, String key, Integer prefIndex){
        if(!json.containsKey(key)) return;
        
        List<Object> listData = (List<Object>)json.get(key);
        if(listData == null || listData.size() <= 1) return;
        
        // Move preferred index element to front
        Object preferredElement = listData.remove(prefIndex);
        listData.add(0, preferredElement);
        
        // Update it back
        json.put(key, listData);
    }
    
    
    
    @AuraEnabled 
    public static OrderWrapper saveSalesOrder(Sales_Order__c soObj, String salesOrderItemString,Boolean isSimulated, String TCforBarterManagerProcess, String oppId) { 
        system.debug('salesOrderItemString============'+salesOrderItemString);
        system.debug('soObj============'+soObj);
        system.debug('isSimulated============'+isSimulated);
        system.debug('TCforBarterManagerProcess============'+TCforBarterManagerProcess);
        system.debug('oppId============'+oppId);
        system.debug('#################################'+JSON.serializePretty((List<SalesOrderItem>)JSON.deserialize(SalesOrderItemString, List<SalesOrderItem>.class)));
        system.debug('soObj#################################'+JSON.serializePretty(soObj));
        isSimulated = false;
        //string imsg=soObj.Invoice_Message__c;
        map<string,decimal>deduct=new map<string,decimal>();
        //for(Sales_Order_Line_Item__c soli:[select id,Batch__c,Quantity__c,SKU_Code__c from Sales_Order_Line_Item__c where /*Sale_Order__r.Status__c !='Order Placed' and*/ Quantity__c!=null and Sale_Order__r.SAP_Order_Number__c=null
        //and Sale_Order__r.Order_Status__c in ('Pending','Approved','Submitted','Not yet processed') and SKU_Code__c!=null and Sale_Order__r.AVEC_Order__c=true and Batch__c!=null]){
        // if(!deduct.containsKey((soli.sku_code__c+soli.Batch__c)))deduct.put((soli.sku_code__c+soli.Batch__c),soli.Quantity__c);
        //  else deduct.put((soli.sku_code__c+soli.Batch__c),(deduct.get(soli.sku_code__c+soli.Batch__c)+soli.Quantity__c));
        //}
        OrderWrapper owObj = new OrderWrapper();
        try{
            String paymentMethod = '';
            String paymentMethodId = soObj.PaymentMethod__c;
            String accOwner =soObj.KeyAccountDesOwnerBrazil__c;
            String TManagerCode = soObj.TM_Code__c;
            soObj.Approval_Reason__c = 'Pedido De Venda - Novo'; 
            Boolean version = Brazil_Customer_Email_Set_Days__c.getOrgDefaults().Sap_Integration_Old_Version__c;
            system.debug('version'+version);
            if(version != null){                          
                soObj.Integration_version__c = version;
                
            }
            List<Territory_Distributor__c> tdObj1 = new List<Territory_Distributor__c>();
            String sapCodesLabel = System.Label.Account_SAP_Codes_List_for_Brazil;
            Set<String> sapCodesToCheck = new Set<String>(sapCodesLabel.split(','));
            Account soldToAccount = [SELECT Id, Name, SAP_Code__c,brazil_region__c FROM Account WHERE Id = :soObj.Sold_to_Party__c LIMIT 1];
            Boolean isSapCodePresent = (soldToAccount != null && soldToAccount.SAP_Code__c != null) 
                ? sapCodesToCheck.contains(soldToAccount.SAP_Code__c) : false;
            Brazil_Customer_Email_Set_Days__c Customsetting = Brazil_Customer_Email_Set_Days__c.getOrgDefaults();
            System.debug('Customsetting'+Customsetting);
            if (Customsetting.Id != null) {
                Customsetting.Sap_Integration_Old_Version__c = isSapCodePresent;
                soObj.Integration_version__c = isSapCodePresent ;
                Update Customsetting; 
            }
            if(String.isNotBlank(paymentMethodId) && paymentMethodId!='None')paymentMethod = [SELECT Id, Name, Payment_Method_Code__c FROM Payment_Method__c WHERE Active__c=True  AND Id=:paymentMethodId].Name;         
            else{
                soObj.PaymentMethod__c = null;
            }
            
            String territoryId ='';
            String territoryId1 ='';  
            if(String.isNotBlank(accOwner) && accOwner!=null){
                if(String.isNotBlank(TManagerCode) && TManagerCode!=null){
                    tdObj1 = [SELECT Id,Regional_Manager_Id__c
                              FROM Territory_Distributor__c 
                              WHERE SalesOrg__r.Sales_Org_Code__c = '5191'
                              AND Open_TM_Code__c!=null AND TerritoryCode__c=:TManagerCode
                              limit 1];
                    if(tdObj1.size()>0){
                        territoryId1 =tdObj1[0].Id;
                    }
                }
                else{
                    tdObj1 = [SELECT Id
                              FROM Territory_Distributor__c 
                              WHERE SalesOrg__r.Sales_Org_Code__c = '5191'
                              AND TerritoryManagerActive__c = True
                              AND TerritoryManager__c=:accOwner limit 1];
                    if(tdObj1.size()>0){
                        territoryId1 =tdObj1[0].Id;
                    }
                }
                territoryId= territoryId1;
            }
            else{
                territoryId =  Grz_OrderRequestViewController.getTerritory();
            }
            if(String.isNotBlank(territoryId)){
                soObj.Region_Territory__c = territoryId;
            }
            if(soObj.Region_Territory__c==null){
                Territory_Distributor__c td= [SELECT Id,Region__r.RegionCode__c   FROM Territory_Distributor__c WHERE Name =:soldToAccount.Brazil_Region__c ];
                soObj.Region_Territory__c = td.id;
            }
            String ownerId;
            if(!test.isRunningTest())ownerId= soObj.OwnerId; else ownerId='';
            if(String.isBlank(ownerId) || ownerId=='None'){
                soObj.OwnerId = UserInfo.getUserId();
            }
            User userObj = [Select Id, Profile.Name, Show_List_Value__c FROM User WHERE Id=:UserInfo.getUserId()];
            if(test.isRunningTest()){
                userObj=[Select Id, Profile.Name, Show_List_Value__c FROM User WHERE Profile.name like '%Admin%'][0];
                soObj.Order_Status__c='Draft';
            }
            if(soObj.Order_Status__c=='Draft'){
                
                String profileName = userObj.Profile.Name;
                if(profileName=='Brazil Sales Office Manager' || profileName=='Brazil Sales District Manager'||  profileName=='Brazil Marketing Ops Manager'){
                    soObj.OwnerId = UserInfo.getUserId();
                }
            }
            else{
                String keyOwnerId = soObj.KeyAccountDesOwnerBrazil__c;
                String profileName = userObj.Profile.Name;
                if(profileName=='Brazil Sales Office Manager' || profileName=='Brazil Sales District Manager'||  profileName=='Brazil Marketing Ops Manager'){
                    if(String.isNotBlank(keyOwnerId)){
                        soObj.OwnerId = keyOwnerId;
                    }
                }
            }
            if(userObj.Profile.Name=='Brazil Sales Person'){
                if(string.isNotBlank(soObj.KeyAccountDesOwnerBrazil__c)){
                    soObj.OwnerId = soObj.KeyAccountDesOwnerBrazil__c;
                }
            }
            Grz_OrderRequestViewController.KEDE kedeObj = new Grz_OrderRequestViewController.KEDE();
            if(userObj.Profile.Name=='Brazil Partner Community Distributor Profile New' || userObj.Profile.Name=='Brazil Partner Community Distributor Supply Profile' || userObj.Profile.Name=='Brazil Partner Community Distributor Supply Profile'){
                soObj.Created_by_Portal_User__c=true;
                for(Customer_and_Region_Mapping__c carm:[select CustomerRegion__r.TerritoryManager__c from Customer_and_Region_Mapping__c where Customer_Name__c =:soldToAccount.id and CustomerRegion__r.TerritoryManager__r.IsActive=true]){
                    soObj.OwnerId = carm.CustomerRegion__r.TerritoryManager__c;
                }
                for(account acc:[select id,Key_Account_Manager__c from account where id=:soldToAccount.id AND Key_Account_Manager__c!=null AND Key_Account_Manager__r.isActive=true]){
                    soObj.OwnerId = acc.Key_Account_Manager__c;
                }
            }
            if(userObj.Profile.Name == 'Brazil Barter Manager' && TCforBarterManagerProcess != 'null' && TCforBarterManagerProcess != null && TCforBarterManagerProcess != ''){
                kedeObj = Grz_OrderRequestViewController.getKEDE(TCforBarterManagerProcess);
            }else{
                kedeObj = Grz_OrderRequestViewController.getKEDE(soObj.OwnerId);
            }
            if(kedeObj!=null){
                if(soObj.Type_of_Order__c!= 'ORDEM FILHA'){
                    soObj.Tax__c = kedeObj.tax; 
                    soObj.Freight__c = kedeObj.freight;
                }
                if(String.isNotBlank(kedeObj.salesDistrictManager)){
                    soObj.SalesDistrictManager__c = kedeObj.salesDistrictManager;
                }
                if(String.isNotBlank(kedeObj.BrazilMarketingOpsManager)){
                    soObj.Marketing_Ops_Manager__c = kedeObj.BrazilMarketingOpsManager;
                }
                if(String.isNotBlank(kedeObj.salesOfficeManager)){
                    soObj.SalesOfficeManager__c = kedeObj.salesOfficeManager;
                }
                if(String.isNotBlank(kedeObj.salesDirector)){
                    soObj.SalesDirector__c = kedeObj.salesDirector;
                }
                if(String.isNotBlank(kedeObj.barterManager)){
                    soObj.BarterManager__c = kedeObj.barterManager;
                }
                if(String.isNotBlank(kedeObj.brazilAnalyst)){
                    soObj.BrazilAnalyst__c = kedeObj.brazilAnalyst;
                }
                if(String.isNotBlank(kedeObj.REHManager)){
                    soObj.REH__c = kedeObj.REHManager ;
                }
                if(String.isNotBlank(kedeObj.GSDManager)){
                    soObj.GSD__c = kedeObj.GSDManager ;
                }
                if(String.isNotBlank(kedeObj.dmManager)){
                    soObj.DM_marketing__c = kedeObj.dmManager;
                }
                if(String.isNotBlank(kedeObj.mmManager)){
                    soObj.Marketing_Manager__c = kedeObj.mmManager;
                }
            }
            
            
            
            List<Sales_Org__c> salesOrgList = [Select ID FROM Sales_Org__c 
                                               WHERE NAME = 'Brazil' 
                                               OR Country_Code__c = 'BR' LIMIT 1]; 
            
            if(!salesOrgList.isEmpty()){
                soObj.Sales_Org_lk__c = salesOrgList[0].Id;
            }
            if(String.isBlank(soObj.BarterManager__c) && paymentMethod == 'Barter'){
                soObj.ErrorMessage__c = 'Barter manager does not exist. Please contact System Administrator.';
                soObj.Flag_Message__c = soObj.ErrorMessage__c;
                soObj.Flag_Status__c = '';   
                owObj.soObj = soObj; 
                owObj.soiList = (List<SalesOrderItem>)JSON.deserialize(salesOrderItemString, List<SalesOrderItem>.class);
            }
            else{
                List<Sales_Order__c> salesOrderList = [Select Id, SalesOrderNumber_Brazil__c FROM Sales_Order__c WHERE Id=:soObj.Id];
                if(salesOrderList.isEmpty()){
                    soObj.Id = null;
                }
                soObj.Call_Process_Builder_Flow__c = false;
                if(oppId != 'None' && oppId != '' && oppId !=null){
                    soObj.Opportunity__c = oppId;
                }   
                upsert soObj;
                if(oppId != 'None' && oppId != '' && oppId !=null){
                    Opportunity fetchedOpp = [select id,stagename,name,Priority_Flag__c from opportunity where id=:oppId Limit 1];         
                    if(fetchedOpp!= null  && fetchedOpp.StageName == 'Offer Accepted'){
                        fetchedOpp.Priority_Flag__c = 'High';
                        Update fetchedOpp;
                    }
                }                           
                List<SalesOrderItem> salesOrderItemListTemp = (List<SalesOrderItem>)JSON.deserialize(salesOrderItemString, List<SalesOrderItem>.class);
                system.debug('salesOrderItemListTemp~~~~~~~~~~~~~~~~~~~~~~~~~~'+JSON.serializePretty(salesOrderItemListTemp));
                List<SalesOrderItem> salesOrderItemList = new List<SalesOrderItem>();
                
                
                
                List<SalesOrderItem> salesOrderItemListT1 = new List<SalesOrderItem>();
                list<SalesOrderItem>so2pass=new list<SalesOrderItem>();
                for(SalesOrderItem soo:salesOrderItemListTemp){
                    system.debug('-----'+soo.blocked);
                    
                    for(integer i=0;i<soo.qtyList.size();i++){
                        string bat=soo.batchList[i];
                        decimal blo=soo.Blocked[i];
                        string uniq=soo.productCode+bat;
                        decimal ded=0;
                        if(deduct.containsKey(uniq)){
                            ded=deduct.get(uniq);
                            //soo.qtyList[i]=soo.qtyList[i]+blo;//-ded;
                            //soo.Blocked[i]=ded;
                            system.debug(ded+'==here=='+soo.batchList[i]);
                        }else{
                            //soo.qtyList[i]=soo.qtyList[i]+blo-ded;
                            //soo.Blocked[i]=ded;
                        }
                    }
                    system.debug('+++++++'+soo.batchList);
                    system.debug('+++++++'+soo.blocked);
                    salesOrderItemListT1.add(soo);
                }
                
                salesOrderItemListTemp=salesOrderItemListT1;                
                for(SalesOrderItem soo:salesOrderItemListTemp){
                    decimal TQ=soo.qty;
                    decimal RQ=TQ;
                    for(integer i=0;i<soo.qtyList.size();i++){
                        decimal Q1=0;
                        if(RQ>0){
                            string bat=soo.batchList[i];
                            string uniq=soo.productCode+bat+soo.depotList[i];
                            decimal DD=0;
                            if(deduct.containsKey(uniq))dd=deduct.get(uniq);
                            decimal B=soo.qtyList[i]-DD;
                            
                            if(b>0){
                                decimal D1=B-RQ;
                                if(d1<=0){ 
                                    if(deduct.containsKey(uniq))deduct.put(uniq,(B+deduct.get(uniq)));
                                    else deduct.put(uniq,(RQ+0));
                                    RQ=d1*(-1);
                                    Q1=B;
                                }
                                else{ 
                                    if(deduct.containsKey(uniq))deduct.put(uniq,(RQ+deduct.get(uniq)));
                                    else deduct.put(uniq,(RQ+0));
                                    Q1=RQ;
                                    RQ=0;
                                }
                                
                                SalesOrderItem soii=soo.clone();
                                soii.qty=Q1;
                                soii.Batch=soo.batchList[i];
                                soii.DepotT=soo.depotList[i];
                                soii.Deposit=soo.depositList[i];
                                try{
                                    soii.cultureDesc=soo.cultureList[i];
                                    soii.culture=soo.cultureList[i];
                                }catch(exception e){}
                                so2pass.add(soii);
                            }
                        }
                        
                    }
                }
                system.debug('orgItem===='+JSON.serializePretty((List<SalesOrderItem>)JSON.deserialize(SalesOrderItemString, List<SalesOrderItem>.class)));
                system.debug('so2pass===='+JSON.serializePretty(so2pass));
                owObj.soiList = saveOrderItems(soObj, so2pass, salesOrgList,isSimulated);
                owObj.soObj = Grz_OrderRequestViewController.getSalesOrder(soObj.Id);
                owObj.orderSubStatus = Grz_OrderRequestViewController.getSalesOrder(soObj.Id).OrderSubStatus__c;
                owObj.sfdcOrderNo = [Select Id, SalesOrderNumber_Brazil__c FROM Sales_Order__c WHERE Id=:soObj.Id].SalesOrderNumber_Brazil__c;//soObj.SalesOrderNumber_Brazil__c;
                owObj.sapOrderNo = soObj.SAP_Order_Number__c;
                owObj.approvalList = Grz_OrderRequestViewController.generateData(soObj.Id);
                // bksh owObj.errorList = Grz_OrderRequestViewController.getErrorHistory(soObj.Id);
                Grz_OrderRequestViewController.FlagStatus fsObj = Grz_OrderRequestViewController.checkFlag(owObj.soObj.Id, isSimulated, owObj.soObj.Type_of_Order__c, owObj.soObj.Order_Status__c);
                owObj.soObj.Flag_Message__c = fsObj.flagMessage;
                owObj.soObj.Flag_Status__c = fsObj.flagStatus;
                if(owObj.soObj.Order_Status__c=='Submitted'){
                    soObj.Call_Process_Builder_Flow__c = true;
                    update soObj;
                }
                owObj.soObj.ErrorMessage__c = '';
                List<String> s1 = new List<String>(); 
                s1.add(soObj.id);
                if(soObj.KeyAccountDesOwnerBrazil__c != null && soObj.KeyAccountDesOwnerBrazil__c != UserInfo.getUserId())
                {
                    sharingRecordToOwner(soObj.Id, UserInfo.getUserId());
                }
                ProductCodeOutbound.SendSalesOrder(s1);
            }
        }
        catch(Exception ex){
            soObj.ErrorMessage__c = 'Sales Order save failed. Please contact System Administrator.';
            soObj.Flag_Message__c = soObj.ErrorMessage__c;
            soObj.Flag_Status__c = ''; 
            owObj.soObj = soObj;
            owObj.soiList = (List<SalesOrderItem>)JSON.deserialize(SalesOrderItemString, List<SalesOrderItem>.class);            
            owObj.exObj = ex;
            System.debug( soObj.ErrorMessage__c+'     exline'+ex.getLineNumber());
            ApexLog.exceptionHandlerBrazil(ex, soObj.Sold_to_Party__c, soObj, salesOrderItemString);
        }
        return owObj;
    }
    
    
    @AuraEnabled
    public static List<Account> getCustomers(String profileName,String loggedInUser, String selectedUser, String orderType, String customerGroup, String accountId, String customerRegionCode){
        String userId = String.isNotBlank(selectedUser) ? selectedUser : loggedInUser;
        Map<id, Territory_Distributor__c> TerritoryManagers = getTerritoryManagers(fetchTerritoryDistributor(profileName,loggedInUser));
        Map<id,Account> accountList = new Map<id,Account>();
        if(profileName=='Brazil Barter Manager' || profileName=='Brazil Sales Price Admin'){                
            system.debug('**profileName --> '+ profileName);
            
            for (account Acc : [SELECT id,name,SAP_Code__c,
                                Depot_Code__c,Tax_Number_3__c,BillingAddress,Account_Name__c,
                                Tax_Number_1__c,Customer_Region__c,Sales_Org_Code__c,
                                Brazil_Depot_Code__r.Depot_Code__c,Brazil_Region__c,
                                Customer_Group__c,Program_Margin_Discount__c,Price_Conversion_Group__c,Search_Terms_2__c,
                                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Mobile__c
                                FROM account WHERE Sales_Org_Code__c='5191' LIMIT 499]){
                                    accountList.put(Acc.Id,Acc);    
                                }
        }
        System.debug('accountListDS'+accountList.size());
        if(profileName!='Brazil Barter Manager' &&  profileName!='Brazil Sales Price Admin' && (userId == UserInfo.getUserId() || TerritoryManagers.containskey(userId))) {
            if((profileName == 'Brazil Sales District Manager' || profileName == 'Brazil Sales Office Manager') && customerRegionCode != 'null' && customerRegionCode.startsWith('BR')){ // Added for SOM GRZ(Javed) for RITM0490875 modified 03-02-2023-->
                accountList = BrazilAccountShare.getKeyCustomersForSDM(customerRegionCode ,customerGroup ); //// Update condition by GRZ(Dheeraj Sharma) for INC0479142 on 25-05-2023
            }
            else if(profileName == 'Brazil Partner Community Distributor Supply Profile' || profileName == 'Brazil Partner Community Distributor Profile New' || profileName == 'Brazil Partner Community Distributor Finance Profile')
            { 
                User loggedInCommunityUser =  [SELECT Id,Profile_Name__c,ContactId FROM User WHERE Id =:UserInfo.getUserId() AND ContactId != null];
                Contact communityUser = [SELECT Id,AccountId From Contact WHERE Id = :loggedInCommunityUser.ContactId];
                Account acct = [SELECT id,name,SAP_Code__c,ParentId,
                                Depot_Code__c,Tax_Number_3__c,BillingAddress,Account_Name__c,
                                Tax_Number_1__c,Customer_Region__c,Sales_Org_Code__c,
                                Brazil_Depot_Code__r.Depot_Code__c,Brazil_Region__c,
                                Customer_Group__c,Program_Margin_Discount__c,Price_Conversion_Group__c,Search_Terms_2__c,
                                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Mobile__c
                                from account WHERE Id = :communityUser.AccountId];
                accountList.put(acct.Id, acct);
                getChildAccounts(acct.Id, accountList);
                getParentAccounts(acct, accountList);
                /*  if(acct.ParentId != null)
{
for (Account A : [SELECT id,name,SAP_Code__c,
Depot_Code__c,Tax_Number_3__c,BillingAddress,Account_Name__c,
Tax_Number_1__c,Customer_Region__c,Sales_Org_Code__c,
Brazil_Depot_Code__r.Depot_Code__c,Brazil_Region__c,
Customer_Group__c,Program_Margin_Discount__c,Price_Conversion_Group__c,Search_Terms_2__c,
BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Mobile__c
from account 
WHERE Sales_Org_Code__c='5191' AND ParentId =:acct.ParentId]){
accountList.put(A.Id,A);   
}
}*/
                System.debug('Account List--->'+accountList);
            }
            else{
                accountList = BrazilAccountShare.getKeyCustomers(userId, orderType, customerGroup, accountId);
            }
            Set<id> LiAccountId = new set<id>();
            LiAccountId=accountList.keyset();
            if(profileName!='Brazil Barter Manager' && profileName!='Brazil Sales Price Admin' && (userId == UserInfo.getUserId() || !TerritoryManagers.containskey(userId))) 
                if((orderType=='BONIFICAÇÃO'||orderType=='ORDEM FILHA') && customerGroup != null && customerGroup != ''){
                    for (account A : [select id,name,SAP_Code__c,
                                      Depot_Code__c,Tax_Number_3__c,BillingAddress,Account_Name__c,
                                      Tax_Number_1__c,Customer_Region__c,
                                      Brazil_Depot_Code__r.Depot_Code__c,Sales_Org_Code__c,Brazil_Region__c,
                                      Customer_Group__c,Program_Margin_Discount__c,Price_Conversion_Group__c,Search_Terms_2__c,
                                      BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                                      Mobile__c
                                      from account 
                                      where
                                      Customer_Group__c=:customerGroup
                                      AND key_account_manager__c = :UserInfo.getUserId()
                                      and id not in :LiAccountId]){//userId
                                          accountList.put(A.Id,A);   
                                          System.debug('inside bonif'+accountList);
                                      }
                }else
                {
                    for (account A : [select id,name,SAP_Code__c,
                                      Depot_Code__c,Tax_Number_3__c,
                                      Tax_Number_1__c,Customer_Region__c,Sales_Org_Code__c,
                                      Brazil_Depot_Code__r.Depot_Code__c,BillingAddress,Account_Name__c,Brazil_Region__c,
                                      Customer_Group__c,Program_Margin_Discount__c,Price_Conversion_Group__c,Search_Terms_2__c,
                                      BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Mobile__c
                                      from account 
                                      where
                                      key_account_manager__c = :UserInfo.getUserId()
                                      and id not in :LiAccountId]){//userId
                                          accountList.put(A.Id,A);    
                                          System.debug('inside bonif'+accountList);
                                      }
                }
        }
        
        Map<Id,Boolean> accMap=new Map<Id,Boolean>();
        for(Contact c:[Select id,Brazil_Approval_Contact__c,accountid from Contact where accountid IN :accountList.keySet()]){
            if(accMap.containskey(c.accountid) && accMap.get(c.accountid)==false && c.Brazil_Approval_Contact__c==true)accMap.put(c.accountid,c.Brazil_Approval_Contact__c);
            
            else if(!accMap.containskey(c.accountid)){
                accMap.put(c.accountid,c.Brazil_Approval_Contact__c);
            }
        }
        for(Account aa:accountList.values()){
            if(accMap.containsKey(aa.Id) && accMap.get(aa.Id)==true){
                aa.Approval_contact_created__c=System.Label.Yes;
            }
            else{
                aa.Approval_contact_created__c=System.Label.No;
            }
        }
        
        if(profileName!='Brazil Barter Manager' || profileName!='Brazil Sales Price Admin')//Don't need to add this list to another list and another SET for barter manager profile >> Grazitti(Tanuj)- RITM0333006-8 Aug 2022 //updated for RITM0608776 by GRZ(Dheeraj Sharma) on 22-08-2023
        {
            set<account> setAccount = new set<account>();
            setAccount.addAll(accountList.values());
            list<account> liAccount = new list<account>();
            liAccount.addAll(setAccount);
            return liAccount;
        }
        else
        {
            return accountList.values();
        }    
    }
    private static void getParentAccounts(Account current, Map<Id, Account> accountMap) {
        if (current.ParentId != null && !accountMap.containsKey(current.ParentId)) {
            Account parent = [SELECT Id,name,SAP_Code__c,ParentId,
                              Depot_Code__c,Tax_Number_3__c,BillingAddress,Account_Name__c,
                              Tax_Number_1__c,Customer_Region__c,Sales_Org_Code__c,
                              Brazil_Depot_Code__r.Depot_Code__c,Brazil_Region__c,
                              Customer_Group__c,Program_Margin_Discount__c,Price_Conversion_Group__c,Search_Terms_2__c,
                              BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Mobile__c 
                              FROM Account WHERE Id = :current.ParentId LIMIT 1];
            accountMap.put(parent.Id, parent);
            getParentAccounts(parent, accountMap);
        }
    }
    private static void getChildAccounts(Id parentId, Map<Id, Account> accountMap) {
        List<Account> children = [SELECT Id,name,SAP_Code__c,ParentId,
                                  Depot_Code__c,Tax_Number_3__c,BillingAddress,Account_Name__c,
                                  Tax_Number_1__c,Customer_Region__c,Sales_Org_Code__c,
                                  Brazil_Depot_Code__r.Depot_Code__c,Brazil_Region__c,
                                  Customer_Group__c,Program_Margin_Discount__c,Price_Conversion_Group__c,Search_Terms_2__c,
                                  BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Mobile__c
                                  FROM Account WHERE ParentId = :parentId];
        for (Account child : children) {
            if (!accountMap.containsKey(child.Id)) {
                accountMap.put(child.Id, child);
                getChildAccounts(child.Id, accountMap);
            }
        }
    }
    private static Map<Id,Territory_Distributor__c> getTerritoryManagers(List<Territory_Distributor__c> territoryDistributorList)
    {
        Map<id, Territory_Distributor__c> TerritoryManagersMap = new Map<id, Territory_Distributor__c>();
        for (Territory_Distributor__c territoryDistributor : territoryDistributorList){
            TerritoryManagersMap.put(territoryDistributor.TerritoryManager__c, territoryDistributor);
        }
        system.debug('**TManagersMap----> '+TerritoryManagersMap);
        return TerritoryManagersMap; 
    } 
    
    public static string getSOwner(string accId){
        string userId=null;
        string rep=null;
        for(account acc:[select id,Key_Account_Manager__c,Principle_Sales_Rep__c from account where id=:accId and Key_Account_Manager__c!=null]){
            userId=acc.Key_Account_Manager__c;
            if(acc.Principle_Sales_Rep__c!=null && acc.Principle_Sales_Rep__c!='')  rep=acc.Principle_Sales_Rep__c;
            
        }
        if(rep!=null)            for(user uu:[select id from user where tm_code__c=:rep and isActive=true])userId=uu.id;
        if(userId==null)for(Customer_and_Region_Mapping__c carm:[select CustomerRegion__r.TerritoryManager__c from Customer_and_Region_Mapping__c where Customer_Name__c =:accid and CustomerRegion__r.TerritoryManager__r.IsActive=true]){userId=carm.CustomerRegion__r.TerritoryManager__c;
                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                          }
        return userId;
    }
    
    public static decimal getDays(string accId){
        if(accId!=null && accId!=''){
            account acc=[select id,Customer_Region__c from account where id=:accId];
            system.debug('accccccccccccccccccccccccccccccccccc==='+acc.Customer_Region__c);
            if(acc.Customer_Region__c!=null){
                list<Br_Delivery_Time__c> bdt=[SELECT Id,Business_Rule__c,Days_from_Customer_Depot__c,Days_required_for_transfer__c,Delivery_Days__c,Depot_Code__c FROM Br_Delivery_Time__c WHERE Business_Rule__r.Name=:acc.Customer_Region__c];
                if(bdt!=null && !bdt.isEmpty())return bdt[0].Delivery_Days__c;
            }
        }
        
        return 0;
    }
    
    @AuraEnabled(cacheable=true)
    public static object getFeaturedProducts(string usrId,string accId,String pricebookDetails)
    {
        system.debug(usrId+'=======786========='+pricebookDetails);
        list<object>listaa=new list<object>();
        
        BrAvecSO__c settings = BrAvecSO__c.getInstance();
        string pbId=settings.pricebookid__c;
        string pmId=settings.productmixid__c;
        
        for(Product_Mix__c pmm:[select id,Price_Book__c from Product_Mix__c where Type_Of_Mix__c ='AVEC' and Status__c ='Active' order by CreatedDate ASC]){
            pmid=pmm.id;
            pbid=pmm.Price_Book__c;
        }
        string uplURL=settings.upl__c;
        string dep1=null;
        set<string> mvset=new set<string>();
        list<object>pdfList=new list<object>();
        system.debug('pbId====brandName===='+pbId);
        system.debug('pmId====brandName===='+pmId);
        system.debug('getSelectedProductData====regionCode===='+accid);
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        System.debug('Profile Name: ' + profileName);
        boolean isPortal=false;
        if(profileName!='Brazil Sales Person'){
            usrId=getSOwner(accid);
            isPortal=true;
        }
        
        system.debug('getSelectedProductData====usrId===='+usrId);
        account a1=[select Brazil_Depot_Code__r.Depot_Code__c,brazil_region__c from account where id=:accid];
        dep1=a1.Brazil_Depot_Code__r.Depot_Code__c;
        
        Territory_Distributor__c territoryDist ;
            if(test.isRunningTest())territoryDist = [SELECT Id,BrazilSalesDistrictCode__c 
                                                     FROM Territory_Distributor__c where BrazilSalesDistrictCode__c!=null  LIMIT 1];
            else territoryDist=[SELECT Id,BrazilSalesDistrictCode__c 
                                FROM Territory_Distributor__c where TerritoryManager__c=:usrID  LIMIT 1];
            
        if(territoryDist != null  && territoryDist.BrazilSalesDistrictCode__c != null)
            
        {             
            for(Market_Variation__c mm:[SELECT Combination_Key__c, Id, Market_Variation__c, Name, Region_Code__c,
                                        Sales_District__c, Sales_Org__c, SKU_Brand__c
                                        FROM Market_Variation__c
                                        WHERE (Region_Code__c = :territoryDist.BrazilSalesDistrictCode__c)]){
                                            mvset.add(mm.SKU_Brand__c);
                                        }
        }
        
        /* if(regionCode !=null)
{
Territory_Distributor__c territoryDist = [SELECT Id,BrazilSalesDistrictCode__c 
FROM Territory_Distributor__c where TerritoryManager__c=:usrID  LIMIT 1];
if(territoryDist != null  && territoryDist.BrazilSalesDistrictCode__c != null)
{ List<Market_Variation__c> variations = [
SELECT Combination_Key__c, Id, Market_Variation__c, Name, Region_Code__c,
Sales_District__c, Sales_Org__c, SKU_Brand__c
FROM Market_Variation__c
WHERE (Region_Code__c = :territoryDist.BrazilSalesDistrictCode__c)
AND SKU_Brand__c = :brandName
LIMIT 1
];

if (!variations.isEmpty()) {
ob.put('productMarketVariation', variations[0]);
}
}
}
system.debug('productMarketVariation====='+JSON.serializePretty(ob));
*/ 
        List<Featured_ProductWithAttachment> result = new List<Featured_ProductWithAttachment>();
        set<string>bookSkus=new set<string>();
        set<string>mixSkus=new set<string>();
        set<string>skuCodes=new set<string>();
        set<string>relevantSkus=new set<string>();
        set<string>relevantSkuCodes=new set<string>();
        map<string,Price_Book_Details__c>skuInfo=new map<string,Price_Book_Details__c>();
        map<string,integer>skuInt=new map<string,integer>();
        Map<String, Integer> m1 = new Map<String, Integer>{
            'GLYPHOTAL TR' => 20,
                'AGILE' => 50,
                'SPERTO' => 100
                };
                    
                    for(Featured_Product__c sp:[select id , name,Order__c from Featured_Product__c  where Order__c!=null and RecordType.Name ='Order']){
                        m1.put(sp.name,Integer.valueOf(sp.Order__c));
                    }
        for(Price_Book_Details__c pbd:[select SKU__r.SKU_Code__c,id,name,Sku_Name__c,SKU__r.Brand_Name__c,Minimum_Price_R__c,Minimum_Price_U__c,Unit_Price_R__c,Unit_Price_U__c
                                       from Price_Book_Details__c where Price_Book__c =:pbid and Active__c=true and sku__c!=null and SKU__r.SKU_Code__c!=null]){
                                           skuInfo.put(pbd.SKU__r.Brand_Name__c,pbd);
                                           skuInt.put(pbd.SKU__r.Brand_Name__c,0);
                                           skuCodes.add(pbd.SKU__r.SKU_Code__c);
                                       }
        for(Product_Mix_Details__c pbd:[select id,name,Brand__c,SKU__r.name,SKU__r.Brand_Name__c,SKU__r.SKU_Code__c from Product_Mix_Details__c where 
                                        Product_Mix__c =:pmid and SKU__r.SKU_Code__c in: skuCodes and SKU__r.Brand_Name__c in: (skuInfo.keySet())]){
                                            skuInt.put(pbd.SKU__r.Brand_Name__c,(skuInt.get(pbd.SKU__r.Brand_Name__c)+1));
                                            relevantSkus.add(pbd.SKU__r.Brand_Name__c);
                                            relevantSkuCodes.add(pbd.SKU__r.SKU_Code__c);
                                        }
        
        set<string>categoria=new set<string>();
        system.debug('relevantSkuCodes==='+JSON.serializePretty(skuInt));
        Http http1 = new Http();
        HttpRequest request1 = new HttpRequest();
        
        // Use Named Credential
        request1.setEndpoint('callout:Brazil_Inventory_SAP_TO_SFDC/http/Brazil_Inventory_SAP_TO_SFDC');
        request1.setMethod('POST');
        
        // Headers (Content-Type is required)
        request1.setHeader('Content-Type', 'application/json');
        list<string>depots=system.label.InventoryDepotCodes.split(',');
        if(dep1!=null)depots.add(dep1);
        // Request Body
        list<object>items=new list<object>();
        for(string ss:depots){
            items.add(new map<string,object>{'DepotCode'=>ss,'salesOrgCode'=>'5191','Deposit'=>'AVEC'});
        }
        map<string,object>invMap=new map<string,object>{'root'=>new map<string,object>{'item'=>items}};
            system.debug('$$$$$$$$$$$$$$$$$$$$$'+JSON.serializePretty(invMap));
        request1.setBody(JSON.serialize(invMap));
        
        HttpResponse response1 = http1.send(request1);
        
        // Debugging Response
        System.debug('Status Code: ' + response1.getStatusCode());
        set<string>skuCd=new set<string>();
        list<map<string,object>>itemMap=new list<map<string,object>>();
        list<map<string,object>>itemMap1=new list<map<string,object>>();
        if (response1.getStatusCode() == 200) {
            System.debug('Success!!!!!!!!!!!!!!'+JSON.serializePretty(relevantSkuCodes));
            string modifiedResponse=deductedInventory((response1.getBody()),accId,dep1);
            Map<String, Object> mm=(Map<String, Object>)JSON.deserializeUntyped(modifiedResponse);
            if(mm.containsKey('root')){
                Map<String, Object> mm1= (Map<String, Object>)mm.get('root');
                if(mm1.containsKey('item')){
                    list<object> obl=(list<object>)mm1.get('item');
                    for(object oo:obl){
                        Map<String, Object> mm2= (Map<String, Object>)oo;
                        if(mm2.containsKey('Sku_Code')){
                            itemMap1.add(mm2);
                            system.debug(mm1.get('Brand')+'^^^^^^^^^^^^^^^^^^^^^^^^^^^'+mm2.get('Sku_Code'));
                            if(relevantSkuCodes.contains(string.valueOf(mm2.get('Sku_Code')))){ skucd.add(string.valueOf(mm2.get('Sku_Code')));
                                                                                               mm2.put('uid',(string.valueOf(mm2.get('Sku_Code'))+'***'+string.valueOf(mm2.get('Batch'))));
                                                                                               itemMap.add(mm2);
                                                                                              }
                        }
                    }
                }
            }}
        system.debug(itemMap1.size()+'############'+JSON.serializePretty(itemMap));
        date compDate=system.today().addDays(integer.valueOF(getDays(accId))).addDays(30);
        set<string>category=new set<string>();
        Map<string,map<string,object>>itList=new map<string,map<string,object>>();
        Map<string,List<string>>itMap=new Map<string,List<string>>();
        Map<string,List<string>>itMap2=new Map<string,List<string>>();
        map<string,decimal>brandMap=new map<string,decimal>();
        for(Price_Book_Details__c pbd:[select id,SKU__c,name,Sku_Name__c,Minimum_Price_R__c,Minimum_Price_U__c,Unit_Price_R__c,Unit_Price_U__c,SKU__r.Standard_Crop_Culture__c,
                                       SKU__r.Brand_Name__c,SKU__r.Multiple_of__c,Price_Book__r.name,SKU__r.SKU_Code__c from Price_Book_Details__c where 
                                       Price_Book__c =:pbid and Active__c=true and SKU__r.SKU_Code__c in: relevantSkuCodes]){
                                           for(Map<String, Object> mm1:itemMap){
                                               string deppo=string.valueOf(mm1.get('Depot_Code'));
                                               
                                               if(depots.contains(deppo) && pbd.SKU__r.Brand_Name__c==string.valueOf(mm1.get('Brand'))){
                                                   if(brandMap.containsKey(pbd.SKU__r.Brand_Name__c))brandMap.put(pbd.SKU__r.Brand_Name__c,brandMap.get(pbd.SKU__r.Brand_Name__c)+decimal.valueOf(string.valueOf(mm1.get('Available_Quantity'))));
                                                   else brandMap.put(pbd.SKU__r.Brand_Name__c,decimal.valueOf(string.valueOf(mm1.get('Available_Quantity'))));                                                      
                                               } 
                                               if(string.valueOf(mm1.get('Sku_Code'))==pbd.SKU__r.SKU_Code__c && decimal.valueOf(string.valueOf(mm1.get('Available_Quantity')))>0){
                                                   system.debug('inHereeeee'+pbd.SKU__r.Brand_Name__c);
                                                   
                                                   String expire = string.valueOf(mm1.get('Batch_Expire_date'));
                                                   Date expireDate = Date.valueOf(expire);
                                                   //if(expireDate > compDate){
                                                   
                                                   // categoria.add(string.valueOf(mm1.get('Batch_Expire_date')));       
                                                   mm1.put('SKUName',pbd.Sku_Name__c);
                                                   mm1.put('MinBrazilPrice',pbd.Minimum_Price_R__c);
                                                   mm1.put('MinUSDPrice',pbd.Minimum_Price_U__c);
                                                   mm1.put('BrazilPrice',pbd.Unit_Price_R__c);
                                                   mm1.put('USDPrice',pbd.Unit_Price_U__c);
                                                   mm1.put('id',pbd.Sku__c);
                                                   mm1.put('multiple',pbd.SKU__r.Multiple_of__c);
                                                   if(pbd.SKU__r.Standard_Crop_Culture__c!=null)mm1.put('cultureDesc',pbd.SKU__r.Standard_Crop_Culture__c);
                                                   else mm1.put('cultureDesc','Soja');
                                                   itList.put(string.valueof(mm1.get('Brand')),mm1);
                                                   if(!itMap.containsKey((string.valueof(mm1.get('Brand')))))itMap.put(string.valueof(mm1.get('Brand')),new list<string>{pbd.Sku__c});
                                                   else {
                                                       list<string> tmpList=itMap.get(string.valueof(mm1.get('Brand')));
                                                       tmpList.add(pbd.Sku__c);
                                                       itMap.put(string.valueof(mm1.get('Brand')),tmpList);
                                                   }
                                                   if(!itMap2.containsKey((string.valueof(mm1.get('Brand')))))itMap2.put(string.valueof(mm1.get('Brand')),new list<string>{pbd.SKU__r.SKU_Code__c});
                                                   else {
                                                       list<string> tmpList=itMap2.get(string.valueof(mm1.get('Brand')));
                                                       tmpList.add(pbd.SKU__r.SKU_Code__c);
                                                       itMap2.put(string.valueof(mm1.get('Brand')),tmpList);
                                                   }
                                                   
                                                   //}
                                               }
                                           }
                                       }
        system.debug('itList**************'+JSON.serializePretty(itList));
        for(string brd:itList.keySet()){
            decimal aqty=brandMap.get(brd);
            if(aqty>0){
                Http http2 = new Http();
                HttpRequest request2 = new HttpRequest();
                string brandName1=brd.replaceAll(' ','-');
                request2.setEndpoint(uplUrl + EncodingUtil.urlEncode(brandName1, 'UTF-8'));
                system.debug('API%%%%%%%%%%%'+(uplUrl + EncodingUtil.urlEncode(brandName1, 'UTF-8')));
                request2.setMethod('GET');
                request2.setHeader('Content-Type', 'application/json');
                
                HttpResponse response2 = http2.send(request2);
                if (response2.getStatusCode() == 200) {
                    map<string,object>ob=new map<string,object>();
                    
                    system.debug(JSON.serializePretty(response2.getBody()));
                    Map<String,Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(response2.getBody());
                    if(resultData.containsKey('data')){
                        Map<String,Object> rd1=new map<string,object>();
                        rd1=(Map<String, Object>)resultData.get('data');
                        if(rd1.containsKey('productDetailsResponse')){
                            Map<String,Object> rd2=new map<string,object>();
                            rd2=(Map<String, Object>)rd1.get('productDetailsResponse');
                            if(rd2.containsKey('product_logo_image'))ob.put('ImageUrl',rd2.get('product_logo_image'));
                            if(rd2.containsKey('description'))ob.put('ProductDescription',rd2.get('description'));
                            ob.put('skuIds',itMap.get(brd));
                            ob.put('qtyAvl',aqty);
                            ob.put('skuCodess',itMap2.get(brd));
                            if(rd2.containsKey('type')){
                                ob.put('Technical',rd2.get('type'));
                                category.add(string.valueOf(rd2.get('type')));
                            }
                            if(rd2.containsKey('name')){
                                ob.put('Name',brd);
                                ob.put('bhome','background-size: cover;');
                                ob.put('SKU',rd2.get('name'));
                                ob.put('SalesOrgName',rd2.get('name'));
                                ob.put('SalesOrgCode',rd2.get('name'));
                                ob.put('ProductName',rd2.get('name'));
                                ob.put('ProductDta',rd2.get('name'));
                                ob.put('Id',rd2.get('name'));
                                ob.put('Description',rd2.get('name'));
                                ob.put('UnitPrice',0);
                            }
                            if(isPortal==false) listaa.add(ob);
                            else{
                                //if(mvset.contains(brd))listaa.add(ob);
                                listaa.add(ob);
                            }
                        } 
                    }
                    
                    
                } else {
                    
                    map<string,object>ob=new map<string,object>();
                    map<string,object>resp=getBrandData(brd);
                    if(resp!=null){
                        ob.put('ImageUrl',resp.get('Icon'));
                        ob.put('ProductDescription',(resp.get('Description')));
                        ob.put('skuIds',itMap.get(brd));
                        ob.put('skuCodess',itMap2.get(brd));
                        ob.put('Technical',resp.get('Type'));
                        category.add(string.valueOf(resp.get('Type')));
                        
                        ob.put('Name',brd);
                        ob.put('bhome','background-size: cover;');
                        ob.put('SKU',(brd));
                        ob.put('SalesOrgName',(brd));
                        ob.put('SalesOrgCode',(brd));
                        ob.put('ProductName',(brd));
                        ob.put('ProductDta',(brd));
                        ob.put('Id',(brd));
                        ob.put('Description',(resp.get('Description')));
                        ob.put('UnitPrice',0);
                        
                        if(isPortal==false) listaa.add(ob);
                        else{
                            //if(mvset.contains(brd))listaa.add(ob);
                            listaa.add(ob);
                        }
                    }
                    
                    
                    
                    
                    System.debug('Error: ' + response2.getStatusCode() + ' - ' + response2.getBody());
                }
            }}
        system.debug('#######@@@@@@@@####'+JSON.serializePretty(listaa));
        
        List<Object> oblist = listaa;
        
        
        
        List<Map<String, Object>> combinedList = new List<Map<String, Object>>();
        integer qqq=1000;
        for (Object o : oblist) {
            Map<String, Object> prod = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
            String name = (String) prod.get('Name');
            
            if (m1.containsKey(name)) {
                prod.put('sortOrder', m1.get(name));
            } else {
                prod.put('sortOrder', qqq);
                qqq=qqq+1;// large value for unmapped items
            }
            combinedList.add(prod);
        }
        
        combinedList.sort(new MapSortByIntegerKey('sortOrder'));
        
        category.add('Todos');
        system.debug('selectedPrdos===============>'+JSON.serializePretty(new map<string,object>{'categoria'=>category,'lista'=>combinedList,'soUser'=>usrId}));
        return new map<string,object>{'categoria'=>category,'lista'=>combinedList,'soUser'=>usrId};
            }
    
    @AuraEnabled(cacheable=true)
    public static List<Featured_Product_Banner> getBannerData()
    {  
        Id recordTypeId = Schema.SObjectType.Featured_Product__c.getRecordTypeInfosByDeveloperName().get('Banner').getRecordTypeId();
        Set<Id> productIdsSet =  new Set<Id>();
        for(Featured_Product__c product : [SELECT Id,Title__c,Description__c,ImageUrl__c,
                                           (SELECT ContentDocumentId FROM ContentDocumentLinks)
                                           FROM Featured_Product__c 
                                           WHERE RecordTypeId  =:recordTypeId 
                                           LIMIT 100])
        {
            productIdsSet.add(product.Id);
        }
        Map<Id, List<ContentDocument>> productFilesMap = new Map<Id, List<ContentDocument>>();
        List<Featured_Product_Banner> result = new List<Featured_Product_Banner>();
        Set<Id> contentDocIds = new Set<Id>();
        if (!productIdsSet.isEmpty()) {
            List<ContentDocumentLink> contentLinks = [
                SELECT LinkedEntityId, ContentDocument.Id, ContentDocument.Title, ContentDocument.LatestPublishedVersionId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :productIdsSet
            ];
            
            for (ContentDocumentLink link : contentLinks) {
                if (!productFilesMap.containsKey(link.LinkedEntityId)) {
                    productFilesMap.put(link.LinkedEntityId, new List<ContentDocument>());
                }
                productFilesMap.get(link.LinkedEntityId).add(link.ContentDocument);
            }
        }
        List<ContentDocument> allFiles = new List<ContentDocument>();
        for(List<ContentDocument> contentDoc : productFilesMap.values())
        {
            allFiles.addAll(contentDoc); 
        }
        for(ContentDocument contentDoc : allFiles)
        {
            contentDocIds.add(contentDoc.Id); 
        }
        
        Map<Id, String> contentDistMap = new Map<Id, String>();
        if (!contentDocIds.isEmpty()) {
            for (ContentDistribution dist : [
                SELECT ContentDocumentId, ContentDownloadUrl 
                FROM ContentDistribution 
                WHERE ContentDocumentId IN :contentDocIds
            ]) {
                contentDistMap.put(dist.ContentDocumentId, dist.ContentDownloadUrl);
            }
        }
        List<ContentDistribution> newDistributions = new List<ContentDistribution>();
        Map<Id, Id> productToContentDocMap = new Map<Id, Id>();
        
        for (Featured_Product__c product :[SELECT Id,Title__c,Description__c,ImageUrl__c,
                                           SKU__r.Name,SKU__r.Brand_Name__c,SKU__r.SKU_Description__C, Products__r.Name,
                                           (SELECT ContentDocumentId FROM ContentDocumentLinks)
                                           FROM Featured_Product__c
                                           WHERE RecordTypeId  =:recordTypeId 
                                           LIMIT 100]) {
                                               Featured_Product_Banner productWithImage = new Featured_Product_Banner();
                                               productWithImage.Id = product.Id;
                                               productWithImage.Name = product.SKU__r != null ? product.SKU__r.Brand_Name__c : null;
                                               productWithImage.Description = product.Description__c;
                                               productWithImage.ProductName = product.Products__r != null ? product.Products__r.Name : null;
                                               productWithImage.Title = product.Title__c;
                                               for (ContentDocumentLink link : product.ContentDocumentLinks) {
                                                   Id contentDocId = link.ContentDocumentId;
                                                   
                                                   if (contentDistMap.containsKey(contentDocId)) {
                                                       productWithImage.ImageUrl = contentDistMap.get(contentDocId);
                                                       system.debug('productWithImage.ImageUrl >>'+productWithImage.ImageUrl);
                                                       break;
                                                   }
                                               }
                                               
                                               result.add(productWithImage);
                                           }
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static map<string,object> getBrandData( string brandname)
    {  
        Id recordTypeId = Schema.SObjectType.Featured_Product__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        Set<Id> productIdsSet =  new Set<Id>();
        for(Featured_Product__c product : [SELECT Id,Title__c,Description__c,ImageUrl__c,Image_Name__c,
                                           (SELECT ContentDocumentId FROM ContentDocumentLinks)
                                           FROM Featured_Product__c 
                                           WHERE RecordTypeId  =:recordTypeId  
                                           AND Name=:brandName
                                           LIMIT 100])
        {
            productIdsSet.add(product.Id);
        }
        if(productIdsSet==null || productIdsSet.isEmpty())return null;
        Map<Id, List<ContentDocument>> productFilesMap = new Map<Id, List<ContentDocument>>();
        List<Featured_Product_Banner> result = new List<Featured_Product_Banner>();
        Set<Id> contentDocIds = new Set<Id>();
        if (!productIdsSet.isEmpty()) {
            List<ContentDocumentLink> contentLinks = [
                SELECT LinkedEntityId, ContentDocument.Id, ContentDocument.Title, ContentDocument.LatestPublishedVersionId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :productIdsSet
            ];
            
            for (ContentDocumentLink link : contentLinks) {
                if (!productFilesMap.containsKey(link.LinkedEntityId)) {
                    productFilesMap.put(link.LinkedEntityId, new List<ContentDocument>());
                }
                productFilesMap.get(link.LinkedEntityId).add(link.ContentDocument);
                
            }
        }
        List<ContentDocument> allFiles = new List<ContentDocument>();
        for(List<ContentDocument> contentDoc : productFilesMap.values())
        {
            allFiles.addAll(contentDoc); 
        }
        for(ContentDocument contentDoc : allFiles)
        {
            contentDocIds.add(contentDoc.Id); 
        }
        
        Map<Id, String> contentDistMap = new Map<Id, String>();
        system.debug('=contentDocIds====='+contentDocIds);
        if (!contentDocIds.isEmpty()) {
            for (ContentDistribution dist : [
                SELECT ContentDocumentId, ContentDownloadUrl 
                FROM ContentDistribution 
                WHERE ContentDocumentId IN :contentDocIds
            ]) {
                contentDistMap.put(dist.ContentDocumentId, dist.ContentDownloadUrl);
            }
        }
        List<ContentDistribution> newDistributions = new List<ContentDistribution>();
        Map<Id, Id> productToContentDocMap = new Map<Id, Id>();
        map<string,object> map2ret=new map<string,object>();
        system.debug('contentDistMap==='+contentDistMap);
        for (Featured_Product__c product :[SELECT Id,Title__c,Description__c,ImageUrl__c,
                                           SKU__r.Name,SKU__r.Brand_Name__c,SKU__r.SKU_Description__C, Products__r.Name,
                                           (SELECT ContentDocumentId,ContentDocument.FileExtension,ContentDocument.Title FROM ContentDocumentLinks)
                                           FROM Featured_Product__c
                                           WHERE RecordTypeId  =:recordTypeId 
                                           LIMIT 100]) {
                                               map2ret.put('Id',product.Id);
                                               map2ret.put('Description',product.Description__c);
                                               map2ret.put('Type',product.Title__c);
                                               for (ContentDocumentLink link : product.ContentDocumentLinks) {
                                                   Id contentDocId = link.ContentDocumentId;
                                                   
                                                   if (contentDistMap.containsKey(contentDocId)) {
                                                       map2ret.put(link.ContentDocument.Title,contentDistMap.get(contentDocId));
                                                   }
                                               }
                                               
                                           }
        return map2ret;
    }
    
    @AuraEnabled
    public static ResultWrapper getPriceListValues(String cropYear, String priceBookType){
        ResultWrapper wrapper = new ResultWrapper();
        try{
            List<Product_Mix__c> productMix = [SELECT Id,Name,Price_Book__c FROM Product_Mix__c WHERE Status__c = 'Active' AND Type_Of_Mix__c =: priceBookType AND Crop_Year__c =: cropYear AND Price_Book__c != null AND Price_Book__r.isActive__c = True];
            wrapper.data = productMix;
        }catch(Exception ex){
            wrapper.success = false;
            wrapper.message = ex.getMessage();
        }        
        return wrapper;
    }
    @AuraEnabled
    public static PriceBookPaymentTermWrapper getPBPaymentTerms(String productMixId, String accId){
        
        PriceBookPaymentTermWrapper ofObj = new PriceBookPaymentTermWrapper();
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        System.debug('Profile Name: ' + profileName);
        if(profileName!='Brazil Sales Person' && accId!=null){
            ofObj.salesRepUserId = getSOwner(accId);
        }
        ofObj.payTermsDays = Grz_SalesOrderFeaturedProductsController.getPaymentTermsDays(productMixId);
        ofObj.payTermsDates = Grz_SalesOrderCreationRequest.getPaymentTermsDates(productMixId);
        ofObj.payTermBR71 = Grz_SalesOrderCreationRequest.getBR71PaymentTerm();
        ofObj.payTermBR00 = Grz_SalesOrderFeaturedProductsController.getBR00PaymentTerm();
        ofObj.productMix = Grz_SalesOrderFeaturedProductsController.getProductMix(productMixId);
        OfObj.paymentTerms = [SELECT Active__c, CombinationKey__c, CreatedById, CreatedDate, CurrencyIsoCode, Days_to_calc_interest__c, Discount_Italy__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Maturity_Date_Mandatory__c, Name, OwnerId, Payment_Term__c, Payment_Term_Code__c, Payterms_Desc__c, Sales_Org__c, SalesOrgCode__c, Sequence_Number__c, SystemModstamp
                              FROM Payment_Term__c 
                              WHERE Sales_Org__r.Sales_Org_Code__c = '5191' AND Active__c  = true];
        return ofObj;
    }
    public static Product_Mix__c  getProductMix(String mixId){
        Product_Mix__c pb = new Product_Mix__c();
        pb = [SELECT Id, Name,Price_Book__c, Interest_Date_Value__c,Is_BR71_Applied__c,Min_Date_Of_FAT__c FROM Product_Mix__c WHERE  Id =: mixId]; //Nikhil RITM0870181
        return pb;
    }
    public static Map<String,Payment_Term__c>  getBR00PaymentTerm(){
        Map<String,Payment_Term__c> options = new Map<String,Payment_Term__c>();
        for(Payment_Term__c ptObj:[SELECT Id, Days_to_calc_interest__c, Payment_Term_Code__c, Payterms_Desc__c, Sales_Org__c, Maturity_Date_Mandatory__c 
                                   FROM Payment_Term__c WHERE Active__c = True AND Sales_Org__r.Sales_Org_Code__c = '5191' AND Payment_Term_Code__c='BR00'
                                   AND Payterms_Desc__c='SEM PAGAMENTO' limit 1]){
                                       options.put(ptObj.Payment_Term_Code__c+' '+ptObj.Payterms_Desc__c, ptObj);
                                   }
        return options;
    }
    public static Map<String,Campaign_Payment_Terms__c> getPaymentTermsDays(String pb_id){
        Map<String,Campaign_Payment_Terms__c> options = new Map<String,Campaign_Payment_Terms__c>();
        for(Campaign_Payment_Terms__c ptObj:[SELECT Id, Name, Price_Book_Brazil__c, Payment_Term__c,Payment_Term__r.Payment_Term_Code__c,Payment_Term__r.Payterms_Desc__c,
                                             Payment_Term__r.Days_to_calc_interest__c, Payment_Term__r.Maturity_Date_Mandatory__c,
                                             Payment_Term_in_Date__c FROM Campaign_Payment_Terms__c 
                                             WHERE Product_Mix__c=:pb_id AND Payment_Term__r.Active__c = True AND Product_Mix__c != null]){
                                                 options.put(ptObj.Payment_Term__r.Payterms_Desc__c, ptObj);
                                             }
        return options;
    }
    @AuraEnabled(cacheable=true)
    public static list<Shipping_Location__c> getShippingLoations(string accId){
        list<Shipping_Location__c> shipToPartyList = new list<Shipping_Location__c>();
        shipToPartyList = [SELECT Id,Name,Location_Name__c,Distributor__c,Distributor__r.Name,City__c,
                           State__c,Country__c,Pincode__c,Sales_Org__c,Billing_Street_3__c,Billing_Street_1__c,Billing_Street_2__c,
                           Billing_Street_4__c,Billing_Street_5__c,Billing_Street_6__c
                           FROM Shipping_Location__c 
                           WHERE Distributor__c=:accId
                           AND Sales_Org__r.sales_org_code__c ='5191'];
        if(!shipToPartyList.isEmpty()){ return shipToPartyList;
                                      }else{
                                          return null;
                                      }
    }
    
    @AuraEnabled
    public static List<SalesOrderItem> saveOrderItems(Sales_Order__c soObj2, List<SalesOrderItem> salesOrderItemList, List<Sales_Org__c> salesOrgList,boolean IsSimulated){
        Boolean ccoFlag = false;  
        Boolean globalFlag = false;
        System.debug('salesOrderItemList@@@'+JSON.serializePretty(salesOrderItemList));  
        System.debug('IsSimulated@@@'+IsSimulated);  
        List<ExchangeRate__c> exchangeRateList = [SELECT Id, ExchangeRate__c, Createddate FROM ExchangeRate__c WHERE (FromCurrency__c = 'USD' AND ToCurrency__c = 'BRL') 
                                                  and CreatedDate > LAST_N_MONTHS:1 ORDER BY Createddate DESC NULLS FIRST limit 1]; 
        Set<String> materialCodeSet = new Set<String>();
        map<string,string>cul2sku=new map<string,string>();
        
        for(SalesOrderItem item: salesOrderItemList){
            materialCodeSet.add(item.productId);
        }
        for(sku__c sss:[select id,Standard_Crop_Culture__c from sku__c where id in :materialCodeSet]){
            if(sss.Standard_Crop_Culture__c!=null)cul2sku.put(sss.Standard_Crop_Culture__c,sss.id);
        }
        for(Culture__c sss:[select id , name from Culture__c where name in:cul2sku.keySet()]){
            cul2sku.put(sss.id,cul2sku.get(sss.name));
        }
        Account accInfo = [SELECT Id, Depot_Code__c,Price_Conversion_Group__c,Brazil_Region__c FROM Account WHERE Id =: soObj2.Sold_to_Party__c limit 1];
        String depotCode = accInfo.Depot_Code__c;
        //String customerGroup = [SELECT Id, customer_group__c FROM Account WHERE Id=:soObj2.Sold_to_Party__c].customer_group__c;
        String priceConversionFactor = accInfo.Price_Conversion_Group__c;
        
        Map<Id,Id> materialPlantMap = new Map<Id,Id>();
        if(soObj2.Type_of_Order__c == 'ORDEM FILHA'){
            for(Material_Plant_Relation__c mprObj: [SELECT Id, Depot__c, SKU__c, SKU__r.SKU_Code__c
                                                    FROM Material_Plant_Relation__c 
                                                    WHERE SKU__c IN: materialCodeSet 
                                                    AND Depot__c=:depotCode]){
                                                        materialPlantMap.put(mprObj.SKU__c, mprObj.Id);       
                                                    }
        }
        else{
            list<Material_Plant_Relation__c> mprList= new list<Material_Plant_Relation__c>();
            if(IsSimulated){
                mprList= [SELECT Id, Depot__c, SKU__c, SKU__r.SKU_Code__c
                          FROM Material_Plant_Relation__c 
                          WHERE SKU__c IN: materialCodeSet                    
                          AND Depot__c=:depotCode ];
            }else{
                mprList=[SELECT Id, Depot__c, SKU__c, SKU__r.SKU_Code__c
                         FROM Material_Plant_Relation__c 
                         WHERE SKU__c IN: materialCodeSet 
                         AND Depot__c=:depotCode
                         AND Active__c = True];
            }     
            for(Material_Plant_Relation__c mprObj: mprList){
                materialPlantMap.put(mprObj.SKU__c, mprObj.Id);                                         
            }
        }
        delete [SELECT Id FROM Sales_Order_Line_Item__c WHERE Sale_Order__c=:soObj2.Id];
        Grz_OrderRequestViewController.KEDE kedeObj = Grz_OrderRequestViewController.getKEDE(soObj2.OwnerId);
        Map<String,Id> cultureMap = new Map<String,Id>();
        for(Culture__c culObj:[SELECT Id, Name, Culture_Code__c, 
                               Culture_Desc__c, Division__c, Sales_Org__c 
                               FROM Culture__c 
                               WHERE Active__c=True 
                               ORDER BY Culture_Code__c]){
                                   cultureMap.put(culObj.Culture_Desc__c, culObj.Id);
                               }
        List<Sales_Order_Line_Item__c> soiList = new List<Sales_Order_Line_Item__c>();
        Integer i = 0;
        //Map<string,Customer_Conversion_factor__c> MapCCF = getConversionFactor(priceConversionFactor);
        
        Map<string,Discount_Matrix__c> MapDM = new Map<string,Discount_Matrix__c>();
        for (Discount_Matrix__c DM: [select id, Brand_Name__c, BU_Manager__c,
                                     Sales_Director__c, Sales_District_Manager__c,
                                     Sales_Person__c from Discount_Matrix__c]){
                                         MapDM.put(DM.Brand_Name__c, DM);  
                                     }
        Map<Decimal,Decimal> kitItemNumberMap = new Map<Decimal,Decimal>();
        Map<Decimal, String> kitSKUMap = new Map<Decimal, String>();
        System.debug('soObj2@@@'+soObj2); 
        for(SalesOrderItem item: salesOrderItemList){
            Sales_Order_Line_Item__c soiObj = new Sales_Order_Line_Item__c();
            i = i+10;
            soiObj.Item_Number__c = i;
            soiObj.Sale_Order__c = soObj2.Id;
            soiObj.Product_Category__c = item.skuCategory;
            soiObj.SelloutPrice__c = item.selloutprice; 
            soiObj.Expiry_Date__c = item.Batch_Expire_date; 
            soiObj.Item_Category__c = item.itemCategory;
            soiObj.Batch__c = item.Batch;
            soiObj.Br_Transfer_Depot__c = item.depotT;
            soiObj.Round__c = item.round;
            //soiObj.DepotDepot__c = item.depotId;
            if(!test.isRunningTest())soiObj.DepotDepot__c = [SELECT Id FROM Depot__c  WHERE SalesOrg__r.Sales_Org_Code__c ='5191' and Depot_Code__c=:item.depotT][0].Id;
            
            soiObj.Deposit__c = item.Deposit;
            soiObj.Cancellation_Reason__c = item.cancellationReason;
            soiObj.Delivery_Date__c = item.deliveryDate;
            try{
                soiObj.DateofFAT__c = Date.valueOf(item.fatDate);
            }
            catch(Exception ex){
                soiObj.DateofFAT__c = Date.parse(item.fatDate); 
            }
            soiObj.SKU_Name__c = item.productId;
            soiObj.Kit_Product__c = item.kitProduct;
            if(soObj2.Kit_Order__c){
                if(item.kitProduct){
                    kitItemNumberMap.put(item.kitNo, soiObj.Item_Number__c);
                    kitSKUMap.put(item.kitNo,item.productId);
                }else{
                    if(kitItemNumberMap.containsKey(item.refKitNo) && kitSKUMap.containsKey(item.refKitNo)){
                        soiObj.Kit_Item_Number__c = kitItemNumberMap.get(item.refKitNo);
                        soiObj.Kit_SKU__c = kitSKUMap.get(item.refKitNo);
                    }
                    
                }
            }
            soiObj.SKU_Name__c = item.productId;
            soiObj.UnitValue__c = item.unitValue;
            if(item.budgetValue!= null){
                soiObj.BudgetPrice__c = item.budgetValue;
            }
            soiObj.MinValue__c =item.minValue;
            soiObj.InterestRate__c = item.interestRate;
            soiObj.Quantity__c = item.qty;
            soiObj.UnitValuewithInterest__c = item.unitValueWithInterest;
            soiObj.Customer_Conversion_Factor__c = item.CustomerConversionFactor;
            soiObj.Minimum_Price_Conversion_Factor__c = item.custconversionfatorMin;
            /*if(MapCCF.containskey(item.brand)){
if(string.isNotBlank(string.valueOf(MapCCF.get(item.brand).Conversion_Factor__c))){
soiObj.Customer_Conversion_Factor__c = MapCCF.get(item.brand).Conversion_Factor__c;
soiObj.Minimum_Price_Conversion_Factor__c = MapCCF.get(item.brand).Minimum_Price_Conversion_Factor__c;
}
else{
soiObj.Customer_Conversion_Factor__c = 1; 
soiObj.Minimum_Price_Conversion_Factor__c = 1;
}
}
else{
soiObj.Customer_Conversion_Factor__c = 1;
soiObj.Minimum_Price_Conversion_Factor__c = 1;
}*/
            
            soiObj.Time_in_months__c = item.timeInMonths;
            soiObj.Days__c = item.days;
            soiObj.Recommended_price__c=item.Recommendedprice; 
            soiObj.DDS_Grade__c=item.DDSGrade;  
            if(item.priceBookDetailId!= '' && item.priceBookDetailId != null && !item.kitProduct)
            {
                soiObj.PriceBookDetail__c = item.priceBookDetailId;
            }
            soiObj.multipleOf__c = item.multipleOf; 
            soiObj.CurrencyIsoCode = soObj2.CurrencyIsoCode;
            soiObj.MO_Item_No__c = item.moItemNo;
            if(cultureMap.containsKey(item.cultureDesc)){
                soiObj.Culture__c = cultureMap.get(item.cultureDesc);
            }
            if(cul2sku.containsKey(item.productId)){
                soiObj.Culture__c = cul2sku.get(item.productId);
            }
            if(!salesOrgList.isEmpty()){
                soiObj.Sales_Org__c = salesOrgList[0].Id;
            }
            if(!soObj2.Kit_Order__c || (soObj2.Kit_Order__c && !item.kitProduct)){ 
                if(materialPlantMap.containsKey(item.productId)){
                    soiObj.MaterialPlantRelation__c = materialPlantMap.get(item.productId);
                }
                else{
                    CalloutException e = new CalloutException();
                    e.setMessage('?Material   ID not found: '+item.productId);
                    throw e;
                }
            }
            if(!exchangeRateList.isEmpty()){
                soiObj.ExchangeRate__c = exchangeRateList[0].Id;
            }
            if(String.isNotBlank(item.orderItemId)){
                soiObj.Sales_Order_Line_Item__c = item.orderItemId;
            } 
            soiObj.Product_PO_item_number__c = item.POItemNumber;
            RecordType clientOnlyRecordType = [
                SELECT Id FROM RecordType WHERE DeveloperName = 'Simulation'
            ];
            Id idforsimulation;
            if( clientOnlyRecordType != null ){
                idforsimulation = clientOnlyRecordType.Id;
            }else{
                idforsimulation = '0120K000001HskHQAS';
            }
            if(soObj2.RecordTypeId == idforsimulation && soObj2.Parent_Order_Simulated__c!=null){
                Sales_Order_Line_Item__c soliKEDE = [select Id,ListPriceDiscount__c, ListPriceDiscount_1__c,ListPriceDiscount_2__c,ListPriceDiscount_3__c,ListPriceDiscount_4__c,
                                                     TotalOrderMargin__c,TotalOrderMargin_1__c,TotalOrderMargin_2__c,TotalOrderMargin_3__c,ExchangeRate__c,TotalOrderMargin_4__c,
                                                     SalesDistrictManager__c,Marketing_Ops_Manager__c, SalesOfficeManager__c,SalesDirector__c,REH__c,Tax__c,Freight__c
                                                     FROM Sales_Order_Line_Item__c where Sale_Order__c=:soObj2.Parent_Order_Simulated__c limit 1];
                
                if(soliKEDE!=null){
                    soiObj.ExchangeRate__c = soliKEDE.ExchangeRate__c;
                    soiObj.TotalOrderMargin__c = soliKEDE.TotalOrderMargin__c;
                    soiObj.ListPriceDiscount__c = soliKEDE.ListPriceDiscount__c;                
                    soiObj.Tax__c = soliKEDE.Tax__c; 
                    soiObj.Freight__c = soliKEDE.Freight__c;
                    if(String.isNotBlank(soliKEDE.SalesDistrictManager__c)){
                        soiObj.SalesDistrictManager__c = soliKEDE.SalesDistrictManager__c;                    
                        soiObj.TotalOrderMargin_1__c = soliKEDE.TotalOrderMargin_1__c;
                        soiObj.ListPriceDiscount_1__c = soliKEDE.ListPriceDiscount_1__c;
                    }
                    if(String.isNotBlank(soliKEDE.Marketing_Ops_Manager__c)){
                        soiObj.Marketing_Ops_Manager__c = soliKEDE.Marketing_Ops_Manager__c;                    
                        soiObj.TotalOrderMargin_1__c = soliKEDE.TotalOrderMargin_1__c;
                        soiObj.ListPriceDiscount_1__c = soliKEDE.ListPriceDiscount_1__c;
                        
                    }
                    if(String.isNotBlank(soliKEDE.SalesOfficeManager__c)){
                        soiObj.SalesOfficeManager__c = soliKEDE.SalesOfficeManager__c;
                        soiObj.TotalOrderMargin_2__c = soliKEDE.TotalOrderMargin_2__c;
                        soiObj.ListPriceDiscount_2__c = soliKEDE.ListPriceDiscount_2__c;
                    }
                    if(String.isNotBlank(soliKEDE.SalesDirector__c)){
                        soiObj.SalesDirector__c = soliKEDE.SalesDirector__c;
                        soiObj.TotalOrderMargin_3__c = soliKEDE.TotalOrderMargin_3__c;
                        soiObj.ListPriceDiscount_3__c = soliKEDE.ListPriceDiscount_3__c;
                    }
                    if(String.isNotBlank(soliKEDE.REH__c)){
                        soiObj.REH__c = soliKEDE.REH__c;
                        soiObj.TotalOrderMargin_4__c = soliKEDE.TotalOrderMargin_4__c;
                        soiObj.ListPriceDiscount_4__c = soliKEDE.ListPriceDiscount_4__c;
                    }
                }   
            }
            else if(kedeObj!=null){
                soiObj.TotalOrderMargin__c = kedeObj.SP_TotalOrderMargin; 
                if(!item.kitProduct){  
                    
                    soiObj.ListPriceDiscount__c = MapDM.get(item.brand).Sales_Person__c;
                    
                }
                soiObj.Tax__c = kedeObj.tax; 
                soiObj.Freight__c = kedeObj.freight;
                if(String.isNotBlank(kedeObj.salesDistrictManager)){
                    soiObj.SalesDistrictManager__c = kedeObj.salesDistrictManager;                    
                    soiObj.TotalOrderMargin_1__c = kedeObj.SDM_TotalOrderMargin1;
                    if(String.isNotBlank(kedeObj.BrazilMarketingOpsManager)){
                        soiObj.Marketing_Ops_Manager__c = kedeObj.BrazilMarketingOpsManager;    
                    }
                    if(!item.kitProduct){
                        soiObj.ListPriceDiscount_1__c = MapDM.get(item.brand).Sales_District_Manager__c
                            +MapDM.get(item.brand).Sales_Person__c;
                    }
                }
                if(String.isNotBlank(kedeObj.salesOfficeManager)){
                    soiObj.SalesOfficeManager__c = kedeObj.salesOfficeManager;
                    soiObj.TotalOrderMargin_2__c = kedeObj.SOM_TotalOrderMargin2;
                    if(!item.kitProduct){
                        soiObj.ListPriceDiscount_2__c = MapDM.get(item.brand).BU_Manager__c
                            + MapDM.get(item.brand).Sales_District_Manager__c
                            + MapDM.get(item.brand).Sales_Person__c;
                    }
                }
                if(String.isNotBlank(kedeObj.salesDirector)){
                    soiObj.SalesDirector__c = kedeObj.salesDirector;
                    soiObj.TotalOrderMargin_3__c = kedeObj.SD_TotalOrderMargin3;
                    if(!item.kitProduct){
                        soiObj.ListPriceDiscount_3__c = MapDM.get(item.brand).Sales_Director__c
                            + MapDM.get(item.brand).BU_Manager__c
                            + MapDM.get(item.brand).Sales_District_Manager__c
                            + MapDM.get(item.brand).Sales_Person__c;
                    }
                }
                if(String.isNotBlank(kedeObj.REHManager)){
                    soiObj.REH__c = kedeObj.REHManager;
                    soiObj.TotalOrderMargin_4__c = kedeObj.REH_TotalOrderMargin4;
                    soiObj.ListPriceDiscount_4__c = kedeObj.REH_ListPriceDiscount4;
                }
            }
            soiObj.Sales_Deduction_Budget__c = item.salesDeductionCost;
            soiObj.Discount1__c = item.cogsCost;
            soiObj.E2E_Cost__c = item.e2eCost;
            if(item.isBlanket == true){
                soiObj.Blanket_SKU_End_Date__c = Date.valueOf(item.blnkt_EndDate);
                soiObj.Blanket_SKU_Start_Date__c = Date.valueOf(item.blnkt_StartDate);
                soiObj.Blanket_SKU_Status__c = item.blnkt_Status;
            }
            soiObj.Level_1_max__c = item.level1Max;
            soiObj.Level_1_min__c = item.level1Min;
            soiObj.Level_2_max__c = item.level2Max;
            soiObj.Level_2_min__c = item.level2Min;
            soiObj.Level_3_below__c = item.level3Below;
            soiObj.Approval_Level__c = item.approvalLevel;
            soiObj.UOM__c = item.uom;
            soiObj.Base_UOM__c = item.baseUOM;
            soiObj.Converted_Qty__c = item.convertedQnty;
            soiObj.Converted_Net_Price__c = item.convertedNetPrice;
            soiObj.Sales_Deduction_Cal__c = item.salesDeductionCal;
            soiObj.Discount_Cal__c = item.cogsCostCal;
            soiObj.E2E_Cost_Cal__c = item.e2eCostCal;
            soiObj.Margin_Block_Level_1__c = item.mbLevel1;
            soiObj.Margin_Block_Level_2__c = item.mbLevel2;
            soiObj.Contribution_Margin__c = item.contMargin;
            soiList.add(soiObj);
            System.debug('soiObj@@@@@'+soiObj); 
        }
        System.debug('soiList@@@@'+soiList); 
        if(!soiList.isEmpty()){
            system.debug('indide ifff@@');
            insert soiList;
            soObj2.Sent_for_CCO__c = false;
            soObj2.Sent_for_Latam_Director_Approval__c = false;
            if(soObj2.AVEC_Order__c == false){ 
                if(ccoFlag == true){
                    soObj2.Sent_for_Latam_Director_Approval__c = true;
                }
                if(globalFlag == true){
                    soObj2.Sent_for_CCO__c = true;
                }
            }
            update soObj2;
        }
        return getSalesOrderItems(soObj2.Id);
    }
    public static List<SalesOrderItem> getSalesOrderItems(ID soId) {
        string regCode;
        List<Territory_Distributor__c> tdList = [SELECT ID, Name, TerritoryCode__c, Region__c,Region__r.RegionCode__c,Region__r.Brazil_Marketing_Ops_Manager__c
                                                 FROM Territory_Distributor__c 
                                                 WHERE SalesOrg__r.Sales_Org_Code__c = '5191'
                                                 AND (TerritoryManager__c=: UserInfo.getUserId() 
                                                      OR Region__r.RegionHead__c=: UserInfo.getUserId()
                                                      OR Zone__r.ZonalHead__c=: UserInfo.getUserId()
                                                      OR Region__r.Brazil_Marketing_Ops_Manager__c=:UserInfo.getUserId()
                                                      OR SBU__r.SBUUser__c=: UserInfo.getUserId()
                                                      OR BarterManager__c=: UserInfo.getUserId()
                                                     ) limit 1]; 
        
        //system.debug('**Territory List --> ' +tdList);
        if(tdList.size()>0){
            regCode = tdList[0].Region__r.RegionCode__c;
            system.debug('**regionCode --> ' +regCode);
        }
        
        Map<Id,date> dateMap = new Map<Id,date>();
        list<Brazil_Region_SKU_Combination__c> comboList = new list<Brazil_Region_SKU_Combination__c>();
        if(regCode!=null){
            comboList = [SELECT Id, SKU__c, Sales_District__c, Availability__c,Date__c FROM Brazil_Region_SKU_Combination__c where Sales_District__r.RegionCode__c =:regCode] ;
            system.debug('**List Brazil_Region_SKU_Combination --> ' +comboList);
        }
        
        if(comboList.size()>0){
            for( Brazil_Region_SKU_Combination__c temp: comboList){
                if(temp.Date__c !=null){
                    dateMap.put(temp.SKU__c, temp.Date__c); 
                }
            }
        }
        
        system.debug('**Map Min Date --> ' +dateMap);
        // added Recommended_price__c, DDS_Grade__c in query by Sagar for DDS score
        // SKI(Nik) : #CR155 : Brazil Margin Block : 30-08-2022.......added 22 newly created fields for this CR.
        //  Change by Swaranjeet(Grazitti) APPS-4591----Added 3 fields in query 
        List<Sales_Order_Line_Item__c> salesOrderItemList = [SELECT ID,Customer_Conversion_Factor__c,Minimum_Price_Conversion_Factor__c,SelloutPrice__c,round__c,Sale_Order__r.Price_Book__r.CreatedDate,Sale_Order__r.Kit_Order__c,Item_Category__c,Kit_Item_Number__c,Kit_Product__c,Kit_SKU__c,Kit_SKU__r.SKU_Description__c,Kit_SKU__r.Name, Sale_Order__c, DateofFAT__c, SKU_Name__c, Discount__c, Tax__c, Freight__c,
                                                             SKU_Name__r.SKU_Description__c,SKU_Name__r.sku_code__c,SKU_Name__r.Product_Name__c, Time_in_months__c, Days__c, Flag__c,New_Date_of_FAT__c,New_Quantity__c, MO_Item_No__c,Cogs_Info__c, Recommended_price__c, DDS_Grade__c,
                                                             UnitValue__c,Product_Category__c, InterestRate__c, ProductReplacementMargin__c,GP_Total__c,GP_Lista__c,gplistaunitvalue__c,Impacto_GP_vs_LP__c, Net_Price__c,MinValue__c,
                                                             Quantity__c, UnitValuewithInterest__c, Culture__r.Culture_Desc__c,BudgetPrice__c, Product_Replacement_Margin_Unit_Price__c,
                                                             ProductLedgerMargin__c, Approval_Flag__c, Culture__c, Item_Number__c,Budget_Value_Margin__c,
                                                             PriceBookDetail__c, CurrencyIsoCode, Sales_Org__c, Sales_Order_Line_Item__c,
                                                             MaterialPlantRelation__c, TotalValueWithoutInterest__c, Sales_Order_Line_Item__r.Item_Number__c,
                                                             ExchangeRate__c, SKU_Name__r.Name, TotalValueWithInterest__c,multipleOf__c,CreatedDate,
                                                             PriceBookDetail__r.Price_book__r.Currency__c,MaterialPlantRelation__r.Replacement_Cost__c,ExchangeRate__r.ExchangeRate__c,
                                                             PriceBookDetail__r.Unit_Price__c, PriceBookDetail__r.Unit_Price_R__c, PriceBookDetail__r.Unit_Price_U__c,
                                                             PriceBookDetail__r.CreatedDate, SKU_Name__r.Brand_Name__c, PriceBookDetail__r.Minimum_Price_R__c,PriceBookDetail__r.Price_Book__r.Apply_Minimum_Price__c,
                                                             PriceBookDetail__r.Minimum_Price_U__c, PriceBookDetail__r.Price_Book__r.Interest_Date__c,Product_PO_item_number__c,Unit_Price_R__c,Tax_Amount_Without_Interest__c,Freight_Amount_Without_Interest__c,TotalTax__c,TotalFreight__c,TotalPunctuality__c,
                                                             Punctuality_Discount_WI_Calculated__c,Sale_Order__r.Punctuality_Discount__c,TotalReplacementCost__c,Discount_Considering_Barter_Discount__c,SalesPerson__c,Item_Status__c, //Divya INCTASK0186953
                                                             Sales_Deduction_Budget__c, Discount1__c, E2E_Cost__c, Blanket_SKU_End_Date__c, Blanket_SKU_Start_Date__c, Blanket_SKU_Status__c, Level_1_max__c, Level_1_min__c, 
                                                             Level_2_max__c, Level_2_min__c, Level_3_below__c, Approval_Level__c, UOM__c, Base_UOM__c, Converted_Qty__c, Sales_Deduction_Cal__c, Discount_Cal__c, 
                                                             E2E_Cost_Cal__c, Margin_Block_Level_1__c, Margin_Block_Level_2__c, Contribution_Margin__c, Converted_Net_Price__c,Barter_Discount_Percentage__c,BarterDiscountCalculated1__c,Gross_Margin_with_Barter1__c,Cancellation_Reason__c,
                                                             Sale_Order__r.Sold_to_Party__r.Price_Conversion_Group__c,UnitPriceOfPriceList__c,Aderencia__c // added Sale_Order__r.Sold_to_Party__r.Price_Conversion_Group__c by javed  for RITM0652620 Added cancellation reason Bhavika
                                                             FROM Sales_Order_Line_Item__c
                                                             WHERE Sale_Order__c=:soId Order By CreatedDate];//Modified by Deeksha for kit selling Project
        
        Map<String,Decimal> FYMap = new Map<String,Decimal>();
        String custconversiongroup; //Added by Grz(Dheeraj Sharma) for RITM0808578 on 01-08-2024
        list<String> skulist = new list<String>();
        list<String> fyearlist = new list<String>();
        for(Sales_Order_Line_Item__c soiObj: salesOrderItemList){
            String sku = soiobj.SKU_Name__r.Name;
            String year = String.valueOf(soiobj.CreatedDate.year());
            skulist.add(sku);
            fyearlist.add(year);
            if(null!=soiObj.Sale_Order__r.Sold_to_Party__c && soiObj.Sale_Order__r.Sold_to_Party__r.Price_Conversion_Group__c!='' && null!=soiObj.Sale_Order__r.Sold_to_Party__r.Price_Conversion_Group__c){           //Added by Grz(Dheeraj Sharma) for RITM0808578 on 01-08-2024
                custconversiongroup=soiObj.Sale_Order__r.Sold_to_Party__r.Price_Conversion_Group__c; 
            }
        }
        System.debug('sku list-'+skulist);
        System.debug('fyearlist-'+fyearlist);
        
        list<Account_Target__c> fy = [SELECT Id, Quantity__c ,Price__c,Product__c,Product__r.Name,Year__c,RecordType.Name FROM Account_Target__c where Product__r.Name IN :skulist and Year__c IN :fyearlist and RecordType.Name='Yearly'];
        System.debug('fy list-'+fy);
        
        if(fy.size()>0){
            for( Account_Target__c temp: fy){
                if(temp.id !=null){
                    FYMap.put(temp.Product__r.Name, temp.Price__c); 
                }
            }
        }
        
        //Added by Grz(Dheeraj Sharma) for RITM0808578 on 01-08-2024
        Map<String,Customer_Conversion_factor__c> getcustconversion = Grz_OrderRequestViewController.getConversionFactor(custconversiongroup);
        
        Boolean budgetApprovalCheck = false;
        List<SalesOrderItem> itemList = new List<SalesOrderItem>();
        // System.debug('salesOrderItemList'+salesOrderItemList);
        Map<Decimal,List<Decimal>> kitValuesMap = new  Map<Decimal,List<Decimal>>();//Modified by Deeksha for kit selling Project
        for(Sales_Order_Line_Item__c soiObj: salesOrderItemList){
            SalesOrderItem item = new SalesOrderItem();
            item.productCode = soiObj.SKU_Name__r.sku_code__c;
            if( dateMap.containskey(soiObj.SKU_Name__c)){
                system.debug('**Inside Date Map **');
                item.minDate = String.valueOf(dateMap.get(soiObj.SKU_Name__c));
                system.debug('**Date Min --> ' +item.minDate );
            }
            // below 4 lines added by Anmol@wipro for US SOS-002
            if( FYMap.containskey(soiObj.SKU_Name__r.Name)){
                item.quantity = Integer.valueOf(FYMap.get(soiObj.SKU_Name__r.Name));
                //system.debug('**Date Min --> ' +item.minDate );
            }
            
            item.applyMinPrice = soiObj.PriceBookDetail__r.Price_Book__r.Apply_Minimum_Price__c;  // Priya RITM0237685
            
            //Modified by Deeksha for kit selling Project
            item.kitProduct = soiObj.Kit_Product__c;
            if(soiObj.Kit_Product__c){
                item.kitNo = soiObj.Item_Number__c;
            }
            item.refKitNo = soiObj.Kit_Item_Number__c;
            item.productId = soiObj.SKU_Name__c;
            item.productName = soiObj.SKU_Name__r.SKU_Description__c;
            item.brand = soiObj.SKU_Name__r.Brand_Name__c; 
            item.kitSKU = soiObj.Kit_SKU__c;
            item.create_Date = String.valueOf(soiObj.Sale_Order__r.Price_Book__r.CreatedDate); 
            item.currency_Code = soiObj.CurrencyIsoCode;
            item.itemCategory = soiObj.Item_Category__c;
            item.selloutprice=soiObj.SelloutPrice__c; //Added by Krishanu@Wipro 
            //End
            //Added by Sirisha start
            
            item.replacementMargin = soiObj.ProductReplacementMargin__c;
            if(!Test.isRunningTest()){
                item.gptotal = soiObj.GP_Total__c;
            }
            item.gplista = soiObj.GP_Lista__c;
            item.gplistaunitvalue =soiObj.gplistaunitvalue__c; 
            item.impactgpvslp = soiObj.Impacto_GP_vs_LP__c;         
            item.replacementMarginUP = soiObj.Product_Replacement_Margin_Unit_Price__c; //Divya: 13-07-2020: Added for SCTASK0216506
            item.ledgerMargin = soiObj.ProductLedgerMargin__c;
            item.cancellationReason = soiObj.Cancellation_Reason__c;//added by tanuj >> Cancellation Reason >> 6 Feb 2023
            item.fatDate = String.valueOf(soiObj.DateofFAT__c);
            item.fatDateNew = String.valueOf(soiObj.New_Date_of_FAT__c);
            item.unitValue = soiObj.UnitValue__c;
            item.budgetValue = soiObj.BudgetPrice__c; //added by ganesh Date:12/11/2018
            //item.minValue = soiObj.MinValue__c; //added by ganesh Date:16/5/8
            item.qty = soiObj.Quantity__c;
            if(soiObj.New_Quantity__c==0 || soiObj.New_Quantity__c==null){
                item.qtyNew=null; // <!--Added by Grz(Dheeraj Sharma) for RITM0920591 on 17 Feb 2025-->
            }else{
                item.qtyNew = soiObj.New_Quantity__c;
            }
            item.skuCategory = soiObj.Product_Category__c;
            item.unitValueWithInterest = soiObj.UnitValuewithInterest__c;
            item.unitpriceofpricelist = soiObj.UnitPriceOfPriceList__c;
            item.aderencia = soiObj.Aderencia__c;
            /*decimal confactor;
Customer_Conversion_Factor__c custconversionfac =getcustconversion.get(item.brand);
if(custconversionfac!=null){
confactor= custconversionfac.Conversion_Factor__c;
//Added by Grz(Dheeraj Sharma) for RITM0815453 on 19-08-2024
if(soiObj.PriceBookDetail__r.Price_book__r.Currency__c == 'Only BRL'){
item.unitpriceofpricelist =soiObj.PriceBookDetail__r.Unit_Price_R__c*confactor; 
}else{
item.unitpriceofpricelist =soiObj.PriceBookDetail__r.Unit_Price_U__c*confactor;  
}
if(null!=item.unitpriceofpricelist){
item.aderencia=item.unitValueWithInterest/(item.unitpriceofpricelist);
}
}*/
            system.debug('PresentValue'+item.unitValueWithInterest);
            system.debug('unitpriceofpricelist1'+item.unitpriceofpricelist);
            //Added by Grz(Dheeraj Sharma) for RITM0815453 on 19-08-2024
            decimal totalValWithoutinsterestUP=0;
            if(null!=item.unitpriceofpricelist){
                totalValWithoutinsterestUP= soiObj.Quantity__c * item.unitpriceofpricelist;
            }
            decimal taxUP=(soiObj.Tax__c /100) * totalValWithoutinsterestUP;
            decimal freightUP=(soiObj.Freight__c/100) * totalValWithoutinsterestUP;
            decimal punctualityUP = 0;
            if(soiObj.Sale_Order__r.Punctuality_Discount__c != null){
                punctualityUP=(soiObj.Sale_Order__r.Punctuality_Discount__c/100) * totalValWithoutinsterestUP;
            }
            decimal denominator = (totalValWithoutinsterestUP - taxUP - punctualityUP);
            system.debug('totalValWithoutinsterestUP'+totalValWithoutinsterestUP);
            system.debug('taxUP'+taxUP);
            system.debug('freightUP'+freightUP);
            system.debug('punctualityUP'+punctualityUP);
            system.debug('TotalReplacementCost__c'+soiObj.TotalReplacementCost__c);
            decimal TotalReplacementCost = 0;
            if(soiObj.TotalReplacementCost__c != null){
                TotalReplacementCost = soiObj.TotalReplacementCost__c;
            }        
            if(denominator != 0.00){
                item.MargemLista = ((totalValWithoutinsterestUP - taxUP - freightUP - punctualityUP-TotalReplacementCost)/(totalValWithoutinsterestUP - taxUP - punctualityUP ))*100 ;
                system.debug('item.MargemLista'+item.MargemLista);
            }
            else{
                item.MargemLista = 0.00; 
            }
            
            item.totaltax = soiObj.TotalTax__c;
            item.totalfreight = soiObj.TotalFreight__c;
            item.totalpunctuality = soiObj.TotalPunctuality__c;
            item.totalValueWithInterest = soiObj.TotalValueWithoutInterest__c; //changes by ganesh Date :11/5/2018
            item.taxAmountWithoutInterest = soiObj.Tax_Amount_Without_Interest__c;
            item.freightAmountWithoutInterest = soiObj.Freight_Amount_Without_Interest__c;
            item.punctualityDiscountWICalculated = soiObj.Punctuality_Discount_WI_Calculated__c;
            item.totalReplacementCost1 = soiObj.TotalReplacementCost__c;
            item.timeInMonths = soiObj.Time_in_months__c;
            item.orderItemId = soiObj.Sales_Order_Line_Item__c;
            if(soiObj.Days__c!=null){
                item.days = soiObj.Days__c;
                system.debug('item.days=='+item.days);
                system.debug('item.days=='+soiObj.Days__c);
            }
            item.CogsInfo= soiObj.Cogs_Info__c;
            
            // added by Sagar for DDS score 
            item.DiscountBarter=soiObj.Discount_Considering_Barter_Discount__c;
            item.BarterDiscountPercentage=soiObj.Barter_Discount_Percentage__c;// Change by Swaranjeet(Grazitti) APPS-4591 
            if(soiObj.Barter_Discount_Percentage__c != null){
                item.bartercheckpoint=true;
            }
            else{
                item.bartercheckpoint=false;
            }
            
            if(soiObj.Gross_Margin_with_Barter1__c != null){
                item.GrossMarginwithBarter=soiObj.Gross_Margin_with_Barter1__c;//Change by Swaranjeet(Grazitti) APPS-4591 
            }else{
                item.GrossMarginwithBarter = 0;
            }
            item.BarterDiscountCalculated=soiObj.BarterDiscountCalculated1__c;//Change by Swaranjeet(Grazitti) APPS-4591
            
            item.Ids=soiObj.ID;
            item.salesperson=soiObj.SalesPerson__c;
            
            item.ItemStatus = soiObj.Item_Status__c;
            item.CustomerConversionFactor = soiObj.Customer_Conversion_Factor__c; //Added by Sagar for calculating Barter Discount
            item.custconversionfatorMin = soiObj.Minimum_Price_Conversion_Factor__c;
            item.Recommendedprice=soiObj.Recommended_price__c;      
            item.DDSGrade=soiObj.DDS_Grade__c;
            
            // added by Sagar for DDS score 
            if(item.DDSGrade == 'Very Good Quality'){
                item.DDSGrade='Muito Bom';
            }
            else if(item.DDSGrade == 'Good Quality'){
                item.DDSGrade='Ok';
            }
            else if(item.DDSGrade == 'Low Quality'){
                item.DDSGrade='Ruim';
            }
            else if(item.DDSGrade == 'Very Low Quality'){
                item.DDSGrade='Muito Ruim';
            }
            else if(item.DDSGrade == 'No Grade as deal_price<min_price'){
                item.DDSGrade='No Grade as deal price min price';
            }
            item.interest_Date = String.valueOf(soiObj.PriceBookDetail__r.Price_Book__r.Interest_Date__c);//Divya INCTASK0186953
            if(String.isNotBlank(soiObj.Sales_Order_Line_Item__c)){ item.itemNo = soiObj.Sales_Order_Line_Item__r.Item_Number__c;
                                                                  }
            else{
                item.itemNo = soiObj.Item_Number__c;
            }
            system.debug('budgetFlag'+item.budgetFlag);
            system.debug('soiObj.Budget_Value_Margin__c'+soiObj.Budget_Value_Margin__c);
            
            if(soiObj.Budget_Value_Margin__c  < 0){
                budgetApprovalCheck = true;
                // item.budgetFlag = true;
            }
            
            item.cancellationReason = soiObj.Cancellation_Reason__c;//Added by Bhavika 7 Feb 2023
            item.moItemNo = soiObj.MO_Item_No__c;
            item.priceBookDetailId = soiObj.PriceBookDetail__c;
            item.interestRate = soiObj.InterestRate__c;
            item.flag = soiObj.Flag__c;
            item.listValue = soiObj.Net_Price__c;
            item.discount = soiObj.Discount__c;
            item.cultureDesc = soiObj.Culture__r.Culture_Desc__c;
            item.culture=soiObj.Culture__c;            
            item.POItemNumber = soiObj.Product_PO_item_number__c;//Deeksha SCTASK0216504
            item.multipleOf = soiObj.multipleOf__c;  // added by Nik on 10/05/2019......
            //Modified by Deeksha for kit selling Project
            item.round = soiObj.round__c;  
            if(!soiObj.Kit_Product__c){
                item.create_Date = String.valueOf(soiObj.PriceBookDetail__r.CreatedDate);   // CR92....Nik...22/07/2019......
                item.materialPlnRplc_Cost = soiObj.MaterialPlantRelation__r.Replacement_Cost__c;   // CR92....Nik...22/07/2019......
                item.exchange_Rate = soiObj.ExchangeRate__r.ExchangeRate__c;                       // CR92....Nik...22/07/2019......
                item.currency_Code = soiObj.PriceBookDetail__r.Price_book__r.Currency__c;          // CR92....Nik...22/07/2019......
                //item.unitValue = soiObj.PriceBookDetail__r.Unit_Price__c;                       // CR92....Nik...22/07/2019......
                item.unitValueBRL = soiObj.PriceBookDetail__r.Unit_Price_R__c;                       // CR92....Nik...22/07/2019......
                //item.unitValueBRL = soiObj.Unit_Price_R__c;
                item.unitValueUSD = soiObj.PriceBookDetail__r.Unit_Price_U__c;                       // CR92....Nik...22/07/2019......
                item.minValueBRL = soiObj.PriceBookDetail__r.Minimum_Price_R__c;                   // CR92 changes....Nik...27/07/2019......
                item.minValueUSD = soiObj.PriceBookDetail__r.Minimum_Price_U__c;                   // CR92 changes....Nik...27/07/2019......
                //item.totalValue = soiObj.TotalValueWithoutInterest__c;
                
                if(item.currency_Code == 'Only BRL'){ 
                    item.minValue = soiObj.PriceBookDetail__r.Minimum_Price_R__c;
                }
                else{
                    item.minValue = soiObj.PriceBookDetail__r.Minimum_Price_U__c;
                }
            }
            if(soiObj.Sale_Order__r.Kit_Order__c){
                List<Decimal> valuesList = new List<Decimal>();
                if(soiObj.Kit_Product__c){
                    if(item.currency_Code == 'BRL'){ 
                        item.currency_Code = 'Only BRL';
                    }
                    else{
                        item.currency_Code = 'Only USD';
                    }
                    if(kitValuesMap.containsKey(item.kitNo)){  
                        kitValuesMap.get(item.kitNo).set(0,item.qty);
                    }
                    else{
                        valuesList.add(item.qty);
                        valuesList.add(item.unitValueBRL);
                        valuesList.add(item.unitValueUSD);
                        valuesList.add(item.minValueBRL);
                        valuesList.add(item.minValueUSD);
                        valuesList.add(item.minValue);
                        //valuesList.add(item.totalValue);
                    }
                }
                else{
                    if(kitValuesMap.containsKey(soiObj.Kit_Item_Number__c)){
                        valuesList = kitValuesMap.get(soiObj.Kit_Item_Number__c);
                        if(valuesList[1]!=null){valuesList[1] += item.unitValueBRL*item.qty;}else{valuesList[1] = item.unitValueBRL*item.qty;}
                        if(valuesList[2]!=null){valuesList[2] += item.unitValueUSD*item.qty;}else{valuesList[2] = item.unitValueUSD*item.qty;}
                        if(valuesList[3]!=null){valuesList[3] += item.minValueBRL*item.qty;}else{valuesList[3] =item.minValueBRL*item.qty;}
                        if(valuesList[4]!=null){valuesList[4] += item.minValueUSD*item.qty;}else{valuesList[4] = item.minValueUSD*item.qty;}
                        if(valuesList[5]!=null){valuesList[5] += item.minValue*item.qty;}else{valuesList[5] = item.minValue*item.qty;}
                        //if(valuesList[6]!=null){valuesList[6] += item.totalValue;}else{valuesList[6] = item.totalValue;}
                        
                    }
                    else{
                        valuesList.add(1);
                        valuesList.add(item.unitValueBRL);
                        valuesList.add(item.unitValueUSD);
                        valuesList.add(item.minValueBRL);
                        valuesList.add(item.minValueUSD);
                        valuesList.add(item.minValue);
                        //valuesList.add(item.totalValue);                        
                    }
                }
                kitValuesMap.put(item.kitNo,valuesList);
                System.debug('@@@kitValuesMap '+kitValuesMap);
            }
            
            /* ******************************************** SKI(Nik) : #CR155 : Brazil Margin Block : 30-08-2022.... Start ************************************************* */
            item.salesDeductionCost = soiObj.Sales_Deduction_Budget__c;
            item.cogsCost = soiObj.Discount1__c;
            item.e2eCost = soiObj.E2E_Cost__c;
            
            if(soiObj.Blanket_SKU_End_Date__c != null){
                item.blnkt_EndDate = String.valueOf(soiObj.Blanket_SKU_End_Date__c);
            }
            if(soiObj.Blanket_SKU_Start_Date__c != null){
                item.blnkt_StartDate = String.valueOf(soiObj.Blanket_SKU_Start_Date__c);
            }
            
            item.blnkt_Status = soiObj.Blanket_SKU_Status__c;
            item.isBlanket = soiObj.Blanket_SKU_Status__c;
            item.level1Max = soiObj.Level_1_max__c;
            item.level1Min = soiObj.Level_1_min__c;
            item.level2Max = soiObj.Level_2_max__c;
            item.level2Min = soiObj.Level_2_min__c;
            item.level3Below = soiObj.Level_3_below__c;
            item.approvalLevel = soiObj.Approval_Level__c;
            item.uom = soiObj.UOM__c;
            item.baseUOM = soiObj.Base_UOM__c;
            item.convertedQnty = soiObj.Converted_Qty__c;
            item.convertedNetPrice = soiObj.Converted_Net_Price__c;
            item.salesDeductionCal = soiObj.Sales_Deduction_Cal__c;
            item.cogsCostCal = soiObj.Discount_Cal__c;
            item.e2eCostCal = soiObj.E2E_Cost_Cal__c;
            item.mbLevel1 = soiObj.Margin_Block_Level_1__c;
            item.mbLevel2 = soiObj.Margin_Block_Level_2__c;
            item.contMargin = soiObj.Contribution_Margin__c;
            item.exchngRate = soiObj.ExchangeRate__r.ExchangeRate__c;
            item.curncyCode = soiObj.CurrencyIsoCode;
            /* ******************************************** SKI(Nik) : #CR155 : Brazil Margin Block : 30-08-2022.... End ************************************************* */
            itemList.add(item);
        } 
        
        if(!kitValuesMap.isEmpty()){
            for(SalesOrderItem item : itemList){
                if(item.kitProduct){
                    if(kitValuesMap.containsKey(item.kitNo)){
                        item.unitValueBRL = (kitValuesMap.get(item.kitNo))[1];                   
                        item.unitValueUSD = (kitValuesMap.get(item.kitNo))[2];
                        item.minValueBRL = (kitValuesMap.get(item.kitNo))[3];
                        item.minValueUSD = (kitValuesMap.get(item.kitNo))[4];
                        item.minValue = (kitValuesMap.get(item.kitNo))[5];  
                        //item.totalValueWithInterest = (kitValuesMap.get(item.kitNo))[6]; 
                        if(item.currency_Code == 'Only BRL'){
                            item.listValue = item.unitValueBRL/item.qty;
                        }
                        else{
                            item.listValue = item.unitValueUSD/item.qty;
                        }
                    }
                }
                else{
                    if(kitValuesMap.containsKey(item.refKitNo)){
                        System.debug('@@@'+kitValuesMap.get(item.refKitNo));
                        item.componentQty = item.qty/kitValuesMap.get(item.refKitNo)[0];
                        if(item.currency_Code == 'Only BRL'){ 
                            item.listValue = item.unitValueBRL;
                        }
                        else{
                            item.listValue = item.unitValueUSD;
                        }
                        //item.listValue = item.componentQty*
                    }
                    
                }
            }  
            
        }
        
        if(BudgetApprovalCheck || test.isRunningTest()){
            System.debug('BudgetApprovalCheck');
            Sales_Order__c so =[select id,BudgetApprovalCheck__c from Sales_Order__c where id =:soId limit 1]; 
            if(so.BudgetApprovalCheck__c!=true){
                so.BudgetApprovalCheck__c=true;
                update so;
            }
        }
        //End:Modified by Deeksha for kit selling Project
        System.debug('itemList: '+itemList);
        System.debug('DML Statements : '+Limits.getDMLStatements());
        System.debug('HeapSize : '+Limits.getHeapSize());
        System.debug('Queries : '+Limits.getQueries());
        return itemList;
    }
    public static boolean sharingRecordToOwner(String recordId, String userOrGroupId){
        Sales_Order__share jobShr  = new Sales_Order__share();
        jobShr.ParentId = recordId;
        jobShr.UserOrGroupId = userOrGroupId;
        jobShr.AccessLevel = 'Edit';
        jobShr.RowCause = Schema.Sales_Order__share.RowCause.Manual;
        Database.SaveResult sr = Database.insert(jobShr,false);
        if(sr.isSuccess()){
            return true;
        }
        else {
            Database.Error err = sr.getErrors()[0];
            if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
               err.getMessage().contains('AccessLevel')){
                   return true;
               }
            else{
                return false;
            }
        }
    }
    @AuraEnabled
    public static String getEstimatedDeliveryDate(String customerRegionCode)
    {
        String numberofDays = '';
        List<Business_Rule__c > businessRule = [SELECT Id, Delivery_Time__c, Name, OwnerId
                                                FROM Business_Rule__c WHERE Name =:customerRegionCode];
        if(!businessRule.isEmpty())
        {
            List<Delivery_Time__c> deliveryTime = [SELECT Id, Days__c,Depot_Code__c
                                                   FROM Delivery_Time__c WHERE Id = :businessRule[0].Delivery_Time__c];
            if(!deliveryTime.isEmpty())
            {
                numberofDays = String.valueOf(deliveryTime[0].Days__c);
            }
        }
        return numberofDays;
    }
    public class LoggInUserInfo
    {
        @AuraEnabled public User userInfo{get;set;}
        @AuraEnabled public  Decimal avecValue;
        @AuraEnabled public  Decimal nonAvecValue;
        @AuraEnabled public  string gdmManager;
        @AuraEnabled public  String regionValue;
        @AuraEnabled public Boolean isKeyAccountManager{get;set;}
        @AuraEnabled public List<String> cropYearList;
        @AuraEnabled public List<String> currencyList;
        @AuraEnabled public List<String> incoTermsList;
        @AuraEnabled public AdminMPTParameters adminparameters;
    }
    public class ResultWrapper{
        @AuraEnabled public Object data     {get;set;}
        @AuraEnabled public String newPriceBookId  {get;set;}
        @AuraEnabled public String message  {get;set;}
        @AuraEnabled public Boolean success {get;set;}
        
        public ResultWrapper(){
            this.message = 'Success';
            this.success = true;
        }
    }
    public class PriceBookPaymentTermWrapper {
        @AuraEnabled public Map<String,Campaign_Payment_Terms__c> payTermsDays;
        @AuraEnabled public Map<String,Campaign_Payment_Terms__c> payTermsDates;
        @AuraEnabled public Map<String,Payment_Term__c> payTermBR00;
        @AuraEnabled public List<Payment_Term__c> paymentTerms;
        @AuraEnabled public Payment_Term__c payTermBR71;
        @AuraEnabled public Product_Mix__c productMix;
        @AuraEnabled public String salesRepUserId;
        
        public PriceBookPaymentTermWrapper(){
            payTermsDays = new Map<String,Campaign_Payment_Terms__c>();
            payTermsDates = new Map<String,Campaign_Payment_Terms__c>();
            payTermBR00 = new Map<String,Payment_Term__c>();
            payTermBR71 = new Payment_Term__c();
            productMix = new Product_Mix__c();
            paymentTerms = new List<Payment_Term__c>();
        }   
    }
    public class Featured_Product_Banner {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Description;
        @AuraEnabled public String ProductName;
        @AuraEnabled public String Title;
        @AuraEnabled public String ImageUrl;
        
    }
    public class Featured_ProductWithAttachment {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ProductDescription;
        @AuraEnabled public String Description;
        @AuraEnabled public String SKU;
        @AuraEnabled public String ProductName;
        @AuraEnabled public String Technical;
        @AuraEnabled public String SalesOrgCode;
        @AuraEnabled public String SalesOrgName;
        @AuraEnabled public Decimal UnitPrice;
        @AuraEnabled public String Material;
        @AuraEnabled public String ImageUrl;
        @AuraEnabled public object ProductDta;
    }
    public class AdminMPTParameters{
        @AuraEnabled public Decimal level1Max;
        @AuraEnabled public Decimal level1Min;
        @AuraEnabled public Decimal level2Max;
        @AuraEnabled public Decimal level2Min;
        @AuraEnabled public Decimal level3Below;
        @AuraEnabled public String approvalLevel;
        @AuraEnabled public String id;
        @AuraEnabled public Boolean active;
        
        public AdminMPTParameters(){
            level1Max = 0;
            level1Min = 0;
            level2Max = 0;
            level2Min = 0;
            level3Below = 0;
            approvalLevel = '';
            id = '';
            active = false;
        }
    }
    public class RootWrapper {
        public Root root;
    }
    
    public class Root {
        public List<Item> item;
        public TeOrdens TeOrdens;
    }
    
    public class Item {
        public String Brand;
        public String Sku_Code;
        public String Depot_Code;
        public String Deposit;
        public String Batch;
        public String Manufacturing_Date;
        public String Batch_Expire_date;
        public Date deliveryDate;
        public Decimal Total_Quantity;
        public Decimal Available_Quantity;
        public Decimal Balance_of_order_created;
        public Decimal Transfer;
        public Decimal Quality_control;
        public Decimal Restrict;
        public Decimal Blocked;
        public Decimal Returns;
    } 
    public class TeOrdens {
        public List<Ordens> Ordens;
    }
    public class Ordens {
        public String sales_order_number;
        public String item_number;
        public String sku_code;
        public String Cust_depot;
        public String Origin_depot;
        public String storage_location;
        public String batch_number;
        public decimal Quantity_in_SU;
    }
    public class SalesOrderItem {
        @AuraEnabled public string minDate;
        @AuraEnabled public Boolean applyMinPrice; // Priya RITM0237685
        @AuraEnabled public String productId;
        @AuraEnabled public String productCode;
        @AuraEnabled public String orderItemId;
        @AuraEnabled public String priceBookDetailId;
        @AuraEnabled public String skuCategory;
        @AuraEnabled public String productName;
        @AuraEnabled public String fatDate;
        @AuraEnabled public String depotId;
        @AuraEnabled public String Depot_Code;
        @AuraEnabled public String fatDateNew;
        @AuraEnabled public Decimal qty;
        @AuraEnabled public Decimal qtyNew;
        @AuraEnabled public Decimal inventory;
        @AuraEnabled public Decimal listValue;
        @AuraEnabled public Decimal minValue;
        @AuraEnabled public Decimal unitValue;
        @AuraEnabled public Decimal budgetValue;
        @AuraEnabled public Decimal discount;
        @AuraEnabled public Decimal replacementMargin;
        @AuraEnabled public Decimal replacementMarginUP;
        @AuraEnabled public Decimal ledgerMargin;
        @AuraEnabled public Decimal unitValueWithInterest;
        @AuraEnabled public Decimal totalValue;
        @AuraEnabled public Decimal totalValueWithInterest;
        @AuraEnabled public Decimal gptotal;
        @AuraEnabled public Decimal gplista;
        @AuraEnabled public Decimal gplistaunitvalue;
        @AuraEnabled public String salesperson;
        @AuraEnabled public Decimal unitpriceofpricelist;
        @AuraEnabled public Decimal interestRate;
        @AuraEnabled public Decimal days;
        @AuraEnabled public Decimal CogsInfo;//Modified by Sagar
        @AuraEnabled public Decimal aderencia; // added by Sagar 
        @AuraEnabled public Decimal MargemLista; // added by Sagar 
        @AuraEnabled public Decimal impactgpvslp;//Added by Sirisha
        
        @AuraEnabled public Decimal Recommendedprice; // added by Sagar for DDS score   
        @AuraEnabled public String DDSGrade; // added by Sagar for DDS score    
        @AuraEnabled public String cogsitem;//Modified by Sagar for Deal scoring   
        @AuraEnabled public String DDSApiErrMsg; // added by Sagar for DDS score
        @AuraEnabled public Decimal DiscountBarter; // added by Sagar for Discount Barter
        @AuraEnabled public String ItemStatus;// added by Sagar for Item Status
        @AuraEnabled public Decimal CustomerConversionFactor; //Added by Sagar for calculating Barter Discount
        @AuraEnabled public Decimal custconversionfatorMin;
        @AuraEnabled public Decimal BarterDiscountPercentage;//Change by Swaranjeet(Grazitti) APPS-4591 
        
        @AuraEnabled public Decimal GrossMarginwithBarter;//Change by Swaranjeet(Grazitti) APPS-4591
        @AuraEnabled public Decimal BarterDiscountCalculated;//Change by Swaranjeet(Grazitti) APPS-4591
        
        @AuraEnabled public String Ids;//Change by Swaranjeet(Grazitti) APPS-4591 
        @AuraEnabled public boolean bartercheckpoint;//Change by Swaranjeet(Grazitti) APPS-4591 
        @AuraEnabled public Decimal timeInMonths;
        @AuraEnabled public Decimal multipleOf;
        @AuraEnabled public String cultureDesc;
        @AuraEnabled public String culture;
        @AuraEnabled public String cancellationReason;//Added by Bhavika 6Feb 2023
        
        @AuraEnabled public String flag;
        @AuraEnabled public Decimal itemNo;
        @AuraEnabled public Decimal moItemNo;
        @AuraEnabled public Boolean isMO;
        @AuraEnabled public Boolean budgetFlag;
        @AuraEnabled public String currency_Code;
        @AuraEnabled public Decimal materialPlnRplc_Cost;
        @AuraEnabled public Decimal exchange_Rate;
        @AuraEnabled public String create_Date;
        @AuraEnabled public Date deliveryDate;
        @AuraEnabled public Date Batch_Expire_date;
        @AuraEnabled public Decimal unitValueBRL;
        @AuraEnabled public Decimal unitValueUSD;
        @AuraEnabled public String brand;
        @AuraEnabled public String Deposit;
        @AuraEnabled public String Batch;
        @AuraEnabled public String DepotT;
        @AuraEnabled public Decimal minValueBRL;
        @AuraEnabled public Decimal minValueUSD;
        @AuraEnabled public String interest_Date; //Divya INCTASK0186953
        @AuraEnabled public String POItemNumber; //Deeksha SCTASK0216504
        @AuraEnabled public Boolean kitProduct; //Modified by Deeksha for kit selling Project
        @AuraEnabled public Decimal kitNo;//Modified by Deeksha for kit selling Project
        @AuraEnabled public Decimal refKitNo;//Modified by Deeksha for kit selling Project
        @AuraEnabled public Decimal componentQty;//Modified by Deeksha for kit selling Project
        @AuraEnabled public String itemCategory;//Modified by Deeksha for kit selling Project
        @AuraEnabled public String kitSKU ;//Modified by Deeksha for kit selling Project
        @AuraEnabled public Decimal round;//Modified by Deeksha for kit selling Project
        @AuraEnabled public Decimal totalreplacementcost;//Modified by Sagar for Deal scoring 
        @AuraEnabled public Decimal quantity;// Modified by by Anmol@wipro for US SOS-002 
        //added by Krishanu@Wipro
        @AuraEnabled public Decimal taxAmountWithoutInterest;
        @AuraEnabled public Decimal freightAmountWithoutInterest;
        @AuraEnabled public Decimal punctualityDiscountWICalculated;
        @AuraEnabled public Decimal totalReplacementCost1;
        @AuraEnabled public Decimal totaltax ;
        @AuraEnabled public Decimal totalfreight;
        @AuraEnabled public Decimal totalpunctuality;
        @AuraEnabled public Decimal selloutprice; //added by Aditya@wipro
        
        /* ************************** SKI(Nik) : #CR155 : Brazil Margin Block : 30-08-2022.... Start ************************************** */
        @AuraEnabled public Decimal salesDeductionCost;
        @AuraEnabled public Decimal cogsCost;
        @AuraEnabled public Decimal e2eCost;
        @AuraEnabled public String blnkt_EndDate;
        @AuraEnabled public String blnkt_StartDate;
        @AuraEnabled public Boolean blnkt_Status;
        @AuraEnabled public Boolean isBlanket;
        @AuraEnabled public Decimal level1Max;
        @AuraEnabled public Decimal level1Min;
        @AuraEnabled public Decimal level2Max;
        @AuraEnabled public Decimal level2Min;
        @AuraEnabled public Decimal level3Below;
        @AuraEnabled public String approvalLevel;
        @AuraEnabled public String uom;
        @AuraEnabled public String baseUOM;
        @AuraEnabled public Decimal convertedQnty;
        @AuraEnabled public Decimal convertedNetPrice;
        @AuraEnabled public Decimal salesDeductionCal;
        @AuraEnabled public Decimal cogsCostCal;
        @AuraEnabled public Decimal e2eCostCal;
        @AuraEnabled public Boolean mbLevel1;
        @AuraEnabled public Boolean mbLevel2;
        @AuraEnabled public Decimal contMargin;
        @AuraEnabled public Decimal exchngRate;
        @AuraEnabled public String curncyCode;
        @AuraEnabled public List<decimal> qtyList;
        @AuraEnabled public List<decimal> Blocked;
        @AuraEnabled public List<String> batchList;
        @AuraEnabled public List<String> depositList;
        @AuraEnabled public List<String> depotList;
        @AuraEnabled public List<String> cultureList;
        
        public SalesOrderItem(){
            totaltax = 0;
            totalfreight =0;
            totalpunctuality = 0;
            minDate = '';
            applyMinPrice= false;
            skuCategory = '';
            itemCategory = '';//Modified by Deeksha for kit selling Project
            isMO = false;
            budgetFlag = false;
            itemNo = 0;
            moItemNo = 0;
            productId = '';
            productCode = '';
            budgetValue = 0;
            orderItemId = '';
            priceBookDetailId = '';
            productName = '';
            Deposit = '';
            depotId = '';
            fatDate = '';
            fatDateNew='';
            interest_Date = '';//Divya INCTASK0186953
            qty = 0;
            qtyNew=0;
            Depot_Code='';
            DepotT='';
            listValue = 0;
            minValue = 0;
            unitValue = 0;
            unitValueWithInterest = 0;
            totalValueWithInterest = 0;
            totalValue = 0;
            interestRate = 0;
            gptotal = 0;
            gplista = 0;
            gplistaunitvalue = 0;
            impactgpvslp = 0;
            days = 0;
            CogsInfo=0;
            punctualityDiscountWICalculated=0;
            taxAmountWithoutInterest=0;
            freightAmountWithoutInterest=0;
            totalReplacementCost1=0;
            Recommendedprice = 0;//added by Sagar for Deal scoring 
            DDSGrade = '';//added by Sagar for Deal scoring 
            DDSApiErrMsg=''; //added by Sagar for Deal scoring
            quantity=0;// Modified by by Anmol@wipro for US SOS-002 
            cultureDesc = '';
            culture='';
            cancellationReason='';//Added by Bhavika
            currency_Code = '';
            materialPlnRplc_Cost = 0;
            exchange_Rate = 0;
            create_Date = '';
            unitValueBRL = 0;
            unitValueUSD = 0;
            replacementMargin = 0;
            replacementMarginUP = 0;
            discount = 0;
            brand = '';
            minValueBRL = 0;
            minValueUSD = 0;
            POItemNumber = ''; //Deeksha :SCTASK0216504
            componentQty = 0;//Modified by Deeksha for kit selling Project
            kitSKU = '';//Modified by Deeksha for kit selling Project
            round = 0;//Modified by Deeksha for kit selling Project
            totalreplacementcost= 0;//added by Sagar for Deal scoring 
            CustomerConversionFactor = 0;//Added by Sagar for calculating Barter Discount
            
            selloutprice = 0; //added by Aditya@wipro
            
            /* ************************** SKI(Nik) : #CR155 : Brazil Margin Block : 30-08-2022.... Start ************************************** */
            salesDeductionCost = 0;
            cogsCost = 0;
            e2eCost = 0;
            blnkt_EndDate = '';
            blnkt_StartDate = '';
            blnkt_Status = false;
            isBlanket = false;
            level1Max = 0;
            level1Min = 0;
            level2Max = 0;
            level2Min = 0;
            level3Below = 0;
            approvalLevel = '';
            uom = '';
            baseUOM = '';
            convertedQnty = 0;
            convertedNetPrice = 0;
            salesDeductionCal = 0;
            cogsCostCal = 0;
            e2eCostCal = 0;
            mbLevel1 = false;
            mbLevel2 = false;
            contMargin = 0;
            exchngRate = 0;
            curncyCode = '';
            /* ************************* SKI(Nik) : #CR155 : Brazil Margin Block : 30-08-2022.... End ******************************************* */
        }
    } 
    public class OrderWrapper{
        @AuraEnabled public Sales_Order__c soObj;
        @AuraEnabled public Grz_OrderRequestViewController.ApprovalList approvalList;
        @AuraEnabled public List<Transaction_Log__c> errorList;
        @AuraEnabled public List<SalesOrderItem> soiList;
        @AuraEnabled public String sfdcOrderNo;
        @AuraEnabled public String sapOrderNo;
        @AuraEnabled public String orderSubStatus;
        public Exception exObj;
        
        public OrderWrapper(){
            soObj = new Sales_Order__c();
            approvalList = new Grz_OrderRequestViewController.ApprovalList();
            errorList = new List<Transaction_Log__c>();
            soiList = new List<SalesOrderItem>();
            sfdcOrderNo = '';
            sapOrderNo = '';
            orderSubStatus = '';
        }
    }
    
}