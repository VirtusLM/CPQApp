@isTest
public class SF_QuoteLineItemControllerTest {

    @isTest
    public static void test_createQuoteLineItems() {

        SF_Quote__c testQuote = SF_TestDataFactory.insertQuoteData();
        SF_Price_List_Item__c testPLI = SF_TestDataFactory.insertPLIWithProductAndPriceList();

        SF_QuoteLineItemController.ProductWrapper testWrap = new SF_QuoteLineItemController.ProductWrapper(); 

    }
        
    

}
