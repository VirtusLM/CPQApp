/*
* ============================================
* @apexClassName: SF_PostInvoiceBatch.cls
* @description: Class contains batch method to post invoice
* @author: G.Tvaliashvili
* @email: givi.tvaliashvili@makingscience.com
* @dateCreated: 06/07/2022
* @lastChange: 06/07/2022 by G.Tvaliashvili
* ============================================
*/


public with sharing class SF_PostInvoiceBatch implements Database.Batchable<sObject>, schedulable{
    
    // getting data of invoices whose status are draft and invoice date equals tomorrow
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Invoice_Posted_Date__c, Status__c FROM SF_Invoice__c WHERE Status__c = 'Draft' 
                                         AND Invoice_Date__c <=: system.today().addDays(1)]);
               
    }
    
    // updating invoice status to posted
    public void execute(Database.BatchableContext bc, List<SF_Invoice__c> sc){
        
        for(SF_Invoice__c invoice : sc){
            invoice.Invoice_Posted_Date__c = system.today();
            invoice.Status__c = 'Posted';
        }
        
        update sc;
        
    // updating invoice line items status to posted

        List<SF_Invoice_Line__c> lineItems = [SELECT Status__c FROM SF_Invoice_Line__c WHERE SF_Invoice__c IN: sc];
        for(SF_Invoice_Line__c il : lineItems){
            il.Status__c = 'Posted';
        }        
        
        update lineItems;
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    // method to run schedulable apex
    public void execute(SchedulableContext sc){
        SF_PostInvoiceBatch pi = new SF_PostInvoiceBatch();
        Database.executeBatch(pi);
    }
    
}