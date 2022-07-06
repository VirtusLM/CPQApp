import { LightningElement,wire,api } from "lwc";
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import SF_Shipping_Street from '@salesforce/schema/Account.SF_Shipping_Street__c';
import SF_Shipping_Postal_Code from '@salesforce/schema/Account.SF_Shipping_Postal_Code__c';
import SF_Shipping_Country from '@salesforce/schema/Account.SF_Shipping_Country__c';
import SF_Shipping_State from '@salesforce/schema/Account.SF_Shipping_State__c';
import SF_Shipping_City from '@salesforce/schema/Account.SF_Shipping_City__c';
import SF_Billing_Street from '@salesforce/schema/Account.SF_Billing_Street__c';
import SF_Billing_Postal_Code from '@salesforce/schema/Account.SF_Billing_Postal_Code__c';
import SF_Billing_Country from '@salesforce/schema/Account.SF_Billing_Country__c';
import SF_Billing_State from '@salesforce/schema/Account.SF_Billing_State__c';
import SF_Billing_City from '@salesforce/schema/Account.SF_Billing_City__c';
import Id_Field from '@salesforce/schema/Account.Id';
import Account_Address from '@salesforce/label/c.Account_Address';
import Account_Address_City from '@salesforce/label/c.Account_Address_City';
import Account_Address_Country from '@salesforce/label/c.Account_Address_Country';
import Account_Address_Postal_Code from '@salesforce/label/c.Account_Address_Postal_Code';
import Account_Address_State from '@salesforce/label/c.Account_Address_State';
import Account_Address_Street from '@salesforce/label/c.Account_Address_Street';
import Account_Error from '@salesforce/label/c.Account_Error';

const FIELDS = [
  SF_Shipping_Street,
  SF_Shipping_Postal_Code, 
  SF_Shipping_Country,
  SF_Shipping_State,
  SF_Shipping_City,
  SF_Billing_Street,
  SF_Billing_Postal_Code,
  SF_Billing_Country,
  SF_Billing_State,
  SF_Billing_City
]; 

const IS_ACTIVE = { SHIPPING:'Shipping', BILLING:'Billing' };
 
export default class SF_googleMap extends LightningElement {
  @api recordId;
  account;

  street;
  city;
  country;
  province; 
  postalcode;  

  mapMarkers=[];
  showAddressForm=false;
  isActive;
  zoomLevel;
  listView;

  labels = {
    Account_Address, Account_Address_City, Account_Address_Country,
    Account_Address_Postal_Code, Account_Address_State, Account_Address_Street,
    Account_Error
  }


  // get account fields
  @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
  wiredRecord({ error, data }) {
      if (error) {
        const event = new ShowToastEvent({
          title: this.labels.Account_Error,
          message: error,
      });
      this.dispatchEvent(event);
      } else if (data) {
        this.account = data;
      } 
  }

  // method to get input values when user changes address
  handleChange(e) { 
    let {city,street,country,province,postalcode} = e.target;
    this.setAddressInformation(city,street,country,province,postalcode); 
    this.city = e.target.city;
    this.street = e.target.street;
    this.country = e.target.country;
    this.postalcode = e.target.postalCode;
    this.province = JSON.stringify(e.target.province);
    this.setMapMarkers();
  }

  // saving new address
  handleSave() {
    if(!this.showAddressForm) return;
    const fields={}; 
    fields[Id_Field.fieldApiName] = this.recordId; 

    if(this.isActive === IS_ACTIVE.SHIPPING) {
      fields[SF_Shipping_Street.fieldApiName] = this.street;
      fields[SF_Shipping_Postal_Code.fieldApiName] = this.postalcode;
      fields[SF_Shipping_Country.fieldApiName] = this.country;
      fields[SF_Shipping_State.fieldApiName] = this.province;
      fields[SF_Shipping_City.fieldApiName] = this.city;
    } else if(this.isActive === IS_ACTIVE.BILLING) { 
      fields[SF_Billing_Street.fieldApiName] = this.street;
      fields[SF_Billing_Postal_Code.fieldApiName] = this.postalcode;
      fields[SF_Billing_Country.fieldApiName] = this.country;
      fields[SF_Billing_State.fieldApiName] = this.province;
      fields[SF_Billing_City.fieldApiName] = this.city;
    }

    updateRecord({ fields }) 
      .then(() => { 
        return refreshApex(this.account);
      })
      .catch(error => {
        const event = new ShowToastEvent({
          title: this.labels.Account_Error,
          message: error,
      });
      this.dispatchEvent(event);
      });

    this.showAddressForm = false;
  }

  // creating shipping address form
  handleCreateShipping() {
    this.showAddressForm = true; 
    this.isActive = IS_ACTIVE.SHIPPING;
    let { 
      SF_Shipping_Street__c,
      SF_Shipping_Country__c,
      SF_Shipping_State__c,
      SF_Shipping_Postal_Code__c,
      SF_Shipping_City__c
    } = this.account.fields;

    this.setAddressInformation( 
      SF_Shipping_Street__c.value,
      SF_Shipping_Country__c.value,
      SF_Shipping_State__c.value,
      SF_Shipping_Postal_Code__c.value, 
      SF_Shipping_City__c.value
    );
    this.setMapMarkers();
  }

  // creating billing address form
  handleCreateBilling() { 
    this.showAddressForm = true;
    this.isActive = IS_ACTIVE.BILLING;
    let {
      SF_Billing_Street__c,
      SF_Billing_Postal_Code__c,
      SF_Billing_Country__c,
      SF_Billing_State__c,
      SF_Billing_City__c
    } = this.account.fields;

    this.setAddressInformation(
      SF_Billing_Street__c.value,
      SF_Billing_Country__c.value,
      SF_Billing_State__c.value,
      SF_Billing_Postal_Code__c.value,
      SF_Billing_City__c.value
    ); 
    this.setMapMarkers();
  }

  // set address information to variables
  setAddressInformation(street,country,province,postalcode,city) {
    this.street = street;
    this.city = city;
    this.postalcode = postalcode; 
    this.country = country;
    this.province = province; 
  }

  // create data for map 
  setMapMarkers() {
    this.mapMarkers = [ 
      {
        location: { 
          City: this.city,
          Country: this.country,
          PostalCode: this.postalcode,
          State: this.province,
          Street: this.street,
        }
      }, 
    ];
    this.zoomLevel = 12;
    this.listView = 'visible';
  }
}