/*
* ============================================
* @apexClassName: SF_QuoteLineItemController.cls
* @description: Class contains the logic of creating quote line items
* @author: L.Mikatsadze
* @email: l.mikatsadze@makingscience.com
* @testClass: SF_QuoteLineItemControllerTest.cls
* @dateCreated: 20/06/2022
* @lastChange: 22/06/2022 by L.Mikatsadze
* ============================================
*/

public with sharing class SF_QuoteLineItemController {

    @AuraEnabled
    public static void createQuoteLineItems(List<ProductWrapper> data, Id quoteId) {

        List<SF_Quote_Line_Item__c> qliList = new List<SF_Quote_Line_Item__c>();
        
        for(ProductWrapper pr : data) {
            SF_Quote_Line_Item__c newQli = new SF_Quote_Line_Item__c(
                Name = pr.name,
                SF_Product__c = pr.productId,
                SF_Price_List_Item__c = pr.pliId,
                SF_Quote__c = quoteId,
                SF_Total_Price__c = pr.basePrice,
                SF_Subtotal__c = pr.basePrice,
                SF_Quantity__c = pr.quantity,
                SF_Is_Bundle__c	 = pr.isBundle,
                CurrencyIsoCode = pr.currencyIsoCode,
                SF_Service_Date__c = System.today().addDays(30),
                SF_Discount__c = 15
            );
                qliList.add(newQli);     
        }   

        List<SF_Quote_Line_Item__c> bundleQlis = new List<SF_Quote_Line_Item__c>();
        List<SF_Quote_Line_Item__c> optionQlis = new List<SF_Quote_Line_Item__c>();
        
        for(SF_Quote_Line_Item__c qli : qliList) {
            if (qli.SF_Is_Bundle__c == true) {
                bundleQlis.add(qli);
            } else {
                optionQlis.add(qli);
            }
        }

        insert bundleQlis;

        for(SF_Quote_Line_Item__c qli : optionQlis) {
            qli.SF_Quote_Line_Item__c = bundleQlis[0].Id;
        }
        
        insert optionQlis;
    }   

    public class ProductWrapper {

        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Id pliId { get; set; }
        @AuraEnabled public Decimal basePrice { get; set; }
        @AuraEnabled public Boolean isBundle { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public String currencyIsoCode { get; set; }
    }

    
    @AuraEnabled
    public static void cloneQuoteLineItems(List<SF_Quote_Line_Item__c> qlis, Id quoteId) {

        List<SF_Quote_Line_Item__c> qliList = new List<SF_Quote_Line_Item__c>();

        for(SF_Quote_Line_Item__c qli : qlis) {
            SF_Quote_Line_Item__c clonedQli = new SF_Quote_Line_Item__c(
                Name = qli.Name,
                SF_Product__c = qli.SF_Product__c,
                SF_Price_List_Item__c = qli.SF_Price_List_Item__c,
                SF_Quote__c = quoteId,
                SF_Total_Price__c = qli.SF_Total_Price__c,
                SF_Subtotal__c = qli.SF_Subtotal__c,
                SF_Quantity__c = qli.SF_Quantity__c,
                CurrencyIsoCode = qli.CurrencyIsoCode,
                SF_Is_Bundle__c = qli.SF_Is_Bundle__c,
                SF_Discount__c = qli.SF_Discount__c,
                SF_Service_Date__c = System.today().addDays(30)
            );
                qliList.add(clonedQli);
        }   
        List<SF_Quote_Line_Item__c> bundleQlis = new List<SF_Quote_Line_Item__c>();
        List<SF_Quote_Line_Item__c> optionQlis = new List<SF_Quote_Line_Item__c>();

        for(SF_Quote_Line_Item__c qli : qliList) {
            if (qli.SF_Is_Bundle__c == true) {
                bundleQlis.add(qli);
            } else {
                optionQlis.add(qli);
            }
        }

        insert bundleQlis;

        for(SF_Quote_Line_Item__c qli : optionQlis) {
            qli.SF_Quote_Line_Item__c = bundleQlis[0].Id;
        }
        
        insert optionQlis;
    }

    @AuraEnabled
    public static void changeQuantity(SF_Quote_Line_Item__c qli) {

        SF_Quote_Line_Item__c updatedQli = new SF_Quote_Line_Item__c(
            Id = qli.Id,
            SF_Quantity__c = qli.SF_Quantity__c);

            update updatedQLi;
    }
}