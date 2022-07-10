trigger SF_CountInvoiceTrigger on SF_Invoice__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        SF_CountInvoiceTriggerHelper.countInvoice(Trigger.new);
    }
}