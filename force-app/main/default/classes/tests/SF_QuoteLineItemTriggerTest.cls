@isTest
public class SF_QuoteLineItemTriggerTest {

    @TestSetup
    static void makeData(){

        SF_Price_List__c testPriceList = SF_TestDataFactory.createPriceList();
        insert testPriceList;

        Account testAcc = SF_TestDataFactory.createAccount(testPriceList);
        insert testAcc;

        Opportunity testOpp = SF_TestDataFactory.createOpportunity(testAcc);
        insert testOpp;

        Contact testCon = SF_TestDataFactory.createContact(testAcc);
        insert testCon;

        SF_Quote__c testQuote = SF_TestDataFactory.createQuote(testAcc, testOpp, testCon);
        insert testQuote;

        Product2 testProduct = SF_TestDataFactory.createProduct();
        insert testProduct;

        SF_Price_List_Item__c testPriceListItem = SF_TestDataFactory.createPriceListItem(testProduct, testPriceList);
        insert testPriceListItem;  
    }

    //@author: L.Mikatsadze
    //@description: Tests before insert trigger on quote line items.
    @isTest
    public static void test_SF_QuoteLineItemTrigger(){

        List<Account> testAcc = [SELECT Id FROM Account WHERE Name ='TestAccount'];
        List<SF_Quote__c> testQuote = [SELECT Id FROM SF_Quote__c WHERE SF_Account__c =:testAcc[0].Id];
        List<Product2> testProduct = [SELECT Id FROM Product2 WHERE Name ='Macbook Pro'];
        List<SF_Price_List__c> testPriceList = [SELECT Id FROM SF_Price_List__c WHERE Name ='USD Price List'];
        List<SF_Price_List_Item__c> testPriceListItem = [SELECT Id, Base_Price__c, Product__c FROM SF_Price_List_Item__c 
                                                WHERE Price_List__c =:testPriceList[0].Id AND Product__c =:testProduct[0].Id];

        SF_Quote_Line_Item__c testQLI = SF_TestDataFactory.createQliBundle(testPriceListItem[0], testQuote[0]);

        Test.startTest();
            insert testQLI;
        Test.stopTest();

        List<SF_Quote_Line_Item__c> testQLI2 = [SELECT Id FROM SF_Quote_Line_Item__c 
                                                WHERE Name ='Macbook Pro'];
                                                
        System.assert(testQLI2.size() > 0, 'Quote Line Item was not created');
    }
}