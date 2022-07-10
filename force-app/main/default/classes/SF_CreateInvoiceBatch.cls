/*
* ============================================
* @apexClassName: SF_CreateInvoiceBatch.cls
* @description: Class contains batch method to create invoice
* @author: G.Tvaliashvili
* @email: givi.tvaliashvili@makingscience.com
* @dateCreated: 03/07/2022
* @lastChange: 06/07/2022 by G.Tvaliashvili
* ============================================
*/


public with sharing class SF_CreateInvoiceBatch implements Database.Batchable<sObject>, schedulable{
    
    // getting data of order which has active status and dont contains any invoices
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Name, CurrencyIsoCode, Opportunity__r.Name, Account__c, Order_Amount__c, NO_Invoices__c FROM SF_Order__c
             WHERE Active__c = true AND NO_Invoices__c = 0]);
               
    }
    
    // creating invoice and invoice line items
    public void execute(Database.BatchableContext bc, List<SF_Order__c> sc){
        
        // creating invoice
        Map<Id, SF_Invoice__c> invoiceMap = new Map<Id, SF_Invoice__c>();
        for(SF_Order__c order : sc){
            SF_Invoice__c invoice = new SF_Invoice__c();
            invoice.CurrencyIsoCode = order.CurrencyIsoCode;
            invoice.SF_Order__c = order.Id;
            invoice.Account__c = order.Account__c;
            invoice.Invoice_Date__c = System.today().addDays(1);
            invoice.Balance__c = order.Order_Amount__c;
            invoice.Opportunity_Name__c = order.Opportunity__r.Name;
            invoice.Status__c = 'Draft';
        	invoiceMap.put(order.Id, invoice);
        }
        // after insert updating order data
        if(invoiceMap.size()>0){
            insert invoiceMap.values();
        }
        
        // creating invoice line items      
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
            invoiceLine.Product__c = op.Product__c;
            
            invoiceLineItems.add(invoiceLine);
        }
        if(invoiceLineItems.size()>0){
            insert invoiceLineItems;
        }
        
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    // method to run schedulable apex
    public void execute(SchedulableContext sc){
        SF_CreateInvoiceBatch ci = new SF_CreateInvoiceBatch();
        Database.executeBatch(ci);
    }
    
}