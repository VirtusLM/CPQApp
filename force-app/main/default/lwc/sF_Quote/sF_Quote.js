import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import createQuote from '@salesforce/apex/SF_QuoteController.createQuote';
import CreatingQuote from '@salesforce/label/c.CreatingQuote';
import CreatingQuoteMessage from '@salesforce/label/c.CreatingQuoteMessage';
import ErrorCreatingQuote from '@salesforce/label/c.ErrorCreatingQuote';
import ErrorCreatingQuoteMessage from '@salesforce/label/c.ErrorCreatingQuoteMessage';

export default class SF_Quote extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isLoaded = false;
    @track hasRendered = true;
    message = true;
    quote;
    quoteId;
    error;
    labels = {
        CreatingQuote,
        CreatingQuoteMessage,
        ErrorCreatingQuote,
        ErrorCreatingQuoteMessage
    }

    //@author: L.Mikatsadze
    //@description: Sends recordId to Apex method and gets quote data.
    renderedCallback() {
        if (this.recordId != null && this.hasRendered) {
            createQuote({ oppId: this.recordId })
                .then(result => {
                    this.hasRendered = false;
                    this.quote = result;
                    this.isLoaded = !this.isLoaded;
                    this.showToast(this.message);
                    const quoteId = this.quote.Id;
                    this.navigateToEdit(quoteId);
                })
                .catch(error => {
                    console.error(error);
                    this.hasRendered = false;
                    this.message = false;
                    this.showToast(this.message);
                    this.isLoaded = !this.isLoaded;
                });
        }
    }

    //@author: L.Mikatsadze
    //@description: Success and error showtoast events.
    showToast(message) {
        if (message) {
            const event = new ShowToastEvent({
                title: this.labels.CreatingQuote,
                message: this.labels.CreatingQuoteMessage,
                variant: 'Success'
            });
            this.dispatchEvent(event);
        } else {
            const event = new ShowToastEvent({
                title: this.labels.ErrorCreatingQuote,
                message: this.labels.ErrorCreatingQuoteMessage,
                variant: 'Error'
            });
            this.dispatchEvent(event);
        }
    }

    //@author: L.Mikatsadze
    //@description: Redirects to quote edit page.
    navigateToEdit(quoteId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteId,
                objectApiName: 'SF_Quote__c',
                actionName: 'edit'
            },
        });
    }
}