/*
* ============================================
* @apexTriggerName: SF_QuoteLineItemTrigger.trigger
* @description: Before insert trigger on SF_Quote_Line_Item__c object.
* @author: L.Mikatsadze
* @email: l.mikatsadze@makingscience.com
* @handlerClass: SF_QuoteLineItemTriggerHandler.cls
* @testClass: SF_QuoteLineItemTriggerTest.cls
* @dateCreated: 25/05/2022
* @lastChange: 26/05/2022 by L.Mikatsadze
* ============================================
*/
trigger SF_QuoteLineItemTrigger on SF_Quote_Line_Item__c (before insert) {
	
    if (Trigger.isBefore && Trigger.isInsert) {
        SF_QuoteLineItemTriggerHandler.defineQuoteLineItemValues(Trigger.new);
    }	
}