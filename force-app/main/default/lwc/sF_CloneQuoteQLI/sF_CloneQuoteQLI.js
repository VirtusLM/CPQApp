import { LightningElement, api } from 'lwc';
import cloneQuote from '@salesforce/apex/SF_CloneQuote.cloneQuote';
import { NavigationMixin } from 'lightning/navigation';

export default class SF_CloneQuote extends NavigationMixin (LightningElement) {
    @api recordId;
    quote;

    renderedCallback(){
        console.log(this.recordId);
        if(!!this.recordId){
            cloneQuote({quoteId : this.recordId, withQLI : true}).then(result =>{
                this.quote = result;
                const quoteId = this.quote[0].Id
                this.navigateToPage(quoteId);
            });
        }
    }

    navigateToPage(quoteId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteId,
                objectApiName: 'SF_Quote__c',
                actionName: 'view'
            },
        });
    }
}