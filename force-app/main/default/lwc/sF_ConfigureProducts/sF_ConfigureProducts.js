import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getProductsByQuoteId from '@salesforce/apex/SF_QuoteController.getProductsByQuoteId';
import getPriceListItemsByQuoteId from '@salesforce/apex/SF_QuoteController.getPriceListItemsByQuoteId';
import getQuoteLineItemFieldNames from '@salesforce/apex/SF_QuoteController.getQuoteLineItemFieldNames';
import createQuoteLineItems from '@salesforce/apex/SF_QuoteLineItemController.createQuoteLineItems';
import cloneQuoteLineItems from '@salesforce/apex/SF_QuoteLineItemController.cloneQuoteLineItems'
import getQuoteLineItems from '@salesforce/apex/SF_QuoteController.getQuoteLineItems';
import acceptQuote from '@salesforce/apex/SF_AcceptQuote.acceptQuote';
import changeQuantity from '@salesforce/apex/SF_QuoteLineItemController.changeQuantity';

export default class SF_ConfigureProducts extends LightningElement {

    @track currentPageReference;
    @track isModalOpen = false;
    @track tableProducts = [];

    userProducts = [];
    filteredOptions = [];
    quoteLineItems = [];
    searchProducts = [];
    columnNames = [];
    products = [];
    basePrices = [];
    options = [];
    quoteId;
    optionQli;
    searchKey = '';
    wrapperArray = [];
    message = true;
    showColumns = true;
    tableData = [];
    bundles = [];
    filteredBundles = [];
    qlitems = [];
    fieldsData = [];
    mapData = [];

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.quoteId = this.currentPageReference?.state?.c__recordId;
    }
    //test commit
    @wire(getQuoteLineItems, ({ quoteId: '$quoteId' }))
    retrieveItems(result) {
        this.tableData = result;
        if (result.data) {
            this.quoteLineItems = JSON.parse(JSON.stringify(result.data));
            console.log(this.quoteLineItems, ' Base data');
            this.qlitems = this.quoteLineItems.qlis;
            this.fieldsData = this.quoteLineItems.fields;
            console.log(this.fieldsData, ' fieldsdata');
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
        if (this.qlitems === undefined || this.qlitems.length == 0) {
            // this.showColumns = false;
        }

        let mapQli = new Map();
        for (let key in this.qlitems[0]) {
            mapQli.set(key, this.qlitems[0][key]);
  
        }

        this.fieldsData.forEach(element => {
            const innerObject = {};
            innerObject['type'] = element.type
        });
        mapQli.forEach(element => {
        })

        // let mapQli = new Map();
        // for (let key in this.quoteLineItems[0]) {
        //     mapQli.set(key, this.quoteLineItems[0][key]);
        //     console.log(mapQli, '  MAP of QLis');
        // }

        // this.bundles.forEach(element => {
        //     let newMap = new Map(Object.entries(element));
        //     const keys = [...newMap.keys()];
        //     const values = [...newMap.values()];
        //     this.mapData.push({ key: keys, value: values });
        // this.mapData.push(keys, values);
        // console.log(newMap);
        // let optArray = [];

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
                                element.Option_Products__r.forEach(temp => {
                                    this.basePrices.forEach(param => {
                                        if (temp.Id === param.Product__c) {
                                            temp['BasePrice'] = param.Base_Price__c;
                                            temp['CurrencyIsoCode'] = param.CurrencyIsoCode;
                                            temp['PriceListItem'] = param.Id;
                                            temp['Quantity'] = 1;
                                            if (temp.SF_IsOptional__c) {
                                                temp.SF_IsOptional__c = false;
                                            } else {
                                                temp.SF_IsOptional__c = true;
                                            }
                                        }
                                    });
                                });
                            });
                            this.searchProducts = JSON.parse(JSON.stringify(this.products));
                            this.userProducts = JSON.parse(JSON.stringify(this.products));
                        });
                });

            getQuoteLineItemFieldNames()
                .then(result => {
                    if (Array.isArray(result)) {
                        this.columnNames = result;
              
                    }
                });
        }
    }

    checkClick(event) {
        const productId = event.target.dataset.id;
        const checkedValue = event.target.checked;

        this.userProducts.forEach(element => {
            element.Option_Products__r.forEach(temp => {
                if (temp.Id === productId) {
                    temp.SF_IsOptional__c = checkedValue;
                    // if (temp.SF_IsOptional__c) {
                    //     element.SF_Price_List_Items__r.forEach(res => {
                    //         res.Base_Price__c += temp.BasePrice;
                    //     });
                    // }
                }
            });
        });

        console.log(this.userProducts, '  Checked Array');
    }

    changeQuantity(event) {
        const productId = event.target.dataset.id;
        const qtyValue = event.target.value;

        this.userProducts.forEach(element => {
            element.Option_Products__r.forEach(temp => {
                element.SF_Price_List_Items__r.forEach(res => {
                    if (temp.Id === productId) {
                        temp.Quantity = qtyValue;
                    } else if (element.Id === productId) {
                        element.Quantity = qtyValue;
                    }
                });
            });
        });
    }

    addClick(event) {
        const index = event.currentTarget.dataset.index;
        const selectedProduct = this.userProducts[index];
        this.addShowToast();
        const wrapperArray = [];
        this.filteredOptions = selectedProduct.Option_Products__r.filter(value => value.SF_IsOptional__c !== false);

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
        console.log(wrapperArray, ' ###############');
        createQuoteLineItems({ data: wrapperArray, quoteId: this.quoteId })
            .then(() => {
                refreshApex(this.tableData);
                this.showColumns = true;
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

    quantityChanger(event) {
        const qliId = event.target.dataset.id;
        const qtyValue = event.target.value;
        console.log(qliId, ' Qli Id');
        console.log(qtyValue, ' Quantity');

        this.bundles.forEach(element => {
            element.optQlis.forEach(option => {
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

        console.log(this.optionQli, '  option changing');
    }

    cloneQuoteLineItemsClick(event) {
        const qliId = event.target.dataset.id;
        this.cloneShowToast();
        console.log(qliId, ' QLI Id');

        let filteredBundles = [];
        console.log(filteredBundles, ' before filtered');

        filteredBundles = this.bundles.filter(value => value.Id == qliId);
        console.log(filteredBundles, ' filtered');

        filteredBundles.forEach(bundle => {
            bundle.optQlis.forEach(opt => {
                filteredBundles.push(opt);
            });
        });
        console.log(filteredBundles, ' last');
        cloneQuoteLineItems({ qlis: filteredBundles, quoteId: this.quoteId })
            .then(() => {
                refreshApex(this.tableData);
                this.showColumns = true;
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