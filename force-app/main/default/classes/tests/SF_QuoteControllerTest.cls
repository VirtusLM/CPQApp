@isTest
public class SF_QuoteControllerTest {

    //@author: L.Mikatsadze
    //@description: Tests creating of quote.
    @isTest
    static void test_createQuote(){
        Account accts = SF_TestDataFactory.inserAccountsWithOppsAndContacts();
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Name ='TestOpp' LIMIT 1];
        SF_QuoteController.createQuote(opp[0].Id);
        List<SF_Quote__c> quote = [SELECT Id FROM SF_Quote__c WHERE SF_Opportunity__c =:opp[0].Id LIMIT 1];
        System.assert(quote.size() > 0, 'Quote was not created');
    }
}