@isTest
public class SF_QuoteLineItemControllerTest {

    @isTest
    public static void test_createQuoteLineItems() {

        SF_Quote__c testQuote = SF_TestDataFactory.insertQuoteData();
        List<SF_QuoteLineItemController.ProductWrapper> testWrappers = SF_TestDataFactory.productWrappperData();
       
        SF_QuoteLineItemController.createQuoteLineItems(testWrappers, testQuote.Id);
        List<SF_Quote_Line_Item__c> testQlis = [SELECT Id FROM SF_Quote_Line_Item__c WHERE SF_Quote__c =:testQuote.Id];

        System.assert(testQlis.size() > 2, 'Quote Line Items were not created');
    }


    @isTest
    public static void test_cloneQuoteLineItems() {

        Account testAcc = SF_TestDataFactory.inserAccountsWithOppsAndContacts();
        SF_Quote__c testQuote = [SELECT Id FROM SF_Quote__c WHERE SF_Account__c =:testAcc.Id LIMIT 1];
        List<SF_Quote_Line_Item__c> qliList = SF_TestDataFactory.insertQuoteLineItems();

        SF_QuoteLineItemController.cloneQuoteLineItems(qliList, testQuote.Id);
        List<SF_Quote_Line_Item__c> testQlis = [SELECT Id FROM SF_Quote_Line_Item__c WHERE SF_Quote__c =:testQuote.Id];

        System.assert(testQlis.size() > 1, 'Quote Line Items were not created');

    }

}
