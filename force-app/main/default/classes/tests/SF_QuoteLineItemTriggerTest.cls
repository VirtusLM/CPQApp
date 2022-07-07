@isTest
public class SF_QuoteLineItemTriggerTest {

    //@author: L.Mikatsadze
    //@description: Tests before insert trigger on quote line items.
    @isTest
    public static void test_SF_QuoteLineItemTrigger(){
        Account accts = SF_TestDataFactory.inserAccountsWithOppsAndContacts();
        SF_Price_List_Item__c plis = SF_TestDataFactory.insertPLIWithProductAndPriceList();

        List<Account> testAcc = [SELECT Id FROM Account WHERE Name ='TestAccount'];
        List<SF_Quote__c> testQuote = [SELECT Id FROM SF_Quote__c WHERE SF_Account__c =:testAcc[0].Id];
        List<Product2> testProduct = [SELECT Id FROM Product2 WHERE Name ='TestProduct'];
        List<SF_Price_List__c> testPriceList = [SELECT Id FROM SF_Price_List__c WHERE Name ='USD_Price_List'];
        List<SF_Price_List_Item__c> testPLI = [SELECT Id, Base_Price__c FROM SF_Price_List_Item__c 
                                                WHERE Price_List__c =:testPriceList[0].Id AND Product__c =:testProduct[0].Id];

        SF_Quote_Line_Item__c testQLI = new SF_Quote_Line_Item__c(
            Name = 'TestQLI',
            SF_Quote__c = testQuote[0].Id,
            SF_Product__c = testProduct[0].Id,
            SF_Price_List_Item__c = testPLI[0].Id
        );
        Test.startTest();
            insert testQLI;
        Test.stopTest();

        List<SF_Quote_Line_Item__c> testQLI2 = [SELECT Id FROM SF_Quote_Line_Item__c 
                                                WHERE Name ='TestProduct'];
        
        System.assert(testQLI2.size() > 0, 'Quote Line Item was not created');
    }
}