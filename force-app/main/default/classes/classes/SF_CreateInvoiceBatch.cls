public with sharing class SF_CreateInvoiceBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('teeest11');
        return Database.getQueryLocator([SELECT Id, Name, CurrencyIsoCode, Opportunity__c, Account__c, Order_Amount__c, NO_Invoices__c FROM SF_Order__c
             WHERE Active__c = true AND NO_Invoices__c = 0]);
               
    }
    
    public void execute(Database.BatchableContext bc, List<SF_Order__c> sc){
        system.debug('teeest');
        Map<Id, SF_Invoice__c> invoiceMap = new Map<Id, SF_Invoice__c>();
        for(SF_Order__c order : sc){
            SF_Invoice__c invoice = new SF_Invoice__c();
            invoice.CurrencyIsoCode = order.CurrencyIsoCode;
            invoice.SF_Order__c = order.Id;
            invoice.Account__c = order.Account__c;
            invoice.Invoice_Date__c = System.today();
            invoice.Balance__c = order.Order_Amount__c;
            invoice.Status__c = 'Draft';
            order.No_Invoices__c++;
        	invoiceMap.put(order.Id, invoice);
        }
        if(invoiceMap.size()>0){
            insert invoiceMap.values();
            update sc;
        }
        
        system.debug(invoiceMap);
        
        List<SF_Order_Product__c> orderProducts = [SELECT Id, Name, SF_Order__c, Total_Price__c, CurrencyIsoCode,
                                                  Product__c FROM SF_Order_Product__c WHERE SF_Order__c IN: sc];
        List<SF_Invoice_Line__c> invoiceLineItems = new List<SF_Invoice_Line__c>();
        for(SF_Order_Product__c op: orderProducts){
            SF_Invoice_Line__c invoiceLine = new SF_Invoice_Line__c();
            invoiceLine.CurrencyIsoCode = op.CurrencyIsoCode;
            invoiceLine.SF_Invoice__c = invoiceMap.get(op.SF_Order__c).Id;
            invoiceLine.Start_Date__c = system.today();
            invoiceLine.End_Date__c = system.today().addDays(30);
            invoiceLine.Invoice_Amount__c = op.Total_Price__c;
            //invoiceLine.Product__c = op.Id;
            
            invoiceLineItems.add(invoiceLine);
        }
        if(invoiceLineItems.size()>0){
            insert invoiceLineItems;
        }
        
                system.debug(invoiceLineItems);

        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
}