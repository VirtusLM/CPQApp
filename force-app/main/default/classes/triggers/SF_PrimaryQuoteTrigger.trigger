trigger SF_PrimaryQuoteTrigger on SF_Quote__c (before insert, before update, before delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            SF_PrimaryQuoteTriggerHandler.insertFired = true;
            SF_PrimaryQuoteTriggerHandler.validatePrimaryQuote(Trigger.new, true, false, false, Trigger.old);
        } else if(Trigger.isUpdate){
            if(SF_PrimaryQuoteTriggerHandler.insertFired){
                SF_PrimaryQuoteTriggerHandler.insertFired = false;
            }else if(SF_PrimaryQuoteTriggerHandler.updateFired){
                SF_PrimaryQuoteTriggerHandler.updateFired = false;
            } else {
                SF_PrimaryQuoteTriggerHandler.updateFired = true;
                SF_PrimaryQuoteTriggerHandler.validatePrimaryQuote(Trigger.new, false, true, false, Trigger.old);
            }
        } else if(Trigger.isDelete){
            SF_PrimaryQuoteTriggerHandler.validatePrimaryQuote(Trigger.old, false, false, true, Trigger.old);
        }
    }
}