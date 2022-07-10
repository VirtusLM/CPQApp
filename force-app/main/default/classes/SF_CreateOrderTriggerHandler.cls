public with sharing class SF_CreateOrderTriggerHandler {
    public static void createOrder(List<SF_Quote__c> quoteId, List<SF_Quote__c> oldQuote){

            List<SF_Order__c> orderList = new List<SF_Order__c>();
            List<SF_Order_Product__c> orderProductList = new List<SF_Order_Product__c>();
            Map<Id, SF_Order__c> quoteMap = new Map<Id, SF_Order__c>();
    
            List<SF_Quote__c> quotes = [SELECT SF_Account__c, SF_Billing_Country__c, 
                                        SF_Billing_Postal_Code__c, SF_Billing_State__c, SF_Billing_Street__c,
                                        SF_Contact__c, CurrencyIsoCode,SF_Total_Price__c, NO_Line_Items__c,
                                        SF_Opportunity__c, SF_Price_List__c, SF_Shipping_Country__c, 
                                        SF_Shipping_Postal_Code__c FROM SF_Quote__c WHERE Id IN: quoteId];
    
            List<SF_Quote_Line_Item__c> qlis = [SELECT Id, Name, SF_Quantity__c, SF_Product__c,
                                                SF_Price_List_Item__c, SF_Total_Price__c, SF_Unit_Price__c FROM SF_Quote_Line_Item__c WHERE SF_Quote__c IN: quoteId];
    
            for(SF_Quote__c quote : quotes ){
                SF_Order__c order = new SF_Order__c();
                order.Account__c = quote.SF_Account__c;
                order.Activated_Date__c = system.today();
                order.Active__c = true;
                order.Billing_Country__c = quote.SF_Billing_Country__c;
                order.Billing_Postal_Code__c = quote.SF_Billing_Postal_Code__c;
                order.Billing_State__c = quote.SF_Billing_State__c;
                order.Billing_Street__c = quote.SF_Billing_Street__c;
                order.Contact__c = quote.SF_Contact__c;
                order.CurrencyIsoCode = quote.CurrencyIsoCode;
                order.Opportunity__c = quote.SF_Opportunity__c;
                order.Order_Amount__c = quote.SF_Total_Price__c;
                order.Order_Start_Date__c = system.today();
                order.SF_Quote__c = quote.Id;
                order.Shipping_Country__c = quote.SF_Shipping_Country__c;
                order.Shipping_Postal_Code__c = quote.SF_Shipping_Postal_Code__c;
                order.Status__c = 'Activated';
    
                orderList.add(order);
                quoteMap.put(quote.Id, order);
            }
            insert orderList;
    
            if(qlis.size()>0){
                for(SF_Quote__c quote : quotes){
                    SF_Order__c order = quoteMap.get(quote.Id);

                        for(SF_Quote_Line_Item__c qli : qlis){
                            SF_Order_Product__c newProduct = new SF_Order_Product__c();
                            newProduct.SF_Order__c = order.Id;
                            newProduct.Product__c = qli.SF_Product__c;
                            newProduct.Quantity__c = qli.SF_Quantity__c;
                            newProduct.SF_Quote_Line_Item__c = qli.Id;
                            newProduct.Start_Date__c = order.Order_Start_Date__c.date();
                            newProduct.End_Date__c = order.Order_End_Date__c.date();
                            newProduct.Total_Price__c = qli.SF_Total_Price__c;
                            newProduct.Unit_Price__c = qli.SF_Unit_Price__c;
                            newProduct.Status__c = 'Activated';
                            
                            orderProductList.add(newProduct);
                        }
                    
                }
            }
            insert orderProductList;
        }

}