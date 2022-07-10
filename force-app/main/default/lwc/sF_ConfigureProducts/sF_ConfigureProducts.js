import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getProductsByQuoteId from '@salesforce/apex/SF_QuoteController.getProductsByQuoteId';
import getPriceListItemsByQuoteId from '@salesforce/apex/SF_QuoteController.getPriceListItemsByQuoteId';
import createQuoteLineItems from '@salesforce/apex/SF_QuoteLineItemController.createQuoteLineItems';
import cloneQuoteLineItems from '@salesforce/apex/SF_QuoteLineItemController.cloneQuoteLineItems'
import getQuoteLineItems from '@salesforce/apex/SF_QuoteController.getQuoteLineItems';
import acceptQuote from '@salesforce/apex/SF_AcceptQuote.acceptQuote';
import changeQuantity from '@salesforce/apex/SF_QuoteLineItemController.changeQuantity';

export default class SF_ConfigureProducts extends LightningElement {

    @track currentPageReference;
    @track isModalOpen = false;
    userProducts = [];
    filteredOptions = [];
    quoteLineItems = [];
    searchProducts = [];
    tableData = [];
    products = [];
    basePrices = [];
    bundles = [];
    options = [];
    qlitems = [];
    fieldsData = [];
    currencyValues = [];
    numberValues = [];
    stringValues = [];
    percentValues = [];
    otherValues = [];
    quoteId;
    optionQli;
    searchKey = '';
    message = true;
    showColumns = true;
 

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.quoteId = this.currentPageReference?.state?.c__recordId;
    }

    @wire(getQuoteLineItems, ({ quoteId: '$quoteId' }))
    retrieveItems(result) {
        this.tableData = result;
        if (result.data) {
            this.quoteLineItems = JSON.parse(JSON.stringify(result.data));
            this.qlitems = this.quoteLineItems.qlis;
            if(this.qlitems === undefined || this.qlitems.length == 0) {
                this.showColumns = false;
            }
            this.fieldsData = this.quoteLineItems.fields;
        }
        const bundles = [];
        const options = [];
        this.qlitems.forEach(element => {
            if (element.SF_Is_Bundle__c) {
                bundles.push(element);
            } else {
                options.push(element);
            }
        });
        bundles.forEach(element => {
            element['optQlis'] = [];
            options.forEach(item => {
                if (item.SF_Quote_Line_Item__c === element.Id) {
                    element.optQlis.push(item);
                }
            });
        });
        this.bundles = bundles;


        this.qlitems.forEach(element => {
            let mapQli = new Map();
            for (let key in element) {
                mapQli.set(key, element[key]);
            }

            this.fieldsData.forEach(element => {
                const innerObject = {
                    recordId: mapQli.get('Id'),
                    bundle: mapQli.get('SF_Is_Bundle__c'),
                    type: element.type,
                    value: mapQli.get(element.fieldApi)
                }

                if (innerObject.type === 'CURRENCY') {
                    this.currencyValues.push(innerObject);
                } else if (innerObject.type === 'DOUBLE') {
                    this.numberValues.push(innerObject)
                } else if (innerObject.type === 'STRING') {
                    this.stringValues.push(innerObject)
                } else if (innerObject.type === 'PERCENT') {
                    this.percentValues.push(innerObject);
                } else {
                    this.otherValues.push(innerObject);
                }
            });
        });

        for (let i = 0; i < this.qlitems.length; i++) {
            const row = {
                string: this.stringValues[i].value,
                unitPrice: this.currencyValues[i].value,
                totalPrice: this.currencyValues[i].value,
                subTotal: this.currencyValues[i].value,
                percent: this.percentValues[i].value,
                number: this.numberValues[i].value
            }
        }
    }

    connectedCallback() {
        if (!!this.quoteId) {
            getProductsByQuoteId({ quoteId: this.quoteId })
                .then(result => {
                    this.products = JSON.parse(JSON.stringify(result));
                    this.products.forEach(element => {
                        element['Quantity'] = 1;
                    });
                    getPriceListItemsByQuoteId({ quoteId: this.quoteId })
                        .then(result => {
                            this.basePrices = JSON.parse(JSON.stringify(result));
                            this.products.forEach(element => {
                                element.Option_Products__r.forEach(item => {
                                    this.basePrices.forEach(param => {
                                        if (item.Id === param.Product__c) {
                                            item['BasePrice'] = param.Base_Price__c;
                                            item['CurrencyIsoCode'] = param.CurrencyIsoCode;
                                            item['PriceListItem'] = param.Id;
                                            item['Quantity'] = 1;
                                            if (item.SF_IsOptional__c) {
                                                item.SF_IsOptional__c = false;
                                            } else {
                                                item.SF_IsOptional__c = true;
                                            }
                                        }
                                    });
                                });
                            });
                            this.searchProducts = JSON.parse(JSON.stringify(this.products));
                            this.userProducts = JSON.parse(JSON.stringify(this.products));
                        });
                })
                .catch(error => {
                    console.error(error);
                    //Showtoast
                });
        }
    }

    checkClick(event) {
        const productId = event.target.dataset.id;
        const checkedValue = event.target.checked;

        this.userProducts.forEach(element => {
            element.Option_Products__r.forEach(item => {
                if (item.Id === productId) {
                    item.SF_IsOptional__c = checkedValue;
                }
            });
        });
    }

    changeQuantity(event) {
        const productId = event.target.dataset.id;
        const qtyValue = event.target.value;

        this.userProducts.forEach(element => {
            element.Option_Products__r.forEach(item => {
                if (item.Id === productId) {
                    item.Quantity = qtyValue;
                } else if (element.Id === productId) {
                    element.Quantity = qtyValue;
                }
            });
        });
    }

    addClick(event) {
        const index = event.currentTarget.dataset.index;
        const selectedProduct = this.userProducts[index];
        this.addShowToast();
        this.filteredOptions = selectedProduct.Option_Products__r.filter(value => value.SF_IsOptional__c !== false);

        const wrapperArray = [];
        this.filteredOptions.forEach(element => {
            const option = {};

            option['productId'] = element.Id;
            option['name'] = element.Name;
            option['quantity'] = element.Quantity;
            option['pliId'] = element.PriceListItem;
            option['isBundle'] = element.SF_Is_Bundle__c;
            option['basePrice'] = element.Quantity * element.BasePrice;
            option['currencyIsoCode'] = element.CurrencyIsoCode;

            wrapperArray.push(option);
        });

        const bundle = {};
        bundle['productId'] = selectedProduct.Id;
        bundle['name'] = selectedProduct.Name;
        bundle['quantity'] = selectedProduct.Quantity;
        bundle['isBundle'] = selectedProduct.SF_Is_Bundle__c;

        selectedProduct.SF_Price_List_Items__r.forEach(element => {
            bundle['pliId'] = element.Id;
            bundle['basePrice'] = element.Base_Price__c * selectedProduct.Quantity;
            bundle['currencyIsoCode'] = element.CurrencyIsoCode;

            wrapperArray.push(bundle);
        });

        createQuoteLineItems({ data: wrapperArray, quoteId: this.quoteId })
            .then(() => {
                refreshApex(this.tableData);
                this.showColumns = true;
            })
            .catch(error => {
                console.error(error);
                //showtoast
            });
    }

    acceptQuoteClick() {
        if (!!this.quoteId) {
            acceptQuote({ quoteId: this.quoteId })
                .then(() => {
                    this.quoteShowToast(this.message);
                })
                .catch(error => {
                    console.error(error);
                    this.message = false;
                    this.quoteShowToast(this.message);
                });
        }
    }

    //Table quantity changer
    quantityChanger(event) {
        const qliId = event.target.dataset.id;
        const qtyValue = event.target.value;

        this.bundles.forEach(bundle => {
            bundle.optQlis.forEach(option => {
                if (option.Id === qliId) {
                    option.SF_Quantity__c = qtyValue;
                    this.optionQli = option;
                    changeQuantity({ qli: this.optionQli })
                        .then(() => {
                            refreshApex(this.tableData);
                            this.showColumns = true;
                        });
                }
            });
        });
    }

    cloneQuoteLineItemsClick(event) {
        const qliId = event.target.dataset.id;
        this.cloneShowToast();

        let filteredBundles = [];
        filteredBundles = this.bundles.filter(value => value.Id == qliId);

        filteredBundles.forEach(bundle => {
            bundle.optQlis.forEach(opt => {
                filteredBundles.push(opt);
            });
        });
        cloneQuoteLineItems({ qlis: filteredBundles, quoteId: this.quoteId })
            .then(() => {
                refreshApex(this.tableData);
                this.showColumns = true;
            })
            .catch(error => {
                console.error(error);
                //showtoast
            });
    }


    cloneShowToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Quote Line Items Cloned Successfully',
            variant: 'Success'
        });
        this.dispatchEvent(event);
    }

    addShowToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Quote Line Items Created Successfully',
            variant: 'Success'
        });
        this.dispatchEvent(event);
    }

    //@author: L.Mikatsadze
    //@description: Success and error showtoast events.
    quoteShowToast(message) {
        if (message) {
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Quote Status Changed to Accepted',
                variant: 'Success'
            });
            this.dispatchEvent(event);
        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Quote Status was not changed to Accepted',
                variant: 'Error'
            });
            this.dispatchEvent(event);
        }
    }

    handleSearchTermChange(event) {
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        this.searchProducts = this.products.filter(rec => JSON.stringify(rec).toLowerCase().includes(searchKey.toLowerCase()));
    }

    //Modal
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

}