/*
* ============================================
* @apexClassName: SF_AcceptQuote.cls
* @description: with this method user can accept and finalize quote
* @author: G.Tvaliashvili
* @email: givi.tvaliashvili@makingscience.com
* @dateCreated: 26/06/2022
* @lastChange: 27/06/2022 by G.Tvaliashvili
* ============================================
*/

public class SF_AcceptQuote {

/*  
    @author: G.tvaliashvili
    @description: setting quote status to accepted
*/
    @AuraEnabled
    public static void acceptQuote (Id quoteId){
        List<SF_Quote_Line_Item__c> quoteLineItems = [SELECT Id, SF_Quote__c FROM SF_Quote_Line_Item__c WHERE SF_Quote__c =: quoteId];
        if(quoteLineItems.size() > 0){
        	SF_Quote__c quote = new SF_Quote__c();
        	quote.Id = quoteLineItems[0].SF_Quote__c;
        	quote.SF_Status__c = 'Accepted';
        	update quote;
        } 
    }
}