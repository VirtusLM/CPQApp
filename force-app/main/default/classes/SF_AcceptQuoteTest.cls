/*
* ============================================
* @apexClassName: SF_AcceptQuoteTest.cls
* @description: Class contains tests of accept quote class
* @author: G.Tvaliashvili
* @email: givi.tvaliashvili@makingscience.com
* @dateCreated: 26/06/2022
* @lastChange: 26/06/2022 by G.Tvaliashvili
* ============================================
*/

@IsTest
public class SF_AcceptQuoteTest {
    @IsTest
    static void acceptQuoteTest1(){
        SF_TestDataFactory.insertQuoteData();
        List<SF_Quote__c> quote = [SELECT Id, SF_Status__c FROM SF_Quote__c order by CreatedDate desc LIMIT 1];
        SF_AcceptQuote.acceptQuote(quote[0].Id);
        List<SF_Quote__c> updatedQuote = [SELECT SF_Status__c FROM SF_Quote__c WHERE Id =: quote[0].Id];
        system.assert(updatedQuote[0].SF_Status__c == 'Accepted', true);
    }
}