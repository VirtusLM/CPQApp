/*
* ============================================
* @apexClassName: SF_CloneQuote.cls
* @description: Class contains tests of cloning quote
* @author: G.Tvaliashvili
* @email: givi.tvaliashvili@makingscience.com
* @dateCreated: 22/06/2022
* @lastChange: 23/06/2022 by G.Tvaliashvili
* ============================================
*/

public class SF_CloneQuote {
    /*
        @description: method for cloning quote with or without quote line items
    */ 
    @auraenabled
    public static List<SF_Quote__c> cloneQuote(Id quoteId, Boolean withQLI){

        // getting fields from metadata 
        Quote_Quote_Line_Items__mdt[] fields = [SELECT Fields__c, QualifiedApiName FROM Quote_Quote_Line_Items__mdt];
        
        Set<String> quoteFields = new Set<String>();
        Set<String> qliFields = new Set<String>();

        for(Quote_Quote_Line_Items__mdt quoteField: fields){
            if(quoteField.QualifiedApiName == 'Quote'){
                quoteFields.addAll(quoteField.Fields__c.split(','));
            }
            else if(quoteField.QualifiedApiName == 'Quote_Line_Items'){
                qliFields.addAll(quoteField.Fields__c.split(','));
            }
        }

        String joinedQuoteFields = String.join(new List<String>(quoteFields), ',');
        String joinedQliFields = String.join(new List<String>(qliFields), ',');
        
        // getting data from quote and quote line items 

        SF_Quote__c currentQuote = Database.query('Select ' + joinedQuoteFields + ' From SF_Quote__c WHERE Id =:quoteId');
        List<SF_Quote_Line_Item__c> currentQLI = Database.query('Select ' + joinedQliFields + ' From SF_Quote_Line_Item__c WHERE SF_Quote__c =:quoteId');

        // creating new quote 
        SF_Quote__c createNewQuote = new SF_Quote__c();

        for(String field : quoteFields){
            createNewQuote.put(field, currentQuote.get(field));
        }

        insert createNewQuote;


        List<SF_Quote_Line_Item__c> createNewQLI = new List<SF_Quote_Line_Item__c>();

        // checking if user wants to clone quote line items  

        if(withQLI == true){

            // cloning quote line items 

            for(SF_Quote_Line_Item__c qli: currentQLI ){
                SF_Quote_Line_Item__c newQLI = new SF_Quote_Line_Item__c();
                    
                for(String field : qliFields){
                    newQLI.put(field, qli.get(field));
                }
                createNewQLI.add(newQLI);
                newQLI.SF_Quote__c = createNewQuote.Id;
            }

            insert createNewQLI;
            
        } 
        return new List<SF_Quote__c> {createNewQuote};
    }
}