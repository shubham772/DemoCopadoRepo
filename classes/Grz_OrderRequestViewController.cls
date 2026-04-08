/**************************************************************************************************
    * Name               : Grz_OrderRequestViewController 
    * Ticket			 : Brazil Sales Order Modernaziation(SFDC-4373)
    * Description        : Controller for Grz_SalesOrderViewDetailsPage LWC Component
    * Test Class         : Grz_OrderRequestViewControllerTest
    * Created By         : Sumit Kumar (Grazitti)                                                                       
**************************************************************************************************/
public without sharing class Grz_OrderRequestViewController {
    public static List<AuditHistory> beforeSort = new List<AuditHistory>();
    public static List<AuditHistory> afterSort = new List<AuditHistory>();
    
    @AuraEnabled  //(cacheable=True)
    public static SalesOrderDataWrapper getSalesOrderDetails(Id recordId){
        System.debug('soId : '+recordId);
        SalesOrderDataWrapper salesOrderWrap = new SalesOrderDataWrapper();
        String query = 'Select Id,Sales_Order__r.SalesOrderNumber_Brazil__c,SalesOrderNumber_Brazil__c,SAP_Order_Number__c,SDM_Approval_On_Order_Cancellation__c,SDM_Item_Update_Cancel_Status__c,OLC_Order__c,'; // Added OLC_Order__c field for Brazil Project OLC - PRJ0010060 - Nikhil Verma
        query+=  'Kit_Order__c,Use_Campaign__c,Pricebook_for_equalization__c,AVEC_Order__c,Type_of_Order__c,Order_Status__c,toLabel(OrderSubStatus__c),Punctuality_Discount__c,Invoice_Status__c,CurrencyIsoCode,';
        query+=  'Owner.Name,Directed_Sales__c,toLabel(Currency_Brazil__c),Price_Book__c,Price_Book__r.Name,Price_Book__r.Interest_Date__c,Price_Book__r.Sales_Order_Block_Date__c,Price_Book__r.Currency__c,Price_Book__r.Campaign_pricebook__c,Price_Book__r.CreatedDate,';
        query+=  'Price_Book__r.isActive__c,Price_Book__r.Expiry_Date__c,PaymentMethod__c,PaymentMethod__r.Name,Campaign_Payment_Term_Date__c,ReloadPaymentTerms__c,Maturity_Date__c,Sold_to_Party__c, Sold_to_Party__r.name,Sold_to_Party__r.SAP_Code__c,';
        query+=  'Sold_to_Party__r.Tax_Number_1__c,Sold_to_Party__r.Depot_Code__c,Sold_to_Party__r.Tax_Number_Br_Portal_Filter__c,Sold_to_Party__r.BillingCity,Sold_to_Party__r.Price_Conversion_Group__c,';
        query+=  'Sold_to_Party__r.Customer_Region__c,Sold_to_Party__r.Customer_Group__c,Sold_to_Party__r.Tax_Number_3__c,Price_Conversion_Factor__c,Signed__c,Flag__c,Region_Territory_Code__c,Sales_District__c,';
        query+=  'TotalValueWithoutInterest__c,Sales_Order_Replacement_Margin_WI__c,SalesOrderReplacementMargin__c,Total_GP_Lista__c,GP_Total__c,Impacto_GP_vs_LP__c,Gross_Margin_with_Barter1__c,GM_Barter__c,';
        query+=  'Purchase_Order_no__c,Purchase_Order_Date__c,Inco_Term__r.IncoTerm_Code__c,Freight__c,Tax__c,Invoice_Message__c,Sales_order_OBS__c,Internal_OBS__c,BarterManager__c,Business_Discount__c,Crop_Year__c,Phase_Out_Order__c,Product_Mix__c,Interest_Date_Value__c,Product_Mix_Name__c,';
        query+=  'Campaign_Type__c,BrazilSalesOrderStatus__c,BrazilSalesOrderApproved__c,RecordType.Name,Total_Tax_Without_Interest__c,Total_Freight_Without_Interest__c,Total_Punctuality_Without_Interest__c,TotalReplacementCost__c from Sales_Order__c ';
        query+=  'where Id =: recordId';
        String custconversiongroup;
        if(recordId != null ){
            salesOrderWrap.Sales_Order = Database.query(query);
            custconversiongroup = salesOrderWrap.Sales_Order.Sold_to_Party__r.Price_Conversion_Group__c;
            System.debug('custconversiongroup : '+custconversiongroup);
            if(salesOrderWrap.Sales_Order.SAP_Order_Number__c != null && !test.isrunningtest()){
                try{
                	SKUBrazilOutboundAPI.SKUUpdate(recordId,null,null); // added this function as per existing functionality on view page load
                }catch(Exception e){
                    System.debug('An exception occurred: ' + e.getMessage());
                }
            }
        }
        salesOrderWrap.brazilLoginUserInfo = brazilLoginUserInfo();
        salesOrderWrap.salesOrderLineItemsList = getSalesOrderItems(recordId);

        if(salesOrderWrap.Sales_Order.Order_Status__c=='Blocked'){
            salesOrderWrap.IsApprovalPending = true;  //Added by Grz(Dheeraj Sharma) for RITM0920591 on 17 Feb 2025-->
        }
        salesOrderWrap.adminMPTList = [SELECT Id, Name, Active__c, Level_1_max__c, Level_1_min__c, Level_2_max__c, 
                                       Level_2_min__c, Level_3_below__c, Sales_Org__c, Approval_Level__c 
                                       FROM Admin_MPT_Colombia__c WHERE Sales_Org__r.Sales_Org_Code__c = '5191' LIMIT 1];
        salesOrderWrap.customerConversionMap = getConversionFactor(custconversiongroup);
        salesOrderWrap.businessRules = Grz_SalesOrderCreationRequest.getBusinessRule(salesOrderWrap.brazilLoginUserInfo.loginUserId);
        salesOrderWrap.custTaxAndFreight = getCustomerTaxFreight(salesOrderWrap.Sales_Order.Sold_to_Party__r.Customer_Region__c);
        salesOrderWrap.enableApproval = checkApprovalReject(recordId);
        salesOrderWrap.getIncoTerms = Grz_SalesOrderCreationRequest.getIncoTerms();
        System.debug('salesOrderWrap.customerConversionMap : '+salesOrderWrap.customerConversionMap);
        return salesOrderWrap;
    }
    
    //isBrazilSalesUsercheck and isBrazilSalesUserKAM method combine into one method to get login user info
    @AuraEnabled(cacheable=True)
    public static UserInfoWrapper brazilLoginUserInfo(){
        UserInfoWrapper userInfoObj = new UserInfoWrapper();
        String userid= UserInfo.getUserId();
        User usr = [select Id,Key_Account_Manager__c,Region1__c, Name,Profile.Name,Show_List_Value__c FROM user where id =:userid];
        userInfoObj.loginUserId = usr.Id;
        userInfoObj.profileName = usr.Profile.Name;
        userInfoObj.showListValue = usr.Show_List_Value__c;
        if(usr.Profile.Name == 'Brazil Sales Person' ){  
            userInfoObj.isBrazilSalesPerson = true; 
        }else{
            userInfoObj.isBrazilSalesPerson = false; 
        }
        if(usr.Region1__c == 'BRAZIL'){
            userInfoObj.isBrazilUser =true; 
        }
        else{
            userInfoObj.isBrazilUser =false; 
        }
        if(usr.Profile.Name == 'Brazil Sales Person' && usr.Key_Account_Manager__c==true){  
            userInfoObj.isBraziluserKAM=true; 
        }else{
            userInfoObj.isBraziluserKAM=false; 
        }
        
        return userInfoObj;
    }
    
    @AuraEnabled
    public static List<Transaction_Log__c> getErrorHistory(String recordId){
        return [SELECT CreatedDate, Message__c FROM Transaction_Log__c WHERE Sales_Order__c=:recordId];
    }
    
    //Added by Grz(Dheerj Sharma) for RITM1032331 on 14-08-2025
    @AuraEnabled
    public static List<Monitor_Log__c> getMonitoryLogHistory(String recordId){
        return [select Id ,Name,createddate,Method__c, Response__c from Monitor_Log__c where Sales_Order__c=:recordId and Module__c='OrderItemBlocking' order by createddate desc];
    }
    



    // function to check if we need to show approval reject button
    public static boolean checkApprovalReject(String recordId){     
        Boolean isSubmitForApproval = false;
        set<Id> actorIdSet= new set<Id>();// added by javed for RITM0867399
        List<ProcessInstance> processList = [SELECT ID, 
                                             (SELECT ID,ToLabel(StepStatus),TargetObjectId,ActorId,IsPending,CreatedDate, Actor.Name 
                                              FROM StepsAndWorkitems order by CreatedDate DESC,IsPending DESC ) 
                                             FROM ProcessInstance WHERE TargetObjectId =:recordId ORDER BY CreatedDate DESC];
        // added below code by javed for RITM0867399                                     
        for(ProcessInstance pI:processList){
            for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems){
               actorIdSet.add(sWI.ActorId);
            }
        }      
        list<user> userList;
        if(actorIdSet.size()>0){
         userList=[select id,name,DelegatedApproverid from user where id in:actorIdSet and DelegatedApproverid!=null and DelegatedApproverid=:UserInfo.getUserId() limit 1];
        
        }
          // added above code by javed for RITM0867399 
        for(ProcessInstance pI:processList){
            for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems){
                if(sWI.StepStatus==System.Label.Pending){
                    if(isSubmitForApproval != true){
                        if( sWI.Actor.Name != System.Label.GRZ_GABRIELVIDIGALCRUVINEL && (sWI.ActorId==UserInfo.getUserId() || sWI.Actor.Name==System.Label.AvecApproversQueueName || userList.size()>0)){//    // added delegatedApprovarCheck  check by javed for RITM0867399 
                            isSubmitForApproval = true;
                        }
                        else{
                            isSubmitForApproval = false;
                        }
                    }
                }
            }
        }
        return isSubmitForApproval;
    }
    
    @AuraEnabled
    public static ApprovalList generateData(String recordId){
        ApprovalList approvalResultForObject = new ApprovalList();
        Boolean isSubmitForApproval = true;
        List<ProcessInstance> processList = [SELECT ID, 
                                             (SELECT ID, ProcessNodeId, ToLabel(StepStatus), Comments, TargetObjectId, ActorId, 
                                              CreatedById, IsDeleted, IsPending, OriginalActorId, ProcessInstanceId, RemindersSent, 
                                              CreatedDate, Actor.Name, OriginalActor.Name , ProcessNode.Name 
                                              FROM StepsAndWorkitems order by CreatedDate DESC,IsPending DESC ) 
                                             FROM ProcessInstance WHERE TargetObjectId =:recordId ORDER BY CreatedDate DESC];
        
        for(ProcessInstance pI:processList){
            
            for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems){
                
                if(sWI.StepStatus==System.Label.Pending){
                    if(approvalResultForObject.enableApproval != true){
                        
                        if( sWI.Actor.Name != System.Label.GRZ_GABRIELVIDIGALCRUVINEL && (sWI.ActorId==UserInfo.getUserId() || sWI.Actor.Name==System.Label.AvecApproversQueueName)){
                            approvalResultForObject.enableApproval = true;
                        }
                        else{
                            approvalResultForObject.enableApproval = false;
                        }
                    }
                }
                approvalResultForObject.listOfSteps.add(sWI);
                
                AuditHistory ahObj = new AuditHistory();
                ahObj.createdDate = sWI.CreatedDate;
                ahObj.stepStatus = sWI.StepStatus;
                ahObj.originalActorName = sWI.OriginalActor.Name;
                ahObj.actorName = sWI.Actor.Name;
                ahObj.comments = sWI.Comments;
                approvalResultForObject.listOfStepsAudit.add(ahObj);
            }
        }
        
        for(AuditHistory__c ahyObj:[SELECT Id, CreatedByUser__r.Name, CreatedDateTime__c, 
                                    LastModifiedBy__r.Name , MessageString__c, 
                                    ModifiedDateTime__c, SalesOrder__c
                                    FROM AuditHistory__c
                                    WHERE SalesOrder__c=:recordId ORDER BY CreatedDate DESC]){
                                        
                                        AuditHistory ahObj = new AuditHistory();
                                        ahObj.createdDate = ahyObj.ModifiedDateTime__c;
                                        ahObj.stepStatus = ahyObj.MessageString__c;
                                        ahObj.originalActorName = ahyObj.LastModifiedBy__r.Name;
                                        approvalResultForObject.listOfStepsAudit.add(ahObj);                                       
                                    }
        beforeSort = approvalResultForObject.listOfStepsAudit;
        sortAuditHistory();
        approvalResultForObject.listOfStepsAudit = afterSort;
        approvalResultForObject.recordId = recordId;
        return approvalResultForObject;
    }
    
    public static void sortAuditHistory(){
        Integer targetsize = beforeSort.size();
        
        while(afterSort.size() != targetsize){
            findMinDateValue();
        }
    }
    
    public static void findMinDateValue(){
        Datetime dt = Datetime.newInstance(1900, 12, 31, 00, 00 , 00); // if decending
        
        Integer i = 0;
        Integer mini = 0;
        
        for (i = 0; i != beforeSort.size() ; i ++){
            if(beforeSort[i].createdDate > dt){ // if decending
                dt = beforeSort[i].createdDate;
                mini = i;
            }
        }
        
        afterSort.add(beforeSort[mini]);
        beforeSort.remove(mini);
    }
    
    

//Start Grz(Dheeraj) DDS CR CHG0038588
@AuraEnabled
public static DDSValuesWrapper getPicklistValuesAndDdsStatus() {
    DDSValuesWrapper wrapper = new DDSValuesWrapper();
    /*commenting for RITM1108317 - Shashank Dubey
    Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('Brazil_Price2Win_DDS__mdt').getDescribe().fields.getMap();

    // Get picklist values for UGDNs__c
    Schema.DescribeFieldResult ugdnFieldDesc = fieldsMap.get('UGDNs__c').getDescribe();
    for (Schema.PicklistEntry pe : ugdnFieldDesc.getPicklistValues()) {
        wrapper.ugdnPicklist.add(pe.getValue());


    }

    // Get picklist values for Products_Brand__c
    Schema.DescribeFieldResult brandFieldDesc = fieldsMap.get('Products_Brand__c').getDescribe();
    for (Schema.PicklistEntry pe : brandFieldDesc.getPicklistValues()) {
        wrapper.brandPicklist.add(pe.getValue());
    }
    */
    List<Brazil_Price2Win_DDS__mdt> ddsRecords = [
        SELECT DDS_ACTIVE__c
        FROM Brazil_Price2Win_DDS__mdt
        WHERE DeveloperName = 'DDS_Access'
        LIMIT 1
    ];

    Boolean isActive = false;
    if (!ddsRecords.isEmpty()) {
        isActive = ddsRecords[0].DDS_ACTIVE__c;
    }
    //commenting for RITM1108317 - Shashank Dubey
    // Logged-in user's UGDN 
    //User u = [SELECT UGDN_Number__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

    //!(isActive && wrapper.ugdnPicklist.contains(u.UGDN_Number__c));
    wrapper.isDDSActive = !isActive;

    return wrapper;

}

//Nikhil for DDS
@AuraEnabled
public static List<SalesOrderItem> calculateReplacementMargin(String accountId, String currencyCode, String salesOrderItemString) {
    List<SalesOrderItem> salesOrderItemList;
    try {
        salesOrderItemList = (List<SalesOrderItem>) JSON.deserialize(salesOrderItemString, List<SalesOrderItem>.class);
    } catch (Exception e) {
        System.debug('Deserialization error: ' + e.getMessage());
        return new List<SalesOrderItem>();
    }
    Account accRec = [SELECT Id, Depot_Code__c,Customer_Region__c FROM Account WHERE Id =: accountId LIMIT 1];
    Decimal exchangeRate = [SELECT Id, ExchangeRate__c FROM ExchangeRate__c WHERE (FromCurrency__c = 'USD' AND ToCurrency__c = 'BRL') and CreatedDate > LAST_N_MONTHS:1 ORDER BY Createddate DESC NULLS FIRST limit 1].ExchangeRate__c; 
    Set<String> materialCodeSet = new Set<String>();
    for (SalesOrderItem soItem : salesOrderItemList) {
        materialCodeSet.add(soItem.productId);
    }
    Map<Id,Decimal> materialPlantMap = new Map<Id,Decimal>();
    for(Material_Plant_Relation__c mprObj: [SELECT Id,SKU__c, Replacement_Cost__c FROM Material_Plant_Relation__c WHERE SKU__c IN: materialCodeSet AND Depot__c =: accRec.Depot_Code__c AND Active__c = True]){
        materialPlantMap.put(mprObj.SKU__c, mprObj.Replacement_Cost__c);                                         
    }
    List<Business_Rule__c> bRule = [SELECT Id,Name,Freight__c,Taxes__c FROM Business_Rule__c WHERE Name =:accRec.Customer_Region__c];

    for (SalesOrderItem item : salesOrderItemList) {
        Decimal taxAmount = bRule.size()> 0 ? (bRule[0].Taxes__c * item.totalValueWithInterest)/100 : 0;
        Decimal freightAmount = bRule.size()> 0 ? (bRule[0].Freight__c * item.totalValueWithInterest)/100 : 0;
        Decimal replacementCost = currencyCode == 'BRL' ? item.qty * (materialPlantMap.get(item.productId) * exchangeRate) : item.qty * materialPlantMap.get(item.productId);
        item.productReplacementMargin = (((item.totalValueWithInterest - taxAmount - freightAmount - replacementCost) / (item.totalValueWithInterest - taxAmount))*100).setScale(2);
    }
    return salesOrderItemList;
}





@AuraEnabled
public static List<SalesOrderItem> dealScoringValidCall(DDSRequestWrapper requestData) {
    String sapCodeStr = requestData.sapCode != null ? requestData.sapCode.replaceFirst('^0+', '') : null;
    Integer sapCode = sapCodeStr != null ? Integer.valueOf(sapCodeStr) : null;
    String customer = requestData.customerName;
    String currencyCode = requestData.currencyCode;
    String salesOrderItemString = requestData.salesOrderItemString;

    List<SalesOrderItem> itemList;
    try {
        itemList = (List<SalesOrderItem>) JSON.deserialize(salesOrderItemString, List<SalesOrderItem>.class);
    } catch (Exception e) {
        System.debug('Deserialization error: ' + e.getMessage());
        return new List<SalesOrderItem>();
    }

    DDSValuesWrapper ddsWrapper = getPicklistValuesAndDdsStatus();

    if (ddsWrapper.isDDSActive && !Test.isRunningTest()) {
        for (SalesOrderItem soItem : itemList) {
            soItem.DDSGrade = 'NA';
            soItem.Recommendedprice = 0;
        }
        return itemList;

    }
    /*
    Commenting for RITM1108317 - Shashank Dubey
    Map<Integer, SalesOrderItem> validItemsMap = new Map<Integer, SalesOrderItem>();
    Integer index = 0;
    Set<String> allowedBrandsUpper = new Set<String>();
    for (String b : ddsWrapper.brandPicklist) {
        allowedBrandsUpper.add(b != null ? b.toUpperCase() : '');
    }

    for (SalesOrderItem soItem : itemList) {
        String brandUpper = (soItem.brand != null) ? soItem.brand.toUpperCase() : '';
        if (allowedBrandsUpper.contains(brandUpper)) {
            validItemsMap.put(index, soItem);
        } else {
            soItem.DDSGrade = 'NA';
            soItem.Recommendedprice = 0;
        }
        index++;
    }
    */

    Map<String, String> ddscon = new Map<String, String>{
        'very good quality' => 'Muito Bom',
        'good quality' => 'Ok',
        'low quality' => 'Ruim',
        'very low quality' => 'Muito Ruim'
    };





    Map<String, SalesOrderItem> itemKeyToItemMap = new Map<String, SalesOrderItem>();
    Map<String, String> singleRequestMap = new Map<String, String>();


    Integer uniqueNumber = 10;
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeFieldName('dataframe_records');
    gen.writeStartArray();








    // Prepare unique key and per-item request map
    for (SalesOrderItem item: itemList) {
        //Shashank Dubey - RITM1108317
        //SalesOrderItem item = validItemsMap.get(i);
        if (item.qty == null || item.unitValue == null || item.contMargin == null) {
            continue;
        }
        String uniqueKey = uniqueNumber + '-' + item.productCode;
        itemKeyToItemMap.put(uniqueKey, item);

        Map<String, Object> singleItemMap = new Map<String, Object>{
            'ItemUniqueNumber' => uniqueKey,
            'Product SKU Code' => item.productCode,
            'Brand' => item.brand,
            'Customer Code' => sapCode,
            'Customer Name' => customer,
            'Product Volume' => item.qty,
            'Payment Terms' => item.days,
            'Lockin_price' => item.unitValue,
            'Sales_order_currency' => currencyCode,
            'Contribution_Margin__c' => item.productReplacementMargin, //item.contMargin,
            'Contribution_Margin_Total_Value' => item.contMarginTotalValue,
            'Unit_Price' => currencyCode == 'BRL' ? item.unitValueBRL : item.unitValueUSD
        };
        String singleRequestJson = JSON.serialize(singleItemMap);
        singleRequestMap.put(uniqueKey, singleRequestJson);

        // Write JSON for batch
        gen.writeStartObject();
        gen.writeStringField('ItemUniqueNumber', uniqueKey);
        gen.writeStringField('Product SKU Code', item.productCode);
        gen.writeStringField('Brand', item.brand);
        gen.writeNumberField('Customer Code', sapCode);
        gen.writeStringField('Customer Name', customer);
        gen.writeNumberField('Product Volume', item.qty);
        gen.writeNumberField('Payment Terms', item.days);
        gen.writeNumberField('Lockin_price', item.unitValue);
        gen.writeStringField('Sales_order_currency', currencyCode);
        gen.writeNumberField('Contribution_Margin__c', item.productReplacementMargin);
        gen.writeNumberField('Contribution_Margin_Total_Value', item.contMarginTotalValue);
        if (currencyCode == 'BRL') {
            gen.writeNumberField('Unit_Price', item.unitValueBRL);
        } else {
            gen.writeNumberField('Unit_Price', item.unitValueUSD);
        }
        gen.writeEndObject();





        item.ddsMonitorLog = 'StatusCode: PENDING\nRequest: ' + singleRequestJson;

        uniqueNumber += 10;
    }




    gen.writeEndArray();
    gen.writeEndObject();

    String requestBody = gen.getAsString();
    System.debug('Request Body: ' + requestBody);

    if (itemKeyToItemMap.isEmpty()) {
        return itemList;
    }
    String token = Label.DDS_TOKEN;




    Http http = new Http();
    HttpRequest request = new HttpRequest();
    HttpResponse response;
    
    //request.setEndpoint('callout:DDS_Data_Access/serving-endpoints/GetPriceModel/invocations');
    request.setEndpoint('callout:DDS_Data_Access/serving-endpoints/p2win_getprice_br/invocations');//Shashank Dubey RITM1108317
    request.setMethod('POST');
    request.setHeader('Authorization', 'Bearer ' + token);
    request.setHeader('Content-Type', 'application/json');
    request.setBody(requestBody);
    request.setTimeout(30000);

    try {
        if (Test.isRunningTest()) {
            response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(
                '{"predictions":[{"ItemUniqueNumber":"10-2020255","Deal_grade":"very good quality","Final_reco_price":"123.45"}]}'
            );
        } else {
            response = http.send(request);



        }

        Integer statusCode = response.getStatusCode();
        String responseBody = response.getBody();
        System.debug('responseBody' + responseBody);

        if (statusCode == 200) {
            String cleanedResponse = responseBody.replaceAll(': ?NaN', ': \"NaN\"')
                                                 .replaceAll(': ?Infinity', ': \"Infinity\"')
                                                 .replaceAll(': ?-Infinity', ': \"-Infinity\"');

            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(cleanedResponse);
            if (responseMap.containsKey('predictions')) {
                List<Object> predictions = (List<Object>) responseMap.get('predictions');
                for (Object obj : predictions) {
                    Map<String, Object> resItem = (Map<String, Object>) obj;
                    String responseKey = (String) resItem.get('ItemUniqueNumber');















                    if (responseKey != null && itemKeyToItemMap.containsKey(responseKey)) {
                        SalesOrderItem matchedItem = itemKeyToItemMap.get(responseKey);
                        String rawGrade = (String) resItem.get('Deal_grade');
                        String normalizedGrade = rawGrade != null ? rawGrade.toLowerCase().trim() : '';
                        matchedItem.DDSGrade = ddscon.containsKey(normalizedGrade) ? ddscon.get(normalizedGrade) : rawGrade;

                        String singleResponseJson = JSON.serialize(resItem);
                        String singleRequestForItem = singleRequestMap.get(responseKey);

                        matchedItem.ddsMonitorLog = 'StatusCode: ' + statusCode + '\n' +
                                                   'Request: ' + singleRequestForItem + '\n' +
                                                   'Response: ' + singleResponseJson;

                        Object recPriceObj = resItem.get('Final_reco_price');
                        if (recPriceObj != null) {
                            try {
                                matchedItem.Recommendedprice = Decimal.valueOf(String.valueOf(recPriceObj)).setScale(2);
                            } catch (Exception ex) {
                                matchedItem.Recommendedprice = 0;
                            }















                        }







                    }
                }

             
            } else {
                // Case: 200 but **no predictions key in response**
                for (String uniqueKey : itemKeyToItemMap.keySet()) {
                    SalesOrderItem item = itemKeyToItemMap.get(uniqueKey);
                    String singleRequestForItem = singleRequestMap.get(uniqueKey);
                    item.DDSGrade = 'DDS';
                    item.Recommendedprice = 0;
                    item.ddsMonitorLog = 'StatusCode: ' + statusCode + '\n' +
                                        'Request: ' + singleRequestForItem + '\n' +
                                        'Response: ' + responseBody;
                }




            }
        } else {
            // Non-200 status code: log **single item request/response** for every item
            for (String uniqueKey : itemKeyToItemMap.keySet()) {
                SalesOrderItem item = itemKeyToItemMap.get(uniqueKey);
                String singleRequestForItem = singleRequestMap.get(uniqueKey);
                item.DDSGrade = 'DDS';
                item.Recommendedprice = 0;
                item.ddsMonitorLog = 'StatusCode: ' + statusCode + '\n' +
                                    'Request: ' + singleRequestForItem + '\n' +
                                    'Error:  ' + statusCode + '\n' +
                                    'Response: ' + responseBody;
            }



        }
    } catch (Exception e) {
        // Exception: log **single item request** + exception for every item
        for (String uniqueKey : itemKeyToItemMap.keySet()) {
            SalesOrderItem item = itemKeyToItemMap.get(uniqueKey);
            String singleRequestForItem = singleRequestMap.get(uniqueKey);
            item.DDSGrade = 'DDS';
            item.Recommendedprice = 0;
            item.ddsMonitorLog = 'StatusCode: Exception\n' +
                                'Request: ' + singleRequestForItem + '\n' +
                                'Error: ' + e.getMessage();
        }
    }

    return itemList;
}


// End Grz(Dheeraj) DDS CR CHG0038588

    @AuraEnabled
    public static List<SalesOrderItem> totalrepcostlogic (String salesOrderItemString, string sCurrencyCode, decimal usdrate, string customer1) {
        List<SalesOrderItem> item = (List<SalesOrderItem>)JSON.deserialize(SalesOrderItemString, List<SalesOrderItem>.class);
        /*List<string> itemsku = new List<string>();
        for(SalesOrderItem item1:item){
            itemsku.add(item1.productCode);
        }
        Account acc = [SELECT Id, Depot_Code__c FROM Account WHERE Id=:customer1];
        String depotcode = acc.Depot_Code__c;
        List<Material_Plant_Relation__c> mtrel = [Select id,Name,Material_Code__c,Replacement_Cost__c,Depot_Code__c from Material_Plant_Relation__c where Active__c=true and Material_Code__c IN :itemsku and Depot__c=:depotcode];
        
        system.debug(mtrel);
        for(SalesOrderItem soitem:item){    
            for(Material_Plant_Relation__c mtrel1:mtrel){
                if(mtrel1.Material_Code__c == soitem.productCode) {
                    decimal decReplacementCost = mtrel1.Replacement_Cost__c;
                    soitem.totalreplacementcost = decReplacementCost * soitem.qty;
                }
            }
        }*/  
        return item;
    }
    
    // Method used to get sales order line items records on view page
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
        List<Sales_Order_Line_Item__c> salesOrderItemList = [SELECT ID,Quantity_Changed__c,Date_Of_FAT_Changed__c,Cancel_Line_Item_Compare__c,Sale_Order__r.Order_Status__c,Customer_Conversion_Factor__c,Minimum_Price_Conversion_Factor__c,SelloutPrice__c,round__c,Sale_Order__r.Price_Book__r.CreatedDate,Sale_Order__r.Kit_Order__c,Item_Category__c,Kit_Item_Number__c,Kit_Product__c,Kit_SKU__c,Kit_SKU__r.SKU_Description__c,Kit_SKU__r.Name, Sale_Order__c, DateofFAT__c, SKU_Name__c, Discount__c, Tax__c, Freight__c,
                                                             SKU_Name__r.SKU_Description__c,SKU_Name__r.sku_code__c,SKU_Name__r.Product_Name__c, Time_in_months__c, Days__c, Flag__c,New_Date_of_FAT__c,New_Quantity__c, MO_Item_No__c,Cogs_Info__c, Recommended_price__c, DDS_Grade__c,
                                                             UnitValue__c,Product_Category__c, InterestRate__c, ProductReplacementMargin__c,GP_Total__c,GP_Lista__c,gplistaunitvalue__c,Impacto_GP_vs_LP__c, Net_Price__c,MinValue__c,
                                                             Quantity__c, UnitValuewithInterest__c, Culture__r.Culture_Desc__c,BudgetPrice__c, Product_Replacement_Margin_Unit_Price__c,
                                                             ProductLedgerMargin__c, Approval_Flag__c, Culture__c, Item_Number__c,Budget_Value_Margin__c,
                                                             PriceBookDetail__c, CurrencyIsoCode, Sales_Org__c, Sales_Order_Line_Item__c,Sale_Order__r.Avec_Checkbox__c,Sale_Order__r.AVEC_Order__c,
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
                                                             Sale_Order__r.Sold_to_Party__r.Price_Conversion_Group__c,UnitPriceOfPriceList__c,Aderencia__c,Cancel_Line_Item__c ,DDS_MonitorLog__c //Grz(Dheeraj) DDS CR CHG0038588 // added Cancel_Line_Item__c field by javed for RITM1013366 added Sale_Order__r.Sold_to_Party__r.Price_Conversion_Group__c by javed  for RITM0652620 Added cancellation reason Bhavika
                                                             FROM Sales_Order_Line_Item__c
                                                             WHERE Sale_Order__c=:soId Order By CreatedDate];//// added Cancel_Line_Item_Compare__c filed here RITM1033161 Modified by Deeksha for kit selling Project
        
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
        Map<String,Customer_Conversion_factor__c> getcustconversion = getConversionFactor(custconversiongroup);
        
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
            if(soiObj.Sale_Order__r.Avec_Checkbox__c==true || soiObj.Sale_Order__r.AVEC_Order__c==true)item.unitValue=soiObj.UnitValuewithInterest__c;//change by gurbaksh AVEC ecommerce 18-11-2025
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
            item.Recommendedprice=soiObj.Recommended_price__c;      //Grz(Dheeraj) DDS CR CHG0038588
            item.DDSGrade=soiObj.DDS_Grade__c;//Grz(Dheeraj) DDS CR CHG0038588
            item.ddsMonitorLog=soiObj.DDS_MonitorLog__c;//Grz(Dheeraj) DDS CR CHG0038588


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
             // added below by javed for RITM1013366
             if(soiObj.Sale_Order__r.Order_Status__c=='Blocked' || soiObj.Sale_Order__r.Order_Status__c=='Error in line item change'){
             item.cancelationReasonAvailable=true;// added by javed for RITM1033161
             item.cancelCheckbox=true;
             }
             // added below code by javed for RITM1033161
             
              Map<String, String> valueLabelMap = new Map<String,String>();
              Schema.DescribeFieldResult fieldResult = Sales_Order_Line_Item__c.Cancellation_Reason__c.getDescribe(); 
              List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
               for(Schema.PicklistEntry pickListVal : ple) {
                    if(pickListVal.isActive()) {
                       valueLabelMap.put(pickListVal.getValue(), pickListVal.getLabel());
                   } 
                }
               if(soiObj.Date_Of_FAT_Changed__c==true || soiObj.Quantity_Changed__c==true || (soiObj.Cancel_Line_Item__c==true && soiObj.Cancel_Line_Item_Compare__c==true)){
            if(valueLabelMap.containskey(soiObj.Cancellation_Reason__c)){
             item.cancelationReason=valueLabelMap.get(soiObj.Cancellation_Reason__c);
            }
               }
              // added above code by javed for RITM1033161
            if(soiObj.Cancel_Line_Item__c==true && soiObj.Cancel_Line_Item_Compare__c==true){
                item.cancelLineItem='Sim';
            }else{
                 item.cancelLineItem='Não';
            }
             // added above by javed for RITM1013366

           // added by javed for RITM1013366
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
        
        if(BudgetApprovalCheck){
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
    
    //Added by Grz(Dheeraj Sharma) for RITM0808578 on 01-08-2024
    public static Map<String,Customer_Conversion_factor__c> getConversionFactor(String cusgroup){
        Map<string,Customer_Conversion_factor__c> MapCF = new Map<string,Customer_Conversion_factor__c>();
        
        for (Customer_Conversion_factor__c DM: [select id, Conversion_Factor__c, Customer_Group__c,Sales_Org__c,Brand_Name__c,Minimum_Price_Conversion_Factor__c
                                                from Customer_Conversion_factor__c where Sales_Org__r.Sales_Org_Code__c = '5191' and Customer_Group__c =: cusgroup]){
                                                    MapCF.put(DM.Brand_Name__c, DM); 
                                                }
        return MapCF;
    }
    
    public static Boolean checkApproval(String recordid) {
        system.debug('@@@@recordid++++'+recordid);
        Boolean resposneBoolean=false;
        List<ProcessInstanceWorkitem> PIWIList=[select id,ProcessInstance.ProcessDefinition.DeveloperName,ProcessInstance.Status,ProcessInstance.ProcessDefinitionid,ProcessInstance.ProcessDefinition.Name,Actor.name,ProcessInstance.TargetObjectId from
                                                ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:recordid and ProcessInstance.ProcessDefinitionid=:system.label.Approval_Process_id and Actorid=: Userinfo.getUserId() and ProcessInstance.Status='Pending']; 
        if(PIWIList.size()>0){
            resposneBoolean=true;
        }
        return resposneBoolean;
    
    }

    @AuraEnabled
    public static CustomerTaxAndFreight getCustomerTaxFreight(String regnName){
        CustomerTaxAndFreight taxFreight = new CustomerTaxAndFreight();
        if(regnName != null || String.isNotBlank(regnName) || regnName != ''){
            List<Business_Rule__c> bRuleList = [SELECT Id,Name,Freight__c,Taxes__c FROM Business_Rule__c WHERE Name =: regnName LIMIT 1];
            if(bRuleList.size()>0){
                taxFreight.tax = bRuleList[0].Taxes__c;
                taxFreight.freight = bRuleList[0].Freight__c;
                taxFreight.customerRegion = bRuleList[0].Name;
                taxFreight.id = bRuleList[0].id;
            }
        }
        return taxFreight;
    }
    
    //Added by Grz(Dheeraj Sharma) for RITM0808467 on 01-08-2024
    @AuraEnabled    
    public static List<Brazil_Margin_Block__c> getMarginBlockValues(){
        List<Brazil_Margin_Block__c> marginData = [select id ,name,Margin__c, Type_Of_Orders__c, Block_Date__c from Brazil_Margin_Block__c  where name =:System.label.MarginBlockRecName limit 1];
        return marginData;
    }
    
    @AuraEnabled
    public static MainWrapper getInventory(String OrderType, Boolean isAvec) {
        MainWrapper mainWrap = new MainWrapper();
        AvecTypeMonthValue__c se = AvecTypeMonthValue__c.getInstance(); 
        List<Inventory> iv = new List<Inventory>();
        Decimal total = 0;
        List<Territory_Distributor__c> territorydist=new List<Territory_Distributor__c>();
        List<Inventory_Control__c> ic = new List<Inventory_Control__c>();
        
        system.debug('soId@@getInventory : ' + OrderType + ' Avec: ' + isAvec);
         //Added by Pragati Sharma(Grz) for SFDC-4442
        try {
            // Fetching the Territory Distributor info
            territorydist = [ SELECT ID, Zone_Code__c,TerritoryCode__c,Region__r.RegionCode__c 
                             FROM Territory_Distributor__c 
                             WHERE SalesOrg__r.Sales_Org_Code__c = '5191'
                             AND TerritoryManagerActive__c = TRUE
                             AND (TerritoryManager__c = :UserInfo.getUserId() 
                                  OR Region__r.RegionHead__c = :UserInfo.getUserId() 
                                  OR Region__r.Brazil_Marketing_Ops_Manager__c = :UserInfo.getUserId()
                                  OR Zone__r.ZonalHead__c = :UserInfo.getUserId() 
                                  OR SBU__r.SBUUser__c = :UserInfo.getUserId() 
                                  OR BarterManager__c = :UserInfo.getUserId()) 
                             LIMIT 1];
            system.debug('Fetched Zone_Code__c: ' + territorydist[0].Zone_Code__c);
        } catch (Exception e) {
            System.debug('Error fetching Territory Distributor: ' + e.getMessage());
        }
        
        
        String buCondition = (territorydist != null && territorydist[0].Zone_Code__c != null) ? territorydist[0].Zone_Code__c : '5191';
        system.debug('buCondition'+buCondition);
        
        if(isAvec){
            ic = [SELECT Id, Quantity__c, FY__c, Product__c, Fiscal_Year__c, Inventory_Active__c, 
                  Inventory_Block_Alert__c, Quarter__c, Avec_Order__c,BU__c
                  FROM Inventory_Control__c 
                  WHERE (BU__c = :buCondition OR BU__c ='5191')
                  AND Avec_Order__c = :isAvec];
        }
        else{
            ic = [SELECT Id, Quantity__c, FY__c, Product__c, Fiscal_Year__c, Inventory_Active__c, 
                  Inventory_Block_Alert__c, Quarter__c, Avec_Order__c,BU__c
                  FROM Inventory_Control__c 
                  WHERE (BU__c = :buCondition OR BU__c ='5191')  AND Avec_Order__c = false
                 ];
        }
        system.debug('688 ic '+ic);
        //Ends for SFDC-4442
   
        
        for (Inventory_Control__c i : ic) {
            Inventory inv = new Inventory();
            String fiscalYear = i.Fiscal_Year__c;
            String yearStart = '20' + fiscalYear.substring(0, 2) + '-04-01';
            String yearEnd = '20' + fiscalYear.substring(3) + '-03-31';
            
            inv.year = yearStart;
            inv.year1 = yearEnd;
            inv.qty = i.Quantity__c;
            inv.inventoryactive = i.Inventory_Active__c;
            inv.inventoryblockalert = i.Inventory_Block_Alert__c;
            inv.productname = i.Product__c;
            inv.fiscalYear = i.Fiscal_Year__c;
            inv.isAvec=i.Avec_Order__c;
            inv.BU=i.BU__c;
            if (i.Quarter__c != null) {
                inv.quarter = i.Quarter__c;
            }
            
            inv.totalqty = i.Quantity__c;
            iv.add(inv);
            system.debug('Processed Inventory: ' + inv);
        }
        
        
        mainWrap.inventoryList = iv;
        mainWrap.TerritoryRegionInfo = getUserTerritoryInfo();
        mainWrap.minMaxValue = getMinValDisc(OrderType);
        mainWrap.ZoneCode=getZoneCode();
        mainWrap.nonAvecValue = se.Non_Avec_Days__c; 
        mainWrap.avecValue = se.Avec_Days__c;
        Grz_OrderRequestViewController.KEDE kedeObj = Grz_OrderRequestViewController.getKEDE(UserInfo.getUserId());
        if (!String.isEmpty(kedeObj.territoryCode) && !String.isEmpty(kedeObj.regionCode)) { 
            String regionValue = se.Region_Value__c;
            List<String> regionValuesList = regionValue.split(',');
            if(!regionValuesList.isempty()){
                for (String region : regionValuesList) {
                    region = region.trim();
                    if ((kedeObj.territoryCode.length() == 5 && region.length() == 5 &&
                         region.contains(kedeObj.territoryCode)) || (kedeObj.regionCode.length() == 6 && region.length() == 6 &&
                                                                     region.contains(kedeObj.regionCode)) )
                    {
                        mainWrap.regionValue='true';
                    }
                }
            }
        }
        system.debug('mainWrap'+mainWrap.ZoneCode);
        return mainWrap;
    }
    
    
    @AuraEnabled
    public static List<Territory_Distributor__c> getUserTerritoryInfo(){
        //Updated below for RITM0689745 GRZ(Dheeraj Sharma) 23-01-2024 
        Id profileId=userinfo.getProfileId();
        String regionCode;
        String profName=[Select Id,Name from Profile where Id=:profileId].Name;      
        List<String> ProfileNames =System.label.MinVal_and_MaxDisc_Profile.split(',');
        List<Territory_Distributor__c> territoryInfo = new  List<Territory_Distributor__c>(); 
        if(ProfileNames.contains(profName)){
            territoryInfo=[SELECT id,name ,Regional_Manager__c,TerritoryCode__c,Region_Code__c,Region__r.Marketing_Manager__c, TerritoryManager__r.Name from Territory_Distributor__c where Region__r.RegionHead__c=: Userinfo.getUserId()];
        }else if(profName=='Brazil Sales Office Manager'){// added by javed for RITM0986133
            territoryInfo=[SELECT id,name ,Regional_Manager__c,TerritoryCode__c,Region_Code__c,Region__r.Marketing_Manager__c, TerritoryManager__r.Name from Territory_Distributor__c where Zonal_Manager_Id__c=: Userinfo.getUserId()];// added by javed for RITM0986133
        }
        else{
            territoryInfo=[SELECT id,name ,Regional_Manager__c,TerritoryCode__c,Region_Code__c,Region__r.Marketing_Manager__c, TerritoryManager__r.Name from Territory_Distributor__c where TerritoryManager__c=: Userinfo.getUserId()];
        }
        return territoryInfo;
    }
    
    @AuraEnabled
    public static MinValWrapper getMinValDisc(String typeval){
        
        List<MinValue_Discount_Parameters__mdt> listV1 = new List<MinValue_Discount_Parameters__mdt>();
        if(typeval != '' && typeval != null) {
            listV1 = [select Type__c,Min_Value__c,Max_Discount__c,Min_Value_USD__c from MinValue_Discount_Parameters__mdt where Type__c = :typeval limit 1];
        }
        
        MinValWrapper res1 = new MinValWrapper();
        if(listV1.size() > 0) {
            res1.OrderType = listV1.get(0).Type__c;
            res1.MinVal = listV1.get(0).Min_Value__c;
            res1.MinValUSD = listV1.get(0).Min_Value_USD__c;
            res1.MaxDisc = listV1.get(0).Max_Discount__c;
        }
        return res1;
    }
    
    
    // created this mtd by Sagar for Child Replacement Margin
    @AuraEnabled
    public static decimal ChildReplacementMargin (Sales_Order__c soObj, String salesOrderItemString) {
        User userObj = [Select Id, Profile.Name, Show_List_Value__c FROM User WHERE Id=:UserInfo.getUserId()];
        string sCurrencyCode = soObj.CurrencyIsoCode;
        Price_Book__c PBdetail = [select id,USD_Rate__c from Price_Book__c where id=:soObj.Price_Book__c];
        decimal usdrate=0;
        if(PBdetail.USD_Rate__c != null){
            usdrate=PBdetail.USD_Rate__c;
        }
        List<SalesOrderItem> lineitems = new List<SalesOrderItem>();
        Account acc = [Select Name,Depot_Code__c, Price_Conversion_Group__c,Customer_Region__c from Account where id =: soObj.Sold_to_Party__c];
        List<SalesOrderItem> item1 = (List<SalesOrderItem>)JSON.deserialize(SalesOrderItemString, List<SalesOrderItem>.class); 
        List<string> itemsku = new List<string>();
        for(SalesOrderItem item:item1){
            itemsku.add(item.productCode);
        }
        List<Material_Plant_Relation__c> mtrel = [Select id,Name,Material_Code__c,Replacement_Cost__c,Depot_Code__c from Material_Plant_Relation__c 
                                                  where Active__c=true and Material_Code__c IN :itemsku and Depot__c=:acc.Depot_Code__c];		
        map<string,decimal> mtrelmap = new map<string,decimal>();
        for(Material_Plant_Relation__c mtrel1:mtrel ){
            mtrelmap.put(mtrel1.Material_Code__c,mtrel1.Replacement_Cost__c);
        }
        double itemsize = item1.size();
        
        String CustomerRegion = acc.Customer_Region__c;
        Business_Rule__c BRobj = [select Freight__c,Taxes__c from Business_Rule__c where Name=:CustomerRegion limit 1];
        ExchangeRate__c   exrate= [SELECT Id, ExchangeRate__c, Createddate 
                                   FROM ExchangeRate__c  where FromCurrency__c = 'USD' AND ToCurrency__c = 'BRL' 
                                   Order BY Createddate DESC limit 1];
        decimal exrate1=exrate.ExchangeRate__c;
        decimal ATotalreplcost = 0.0;
        decimal ATaxAmount = 0.0;
        decimal ATotalFreight = 0.0;
        decimal ATotalValueWithInterest = 0.0;
        decimal ATotalPunctuality = 0.0;
        for(SalesOrderItem soitem:item1){
            soitem.productCode=String.ValueOf(soitem.productCode);
            soitem.totalreplacementcost = mtrelmap.get(soitem.productCode) * soitem.qty ;
            ATotalreplcost = ATotalreplcost + soitem.totalreplacementcost;
            ATotalValueWithInterest = ATotalValueWithInterest + (soitem.qty * soitem.unitValueWithInterest);
            ATaxAmount = ATaxAmount + ((BRobj.Taxes__c/100) * soitem.qty * soitem.unitValueWithInterest) ;
            ATotalFreight = ATotalFreight + ((BRobj.Freight__c/100) * soitem.qty * soitem.unitValueWithInterest) ;
            
            if(soObj.Punctuality_Discount__c != null){
                ATotalPunctuality = ATotalPunctuality + (soObj.Punctuality_Discount__c * soitem.qty * soitem.unitValueWithInterest);
            }
        }
        ATotalreplcost = ATotalreplcost * exrate1 ;
        decimal Result = ( ( ATotalValueWithInterest - ATaxAmount - ATotalFreight - ATotalPunctuality - ATotalreplcost )/(ATotalValueWithInterest- ATaxAmount - ATotalPunctuality));  
        System.debug('result'+Result);
        Result = Result * 100 ;
        return Result; 
    }
    
    @AuraEnabled
    public static Sales_Order__c barterDiscountUpdate(Sales_Order__c soObj, String salesOrderItemString, boolean isApprove) {
        try{
            Sales_Order__c soObj1 = [select id,Business_Discount__c from Sales_Order__c where id=:soObj.Id];
            soObj1.Business_Discount__c = soObj.Business_Discount__c;
            update soObj1;   
            List<Sales_Order_Line_Item__c> salesOrderItemList = [SELECT ID, Sale_Order__c, SKU_Name__c, Discount__c,SKU_Name__r.SKU_Description__c,
                                                                 UnitValue__c, MinValue__c,Quantity__c, UnitValuewithInterest__c,
                                                                 CurrencyIsoCode, TotalValueWithoutInterest__c,Item_Number__c,SKU_Name__r.Name, TotalValueWithInterest__c,
                                                                 Discount_Considering_Barter_Discount__c
                                                                 FROM Sales_Order_Line_Item__c WHERE Sale_Order__c=:soObj.id];
            Map<String,SalesOrderItem> newmap = new Map<String,SalesOrderItem>();
            if(salesOrderItemString != null || salesOrderItemString !=''){
                List<SalesOrderItem> salesOrderItemList1 = (List<SalesOrderItem>)JSON.deserialize(salesOrderItemString, List<SalesOrderItem>.class); 
                for(SalesOrderItem sitemmap : salesOrderItemList1) {
                    newmap.put(String.Valueof(sitemmap.itemNo),sitemmap);
                }
                if(salesOrderItemList.size()>0){ 
                    system.debug('salesOrderItemList@@@'+salesOrderItemList);
                    for(Sales_Order_Line_Item__c sitem:salesOrderItemList){
                        if(newmap.containsKey(String.Valueof(sitem.Item_Number__c))){
                            
                            SalesOrderItem oSOItem =newmap.get(String.Valueof(sitem.Item_Number__c));
                            system.debug('oSOItem@@@'+oSOItem);
                            if(oSOItem.unitValue != null){
                                sitem.UnitValue__c = oSOItem.unitValue;
                            }
                            if(oSOItem.DiscountBarter > 0.00){
                                sitem.Discount_Considering_Barter_Discount__c = oSOItem.DiscountBarter; // added by javed for RITM0669137
                            }
                            else{
                                sitem.Discount_Considering_Barter_Discount__c = 0.00;  
                            }
                        }
                    }
                }
                if(salesOrderItemList.size()>0){
                    update salesOrderItemList;
                } 
            }
            List<ProcessInstance> instanceList = [SELECT Id FROM ProcessInstance
                                                  WHERE TargetObjectId=:soObj.Id 
                                                  AND Status = 'Pending' LIMIT 1];
            
            if(!instanceList.isEmpty() && !isApprove){
                ProcessInstance instance = instanceList[0];
                
                ProcessInstanceWorkitem workItem = [SELECT Id FROM ProcessInstanceWorkitem
                                                    WHERE ProcessInstanceId=:instance.Id LIMIT 1];
                
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setWorkitemId(workItem.id);
                pwr.setAction('Reject');
                pwr.setComments('Cancelled: '+soObj.Remarks__c);
                Approval.ProcessResult result2 =  Approval.process(pwr);
            }  
            if(soObj.Order_Status__c=='Cancelled' || soObj.Order_Status__c=='Cancelado'){ AuditHistory__c ahObj = new AuditHistory__c();
                                                                                         ahObj.SalesOrder__c = soObj.Id;
                                                                                         ahObj.CreatedDateTime__c = System.now();
                                                                                         ahObj.ModifiedDateTime__c = System.now();
                                                                                         ahObj.OrderCancelled__c = true;
                                                                                         ahObj.LastModifiedBy__c = UserInfo.getUserId();
                                                                                         insert ahObj;
                                                                                        }       
        }
        catch(Exception ex){
            ApexLog.exceptionHandlerBrazil(ex, soObj.Sold_to_Party__c, soObj, '');
            TransactionLogHandler.addTransactionEntry(ex, soObj);
        }        
        return soObj;
    }
    
    @AuraEnabled
    public static string validateSAPResponse (Boolean isApproved, String recordId, String comments, string processname){
        string SAPResponse = '';
        if(processname == 'isSOCancelProcess'){
            Sales_Order__c SO = [select id,SAP_Order_Number__c, ErrorMessage__c,Order_Status__c,Error_Message__c,
                                 Order_Blocked__c,SDM_Approval_On_Order_Cancellation__c,Cancel_Comment__c,Cancellation_Reason__c
                                 from Sales_Order__c where Id =:recordId]; 
            SalesOrderCancellationRequestWrapper request = new SalesOrderCancellationRequestWrapper();
            request.SAP_Order_Number = SO.SAP_Order_Number__c;
            request.Action = '2';
            request.Rejection_Code = SO.Cancellation_Reason__c; 
            SalesOrderCancellationResponseWrapper response;
            if(!Test.isRunningTest()){
                response = OrderBlocking.OrderBlockingAPICall(request);
                SAPResponse=response.Message_Text;
                if(response.Message_Type == 'S'){
                    customProcessApproval(isApproved,recordId,comments);
                }
            }
            return SAPResponse;
        }
        if(processname == 'isSOItemsEditProcess'){
            Sales_Order__c soapi = [select id, SAP_Order_Number__c,Order_Status__c from Sales_Order__c where Id=:recordId]; 
            List<Sales_Order_Line_Item__c> soitems =  [Select Id,Name,Item_Number__c,ProductName__c,SKU_Name__r.Brand_Name__c,Quantity__c,Unbilled_Quatity__c,Quantity_Billed__c ,DateofFAT__c,Cancel_Line_Item__c,New_Quantity__c,New_Date_of_FAT__c,Date_Of_FAT_Changed__c,Quantity_Changed__c,Cancellation_Reason__c,Item_Status__c from Sales_Order_Line_Item__c where Sale_Order__c =:recordId AND (Date_Of_FAT_Changed__c = true OR Quantity_Changed__c = true OR Cancel_Line_Item__c =true)];
            if(!Test.isRunningTest()){
                OrderItemBlocking.OrderItemBlockingRes response = OrderItemBlocking.OrderItemBlockingAPICall1(soapi,soitems,2);
                SAPResponse=response.Message_Text;
                if(response.Message_Type == 'S'){
                    customProcessApproval(isApproved,recordId,comments);
                }
            }
            return SAPResponse;
        }
        return 'sucesso' ;
    }
    
    @AuraEnabled
    public static void customProcessApproval(Boolean isApproved, String recordId, String comments) { 
        List<Id> newWorkItemIds = new List<Id>();
        for (List<ProcessInstance> pis : [Select (Select Id From Workitems) From ProcessInstance p WHERE p.TargetObjectId = :recordId AND p.Status = 'Pending']) {
            for (ProcessInstance pi : pis) {
                for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                    for (ProcessInstanceWorkitem wi : wis ) {
                        newWorkItemIds.add(wi.id);
                    }
                }           
            }
        }
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments(comments);
        if (isApproved) {
            req2.setAction('Approve');
        } else {
            req2.setAction('Reject');
        }
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        if(newWorkItemIds.size() > 0) {
            req2.setWorkitemId(newWorkItemIds.get(0));
            Approval.ProcessResult result2 =  Approval.process(req2);
        }
        
    }
    
    @AuraEnabled
    public static ApprovalList processApproval(Boolean isApproved, String recordId, String comments) {
        List<Id> newWorkItemIds = new List<Id>();
        for (List<ProcessInstance> pis : [Select (Select Id From Workitems) From ProcessInstance p WHERE p.TargetObjectId = :recordId AND p.Status = 'Pending']) {
            for (ProcessInstance pi : pis) {
                for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                    for (ProcessInstanceWorkitem wi : wis ) {
                        newWorkItemIds.add(wi.id);
                    }
                }           
            }
        }
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments(comments);
        if (isApproved) {
            req2.setAction('Approve');
        } else {
            req2.setAction('Reject');
        }
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        if(newWorkItemIds.size() > 0) {
            req2.setWorkitemId(newWorkItemIds.get(0));
            Approval.ProcessResult result2 =  Approval.process(req2);
        }
        return Grz_OrderRequestViewController.generateData(recordId); //result2.isSuccess();
    }    
    
    @AuraEnabled
    public static boolean updateBarter (Map<String,decimal> recordMap, Decimal TotalofDiscount, Decimal BarterDiscountSalesorder, Decimal Grosssalesorder,Map<String,decimal> NewGrossmap, Map<String,decimal> BarterpercentcalculatedMap) {
        List<Sales_Order_Line_Item__c> updatelist = new List<Sales_Order_Line_Item__c>();
        Set<Sales_Order__c> updatesetsalesorder = new Set<Sales_Order__c>();
        list<Sales_Order__c> updatelistsalesorder = new List<Sales_Order__c>();
        List<Sales_Order_Line_Item__c> salesOrderItemList = [SELECT ID,BarterDiscountCalculated1__c,Sale_Order__c,Barter_Discount_Percentage__c,Gross_Margin_with_Barter1__c
                                                             FROM Sales_Order_Line_Item__c
                                                             WHERE ID in :recordMap.keyset()];
        if(salesOrderItemList.size()>0){
            for(Sales_Order_Line_Item__c salesitem :salesOrderItemList){
                salesitem.Barter_Discount_Percentage__c = recordmap.get(salesitem.ID);
                if(BarterpercentcalculatedMap.containsKey(salesitem.ID)){
                    salesitem.BarterDiscountCalculated1__c = BarterpercentcalculatedMap.get(salesitem.ID);
                }
                if(NewGrossmap.containsKey(salesitem.ID)){
                    salesitem.Gross_Margin_with_Barter1__c = NewGrossmap.get(salesitem.ID);
                }
                updatelist.add(salesitem);
            }
            String salesorderid = salesOrderItemList[0].Sale_Order__c;
            Sales_Order__c ssorder = [select id, Total_of_Discount_Applied__c,TotalBarterDiscount__c,Gross_Margin_with_Barter1__c from Sales_Order__c where id =:salesorderid];
            
            if(TotalofDiscount != Null && BarterDiscountSalesorder != Null && Grosssalesorder != Null){
                ssorder.Total_of_Discount_Applied__c = TotalofDiscount;
                ssorder.Business_Discount__c=TotalofDiscount;// added by javed for RITM0669137
                ssorder.TotalBarterDiscount__c = BarterDiscountSalesorder;
                ssorder.Gross_Margin_with_Barter1__c = Grosssalesorder;
                updatesetsalesorder.add(ssorder);
                
            }
        }
        if(updatelist.size()>0){
            update updatelist;
        }
        updatelistsalesorder.addAll(updatesetsalesorder);
        if(updatelistsalesorder.size()>0){
            update updatelistsalesorder;
        }
        return true;
    }
    
    @AuraEnabled      
    public static SOMQuantity validateQuantitySOC(String priceBookId, String selectedCurrency, String motherOrderId, String depotCode, String accountState, String orderId, String salesOrderItemString,Boolean isSimulated){
        
        List<Grz_SalesOrderCreationRequest.PriceDetail> priceList = Grz_SalesOrderCreationRequest.getMOPriceBookDetails(priceBookId,selectedCurrency, motherOrderId, depotCode, accountState, orderId, false,isSimulated);
        List<SalesOrderItem> salesOrderItemList = (List<SalesOrderItem>)JSON.deserialize(SalesOrderItemString, List<SalesOrderItem>.class);
        Map<Decimal, Grz_SalesOrderCreationRequest.PriceDetail> priceMap = new Map<Decimal, Grz_SalesOrderCreationRequest.PriceDetail>();
        for (Grz_SalesOrderCreationRequest.PriceDetail pdObj : priceList) {
            priceMap.put(pdObj.itemNo, pdObj);
        }
        Map<Decimal, SalesOrderItem> soiMap = new Map<Decimal, SalesOrderItem>();
        List<String> productList = new List<String>();
        for(SalesOrderItem soiObj : salesOrderItemList){
            soiMap.put(soiObj.moItemNo, soiObj);
            if(priceMap.containsKey(soiObj.moItemNo)){
                Grz_SalesOrderCreationRequest.PriceDetail priceObj = priceMap.get(soiObj.moItemNo);  
                if(soiObj.qty > priceObj.balanceQty2){
                    productList.add(soiObj.productName);
                }
            }
        }
        SOMQuantity sqObj;
        if(!productList.isEmpty()){
            for(Grz_SalesOrderCreationRequest.PriceDetail pdObj:priceList){
                if(soiMap.containsKey(pdObj.itemNo)){
                    SalesOrderItem soiObj = soiMap.get(pdObj.itemNo);
                    pdObj.balanceQty -= soiObj.qty;
                    pdObj.balanceQty2 -= soiObj.qty;
                    pdObj.percUsed = (Math.abs(pdObj.balanceQty / pdObj.qty) *100).setScale(2);
                }
            }
            sqObj = new SOMQuantity();
            sqObj.priceList = priceList;
            sqObj.productList = productList;
        }
        return sqObj;
    }
    
    
    @AuraEnabled
    public static OrderWrapper rollbackSalesOrder (Sales_Order__c soObj, String salesOrderItemString,Boolean isRollback, Boolean isSimulated, String TCforBarterManagerProcess, String oppId) { //Added new parameter TCforBarterManagerProcess by GRZ(Nikhil Verma) for RITM0422585 modified 09-09-2022
        Savepoint sp = Database.setSavepoint();
            System.debug('salesOrderItemStringdroll'+salesOrderItemString);

        OrderWrapper owObj = new OrderWrapper();
        owObj = Grz_OrderRequestViewController.saveSalesOrder(soObj, salesOrderItemString, true, isSimulated, TCforBarterManagerProcess,oppId); //Added new parameter TCforBarterManagerProcess by GRZ(Nikhil Verma) for RITM0422585 modified 09-09-2022
        Database.rollback(sp);   
        if(owObj.exObj!=null){
            System.debug('ex No: '+owObj.exObj.getLineNumber()+' ex Msg: '+owObj.exObj.getMessage());
            ApexLog.exceptionHandlerBrazil(owObj.exObj, soObj.Sold_to_Party__c, soObj, salesOrderItemString);
        }
        owObj.sfdcOrderNo = '';
        return owObj;
    }   
    
    
    @AuraEnabled
    public static OrderWrapper saveSalesOrder(Sales_Order__c soObj, String salesOrderItemString, Boolean isRollback, Boolean isSimulated, String TCforBarterManagerProcess, String oppId) { //Added new parameter TCforBarterManagerProcess by GRZ(Nikhil Verma) for RITM0422585 modified 09-09-2022
        OrderWrapper owObj = new OrderWrapper();
      System.debug('salesOrderItemStringdsss'+salesOrderItemString);
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
            Account soldToAccount = [SELECT Id, Name, SAP_Code__c FROM Account WHERE Id = :soObj.Sold_to_Party__c LIMIT 1];
            Boolean isSapCodePresent = (soldToAccount != null && soldToAccount.SAP_Code__c != null) 
                ? sapCodesToCheck.contains(soldToAccount.SAP_Code__c) : false;
            Brazil_Customer_Email_Set_Days__c Customsetting = Brazil_Customer_Email_Set_Days__c.getOrgDefaults();
            System.debug('Customsetting'+Customsetting);
            if (Customsetting.Id != null) {
                Customsetting.Sap_Integration_Old_Version__c = isSapCodePresent;
                soObj.Integration_version__c = isSapCodePresent ;
                Update Customsetting; 
            }
            if(String.isNotBlank(paymentMethodId) && paymentMethodId!='None'){
                paymentMethod = [SELECT Id, Name, Payment_Method_Code__c 
                                 FROM Payment_Method__c 
                                 WHERE Active__c=True 
                                 AND Id=:paymentMethodId].Name;         
            }
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
            Id idforsimulation;
            if(isSimulated){ 
                RecordType clientOnlyRecordType = [
                    SELECT Id FROM RecordType WHERE DeveloperName = 'Simulation'
                ];
                
                if( clientOnlyRecordType != null ){
                    idforsimulation = clientOnlyRecordType.Id;
                }else{
                    idforsimulation = '0120K000001HskHQAS';
                }
                soObj.RecordTypeId = idforsimulation;
            }
            String ownerId = soObj.OwnerId;
            if(String.isBlank(ownerId) || ownerId=='None'){
                soObj.OwnerId = UserInfo.getUserId();
            }
            User userObj = [Select Id, Profile.Name, Show_List_Value__c FROM User WHERE Id=:UserInfo.getUserId()];
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
            KEDE kedeObj = new KEDE();
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
                if(soObj.SalesOfficeManager__c == soObj.SalesDirector__c){
                   soObj.BrazilSDSOMCheckEqual__c=true;              //Added by Grz(Dheeraj Sharma) for RITM1027374 on 12-08-2025
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
                // Project OLC - PRJ0010060 - Nikhil Verma 
                if(soObj.Type_of_Order__c == 'Projeto OLC' && !isSimulated){ // Update for RITM1049030 Nikhil Verma
                    soObj.Order_Status__c = 'Pending';
                }
                //add start for RITM1058295 - Shashank Dubey 
                List<Product_Mix__c> productMix = [select Id, Requires_MIS_Approval__c from Product_Mix__c where Id = :soObj.Product_Mix__c];
                if(!productMix.isEmpty() && productMix[0].Requires_MIS_Approval__c){
                    soObj.Sent_For_MIS_Approval__c = true;//send this so to mis approval
                    //soObj.OrderSubStatus__c = 'Pending with MIS';
                    //soObj.Order_Status__c = 'Pending';
                }
                //add end for RITM1058295 - Shashank Dubey 
                upsert soObj;
                if(oppId != 'None' && oppId != '' && oppId !=null){
                    Opportunity fetchedOpp = [select id,stagename,name,Priority_Flag__c from opportunity where id=:oppId Limit 1];         
                    if(fetchedOpp!= null){
                        fetchedOpp.StageName = 'Engage';
                        fetchedOpp.Priority_Flag__c = 'High';
                        Update fetchedOpp;
                    }
                }   
                System.debug('Shanks ---- savesalesorder-1' + soObj.Order_Status__c);                     
                List<SalesOrderItem> salesOrderItemList = (List<SalesOrderItem>)JSON.deserialize(salesOrderItemString, List<SalesOrderItem>.class);
                owObj.soiList = Grz_OrderRequestViewController.saveOrderItems(soObj, salesOrderItemList, salesOrgList,isSimulated); // add IsSimulated Parameter for RITM0518333 GRZ(Javed Ahmed) 14-03-2023
                owObj.soObj = Grz_OrderRequestViewController.getSalesOrder(soObj.Id);
                owObj.orderSubStatus =  Grz_OrderRequestViewController.getSalesOrder(soObj.Id).OrderSubStatus__c;
                owObj.sfdcOrderNo = [Select Id, SalesOrderNumber_Brazil__c FROM Sales_Order__c WHERE Id=:soObj.Id].SalesOrderNumber_Brazil__c;//soObj.SalesOrderNumber_Brazil__c;
                owObj.sapOrderNo = soObj.SAP_Order_Number__c;
                owObj.approvalList = Grz_OrderRequestViewController.generateData(soObj.Id);
                owObj.errorList = Grz_OrderRequestViewController.getErrorHistory(soObj.Id);
                FlagStatus fsObj = Grz_OrderRequestViewController.checkFlag(owObj.soObj.Id, isSimulated, owObj.soObj.Type_of_Order__c, owObj.soObj.Order_Status__c);
                owObj.soObj.Flag_Message__c = fsObj.flagMessage;
                owObj.soObj.Flag_Status__c = fsObj.flagStatus;
                // Added condition for Project OLC - PRJ0010060 - Nikhil Verma
                if(isRollback == false && (owObj.soObj.Order_Status__c=='Submitted' || (owObj.soObj.Type_of_Order__c == 'Projeto OLC' && owObj.soObj.Order_Status__c=='Pending'))){
                    soObj.Call_Process_Builder_Flow__c = owObj.soObj.Type_of_Order__c != 'Projeto OLC' ? true : false;
                    // Project OLC - PRJ0010060 - Nikhil Verma 
                    if(soObj.Type_of_Order__c == 'Projeto OLC'){
                        soObj.OrderSubStatus__c = 'Pending KAM';
                    }
                    update soObj;
                }
                owObj.soObj.ErrorMessage__c = '';
                List<String> s1 = new List<String>(); 
                s1.add(soObj.id);
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
            ApexLog.exceptionHandlerBrazil(ex, soObj.Sold_to_Party__c, soObj, salesOrderItemString);
        }
        return owObj;
    }
    
    public static KEDE getKEDE(String loggedInUser) {
        List<Territory_Distributor__c> tdList =  new List<Territory_Distributor__c>();
        if(!String.isBlank(loggedInUser) && loggedInUser != 'null' && loggedInUser.startsWith('BR')){
            tdList = [SELECT ID,TerritoryCode__c,Region__r.RegionCode__c, Region__r.RegionHead__c,Region__r.Brazil_Marketing_Ops_Manager__c, BrazilAnalyst__c,
                      Zone__r.ZonalHead__c, SBU__r.MarketingDirector__c,SBU__r.GSD__c,SBU__r.REH__c,
                      TerritoryManager__c, BarterManager__c,Region__r.DM_marketing__c,Region__r.Marketing_Manager__c
                      FROM Territory_Distributor__c 
                      WHERE SalesOrg__r.Sales_Org_Code__c = '5191'
                      AND TerritoryManagerActive__c = True
                      AND TerritoryCode__c  =: loggedInUser
                      ORDER BY LastModifiedDate DESC];
        }else{
            tdList = [SELECT ID, TerritoryCode__c,Region__r.RegionCode__c,Region__r.RegionHead__c,Region__r.Brazil_Marketing_Ops_Manager__c, BrazilAnalyst__c,
                      Zone__r.ZonalHead__c, SBU__r.MarketingDirector__c,SBU__r.GSD__c,SBU__r.REH__c, 
                      TerritoryManager__c, BarterManager__c,Region__r.DM_marketing__c,Region__r.Marketing_Manager__c
                      FROM Territory_Distributor__c 
                      WHERE SalesOrg__r.Sales_Org_Code__c = '5191'
                      AND TerritoryManagerActive__c = True
                      AND (TerritoryManager__c=: loggedInUser 
                           OR Region__r.RegionHead__c=: loggedInUser
                           OR Region__r.Brazil_Marketing_Ops_Manager__c=: loggedInUser
                           OR Zone__r.ZonalHead__c=: loggedInUser
                           OR SBU__r.MarketingDirector__c=: loggedInUser 
                           OR BarterManager__c=: loggedInUser
                          ) 
                      ORDER BY LastModifiedDate DESC];
        }       
        KEDE kedeObj = new KEDE();
        if(!tdList.isEmpty()){
            String territoryUser = tdList[0].TerritoryManager__c;
            String regionalHeadUser = tdList[0].Region__r.RegionHead__c;
            String regionalBrazilMarketingOpsManager = tdList[0].Region__r.Brazil_Marketing_Ops_Manager__c;
            String zonalHeadUser = tdList[0].Zone__r.ZonalHead__c;
            String sbuUser = tdList[0].SBU__r.MarketingDirector__c; 
            String barterManager = tdList[0].BarterManager__c;
            String analystUser = tdList[0].BrazilAnalyst__c;
            String gsdUser = tdList[0].SBU__r.GSD__c;
            String rehUser = tdList[0].SBU__r.REH__c;
            string dmManager=tdList[0].Region__r.DM_marketing__c;
            string mmManager=tdList[0].Region__r.Marketing_Manager__c;
            
            Set<Id> userIdSet = new Set<Id>();
            if(String.isNotBlank(territoryUser)){
                userIdSet.add(territoryUser);
            }
            if(String.isNotBlank(regionalHeadUser)){
                userIdSet.add(regionalHeadUser);
            }
            if(String.isNotBlank(regionalBrazilMarketingOpsManager)){
                userIdSet.add(regionalBrazilMarketingOpsManager);
            }
            if(String.isNotBlank(zonalHeadUser)){
                userIdSet.add(zonalHeadUser);
            }
            if(String.isNotBlank(sbuUser)){
                userIdSet.add(sbuUser);    
            }
            if(String.isNotBlank(barterManager)){ 
                kedeObj.barterManager = barterManager;
            }
            if(String.isNotBlank(analystUser)){
                kedeObj.brazilAnalyst = analystUser;
            }
            if(String.isNotBlank(gsdUser)){
                kedeObj.GSDManager = gsdUser;
            }
            if(String.isNotBlank(rehUser)){
                kedeObj.REHManager = rehUser;
            }
            if(String.isNotBlank(dmManager)){
                kedeObj.dmManager = dmManager;
            }
            if(String.isNotBlank(mmManager)){
                kedeObj.mmManager = mmManager;
            }
            if(tdList[0].TerritoryCode__c!=null){
                kedeObj.territoryCode=tdList[0].TerritoryCode__c; 
            }
            if(tdList[0].Region__r.RegionCode__c!=null){
                kedeObj.regionCode=tdList[0].Region__r.RegionCode__c;
            }
            Map<Id, Employee_Details__c> businessRulesMap = Grz_OrderRequestViewController.getBusinessRuleMap(userIdSet);
            Map<String, Business_Rule__c> defaultBusinessRulesMap = Grz_SalesOrderCreationRequest.getDefaultBusinessRulesMap();
            
            if(businessRulesMap.containsKey(territoryUser) && String.isNotBlank(territoryUser)){ Employee_Details__c brObj = businessRulesMap.get(territoryUser);
                                                                                                if(String.isNotBlank(brObj.Associate_Group__c)){
                                                                                                    kedeObj.SP_TotalOrderMargin = brObj.Associate_Group__r.Business_Rule__r.Total_Order_Margin__c;
                                                                                                    kedeObj.SP_ListPriceDiscount = brObj.Associate_Group__r.Business_Rule__r.List_Price_Discount__c;
                                                                                                    kedeObj.tax = brObj.Associate_Group__r.Business_Rule__r.Taxes__c;
                                                                                                    kedeObj.freight = brObj.Associate_Group__r.Business_Rule__r.Freight__c;
                                                                                                }
                                                                                               }
            else if(defaultBusinessRulesMap.containsKey('Sales Person')){
                Business_Rule__c defObj = defaultBusinessRulesMap.get('Sales Person');
                kedeObj.SP_TotalOrderMargin = defObj.Total_Order_Margin__c;
                kedeObj.SP_ListPriceDiscount = defObj.List_Price_Discount__c;
                kedeObj.tax = defObj.Taxes__c;
                kedeObj.freight = defObj.Freight__c;
            }
            
            if(businessRulesMap.containsKey(regionalHeadUser) && String.isNotBlank(regionalHeadUser)){
                Employee_Details__c brObj = businessRulesMap.get(regionalHeadUser);
                if(String.isNotBlank(brObj.Associate_Group__c)){
                    kedeObj.salesDistrictManager = regionalHeadUser;
                    kedeObj.SDM_TotalOrderMargin1 = brObj.Associate_Group__r.Business_Rule__r.Total_Order_Margin__c;
                    kedeObj.SDM_ListPriceDiscount1 = brObj.Associate_Group__r.Business_Rule__r.List_Price_Discount__c;
                }
            }
            else if(defaultBusinessRulesMap.containsKey('Sales District Manager')){
                Business_Rule__c defObj = defaultBusinessRulesMap.get('Sales District Manager');
                kedeObj.salesDistrictManager = regionalHeadUser;
                kedeObj.SDM_TotalOrderMargin1 = defObj.Total_Order_Margin__c;
                kedeObj.SDM_ListPriceDiscount1 = defObj.List_Price_Discount__c;
            }
            if(businessRulesMap.containsKey(regionalBrazilMarketingOpsManager) && String.isNotBlank(regionalBrazilMarketingOpsManager)){
                Employee_Details__c brObj = businessRulesMap.get(regionalBrazilMarketingOpsManager);
                if(String.isNotBlank(brObj.Associate_Group__c)){
                    kedeObj.BrazilMarketingOpsManager = regionalBrazilMarketingOpsManager;
                    kedeObj.SDM_TotalOrderMargin4 = brObj.Associate_Group__r.Business_Rule__r.Total_Order_Margin__c;
                    kedeObj.SDM_ListPriceDiscount4 = brObj.Associate_Group__r.Business_Rule__r.List_Price_Discount__c;
                }
            }
            else if(defaultBusinessRulesMap.containsKey('Brazil Marketing Ops Manager')){
                Business_Rule__c defObj = defaultBusinessRulesMap.get('Brazil Marketing Ops Manager');
                kedeObj.BrazilMarketingOpsManager = regionalBrazilMarketingOpsManager;
                kedeObj.SDM_TotalOrderMargin4 = defObj.Total_Order_Margin__c;
                kedeObj.SDM_ListPriceDiscount4 = defObj.List_Price_Discount__c;
            }
            
            if(businessRulesMap.containsKey(zonalHeadUser) && String.isNotBlank(zonalHeadUser)){
                Employee_Details__c brObj = businessRulesMap.get(zonalHeadUser);
                if(String.isNotBlank(brObj.Associate_Group__c)){
                    kedeObj.salesOfficeManager = zonalHeadUser;
                    kedeObj.SOM_TotalOrderMargin2 = brObj.Associate_Group__r.Business_Rule__r.Total_Order_Margin__c;
                    kedeObj.SOM_ListPriceDiscount2 = brObj.Associate_Group__r.Business_Rule__r.List_Price_Discount__c;
                }
            }
            else if(defaultBusinessRulesMap.containsKey('Sales Office Manager')){
                Business_Rule__c defObj = defaultBusinessRulesMap.get('Sales Office Manager');
                kedeObj.salesOfficeManager = zonalHeadUser;
                kedeObj.SOM_TotalOrderMargin2 = defObj.Total_Order_Margin__c;
                kedeObj.SOM_ListPriceDiscount2 = defObj.List_Price_Discount__c;
            }     
            if(businessRulesMap.containsKey(sbuUser) && String.isNotBlank(sbuUser)){
                Employee_Details__c brObj = businessRulesMap.get(sbuUser);
                if(String.isNotBlank(brObj.Associate_Group__c)){
                    kedeObj.salesDirector = sbuUser;
                    kedeObj.SD_TotalOrderMargin3 = brObj.Associate_Group__r.Business_Rule__r.Total_Order_Margin__c;
                    kedeObj.SD_ListPriceDiscount3 = brObj.Associate_Group__r.Business_Rule__r.List_Price_Discount__c;
                }                
            }
            else if(defaultBusinessRulesMap.containsKey('Sales Director')){
                Business_Rule__c defObj = defaultBusinessRulesMap.get('Sales Director');
                kedeObj.salesDirector = sbuUser;
                kedeObj.SD_TotalOrderMargin3 = defObj.Total_Order_Margin__c;
                kedeObj.SD_ListPriceDiscount3 = defObj.List_Price_Discount__c;
            } 
            if(businessRulesMap.containsKey(rehUser) && String.isNotBlank(rehUser)){
                Employee_Details__c brObj = businessRulesMap.get(rehUser);
                if(String.isNotBlank(brObj.Associate_Group__c)){
                    kedeObj.REHManager = rehUser;
                    kedeObj.REH_TotalOrderMargin4 = brObj.Associate_Group__r.Business_Rule__r.Total_Order_Margin__c;
                    kedeObj.REH_ListPriceDiscount4 = brObj.Associate_Group__r.Business_Rule__r.List_Price_Discount__c;
                }                
            }
            else if(defaultBusinessRulesMap.containsKey('REH')){
                Business_Rule__c defObj = defaultBusinessRulesMap.get('REH');
                kedeObj.REHManager = rehUser;
                kedeObj.REH_TotalOrderMargin4 = defObj.Total_Order_Margin__c;
                kedeObj.REH_ListPriceDiscount4 = defObj.List_Price_Discount__c;
            } 
        }
        return kedeObj;
    }
    
    public static FlagStatus checkFlag(String recordId, Boolean isSimulated, String orderType, String orderStatus){
        List<AggregateResult> lstAR = [SELECT max(Approval_Flag__c)af 
                                       FROM Sales_Order_Line_Item__c 
                                       WHERE Sale_Order__c =:recordId];
        Decimal flagCount = (Decimal)lstAR[0].get('af');
        String greenFlag = 'like'; 
        String yellowFlag = 'midlike'; 
        String redFlag = 'dislike'; 
        String blackFlag ='dislike_black';
        String blueFlag ='Blue_Dislike';
        FlagStatus fsObj = new FlagStatus();
        if((flagCount==0.0 && orderType!='REMESSA PARA TESTE') || orderType=='ORDEM FILHA'){    
            if(isSimulated){
                fsObj.flagMessage = System.Label.Simulation_Saved_Successfully; 
            }
            else if(orderStatus == 'Draft'){
                fsObj.flagMessage = System.Label.Sales_Order_Draft_Saved_Successfully; 
            }       
            else{
                fsObj.flagMessage = System.Label.Sales_Order_Submitted_Successfully;
            }
            fsObj.flagStatus = greenFlag;
        }
        else if(flagCount==1.0 || flagCount==2.0 || flagCount==3.0 || flagCount==4.0 || ((orderType=='BONIFICAÇÃO' || orderType=='REMESSA PARA TESTE') && flagCount!=5.0) ){
            
            if(isSimulated){
                fsObj.flagMessage = getApprovalMessage(flagCount);
                    //getApprovalMessage(flagCount,System.Label.The_Simulation_does_not_fall_within_the_Margin_Limits_Set_Do_you_wish_To_save_i);
                 //'The Simulation does not fall within the Margin Limits Set. Do you wish To save it as Simulation Order?';
            }            
            else if(orderStatus == 'Draft'){
                fsObj.flagMessage = System.Label.The_Sales_Order_does_not_fall_within_the_Margin_Limits_Set_It_will_be_sent_ahea; //'The Sales Order does not fall within the Margin Limits Set. It will be sent ahead for Approval. Do you wish to Save it as Draft?';
            }                           
            else{
                fsObj.flagMessage = getApprovalMessage(flagCount); //'The Sales Order does not fall within the Margin Limits Set. It will be sent ahead For Approval. Do you wish to send it for Approval?';
            }
            if(flagCount==3.0 || orderType=='BONIFICAÇÃO' || orderType=='REMESSA PARA TESTE' ||flagCount==2.0){
                fsObj.flagStatus = redFlag;
            }
            else if(flagCount==1.0 ){
                fsObj.flagStatus = yellowFlag;
            }
            else if(flagCount==4.0 ){
                fsObj.flagStatus = blueFlag;
            }
        }else if(flagCount==5.0){
            if(orderStatus == 'Draft'){
                fsObj.flagMessage = System.Label.The_Sales_Order_does_not_fall_within_the_Future_Sales_Price_set_It_will_be_sent;
            }else{  
                fsObj.flagMessage = System.Label.The_Sales_Order_Does_Not_Fall_Within_The_Margin_Limits_Set;   
            }
            fsObj.flagStatus = blackFlag;   
        }
        return fsObj;
    }
    
    @AuraEnabled
    public static String getOrderSubStatus(ID soId){
        List<Sales_Order__c> soList = [SELECT Id, toLabel(OrderSubStatus__c)
                                       FROM Sales_Order__c 
                                       WHERE Id =: soId];
        return soList[0].OrderSubStatus__c;
    }
    public static String getApprovalMessage(Decimal approvalFlagCount) {
        String approvalLevel = '';
        approvalFlagCount = Integer.valueOf(approvalFlagCount);
        if (approvalFlagCount == 1) {
            approvalLevel = 'Gerente regional';
        } else if (approvalFlagCount == 2) {
            approvalLevel = 'Diretor de BU';
        } else if (approvalFlagCount == 3) {
            approvalLevel = 'Diretor de marketing';
        } else if (approvalFlagCount == 4) {
            approvalLevel = 'Brasil CCO';
        }
        String message = System.Label.Sales_Order_Does_Not_Fall_Within_Margin_Limits;
        message = message.replace('{0}', approvalLevel);
        return message;
    }
    
    @AuraEnabled
    public static List<SalesOrderItem> saveOrderItems(Sales_Order__c soObj2, List<SalesOrderItem> salesOrderItemList, List<Sales_Org__c> salesOrgList,boolean IsSimulated){
        Boolean ccoFlag = false;  
        Boolean globalFlag = false;
        System.debug('salesOrderItemList'+salesOrderItemList);  
        List<ExchangeRate__c> exchangeRateList = [SELECT Id, ExchangeRate__c, Createddate FROM ExchangeRate__c WHERE (FromCurrency__c = 'USD' AND ToCurrency__c = 'BRL') 
                                                  and CreatedDate > LAST_N_MONTHS:1 ORDER BY Createddate DESC NULLS FIRST limit 1]; 
        Set<String> materialCodeSet = new Set<String>();
        for(SalesOrderItem item: salesOrderItemList){
            materialCodeSet.add(item.productId);
        }
        Account accInfo = [SELECT Id, Depot_Code__c,Price_Conversion_Group__c FROM Account WHERE Id =: soObj2.Sold_to_Party__c limit 1];
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
            // Added for Project OLC - PRJ0010060 - Nikhil Verma to link only BR07 records
            if(soObj2.Type_of_Order__c == 'Projeto OLC'){
                mprList=[SELECT Id, Depot__c, SKU__c, SKU__r.SKU_Code__c
                         FROM Material_Plant_Relation__c 
                         WHERE SKU__c IN: materialCodeSet 
                         AND Replacement_Cost_OLC__c != null AND Replacement_Cost_OLC__c != 0 AND Depot_Code__c = 'BR07'];
            } 
            else if(IsSimulated){
                mprList= [SELECT Id, Depot__c, SKU__c, SKU__r.SKU_Code__c
                          FROM Material_Plant_Relation__c 
                          WHERE SKU__c IN: materialCodeSet                    
                          AND Depot__c=:depotCode ];
            } 
            else{
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
        KEDE kedeObj = Grz_OrderRequestViewController.getKEDE(soObj2.OwnerId);
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
        for(SalesOrderItem item: salesOrderItemList){
            Sales_Order_Line_Item__c soiObj = new Sales_Order_Line_Item__c();
            i = i+10;
            soiObj.Item_Number__c = i;
            soiObj.Sale_Order__c = soObj2.Id;
            soiObj.Product_Category__c = item.skuCategory;
            soiObj.SelloutPrice__c = item.selloutprice; 
            soiObj.Item_Category__c = item.itemCategory;
            soiObj.Round__c = item.round;
            soiObj.Cancellation_Reason__c = item.cancellationReason;
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
            if(soObj2.Type_of_Order__c == 'Projeto OLC'){ // added for Project OLC - PRJ0010060 - Nikhil Verma to set unbilled wty same as entered qty
                soiObj.Unbilled_Quatity__c = item.qty;
            }
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
            soiObj.Contribution_Margin_Total_Value__c = item.contMarginTotalValue;//Grz(Dheeraj) DDS CR CHG0038588;
            soiObj.DDS_Grade__c = item.DDSGrade;//Grz(Dheeraj) DDS CR CHG0038588
            soiObj.Recommended_price__c = item.Recommendedprice;//Grz(Dheeraj) DDS CR CHG0038588
            soiObj.DDS_MonitorLog__c = item.ddsMonitorLog;//Grz(Dheeraj) DDS CR CHG0038588
            soiList.add(soiObj);
        }
        if(!soiList.isEmpty()){
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
    
    @AuraEnabled
    public static Sales_Order__c getSalesOrder(ID soId) {
        List<Sales_Order__c> soList = [SELECT Id,Campaign_pricebook__c,TotalReplacementCost__c,Total_Punctuality_Without_Interest__c,TotalBarterDiscount__c,Total_Tax_Without_Interest__c,Total_Freight_Without_Interest__c,Kit_Order__c, Name,Ship_To_Party__c,Ship_To_Party__r.Location_Name__c,Use_Campaign__c,Campaign_Type__c,Pronutiva__c,
                                       Directed_Sales__c,Expected_Number_of_days__c,SAP_Order_Number__c, Order_Status__c, SalesOrderNumber_Brazil__c, BarterManager__c, 
                                       Sold_to_Party__r.Program_Margin_Discount__c,Sold_to_Party__r.Tax_Number_Br_Portal_Filter__c ,Maturity_Date__c,Price_Book__c, Sales_Order__c, Sold_to_Party__r.Tax_Number_1__c,
                                       Sold_to_Party__r.Name, Sold_to_Party__c, ReloadPaymentTerms__c, OrderSubStatus__c, BrazilAnalyst__c,TM_Code__c,
                                       Sold_to_Party__r.Tax_Number_3__c, TotalValueWithInterest__c, Inco_Term__c, Inco_Term__r.IncoTerm_Code__c,
                                       Sold_to_Party__r.SAP_Code__c, TotalValueWithoutInterest__c, SalesOrderLedgerMargin__c, BrazilSalesOrderApproved__c,
                                       Sold_to_Party__r.Customer_Group__c, SalesOrderReplacementMargin__c, Punctuality_Discount__c, Tax__c, Freight__c,Tax_D__c,Freight_D__c,
                                       Sold_to_Party__r.BillingCity,CreatedById, OwnerId, Owner.Name, Flag__c, Price_Book__r.Name,Price_Book__r.isActive__c,Price_Book__r.Expiry_Date__c, CurrencyIsoCode,Cancelled_details_SO__c,
                                       Sold_to_Party__r.BillingState,Sales_District__c,Sales_Office__c,Created_By_Name__c, Type_of_Order__c, Valid_From__c, Signed__c,Business_Discount__c,BudgetApprovalCheck__c,Enable_cancelled_sales_order__c,
                                       Valid_To__c, Purchase_Order_no__c, Purchase_Order_Date__c, avec_order__c, PaymentMethod__c,Financial_Discount__c,
                                       Payment_Term__c, Invoice_Message__c, Internal_OBS__c, Sales_order_OBS__c, BrazilSalesOrderStatus__c,Price_Book__r.Interest_Date__c,
                                       Sales_Order__r.SalesOrderNumber_Brazil__c, Sales_Order__r.SAP_Order_Number__c, Sales_Order__r.Sold_to_Party__r.Name, 
                                       Sales_Order__r.Sold_to_Party__r.Customer_Group__c, Sales_Order__r.Sold_to_Party__r.BillingCity, Sales_Order__r.Price_Book__r.Name,
                                       Sold_to_Party__r.Depot_Code__c, Sales_Order__r.Price_Book__c, Sales_Order__r.CurrencyIsoCode, Sold_to_Party__r.Customer_Region__c,
                                       Sales_Order__r.Sold_to_Party__r.BillingState, Sales_Order__r.Type_of_Order__c, KeyAccountDesOwnerBrazil__c,
                                       Sales_Order__r.Name, Sales_Order__r.ReloadPaymentTerms__c, Sales_Order__r.Maturity_Date__c, Remarks__c,OLC_Order__c,// Project OLC - PRJ0010060 - Nikhil Verma added OLC_Order__c field
                                       Sales_Order__r.Sold_to_Party__c, Sales_Order__r.Currency_Brazil__c, Currency_Brazil__c, Key_Account__c,Pricebook_for_equalization__c,
                                       Parent_Order_Simulated__c,Campaign_Payment_Term_Date__c,Payment_Term__r.Payterms_Desc__c,Campaign_Payment_Term__c, Parent_Order_Simulated__r.SalesOrderNumber_Brazil__c, 
                                       RecordType.Name, SalesOrgCode__c,Total_Group_Discount__c,Sold_to_Party__r.Price_Conversion_Group__c,GM_Hedge__c,GM_Barter__c,GP_Total__c,GM_Net__c,Total_GP_Lista__c,Impacto_GP_vs_LP__c, Sent_for_CCO__c, Sent_for_Latam_Director_Approval__c, Total_Overall_Margin__c,
                                       Invoice_Status__c,Blocked_Cancellation_Message__c,CreatedFrom__c,Sales_Order_Replacement_Margin_WI__c,Gross_Margin_with_Barter1__c,Total_of_Discount_Applied__c,Price_Conversion_Factor__c,Crop_Year__c,Phase_Out_Order__c,Product_Mix__c,Interest_Date_Value__c,Product_Mix_Name__c
                                       FROM Sales_Order__c 
                                       WHERE Id =: soId];
        soList[0].CreatedFrom__c = 'SFDC';
        return soList[0];
    }
    
    public static String getTerritory(){
        List<Territory_Distributor__c> tdList = [SELECT ID, Name, TerritoryCode__c, Region__c, BarterManager__c
                                                 FROM Territory_Distributor__c 
                                                 WHERE SalesOrg__r.Sales_Org_Code__c = '5191'
                                                 AND TerritoryManagerActive__c = True
                                                 AND (TerritoryManager__c=: UserInfo.getUserId() 
                                                      OR Region__r.RegionHead__c=: UserInfo.getUserId()
                                                      OR Region__r.Brazil_Marketing_Ops_Manager__c=:UserInfo.getUserId()
                                                      
                                                      OR Zone__r.ZonalHead__c=: UserInfo.getUserId()
                                                      OR SBU__r.MarketingDirector__c=: UserInfo.getUserId()
                                                      OR BarterManager__c=: UserInfo.getUserId()
                                                     ) LIMIT 1];
        String territoryId = '';
        if(!tdList.isEmpty()){
            territoryId = tdList[0].Id;
        }
        return territoryId;
    }
    
    /* ********************************* SKI(Nik) : #CR155 : Brazil Margin Block : 30-08-2022.... Start ************************************************* */
    public static Map<Id,Blanket_SKU__c> getBlanketSKUMap(String salesOrgCode){
        Map<Id,Blanket_SKU__c> blanketMap = new Map<Id,Blanket_SKU__c>();
        for(Blanket_SKU__c blnsku : [SELECT Id, Name, SKU__c, Status__c, Start_Date__c, End_Date__c, Sales_Org__c, 
                                     Combination_Key__c FROM Blanket_SKU__c WHERE Sales_Org__r.Sales_Org_Code__c =: salesOrgCode AND 
                                     Status__c = True AND End_Date__c >=: System.today() AND Start_Date__c <=: System.today()]){
                                         if(!blanketMap.containsKey(blnsku.SKU__c)){
                                             blanketMap.put(blnsku.SKU__c,blnsku);
                                         }                            
                                     }
        return blanketMap;
    }
    
    public static Map<Id, Material_Registration__c> getMaterialRegistration(Set<Id> skuSet, String accountState){
        Map<Id, Material_Registration__c> materialRegistrationMap = new Map<Id, Material_Registration__c>();
        for(Material_Registration__c mrObj: [SELECT Id, Name, Sales_Org__c, SKU__c, State__c, 
                                             Effective_From__c, Effective_To__c
                                             FROM Material_Registration__c 
                                             WHERE SKU__c IN : skuSet
                                             AND State__c =: accountState AND Effective_From__c <= TODAY AND Effective_To__c >= TODAY]){                                              
                                                 materialRegistrationMap.put(mrObj.SKU__c, mrObj);                                          
                                             }
        return materialRegistrationMap;
    }  
    
    public class OrderWrapper{
        @AuraEnabled public Sales_Order__c soObj;
        @AuraEnabled public ApprovalList approvalList;
        @AuraEnabled public List<Transaction_Log__c> errorList;
        @AuraEnabled public List<SalesOrderItem> soiList;
        @AuraEnabled public String sfdcOrderNo;
        @AuraEnabled public String sapOrderNo;
        @AuraEnabled public String orderSubStatus;
        public Exception exObj;
        
        public OrderWrapper(){
            soObj = new Sales_Order__c();
            approvalList = new ApprovalList();
            errorList = new List<Transaction_Log__c>();
            soiList = new List<SalesOrderItem>();
            sfdcOrderNo = '';
            sapOrderNo = '';
            orderSubStatus = '';
        }
    }
    
    public class SOMBalance{
        @AuraEnabled public String productId;
        @AuraEnabled public String product;
        @AuraEnabled public String quantity;
        @AuraEnabled public String balance;
        @AuraEnabled public String used;
        @AuraEnabled public String percent;
        @AuraEnabled public String lineItemId;
        
        public SOMBalance(){
            product = '';
            quantity = '0';
            balance = '0';
            percent = '0';
            used = '0';
            lineItemId = '';
        }
    }
    
    public class FlagStatus{
        @AuraEnabled public String flagMessage;
        @AuraEnabled public String flagStatus;
        
        public FlagStatus(){
            flagMessage = '';
            flagStatus = '';
        }
    }
    
    public class KEDE{
        @AuraEnabled public String dmManager;
        @AuraEnabled public String mmManager;
        @AuraEnabled public String territoryCode;
        @AuraEnabled public String regionCode;
        @AuraEnabled public String salesPerson;
        @AuraEnabled public Decimal SP_TotalOrderMargin;
        @AuraEnabled public Decimal SP_ListPriceDiscount;
        @AuraEnabled public Decimal tax;
        @AuraEnabled public Decimal freight;
        @AuraEnabled public String salesDistrictManager;
        @AuraEnabled public Decimal SDM_TotalOrderMargin1;
        @AuraEnabled public Decimal SDM_ListPriceDiscount1;
        @AuraEnabled public String BrazilMarketingOpsManager;
        @AuraEnabled public Decimal SDM_TotalOrderMargin4;
        @AuraEnabled public Decimal SDM_ListPriceDiscount4;
        @AuraEnabled public String salesOfficeManager;
        @AuraEnabled public Decimal SOM_TotalOrderMargin2;
        @AuraEnabled public Decimal SOM_ListPriceDiscount2;
        @AuraEnabled public String salesDirector;
        @AuraEnabled public Decimal SD_TotalOrderMargin3;
        @AuraEnabled public Decimal SD_ListPriceDiscount3;
        @AuraEnabled public String barterManager;
        @AuraEnabled public String brazilAnalyst;
        @AuraEnabled public String REHManager;
        @AuraEnabled public Decimal REH_TotalOrderMargin4;
        @AuraEnabled public Decimal REH_ListPriceDiscount4;
        @AuraEnabled public String GSDManager;
        
        
        public KEDE(){
            dmManager=''; 
            mmManager='';
            territoryCode=''; 
            regionCode='';
            salesPerson = '';
            SP_TotalOrderMargin = 0;
            SP_ListPriceDiscount = 0;
            tax = 0;
            freight = 0;
            salesDistrictManager = '';
            SDM_TotalOrderMargin1 = 0;
            SDM_ListPriceDiscount1 = 0;
            BrazilMarketingOpsManager = '';
            SDM_TotalOrderMargin1 = 0;
            SDM_ListPriceDiscount1 = 0;
            salesOfficeManager = '';
            SDM_TotalOrderMargin1 = 0;
            SDM_ListPriceDiscount1 = 0;
            salesDirector = '';
            SD_TotalOrderMargin3 = 0;
            SD_ListPriceDiscount3 = 0;
            REHManager = '' ;
            REH_TotalOrderMargin4 = 0;
            REH_ListPriceDiscount4 = 0;
            barterManager = '';
            brazilAnalyst = '';
            GSDManager = '';
        }
    }
    
    
    
    public class SOMQuantity{
        @AuraEnabled public List<Grz_SalesOrderCreationRequest.PriceDetail> priceList;
        @AuraEnabled public List<String> productList;
        
        public SOMQuantity(){
            priceList = new List<Grz_SalesOrderCreationRequest.PriceDetail>();
            productList = new List<String>();
        }
    }
    
    public static Map<Id, Employee_Details__c> getBusinessRuleMap(Set<Id> userIdSet) {
        Map<Id, Employee_Details__c> employeeDetailMap = new Map<Id, Employee_Details__c>();
        for(Employee_Details__c edObj: [SELECT Id, Associate_Group__c, User__c,
                                        Associate_Group__r.Business_Rule__c,
                                        Associate_Group__r.Business_Rule__r.Taxes__c,
                                        Associate_Group__r.Business_Rule__r.Freight__c,
                                        Associate_Group__r.Business_Rule__r.Total_Order_Margin__c,
                                        Associate_Group__r.Business_Rule__r.List_Price_Discount__c
                                        FROM Employee_Details__c 
                                        WHERE User__c IN: userIdSet]){
                                            employeeDetailMap.put(edObj.User__c, edObj);                                            
                                        }
        return employeeDetailMap;
    }
    
    
    public class SalesOrderDataWrapper{
        @AuraEnabled public Sales_Order__c Sales_Order{ get; set; }
        @AuraEnabled public UserInfoWrapper brazilLoginUserInfo { get; set; }
        @AuraEnabled public List<SalesOrderItem> salesOrderLineItemsList {get; set;}
        @AuraEnabled public List<Admin_MPT_Colombia__c> adminMPTList {get; set;}
        @AuraEnabled public Boolean IsApprovalPending {get; set;}
        @AuraEnabled public Map<String,Customer_Conversion_factor__c> customerConversionMap{get; set;}
        @AuraEnabled public Employee_Details__c businessRules {get; set;}
        @AuraEnabled public CustomerTaxAndFreight custTaxAndFreight {get; set;}
        @AuraEnabled public boolean enableApproval {get; set;}
        @AuraEnabled public List<String> getIncoTerms {get; set;}
    }    
    
    public class UserInfoWrapper{
        @AuraEnabled public Id loginUserId {get; set;}
        @AuraEnabled public String profileName{get; set;}
        @AuraEnabled public Boolean isBrazilSalesPerson { get; set; }
        @AuraEnabled public Boolean isBraziluserKAM { get; set; }
        @AuraEnabled public Boolean isBrazilUser { get; set; }
        @AuraEnabled public Boolean showListValue { get; set; }
    }
    
    public class ApprovalList{
        @AuraEnabled public List<AuditHistory> listOfStepsAudit;
        @AuraEnabled public List<ProcessInstanceHistory> listOfSteps;
        @AuraEnabled public Boolean enableApproval;
        @AuraEnabled public Id recordId;
        
        public ApprovalList(){
            listOfStepsAudit = new List<AuditHistory>();
            listOfSteps = new  List<ProcessInstanceHistory>();
            enableApproval = false;
        }
    }
    
    public class AuditHistory{
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String stepStatus;
        @AuraEnabled public String originalActorName;
        @AuraEnabled public String actorName;
        @AuraEnabled public String comments;
        
        public AuditHistory(){
            createdDate = System.now();
            stepStatus = '';
            originalActorName = '';
            actorName = '';
            comments = '';
        }
    }
    @AuraEnabled(cacheable=true)
    public static String getZoneCode() {
        
        List<Territory_Distributor__c> distributorList = [
            SELECT Zone_Code__c 
            FROM Territory_Distributor__c 
            WHERE SalesOrg__r.Sales_Org_Code__c = '5191'
            AND TerritoryManagerActive__c = TRUE
            AND (TerritoryManager__c = :UserInfo.getUserId() 
                 OR Region__r.RegionHead__c = :UserInfo.getUserId() 
                 OR Region__r.Brazil_Marketing_Ops_Manager__c = :UserInfo.getUserId()
                 OR Zone__r.ZonalHead__c = :UserInfo.getUserId() 
                 OR SBU__r.SBUUser__c = :UserInfo.getUserId() 
                 OR BarterManager__c = :UserInfo.getUserId()) 
            LIMIT 1
        ];
        
        
        if (!distributorList.isEmpty()) {
            return distributorList[0].Zone_Code__c;
        } else {
            return null; 
        }
    }
    
        //Start Grz(Dheeraj) DDS CR CHG0038588
    public class DDSValuesWrapper {
        @AuraEnabled public List<String> brandPicklist = new List<String>();
        @AuraEnabled public List<String> ugdnPicklist = new List<String>();
        @AuraEnabled public Boolean isDDSActive = true;
        }

    public class DDSRequestWrapper {
        @AuraEnabled public String sapCode {get;set;}
        @AuraEnabled public String customerName {get;set;}
        @AuraEnabled public String currencyCode {get;set;}
        @AuraEnabled public String salesOrderItemString {get;set;}
    }
        //End Grz(Dheeraj) DDS CR CHG0038588

    
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
        @AuraEnabled public Decimal unitValueBRL;
        @AuraEnabled public Decimal unitValueUSD;
        @AuraEnabled public String brand;
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
        @AuraEnabled public Decimal contMarginTotalValue;//Grz(Dheeraj) DDS CR CHG0038588
        @AuraEnabled public Boolean flagForInv;//Grz(Dheeraj) DDS CR CHG0038588
        @AuraEnabled public Boolean flagForQuantityErr;//Grz(Dheeraj) DDS CR CHG0038588
        @AuraEnabled public String invalidQuantity;//Grz(Dheeraj) DDS CR CHG0038588
        @AuraEnabled public String ddsMonitorLog;//Grz(Dheeraj) DDS CR CHG0038588
        @AuraEnabled public Decimal productReplacementMargin;//Nikhil for DDS
        @AuraEnabled public List<String> invalidInventory { get; set; }//Grz(Dheeraj) DDS CR CHG0038588
        @AuraEnabled public String ItemUniqueNumber;
        @AuraEnabled public Decimal exchngRate;
        @AuraEnabled public String curncyCode;
        @AuraEnabled public string cancelLineItem;// added by javed for RITM1013366
        @AuraEnabled public boolean cancelCheckbox;// added by javed for RITM1013366
        @AuraEnabled public string cancelationReason;// added by javed for RITM1033161
         @AuraEnabled public boolean cancelationReasonAvailable;// added by javed for RITM1033161


        public SalesOrderItem(){
            productReplacementMargin = 0; //Nikhil for DDS
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
            fatDate = '';
            fatDateNew='';
            interest_Date = '';//Divya INCTASK0186953
            qty = 0;
            qtyNew=0;
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
            contMarginTotalValue = 0; //Grz(Dheeraj) DDS CR CHG0038588
            flagForInv = false; //Grz(Dheeraj) DDS CR CHG0038588
            flagForQuantityErr = false; //Grz(Dheeraj) DDS CR CHG0038588
            invalidQuantity = ''; //Grz(Dheeraj) DDS CR CHG0038588
             ddsMonitorLog='';//Grz(Dheeraj) DDS CR CHG0038588
             ItemUniqueNumber='';
            exchngRate = 0;
            curncyCode = '';
            cancelLineItem='No';
            /* ************************* SKI(Nik) : #CR155 : Brazil Margin Block : 30-08-2022.... End ******************************************* */
        }
    } 
    
    public class CustomerTaxAndFreight{
        @AuraEnabled public Decimal tax;
        @AuraEnabled public Decimal freight;
        @AuraEnabled public String customerRegion;
        @AuraEnabled public String id;
        
        public CustomerTaxAndFreight(){
            tax = 0;
            freight = 0;
            customerRegion = '';
            id = '';
        }
    }
    
    public class MainWrapper {
        @AuraEnabled public List<Inventory> inventoryList { get; set; }
        @AuraEnabled public List<Territory_Distributor__c> TerritoryRegionInfo { get; set; }
        @AuraEnabled public MinValWrapper minMaxValue { get; set; } 
        @AuraEnabled public List<String> cultureOptions{ get; set; } 
        @AuraEnabled public String zoneCode{ get; set; } 
        @AuraEnabled public Decimal  avecValue{ get; set; } 
        @AuraEnabled public Decimal nonAvecValue{ get; set; } 
        @AuraEnabled public String regionValue{ get; set; } 
        
    }
    
    public class Inventory {
        @AuraEnabled public Decimal qty;
        @AuraEnabled public Boolean inventoryactive;
        @AuraEnabled public Boolean isAvec; // added by pragati
        @AuraEnabled public String inventoryblockalert;
        @AuraEnabled public String productname;
        @AuraEnabled public String year;
        @AuraEnabled public String year1;
        @AuraEnabled public String BU;// added by pragati
        @AuraEnabled public Decimal totalqty;
        @AuraEnabled public String fiscalYear; // added by javed for RITM0682416
        @AuraEnabled public String quarter; // added by pragati
        
        public Inventory(){
            qty = 0;
            inventoryactive= false;
            inventoryblockalert = '';
            productname='';
            year='';
            year1='';
            totalqty = 0;
            fiscalYear='';// added by javed for RITM0682416
            quarter='';// added by pragati
            BU='';// added by pragati
            isAvec=false;// added by pragati
        }
    }
    
    public class MinValWrapper{
        @AuraEnabled public String OrderType{get;set;}
        @AuraEnabled public decimal MinVal{get;set;}
        @AuraEnabled public decimal MinValUSD{get;set;}
        @AuraEnabled public decimal MaxDisc{get;set;}
    }
    
      public class ResWrapper{
        @AuraEnabled public Integer Prod_Code{get;set;}
        @AuraEnabled public decimal Recommended_price{get;set;}
        @AuraEnabled public String DDS_Grade{get;set;}
        @AuraEnabled public String sErrMsg;
        @AuraEnabled public String result;  
    }
    
      public class Salesorder{
        @AuraEnabled public integer Numero_do_Pedido{get;set;}
        @AuraEnabled public string Management{get;set;}
        @AuraEnabled public string Mes_do_pedido{get;set;}
        @AuraEnabled public string Business_Unit{get;set;}
        @AuraEnabled public string Customer_Group{get;set;}
        @AuraEnabled public string Customer{get;set;}
        @AuraEnabled public string Brand{get;set;}
        @AuraEnabled public integer Prod_Code{get;set;}
        @AuraEnabled public string Product_Description{get;set;} 
        @AuraEnabled public integer Quantity{get;set;}
        @AuraEnabled public double Order_Sales_FV_USD{get;set;}
        @AuraEnabled public double Order_Total_Cogs_USD{get;set;}
        @AuraEnabled public double Order_Gross_Margin_PV_USD{get;set;}
        @AuraEnabled public double Price_List_Sales_FV_USD{get;set;}
        @AuraEnabled public string Currency1{get;set;}    
    }
}