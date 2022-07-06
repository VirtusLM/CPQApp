/*
* ============================================
* @apexClassName: SF_CreateOrderTest.cls
* @description: Class contains tests of creating order class
* @author: G.Tvaliashvili
* @email: givi.tvaliashvili@makingscience.com
* @dateCreated: 29/06/2022
* @lastChange: 29/06/2022 by G.Tvaliashvili
* ============================================
*/

//testsetup


@IsTest
public class SF_CreateOrderTest {
    
    @testSetup static void setup() {

        SF_TestDataFactory.insertQuoteData();     
    }

    @IsTest
    static void createOrderTest(){
       
        SF_Quote__c quote = [SELECT Id, SF_Status__c FROM SF_Quote__c order by CreatedDate LIMIT 1];
        SF_Quote__c updateQuote = new SF_Quote__c();
        updateQuote.Id = quote.Id;
        updateQuote.SF_Status__c = 'Accepted';
        
        update updateQuote;

        List<SF_Order__c> checkOrder = [SELECT Id FROM SF_Order__c WHERE SF_Quote__c =: quote.Id];
        List<SF_Order_Product__c> checkOrderProduct = [SELECT Id FROM SF_Order_Product__c WHERE SF_Order__c IN: checkOrder];
        
        system.assert(checkOrder != null, true);
        system.assert(checkOrderProduct != null, true);
      
    }
}