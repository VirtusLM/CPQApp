@isTest 
public class SF_TestDataFactory {

    public static SF_Price_List__c createPriceList() {
        SF_Price_List__c testPL = new SF_Price_List__c(
            Name = 'USD Price List',
            CurrencyIsoCode = 'USD'
        );
        return testPL;
    }

    public static Account createAccount(SF_Price_List__c testPL) {
        Account testAcc = new Account(
            Name = 'TestAccount',
            SF_Account_Location__c = 'United States',
            CurrencyIsoCode = 'USD',
            SF_Price_List__c = testPL.Id
        );
        return testAcc;
    }
    
    public static Opportunity createOpportunity(Account testAcc) {
        Opportunity testOpp = new Opportunity(
            Name = 'TestOpp',
            AccountId = testAcc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(7),
            CurrencyIsoCode = 'USD'
        );
        return testOpp; 
    }

    public static Contact createContact(Account testAcc) {
        Contact testCon = new Contact(
            Salutation = 'Mr.',
            SF_Primary__c = true,
            LastName = 'TestCon',
            AccountId = testAcc.Id,
            CurrencyIsoCode = 'USD'
        );
        return testCon; 
    }

    public static SF_Quote__c createQuote(Account testAcc, Opportunity testOpp, Contact testCon) {
        SF_Quote__c testQuote = new SF_Quote__c(
            Name = 'TestQuote',
            SF_Account__c = testAcc.Id,
            SF_Opportunity__c = testOpp.Id,
            SF_Contact__c = testCon.Id,
            SF_Price_List__c = testOpp.SF_Price_List__c,
            SF_Status__c = 'Approved',
            SF_Expiration_Date__c = System.today().addDays(7)
        );
        return testQuote;
    }
    
    public static Product2 createProduct() {
        Product2 testProduct = new Product2(
            Name = 'Macbook Pro',
            CurrencyIsoCode = 'USD',
            SF_Is_Bundle__c = true 
        );
        return testProduct;
    }

    public static Product2 createProduct2() {
        Product2 testProduct = new Product2(
            Name = 'Macbook Air',
            CurrencyIsoCode = 'USD'
        );
        return testProduct;
    }

    public static Product2 createProduct3() {
        Product2 testProduct = new Product2(
            Name = 'iPad Pro',
            CurrencyIsoCode = 'USD'
        );
        return testProduct;
    }
    
    public static Product2 createOptionProduct(Product2 testProduct) {
        Product2 testOptionProduct = new Product2(
            Name = 'Apple Pencil',
            CurrencyIsoCode = 'USD',
            Product__c = testProduct.Id
        );
        return testOptionProduct;
    }

    public static SF_Price_List_Item__c createPriceListItem(Product2 testProduct, SF_Price_List__c testPL) {
        SF_Price_List_Item__c testPLI = new SF_Price_List_Item__c(
            Product__c = testProduct.Id,
            Price_List__c = testPL.Id,  
            Base_Price__c = 100,
            SF_Active__c = true,
            CurrencyIsoCode = 'USD'
        );
        return testPLI;
    }

    public static SF_Quote_Line_Item__c createQliBundle (SF_Price_List_Item__c testPriceListItem, SF_Quote__c testQuote) {
        SF_Quote_Line_Item__c testQliBundle = new SF_Quote_Line_Item__c(
            Name = 'testQliBundle',
            SF_Product__c = testPriceListItem.Product__c,
            SF_Price_List_Item__c = testPriceListItem.Id,
            SF_Quote__c = testQuote.Id,
            SF_Total_Price__c = 100,
            SF_Subtotal__c = 100,
            SF_Quantity__c = 1,
            SF_Discount__c = 10,
            CurrencyIsoCode = 'USD', 
            SF_Is_Bundle__c = true
        );
        return testQliBundle;
    }

    public static SF_Quote_Line_Item__c createQliOption (SF_Price_List_Item__c testPriceListItem, SF_Quote__c testQuote) {
        SF_Quote_Line_Item__c testQliOption = new SF_Quote_Line_Item__c(
            Name = 'testQliOption',
            SF_Product__c = testPriceListItem.Product__c,
            SF_Price_List_Item__c = testPriceListItem.Id,
            SF_Quote__c = testQuote.Id,
            SF_Total_Price__c = 100,
            SF_Subtotal__c = 100,
            SF_Quantity__c = 1,
            SF_Discount__c = 10,
            CurrencyIsoCode = 'USD', 
            SF_Is_Bundle__c = false
        );
        return testQliOption;
    }

    public static List<SF_QuoteLineItemController.ProductWrapper> productWrapperData(SF_Price_List_Item__c testPriceListItem) {

        List<SF_QuoteLineItemController.ProductWrapper> testWrappers = new List<SF_QuoteLineItemController.ProductWrapper>();

        SF_QuoteLineItemController.ProductWrapper testWrapBundle = new SF_QuoteLineItemController.ProductWrapper();
            testWrapBundle.name = 'Test Bundle Qli';
            testWrapBundle.productId = testPriceListItem.Product__c;
            testWrapBundle.pliId = testPriceListItem.Id;
            testWrapBundle.basePrice = 100;
            testWrapBundle.quantity = 1;
            testWrapBundle.isBundle = true;
            testWrapBundle.currencyIsoCode = 'USD';

        testWrappers.add(testWrapBundle);

        SF_QuoteLineItemController.ProductWrapper testWrapOption = new SF_QuoteLineItemController.ProductWrapper();
            testWrapOption.name = 'Test Option Qli';
            testWrapOption.productId = testPriceListItem.Product__c;
            testWrapOption.pliId = testPriceListItem.Id;
            testWrapOption.basePrice = 100;
            testWrapOption.quantity = 1;
            testWrapOption.isBundle = false;
            testWrapOption.currencyIsoCode = 'USD';
            
        testWrappers.add(testWrapOption);

        return testWrappers;
    }
   



//############################################################################################################################################################
//############################################################################################################################################################

    public static SF_Quote__c insertQuoteData(){
		Account acc = new Account();
        acc.Name = 'cloneQuoteTest';
        acc.SF_Billing_Country__c = 'Georgia';
        acc.SF_Billing_Postal_Code__c = 0177;
        acc.SF_Billing_State__c = 'None';
        acc.SF_Billing_Street__c = 'Kazbegi';
        acc.CurrencyIsoCode = 'USD';
        acc.SF_Account_Location__c = 'Georgia';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'cloneQuoteTest';
        opp.StageName = 'Prospecting';
        opp.CurrencyIsoCode = 'USD';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        
        insert opp;
    
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.CurrencyIsoCode = 'USD';
        con.LastName = 'Test';
        
        insert con;
    
        SF_Quote__c q = new SF_Quote__c();
        q.Name = 'TestQuote';
        q.SF_Account__c = acc.Id;
        q.SF_Opportunity__c = opp.Id;
        q.SF_Expiration_Date__c = system.today().addDays(7);
        insert q;
        
        Product2 p = new Product2();
        p.Name = 'TestProduct';
        p.CurrencyIsoCode = 'USD';
        insert p;
        
        SF_Price_List__c priceList = new SF_Price_List__c();
        priceList.Name = 'TestPriceList';
        insert priceList;
        
        SF_Price_List_Item__c plii = new SF_Price_List_Item__c();
        plii.Price_List__c = priceList.Id;
        insert plii;
        
        SF_Quote_Line_Item__c qli = new SF_Quote_Line_Item__c();
        qli.Name = 'TestQli';
        qli.SF_Product__c = p.Id;
        qli.SF_Quote__c = q.Id;
        qli.SF_Price_List_Item__c = plii.Id;
        insert qli;

        return q;
    }
    
    
}