/*
* ============================================
* @apexClassName: SF_CloneQuoteTest.cls
* @description: Class contains tests of cloning quote
* @author: G.Tvaliashvili
* @email: givi.tvaliashvili@makingscience.com
* @dateCreated: 22/06/2022
* @lastChange: 23/06/2022 by G.Tvaliashvili
* ============================================
*/

@IsTest
public class SF_CloneQuoteTest {
    
    // test of clone quote without quote line items
    @isTest
    static void cloneQuoteTest(){
        SF_TestDataFactory.insertQuoteData();        
        List<SF_Quote__c> oldQuote = [SELECT Id, Name FROM SF_Quote__c order by CreatedDate desc LIMIT 1];
        SF_CloneQuote.cloneQuote(oldQuote[0].Id, false);
        List<SF_Quote__c> newQuote = [SELECT Id, Name FROM SF_Quote__c order by CreatedDate desc LIMIT 1];
        system.assert(oldQuote[0].Name == newQuote[0].Name, true);
        system.assert(oldQuote[0].SF_Quote_Line_Items__r == newQuote[0].SF_Quote_Line_Items__r, false);
    }
    
    // test of clone quote with quote line items
    @isTest
    static void cloneQuoteQLITest(){
        SF_TestDataFactory.insertQuoteData();        
        List<SF_Quote__c> oldQuote = [SELECT Id, Name FROM SF_Quote__c order by CreatedDate desc LIMIT 1];
        SF_CloneQuote.cloneQuote(oldQuote[0].Id, true);
        List<SF_Quote__c> newQuote = [SELECT Id, Name FROM SF_Quote__c order by CreatedDate desc LIMIT 1];
        system.assert(oldQuote[0].Name == newQuote[0].Name, true);
        system.assert(oldQuote[0].SF_Quote_Line_Items__r == newQuote[0].SF_Quote_Line_Items__r, true);
    }
}