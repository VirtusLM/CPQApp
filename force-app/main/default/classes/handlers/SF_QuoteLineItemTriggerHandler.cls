/*
* ============================================
* @apexClassName: SF_QuoteLineItemTriggerHandler.cls
* @description: Handler class of SF_QuoteLineItemTrigger trigger.
* @author: L.Mikatsadze
* @email: l.mikatsadze@makingscience.com
* @dateCreated: 25/05/2022
* @lastChange: 29/05/2022 by L.Mikatsadze
* ============================================
*/
public with sharing class SF_QuoteLineItemTriggerHandler {
    //@author: L.Mikatsadze
    //@description: Gets field values from Product2 and SF_Price_List_Item__c objects and defines to SF_Quote_Line_Item__c fields.
    public static void defineQuoteLineItemValues(List<SF_Quote_Line_Item__c> quoteLineItems) {
        if(quoteLineItems != null){
        
        Set<Id> priceListItemsIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        for(SF_Quote_Line_Item__c qli : quoteLineItems) {
            priceListItemsIds.add(qli.SF_Price_List_Item__c);
            productIds.add(qli.SF_Product__c);
        }

        List<SF_Price_List_Item__c> priceListItems = [SELECT Id, Base_Price__c 
                                                        FROM SF_Price_List_Item__c 
                                                        WHERE Id IN :priceListItemsIds];

        List<Product2> products = [SELECT Id, Name, Description, SF_Is_Bundle__c 
                                            FROM Product2 WHERE Id IN :productIds];


        Map<Id, SF_Price_List_Item__c> priceListItemsMap = new Map<Id, SF_Price_List_Item__c>(priceListItems);
        Map<Id, Product2> productsMap = new Map<Id, Product2>(products);
       

            for(SF_Quote_Line_Item__c qli : quoteLineItems) {

                SF_Price_List_Item__c priceListItem = priceListItemsMap.get(qli.SF_Price_List_Item__c);
                qli.SF_List_Price__c = priceListItem.Base_Price__c;
                qli.SF_Unit_Price__c = priceListItem.Base_Price__c;

                Product2 product = productsMap.get(qli.SF_Product__c);
                qli.Name = product.Name;
                qli.SF_Line_Item_Description__c = product.Description;
            }
        }
    }
}