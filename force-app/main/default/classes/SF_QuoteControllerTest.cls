@isTest
public class SF_QuoteControllerTest {

    @TestSetup
    static void makeData(){

        SF_Price_List__c testPL = SF_TestDataFactory.createPriceList();
        insert testPL;

        Account testAcc = SF_TestDataFactory.createAccount(testPL);
        insert testAcc;

        Opportunity testOpp = SF_TestDataFactory.createOpportunity(testAcc);
        insert testOpp;

        Contact testCon = SF_TestDataFactory.createContact(testAcc);
        insert testCon;

        SF_Quote__c testQuote = SF_TestDataFactory.createQuote(testAcc, testOpp, testCon);
        insert testQuote;

        Product2 testProduct = SF_TestDataFactory.createProduct();
        insert testProduct;

        Product2 testProduct2 = SF_TestDataFactory.createProduct2();
        insert testProduct2;

        Product2 testProduct3 = SF_TestDataFactory.createProduct3();
        insert testProduct3;

        Product2 testOptionProduct = SF_TestDataFactory.createOptionProduct(testProduct);
        insert testOptionProduct;

        SF_Price_List_Item__c testPriceListItem = SF_TestDataFactory.createPriceListItem(testProduct, testPL);
        insert testPriceListItem;  

        SF_Price_List_Item__c testPriceListItem2 = SF_TestDataFactory.createPriceListItem(testProduct2, testPL);
        insert testPriceListItem2; 
        
        SF_Price_List_Item__c testPriceListItem3 = SF_TestDataFactory.createPriceListItem(testProduct3, testPL);
        insert testPriceListItem3; 

        SF_Price_List_Item__c testOptionPriceListItem = SF_TestDataFactory.createPriceListItem(testOptionProduct, testPL);
        insert testOptionPriceListItem; 
    }
    
    //@author: L.Mikatsadze
    //@description: Tests creating of quote with default quote line items.
    @isTest
    public static void test_createQuote(){
        List<Account> testAcc = [SELECT Id, SF_Price_List__c FROM Account WHERE Name = 'TestAccount'];
        List<Opportunity> testOpp = [SELECT Id, SF_Price_List__c FROM Opportunity WHERE AccountId =:testAcc[0].Id];
        
        SF_QuoteController.createQuote(testOpp[0].Id);

        List<SF_Quote__c> quote = [SELECT Id FROM SF_Quote__c WHERE SF_Opportunity__c =:testOpp[0].Id AND SF_Status__c = 'Draft'];
        List<SF_Quote_Line_Item__c> qlis = [SELECT Id, SF_Quote__c FROM SF_Quote_Line_Item__c WHERE SF_Quote__c =:quote[0].Id];
        List<SF_Quote__c> appQuote = [SELECT Id FROM SF_Quote__c WHERE SF_Opportunity__c =:testOpp[0].Id AND SF_Status__c = 'Approved'];

        System.assert(quote.size() == 1 && qlis.size() == 3, 'Quote was not created');
    }

    //@author: L.Mikatsadze
    //@description: Tests getting quote line item's field labels from custom metadata.
    @isTest
    public static void test_getQuoteLineItemFieldNames() {
        System.assert((SF_QuoteController.getQuoteLineItemFieldNames()).size() > 0, 'Field Labels Not Found');
    }

    //@author: L.Mikatsadze
    //@description: Tests getting quote line item's field types from custom metadata.
    @isTest
    public static void test_getQuoteLineItemFieldTypes() {
        System.assert((SF_QuoteController.getQuoteLineItemFieldTypes()).size() > 0, 'Field Types Not Found');
    }

    //@author: L.Mikatsadze
    //@description: Tests getting created quote line items.
    @isTest
    public static void test_getQuoteLineItems() {
        List<Account> testAcc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        List<Opportunity> testOpp = [SELECT Id, SF_Price_List__c FROM Opportunity WHERE AccountId =:testAcc[0].Id];
        List<Product2> testProduct = [SELECT Id FROM Product2 WHERE Name = 'Macbook Pro'];
        List<SF_Quote__c> testQuote = [SELECT Id FROM SF_Quote__c WHERE SF_Opportunity__c =:testOpp[0].Id AND SF_Status__c = 'Approved'];
        List<SF_Price_List_Item__c> testPLI = [SELECT Id, Product__c FROM SF_Price_List_Item__c WHERE Product__c = :testProduct[0].Id];

        SF_Quote_Line_Item__c testQli = SF_TestDataFactory.createQliBundle(testPLI[0], testQuote[0]);
   
        Test.startTest();
            insert testQli;
        Test.stopTest();
  
        System.assert(((SF_QuoteController.getQuoteLineItems(testQuote[0].Id)).fields).size() > 0 && 
                        ((SF_QuoteController.getQuoteLineItems(testQuote[0].Id)).qlis).size() == 1, 'Quote Line Items or Fields Not Found');
    }

    //@author: L.Mikatsadze
    //@description: Tests getting price list items by quote id.
    @isTest
    public static void test_getPriceListItemsByQuoteId() {
        List<Account> testAcc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        List<Opportunity> testOpp = [SELECT Id, SF_Price_List__c FROM Opportunity WHERE AccountId =:testAcc[0].Id];
        List<Contact> testCon = [SELECT Id FROM Contact WHERE AccountId =: testAcc[0].Id];

        SF_Quote__c testQuote = SF_TestDataFactory.createQuote(testAcc[0], testOpp[0], testCon[0]);
        
        Test.startTest();
            insert testQuote;
        Test.stopTest();
        
        System.assert((SF_QuoteController.getPriceListItemsByQuoteId(testQuote.Id)).size() > 0, 'Price List Items Not Found');
    }

    // @author: L.Mikatsadze
    // @description: Tests getting products by quote id.
    @isTest
    public static void test_getProductsByQuoteId() {
        List<Account> testAcc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        List<Opportunity> testOpp = [SELECT Id, SF_Price_List__c FROM Opportunity WHERE AccountId =:testAcc[0].Id];
        List<Contact> testCon = [SELECT Id FROM Contact WHERE AccountId =:testAcc[0].Id];
    
        SF_Quote__c testNewQuote = SF_TestDataFactory.createQuote(testAcc[0], testOpp[0], testCon[0]);

        Test.startTest();
            insert testNewQuote;
        Test.stopTest();

        System.assert((SF_QuoteController.getProductsByQuoteId(testNewQuote.Id)).size() > 0, 'Products Not Found');
    }
}