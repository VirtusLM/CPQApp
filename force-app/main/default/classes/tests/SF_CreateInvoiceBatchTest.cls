/*
* ============================================
* @apexClassName: SF_CreateInvoiceBatchTest.cls
* @description: Class contains tests for create invoice class
* @author: G.Tvaliashvili
* @email: givi.tvaliashvili@makingscience.com
* @dateCreated: 06/07/2022
* @lastChange: 06/07/2022 by G.Tvaliashvili
* ============================================
*/
@isTest
public class SF_CreateInvoiceBatchTest {
    
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

        Test.startTest();
        SF_Quote__c updateQuote = new SF_Quote__c();
        updateQuote.Id = testQuote.Id;
        updateQuote.SF_Status__c = 'Accepted';
        update updateQuote;
        List<Id> quoteId = new List<Id>();
        quoteId.add(updateQuote.Id);
        SF_CreateOrder.createOrder(quoteId);
        Test.stopTest();
    }
    
    @isTest
    public static void createInvoiceTest(){
        
        List<Account> testAcc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        List<Opportunity> testOpp = [SELECT Id FROM Opportunity WHERE AccountId =:testAcc[0].Id];
        List<Contact> testCon = [SELECT Id FROM Contact WHERE AccountId =:testAcc[0].Id];
        List<SF_Quote__c> testQuote = [SELECT Id FROM SF_Quote__c WHERE SF_Account__c =:testAcc[0].Id 
                                        AND SF_Opportunity__c =:testOpp[0].Id AND SF_Contact__c =:testCon[0].Id]; 
        
        List<SF_Order__c> newOrder = [SELECT Id FROM SF_Order__c WHERE SF_Quote__c =: testQuote[0].Id];
        
        Test.startTest();
		SF_CreateInvoiceBatch M = new SF_CreateInvoiceBatch();
		Database.executeBatch(M);
        Test.stopTest();
        
        List<SF_Invoice__c> invoice = [SELECT Id, SF_Order__c FROM SF_Invoice__c WHERE SF_Order__c =: newOrder[0].Id];
        system.assert(invoice.size()>0, 'No invoices found');
    }
    
}