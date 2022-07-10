public class SF_CountInvoiceTriggerHelper {
    public static void countInvoice(List<SF_Invoice__c> invoices){

        Map<Id, List<SF_Invoice__c>> orderInvoice = new Map<Id, List<SF_Invoice__c>>();

        List<SF_Order__c> orders = new List<SF_Order__c>();

        for(SF_Invoice__c i : invoices){
            if(orderInvoice.containsKey(i.SF_Order__c)){
                orderInvoice.get(i.SF_Order__c).add(i);
            }else{
                orderInvoice.put(i.SF_Order__c, new List<SF_Invoice__c>{i});
            }
        }

        for(Id o : orderInvoice.keySet()){
            SF_Order__c order = new SF_Order__c();
            order.Id = o;
            order.No_Invoices__c = orderInvoice.get(o).size();
            orders.add(order);
        }

        update orders;



    }
}