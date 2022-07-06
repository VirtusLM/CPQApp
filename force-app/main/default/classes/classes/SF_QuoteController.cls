/*
* ============================================
* @apexClassName: SF_QuoteController.cls
* @description: Class contains the logic of creating quote
* @author: L.Mikatsadze
* @email: l.mikatsadze@makingscience.com
* @testClass: SF_QuoteControllerTest.cls
* @dateCreated: 22/05/2022
* @lastChange: 24/05/2022 by L.Mikatsadze
* ============================================
*/
public with sharing class SF_QuoteController {
    //@author: L.Mikatsadze
    //@description: Creates new quote.
    @AuraEnabled
    public static SF_Quote__c createQuote(Id oppId){
        List<Opportunity> opps = [SELECT Id, AccountId, SF_Price_List__c FROM Opportunity WHERE Id =:oppId LIMIT 1];

        List<Contact> contact = [SELECT Id FROM Contact WHERE AccountId =:opps[0].AccountId AND SF_Primary__c=true LIMIT 1];
        
        SF_Quote__c newQuote = new SF_Quote__c(
            SF_Opportunity__c = oppId,
            SF_Account__c = opps[0].AccountId,
            SF_Contact__c = contact[0].Id,
            SF_Price_List__c = opps[0].SF_Price_List__c,
            SF_Status__c = 'Draft',
            SF_Expiration_Date__c = System.today().addDays(7)
        );
        
        insert newQuote;
        
        List<Account> account = [SELECT Id, Name FROM Account WHERE Id =:opps[0].AccountId];
        List<SF_Price_List__c> priceList = [SELECT Id, Name FROM SF_Price_List__c WHERE Id =:opps[0].SF_Price_List__c];
        
        List<Custom_Product__mdt> metaDataInfo = [SELECT Account__c, PriceList__c, Products__c FROM Custom_Product__mdt WHERE Active__c=true];

        List<String> accs = metaDataInfo[0].Account__c.split(',');
        List<String> plis = metaDataInfo[0].PriceList__c.split(',');
        List<String> products = metaDataInfo[0].Products__c.split(',');

        List<SF_Quote_Line_Item__c> qlisList = new List<SF_Quote_Line_Item__c>();

        for(String acc : accs) {
            if(acc == account[0].Name) {
                for(String pli : plis) {
                    if(pli == priceList[0].Name) {

                        List<Product2> productsList = [SELECT Id, Name, (SELECT Id FROM SF_Price_List_Items__r) 
                                                                        FROM Product2 WHERE Name IN :products];

                        for(Integer i=0; i<products.size(); i++){
                            List<SF_Price_List_Item__c> pliIds = productsList[i].SF_Price_List_Items__r;
                            
                            SF_Quote_Line_Item__c qli = new SF_Quote_Line_Item__c(
                                Name = productsList[i].Name,
                                SF_Product__c = productsList[i].Id,
                                SF_Quote__c = newQuote.Id,
                                SF_Price_List_Item__c = pliIds[0].Id,
                                SF_Quantity__c = 1
                            );
                                qlisList.add(qli);
                        }
                    }
                }
            }
        }
        insert qlisList;
        return newQuote;
    }    
  
    //@author: L.Mikatsadze
    //@description: Retrieves field api names from custom metadata and gets relevant field labels from SF_Quote_Line_Item__c object.
    @AuraEnabled(cacheable=true)
    public static List<String> getQuoteLineItemFieldNames(){

        List<Datatable_Setting__mdt> metaDataFields = [SELECT Fields__c FROM Datatable_Setting__mdt];
  
        List<String> labels = metaDataFields[0].Fields__c.split(',');
        Set<String> setLables = new Set<String>();
        setLables.addAll(labels);
        
        String ObjectApi = 'SF_Quote_Line_Item__c';
        
        List<String> labelList = new List<String>();
         
        for(String item : setLables){
            String label =(String)Schema.getGlobalDescribe().get(ObjectApi).getDescribe().fields.getMap().get(item).getDescribe().getLabel();
                if(label!='Currency Iso Code')
                    labelList.add(label);
        }

        Cache.Org.put('local.ConfigureProductsCache.qliFieldsLabels', labelList);

        return (List<String>)Cache.Org.get('local.ConfigureProductsCache.qliFieldsLabels');
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getQuoteLineItemFieldTypes(){

        List<Datatable_Setting__mdt> metaDataFields = [SELECT Fields__c FROM Datatable_Setting__mdt];
  
        List<String> labels = metaDataFields[0].Fields__c.split(',');
        Set<String> setLables = new Set<String>();
        setLables.addAll(labels);
        
        String ObjectApi = 'SF_Quote_Line_Item__c';
        
        List<String> typeList = new List<String>();
         
        for(String item : setLables){
            String type = String.valueOf(Schema.getGlobalDescribe().get(ObjectApi).getDescribe().fields.getMap().get(item).getDescribe().getType());
                if(type!='PICKLIST')
                    typeList.add(type);
        }

        Cache.Org.put('local.ConfigureProductsCache.qliFieldsTypes', typeList);

        return (List<String>)Cache.Org.get('local.ConfigureProductsCache.qliFieldsTypes');
    }


//******************************************************************************************************************* */
//******************************************************************************************************************** */

    //@author: L.Mikatsadze
    //@description: Retrieves field api names from custom metadata and gets relevant fields from SF_Quote_Line_Item__c object.
    @AuraEnabled(cacheable=true)
    public static QliDataWrapper getQuoteLineItems(Id quoteId) {

        List<Datatable_Setting__mdt> metaDataFields = [SELECT Fields__c FROM Datatable_Setting__mdt];

        List<String> fields = metaDataFields[0].Fields__c.split(',');
        String fieldsString = string.join(fields,',');

        List <SF_Quote_Line_Item__c> qliRecords = new List <SF_Quote_Line_Item__c>();

        String strSOQL = 'SELECT Id, ' + fieldsString + ', SF_Is_Bundle__c, SF_Quote_Line_Item__c, SF_Product__c, SF_Price_List_Item__c FROM SF_Quote_Line_Item__c WHERE SF_Quote__c =:quoteId ORDER BY CreatedDate ASC';

        qliRecords = Database.query(strSOQL);

        
        List<String> labels = getQuoteLineItemFieldNames();
        List<String> types = getQuoteLineItemFieldTypes();
     
        List<TableFieldsWrapper> labelsTypesFields = new List<TableFieldsWrapper>();

        for(Integer i=0; i<labels.size(); i++) {
            labelsTypesFields.add(new TableFieldsWrapper(labels[i], types[i], fields[i]));  
        }
                    
        QliDataWrapper quoteLineItemRecords = new QliDataWrapper(labelsTypesFields, qliRecords);

        return quoteLineItemRecords;
    }

    public class TableFieldsWrapper {

        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String fieldApi { get; set; }

        public TableFieldsWrapper(String label, String type, String field){
            this.label = label;
            this.type = type;
            this.fieldApi = field;
        }        
    }

    public class QliDataWrapper {
        
        @AuraEnabled public List<SF_Quote_Line_Item__c> qlis { get; set; }
        @AuraEnabled public List<TableFieldsWrapper> fields { get; set; }

        public QliDataWrapper(List<TableFieldsWrapper> fields, List<SF_Quote_Line_Item__c> qlis) {
            this.qlis = qlis;
            this.fields = fields;
        }
    }


    
    // public  class QuoteLineItemWrapper {

        // @AuraEnabled public String name { get; set; }
        // @AuraEnabled public Id recordId { get; set; }
        // @AuraEnabled public Id productId { get; set; }
        // @AuraEnabled public Id pliId { get; set; }
        // @AuraEnabled public Decimal unitPrice { get; set; }
        // @AuraEnabled public Decimal totalPrice { get; set; }
        // @AuraEnabled public Decimal subTotal { get; set; }
        // @AuraEnabled public Decimal discount { get; set; }
        // @AuraEnabled public Decimal quantity { get; set; }
        // @AuraEnabled public String currencyIsoCode { get; set; }
        // @AuraEnabled public Boolean bundle { get; set; }
        // @AuraEnabled public List<Product2> optProducts { get; set; }
    
        // public QuoteLineItemWrapper(List<Product2> optProducts, SF_Quote_Line_Item__c qli){

            // this.name = qli.Name;
            // this.recordId = qli.Id;
            // this.productId = qli.SF_Product__c;
            // this.pliId = qli.SF_Price_List_Item__c;
            // this.unitPrice = qli.SF_Unit_Price__c;
            // this.totalPrice = qli.SF_Total_Price__c;
            // this.subTotal = qli.SF_Subtotal__c;
            // this.discount = qli.SF_Discount__c;
            // this.quantity = qli.SF_Quantity__c;
            // this.currencyIsoCode = qli.CurrencyIsoCode;
            // this.bundle = qli.SF_Is_Bundle__c;
            // this.optQlis = new List<SF_Quote_Line_Item__c>();
            // this.optProducts = optProducts;  
    //     }
    // }

   

    //***************************************************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductsByQuoteId(Id quoteId) {

        List<SF_Quote__c> priceList = [SELECT SF_Price_List__c FROM SF_Quote__c WHERE Id=:quoteId];

        List<SF_Price_List_Item__c> priceListItems = [SELECT Id, Base_Price__c, Product__c, CurrencyIsoCode 
                                                        FROM SF_Price_List_Item__c 
                                                        WHERE Price_List__c=:priceList[0].SF_Price_List__c 
                                                        AND SF_Active__c=true];
        Set<Id> productIds = new Set<Id>();

        for (SF_Price_List_Item__c res : priceListItems) {
            productIds.add(res.Product__c);
        }

        List<Product2> products = [SELECT Id, Name, SF_Is_Bundle__c, (SELECT Id, Name, SF_Is_Bundle__c, SF_IsOptional__c FROM Option_Products__r),
                                                    (SELECT Id, Base_Price__c, CurrencyIsoCode FROM SF_Price_List_Items__r 
                                                    WHERE Product__c IN :productIds AND SF_Active__c=true)
                                                    FROM Product2 WHERE Id IN :productIds AND SF_Is_Bundle__c=true LIMIT 10];

        return products;
    }

    @AuraEnabled(cacheable=true)
    public static List<SF_Price_List_Item__c> getPriceListItemsByQuoteId(Id quoteId) {

        List<SF_Quote__c> priceList = [SELECT SF_Price_List__c FROM SF_Quote__c WHERE Id=:quoteId];

        List<SF_Price_List_Item__c> priceListItems = [SELECT Id, Base_Price__c, Product__c, CurrencyIsoCode 
                                                        FROM SF_Price_List_Item__c 
                                                        WHERE Price_List__c=:priceList[0].SF_Price_List__c 
                                                        AND SF_Active__c=true];
        return priceListItems;
    }

    
//********************************************************************************************************************* */
                                                 //PRODUCT WRAPPER CLASS
//********************************************************************************************************************* */
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getProductList(Id quoteId) {
        List<SF_Quote__c> priceList = [SELECT SF_Price_List__c FROM SF_Quote__c WHERE Id=:quoteId];
        
        //Get all plis of a particular price list/currency
        List<SF_Price_List_Item__c> plis = [SELECT Product__c, Base_Price__c, CurrencyIsoCode 
                                            FROM SF_Price_List_Item__c 
                                            WHERE Price_List__c=:priceList[0].SF_Price_List__c AND SF_Active__c=true];
        
        //Do mapping productId vs. plis
        Map<ID, SF_Price_List_Item__c> pliMap = new Map<ID, SF_Price_List_Item__c>();
        for (SF_Price_List_Item__c pli : plis) {
            pliMap.put(pli.Product__c, pli);
        }
        
        //Get all products associated to the select plis
        List<Product2> products = [SELECT Id, Name, SF_IsOptional__c, SF_Is_Bundle__c FROM Product2 WHERE Id IN :pliMap.keySet()];
        
        List<ProductWrapper> allProducts = new List<ProductWrapper>();
        for(Product2 pr : products){
            allProducts.add(new ProductWrapper(pr, pliMap.get(pr.Id)));
        }
        
        return allProducts;
    }
    
    public class ProductWrapper{
        @AuraEnabled public Decimal basePrice { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String currencyIsoCode { get; set; }
        @AuraEnabled public Boolean isBundle { get; set; }
        
        public ProductWrapper(Product2 pr, SF_Price_List_Item__c pli){
            this.productName = pr.Name;
            this.isBundle = pr.SF_Is_Bundle__c;
            if(pli != null){                
            	this.basePrice = pli.Base_Price__c;
                this.currencyIsoCode = pli.CurrencyIsoCode;
            }
        }        
    }
}