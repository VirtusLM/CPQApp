@isTest
public class SF_QuoteLineItemControllerTest {

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

        SF_Quote_Line_Item__c testQliBundle = SF_TestDataFactory.createQliBundle(testPriceListItem, testQuote);
        insert testQliBundle;

        SF_Quote_Line_Item__c testQliOption = SF_TestDataFactory.createQliOption(testPriceListItem, testQuote);
        insert testQliOption;
    }
    
    //@author: L.Mikatsadze
    //@description: Tests creating of quote line items.
    @isTest
    public static void test_createQuoteLineItems() {

        List<Account> testAcc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        List<Opportunity> testOpp = [SELECT Id FROM Opportunity WHERE AccountId =:testAcc[0].Id];
        List<Contact> testCon = [SELECT Id FROM Contact WHERE AccountId =:testAcc[0].Id];
        List<Product2> testProduct = [SELECT Id FROM Product2 WHERE Name ='Macbook Pro'];
        List<SF_Quote__c> testQuote = [SELECT Id FROM SF_Quote__c WHERE SF_Account__c =:testAcc[0].Id 
                                        AND SF_Opportunity__c =:testOpp[0].Id AND SF_Contact__c =:testCon[0].Id];

        List<SF_Price_List__c> testPriceList = [SELECT Id FROM SF_Price_List__c WHERE Name ='USD Price List'];
        List<SF_Price_List_Item__c> testPriceListItem = [SELECT Id, Base_Price__c, Product__c FROM SF_Price_List_Item__c 
                                                WHERE Price_List__c =:testPriceList[0].Id AND Product__c =:testProduct[0].Id];
        
        List<SF_QuoteLineItemController.ProductWrapper> testWrappers = SF_TestDataFactory.productWrapperData(testPriceListItem[0]);
       
        SF_QuoteLineItemController.createQuoteLineItems(testWrappers, testQuote[0].Id);

        List<SF_Quote_Line_Item__c> testQlis = [SELECT Id FROM SF_Quote_Line_Item__c WHERE SF_Quote__c =:testQuote[0].Id];

        System.assert(testQlis.size() == 4, 'Quote Line Items were not created');
    }

    //@author: L.Mikatsadze
    //@description: Tests cloning of quote line items.
    @isTest
    public static void test_cloneQuoteLineItems() {

        List<Account> testAcc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        List<Opportunity> testOpp = [SELECT Id FROM Opportunity WHERE AccountId =:testAcc[0].Id];
        List<Contact> testCon = [SELECT Id FROM Contact WHERE AccountId =:testAcc[0].Id];
        List<Product2> testProduct = [SELECT Id FROM Product2 WHERE Name ='Macbook Pro'];
        List<SF_Quote__c> testQuote = [SELECT Id FROM SF_Quote__c WHERE SF_Account__c =:testAcc[0].Id 
                                        AND SF_Opportunity__c =:testOpp[0].Id AND SF_Contact__c =:testCon[0].Id];

        List<SF_Price_List__c> testPriceList = [SELECT Id FROM SF_Price_List__c WHERE Name ='USD Price List'];
        List<SF_Price_List_Item__c> testPriceListItem = [SELECT Id, Base_Price__c, Product__c FROM SF_Price_List_Item__c 
                                                            WHERE Price_List__c =:testPriceList[0].Id AND Product__c =:testProduct[0].Id];

         List<SF_Quote_Line_Item__c> testQlisList = new List<SF_Quote_Line_Item__c>();

        SF_Quote_Line_Item__c testQliBundle = [SELECT Id, Name, SF_Product__c, SF_Total_Price__c, SF_Subtotal__c, SF_Quantity__c, 
                                                        SF_Discount__c, CurrencyIsoCode, SF_Is_Bundle__c, SF_Price_List_Item__c 
                                                        FROM SF_Quote_Line_Item__c WHERE SF_Product__c =:testPriceListItem[0].Product__c 
                                                        AND SF_Price_List_Item__c =:testPriceListItem[0].Id AND SF_Is_Bundle__c = true LIMIT 1];
        testQlisList.add(testQliBundle);

        SF_Quote_Line_Item__c testQliOption = [SELECT Id, Name, SF_Product__c, SF_Total_Price__c, SF_Subtotal__c, SF_Quantity__c, 
                                                        SF_Discount__c, CurrencyIsoCode, SF_Is_Bundle__c, SF_Price_List_Item__c 
                                                        FROM SF_Quote_Line_Item__c WHERE SF_Product__c =:testPriceListItem[0].Product__c 
                                                        AND SF_Price_List_Item__c =:testPriceListItem[0].Id AND SF_Is_Bundle__c = false LIMIT 1];
        testQlisList.add(testQliOption);
       
        SF_QuoteLineItemController.cloneQuoteLineItems(testQlisList, testQuote[0].Id);

        Set<String> qlisNames = new Set<String>();
        for(SF_Quote_Line_Item__c qli : testQlisList) {
            qlisNames.add(qli.Name);
        }
        List<SF_Quote_Line_Item__c> testQlis = [SELECT Id, Name FROM SF_Quote_Line_Item__c WHERE SF_Quote__c =:testQuote[0].Id AND Name IN :qlisNames];

        System.assert(testQlis.size() == 4, 'Quote Line Items were not created');

    }
}