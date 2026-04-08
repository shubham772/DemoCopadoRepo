import { LightningElement, track, wire } from 'lwc';
import grzoffer from '@salesforce/resourceUrl/grzoffer';
import Salesorders from "@salesforce/label/c.Grz_SalesOrder";
import Grz_CommunityUserText from "@salesforce/label/c.Grz_CommunityUserText";
import Grz_Terms_and_Contions_Labels from "@salesforce/label/c.Grz_Terms_and_Contions_Labels";
import getSeller from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getSeller';
import getSOListCreated from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getSOListCreated';
import getCurentUserInfo from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getLoggedInUserInfo';
import getEstimatedDeliveryDate from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getEstimatedDeliveryDate';
import getSelectedProductData from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getSelectedProductData';
import getProductMixData from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getProductMixData';
import customerExist from '@salesforce/apex/Grz_SalesOrderCreationRequest.customerExist';
import getShippingLoations from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getShippingLoations';
import saveSalesOrder from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.saveSalesOrder';
import Maximum_payment_date_allowed_the_25th from "@salesforce/label/c.Maximum_payment_date_allowed_the_25th";
import Brazil_Product_Availability from "@salesforce/label/c.Brazil_Product_Availability";
import Qty_should_be_in_multiple_of from "@salesforce/label/c.Qty_should_be_in_multiple_of";
import Maturity_Date_cannot_be_less_than_today from "@salesforce/label/c.Maturity_Date_cannot_be_less_than_today";
import Maximum_billing_within_9_months_of_order_creation from "@salesforce/label/c.Maximum_billing_within_9_months_of_order_creation";
import Purchase_Order_date_is_required from "@salesforce/label/c.Purchase_Order_date_is_required";
import There_is_no_Ship_to_Party_option_available_for_this_Customer from "@salesforce/label/c.There_is_no_Ship_to_Party_option_available_for_this_Customer";
import getCustomerTaxFreight from '@salesforce/apex/Grz_SalesOrderCreationRequest.getCustomerTaxFreight';
import getKeyCustomers from '@salesforce/apex/Grz_SalesOrderCreationRequest.getKeyCustomers';
import Registration_date_is_out_of_limit_Please_contact_the_Customer_Service_Team from "@salesforce/label/c.Registration_date_is_out_of_limit_Please_contact_the_Customer_Service_Team";
import Purchase_Order_No_is_required from "@salesforce/label/c.Purchase_Order_No_is_required";
import Invoice_Message_can_contain_only_characters_and_numbers from "@salesforce/label/c.Invoice_Message_can_contain_only_characters_and_numbers";
import Purchase_Order_No_is_required_and_can_contain_only_characters_and_numbers from "@salesforce/label/c.Purchase_Order_No_is_required_and_can_contain_only_characters_and_numbers";
import Purchase_Order_No from "@salesforce/label/c.Purchase_Order_No";
import Purchase_Order_Date from "@salesforce/label/c.Purchase_Order_Date";
import Enter_PO_No from "@salesforce/label/c.Enter_PO_No";
import Maturity_Date from "@salesforce/label/c.Maturity_Date";
import Invoice_Message from "@salesforce/label/c.Invoice_Message";
import Brazil_Material_Inactive_Message from "@salesforce/label/c.Brazil_Material_Inactive_Message";
import Replacement_Cost_Validation_Error from "@salesforce/label/c.Replacement_Cost_Validation_Error";
import Maturity_date_is_required from "@salesforce/label/c.Maturity_date_is_required";
import Dat_of_Fat_not_be_greater_than_Maturity_Date from "@salesforce/label/c.Dat_of_Fat_not_be_greater_than_Maturity_Date";
import Brazil_Max_Date_Message from "@salesforce/label/c.Brazil_Max_Date_Message";
import Date_of_FAT_greater_than_360 from "@salesforce/label/c.Date_of_FAT_greater_than_360";
import Brazil_Validate_Min_Date from "@salesforce/label/c.Brazil_Validate_Min_Date";
import Are_you_sure_you_want_to_reset_the_details from "@salesforce/label/c.Are_you_sure_you_want_to_reset_the_details";
import SellerDetails from "@salesforce/label/c.Seller_Details";
import Please_provide_valid_input_fill_all_the_mandatory_fields_before_proceeding from "@salesforce/label/c.Please_provide_valid_input_fill_all_the_mandatory_fields_before_proceeding";
import Yes from "@salesforce/label/c.Yes";
import Grz_SelectSeller from "@salesforce/label/c.Grz_SelectSeller";
import getCustomers from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getCustomers';
import getFeaturedProducts from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getFeaturedProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Seller from "@salesforce/label/c.Seller";
import CUSTOMER_DETAILS from "@salesforce/label/c.CUSTOMER_DETAILS";
import Customer_Name from "@salesforce/label/c.Customer_Name";
import getPriceListValues from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getPriceListValues';
import getPBPaymentTerms from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getPBPaymentTerms';
import getPriceBookDetails from "@salesforce/apex/Grz_SalesOrderCreationRequest.getPriceBookDetails";
import Select_A_Price_List from "@salesforce/label/c.Select_A_Price_List";
import Select_Customer from "@salesforce/label/c.Select_Customer";
import Search_Customer from "@salesforce/label/c.Search_Customer";
import getBusinessRule from "@salesforce/apex/Grz_SalesOrderCreationRequest.getBusinessRule";
import Customer from "@salesforce/label/c.Customer";
import No from "@salesforce/label/c.No";
import KeyAccountText from "@salesforce/label/c.Key_Account";
import BrazilAction from "@salesforce/label/c.BrazilAction";
import Customer_Code from "@salesforce/label/c.Customer_Code";
import City from "@salesforce/label/c.City";
import None from "@salesforce/label/c.None";
import Name from "@salesforce/label/c.Name";
import Payment_Terms from "@salesforce/label/c.Payment_Terms";
import Group from "@salesforce/label/c.Group";
import Currency from "@salesforce/label/c.Currency";
import Grz_SO_Community_Labels from "@salesforce/label/c.Grz_SO_Community_Labels";
import Grz_SO_Community_Labels2 from "@salesforce/label/c.Grz_SO_Community_Labels2";
import Save from "@salesforce/label/c.Save";
import Territory_Code from "@salesforce/label/c.Territory_Code";
import Select from "@salesforce/label/c.Select";
import Tax_Number_3 from "@salesforce/label/c.Tax_Number_3";
import Grz_Sales_Order_Terms_And_Contions from "@salesforce/label/c.Grz_Sales_Order_Terms_And_Contions";
import customCSS from '@salesforce/resourceUrl/customCSS';
import termsHtml from '@salesforce/resourceUrl/Grz_BrazilTermsAndConditions';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class Grz_SalesOrderFeaturedProducts extends LightningElement {
    @track productStyle = "background:white;"
    @track categoria = [];
    @track newSalesOrder = new Object();
    @track selectedCurrency = '';
    @track isShowModal = false;
    @track labelsJson;
    @track labelsJson2;
    @track termsLabels;
    @track isBuyNowSOBtnClicked = false;
    @track selItem5 = new Object();
    @track productTitle = "Gainexa Fc (Powder, Ortho Silicic Acid) Beneficial Nutrient Fertilizer";
    @track selectedPriceList = 'aBkHE00000001fF0AQ';
    @track showKeyAccount = false;
    @track showSeller = false;
    @track territoryUser = '';
    @track selectedUser;
    @track sellerOptionsList = [];
    @track accountList = [];
    @track comboBoxAccounts = [];
    @track searchProducts = '';
    @track priceList = [];
    @track featuredProudcts = false;
    @track isShowSOList = false;
    @track isShowShoppingCart = false;
    @track adminMPTParameter;
    @track isTermsChecked = false;
    @track isAgreedOnNoReturn = false;
    @track showTermsConditions = false;
    @track currencyList = [];
    @track cropYearList = [];
    @track avecValue;
    @track nonAvecValue;
    @track regionValue;
    @track isSpinner = true;
    @track isCommunityUser = false;
    @track businessRule = new Object();
    @track isMature = false;
    @track paymentTermsMapDT = new Map();
    @track selectedTerritoryCode;
    @track termsContent = '';
    @track selectedPaymentTermChangeDate;
    @track selectedImage;
    @track interestDate;
    @track interestFixedDate;
    @track interestRunningDays;
    @track customerRegionForSOM;
    @track customerRegionForSDM;
    @track tempAccountList = [];
    @track sellerData = [];
    @track priceListOptions = [];
    @track isValidFAT = true;
    @track isMultiselect = false;
    @track isShowModalOnPayTMChange = false;
    @track isUpdatePayTm = false;
    @track isUpdateCurrency = false;
    @track paymentTermOptions = [];
    @track AVEC = 'AVEC';
    @track selectedPriceBook = '';
    @track totalProducts;
    @track days = 0;
    @track loggedInUser;
    @track selectedCustomer = '';
    @track selItem = new Object();
    @track erroOnSeller = false;
    @track selectedPaymentTerm = '';
    @track isDeliveryOpen = false;
    @track addtoCartCounter = 0;
    @track isCurrencyOpen = false;
    @track isPaymentOpen = false;
    @track isShowProductPage = false;
    @track salesOrderLineItems = [];
    @track productsInCart = [];
    @track salesOrderList = [];
    @track selectedDeliveryLabel = '';
    @track selectedPayTm;
    @track defaultDelivery = '';
    @track selectedDelivery = '';
    @track fieldsList = [];
    @track paginatedProducts = [];
    @track allViewProductList = new Map();
    @track currencyDropDownList = [];
    @track deliveryDropDownList = [];
    @track paymentTermDropDownList = [];
    @track selectedCropYear = '25/26';
    @track productVariants = [];
    @track visibleRows = [];
    @track products = [];
    @track isExpanded = false;
    @track selectedBrand = '';
    @track isMenuOpen = false;
    @track productDescription = '';
    @track error;
    @track currentPage = 1;
    @track totalPages = 1;
    @track defaultValue = No;
    @track priceDetailList = '';
    @track salesRepUserId = '';
    @track productData;
    @track isShowDownloadModal = false;
    @track updatedProductList = [];
    productsPerPage = 8;
    @track isBuyNowClicked = false;
    @track currentContent = '';
    @track buttons = [];
    @track infoColor;
    activeStep = 2;
    @track currentInfo;
    @track label = {
        SellerDetails, Yes, No, Select, Name, Territory_Code, Grz_SelectSeller, Seller, CUSTOMER_DETAILS, Customer_Name, Select_Customer, Search_Customer, Customer, Currency, Select_A_Price_List,
        KeyAccountText, Payment_Terms, Maturity_Date, Purchase_Order_No, Purchase_Order_Date, Enter_PO_No, Invoice_Message, Save, Salesorders, Grz_CommunityUserText,
        Grz_Sales_Order_Terms_And_Contions
    };
    @track showCustomToast = false;
    showCustomToastOnSave() {
        this.showCustomToast = true;
        setTimeout(() => {
            this.showCustomToast = false;
        }, 15000);
    }
    get isSubmitDisabled() {
        return !this.isTermsChecked || !this.isAgreedOnNoReturn;
    }
    handleTermsChange(event) {
        this.isTermsChecked = event.target.checked;
    }

    handleProductSearchChange(event) {
        this.searchProducts = event.target.value ? event.target.value.toLowerCase() : '';
        let filteredProducts = [];
        if (this.searchProducts) {
            filteredProducts = this.products.filter(product =>
                product.Name && product.Name.toLowerCase().includes(this.searchProducts)
            );
        } else {
            filteredProducts = [...this.products];
        }
        var productsPerPage = '10';
        this.totalPages = Math.ceil(filteredProducts.length / productsPerPage);
        const start = (this.currentPage - 1) * this.productsPerPage;
        const end = start + this.productsPerPage;
        this.paginatedProducts = filteredProducts.slice(start, end);
    }

    handleAgreedOnNoReturn(event) {
        this.isAgreedOnNoReturn = event.target.checked;
    }
    getButtonsWithClass() {
        if (this.productData.tabList)
            this.buttons = this.productData.tabList.map(item => {
                const key = Object.keys(item)[0];
                const content = item[key][key];
                const isActive = item[key].isActive;
                if (isActive) {
                    this.currentContent = content;
                }

                return {
                    label: key.charAt(0).toUpperCase() + key.slice(1), // Capitalize
                    key: key,
                    isActive: isActive,
                    content: content,
                    buttonClass: isActive
                        ? 'infoBtn activeButton'
                        : 'infoBtn inActiveButton'
                };
            });
    }
    handlePdfClick(event) {
        let url = event.target.dataset.id;
        window.open(url, '_blank');
    }
    handleBtnClick(event) {
        const selectedKey = event.target.dataset.key;
        console.log('Selected key---->', selectedKey);
        this.buttons = this.buttons.map(tab => {
            const isActive = tab.key === selectedKey;
            if (isActive) {
                console.log('tab.content---->', tab.content);
                console.log('tab.key---->', tab.key);
                console.log('isActive---->', tab.key === selectedKey);
                this.currentContent = tab.content;
            }

            return {
                ...tab,
                isActive,
                buttonClass: isActive
                    ? 'infoBtn  activeButton'
                    : 'infoBtn  inActiveButton',
            };
        });
        this.updateDomContent();
    }
    @track productMixData;
    @wire(getProductMixData)
    wiredSetting({ error, data }) {
        if (data) {
            this.productMixData = data;
            this.selectedPriceList = data.Id;
            console.log('selectedPriceList--->', this.selectedPriceList);
        } else if (error) {
            console.error('Error retrieving setting:', error);
        }
    }
    get isSalesOrdersAvailable() {
        return this.salesOrderList.length > 0 ? true : false;
    }

    async fetchSOListCreated() {
        this.isSpinner = true;
        try {
            const result = await getSOListCreated();
            this.salesOrderList = result;
            this.isSpinner = false;
        } catch (error) {
            console.error('Error retrieving setting:', error);
        } finally {
            this.isSpinner = false;
        }
    }
    @track selectedTech = "Todos";

    handleActive(event) {
        this.backToList();
        this.selectedTech = event.target.value;
        var filteredProducts = [];
        if (this.selectedTech === this.labelsJson2.All || this.selectedTech === 'Todos') {
            filteredProducts = this.products.filter((product) => (product.Technical != this.selectedTech));
        } else {

            filteredProducts = this.products.filter((product) => (product.Technical === this.selectedTech));
        }
        var productsPerPage = '10';
        this.totalPages = Math.ceil(filteredProducts.length / productsPerPage);
        const start = (this.currentPage - 1) * this.productsPerPage;
        const end = start + this.productsPerPage;
        this.paginatedProducts = filteredProducts.slice(start, end);
    }


    handleTabClick(event) {
        this.selectedTech = event.target.dataset.tech;
        var filteredProducts = [];
        if (this.selectedTech === this.labelsJson2.All) {
            filteredProducts = this.products.filter((product) => (product.Technical != this.selectedTech));
        } else {

            filteredProducts = this.products.filter((product) => (product.Technical === this.selectedTech));
        }
        var productsPerPage = '10';
        this.totalPages = Math.ceil(filteredProducts.length / productsPerPage);
        const start = (this.currentPage - 1) * this.productsPerPage;
        const end = start + this.productsPerPage;
        this.paginatedProducts = filteredProducts.slice(start, end);
    }

    isActive(tech) {
        return tech === this.selectedTech ? 'active' : '';
    }

    connectedCallback() {
        Promise.all([loadStyle(this, customCSS)]);
        fetch(termsHtml)
            .then(res => res.arrayBuffer())
            .then(buffer => {
                const decoder = new TextDecoder('iso-8859-1'); // or 'windows-1252'
                const html = decoder.decode(buffer);
                this.termsContent = html;
            });
        console.log('1111111111111111cALLback');

        this.labelsJson = JSON.parse(Grz_SO_Community_Labels);
        console.log('2222222211111cALLback');

        this.labelsJson2 = JSON.parse(Grz_SO_Community_Labels2);
        console.log('333333333111111cALLback');
        this.termsLabels = JSON.parse(Grz_Terms_and_Contions_Labels);
        console.log('4444444444411111cALLback');
        this.resetvalue();
        this.fetchSOListCreated();
        this.retrieveCurrentUserInfo();
        this.selectedPriceBook = this.AVEC;
    }
    renderedCallback() {
        console.log('Color from ata---->', this.infoColor)
        if (this.productDescription) {
            const descEle = this.template.querySelector('.description');
            if (descEle) {
                descEle.innerHTML = this.productDescription;
            }
        }
        const container = this.template.querySelector('.terms');
        if (container) {
            console.log('sssssss');
            container.innerHTML = `<div style="font-size:18px;">${this.termsContent}</div>`;
        }
        const header = this.template.querySelector('.informationHeader');
        if (header) {
            header.style.color = this.infoColor;
        }
        const brandBorder = this.template.querySelector('.brand-border');
        if (brandBorder) {
            brandBorder.style.borderTop = '4px solid ' + this.infoColor;
        }

        const inActiveButtons = this.template.querySelectorAll('.inActiveButton');
        if (inActiveButtons) {

            inActiveButtons.forEach(button => {
                button.style.color = this.infoColor;
                button.style.backgroundColor = 'white';
                button.style.border = '2px solid ' + this.infoColor;
                // button.addEventListener('mouseover', () => {
                //     button.style.backgroundColor = this.infoColor;
                //     button.style.color = 'white';
                // });

                // // Reset on mouseout
                // button.addEventListener('mouseout', () => {
                //     button.style.backgroundColor = 'white';
                //     button.style.color = this.infoColor;
                //     button.style.borderColor = this.infoColor;
                // });
            });

        }
        const activeButton = this.template.querySelector('.activeButton');
        if (activeButton) {
            activeButton.style.setProperty('background-color', this.infoColor, 'important');
            activeButton.style.color = 'white';
        }
        this.updateDomContent();
    }
    updateDomContent() {
        const container = this.template.querySelector('.info');
        if (container) {
            container.innerHTML = this.currentContent;
        }
    }
    fetchBusinessRule(userId) {
        getBusinessRule({ loggedInUser: userId })
            .then((result) => {
                this.businessRule.Taxes__c = result.Associate_Group__c && result.Associate_Group__r.Business_Rule__c != null ? result.Associate_Group__r.Business_Rule__r.Taxes__c : '';
                this.businessRule.Freight__c = result.Associate_Group__c && result.Associate_Group__r.Business_Rule__c != null ? result.Associate_Group__r.Business_Rule__r.Freight__c : '';
            })
            .catch((error) => {
                this.isSpinner = false;
                console.error('Error fetching business rule:--->', error);
            })
    }
    get backgroundStyle() {
        return `background-image: url('${grzoffer}'); background-size: cover; background-position: bottom;`;
    }
    get buttonDisabled() {
        return !this.updatedProductList.some(item => item.qty);
    }
    get completeButtonDisabled() {
        return this.salesOrderLineItems.length <= 0 ? true : false;
    }
    get productSelectionClass() {
        if (this.activeStep > 1) return 'circle active'; // completed step
        if (this.activeStep === 1) return 'circle current'; // current step
        return 'circle'; // default
    }
    get buttonBuyNowDisabled() {
        return !this.updatedProductList.some(item => item.qty) && !this.productsInCart.length > 0;
    }

    @track detailPageLink = '';
    handleOrderDetail(event) {
        this.detailPageLink = "sales-order/" + event.currentTarget.dataset.value;
    }

    get shoppingCartClass() {
        if (this.activeStep > 2) return 'circle active';
        if (this.activeStep === 2) return 'circle current';
        return 'circle';
    }

    get salesOrderClass() {
        if (this.activeStep === 3) return 'circle current';
        return 'circle';
    }
    get iconClass() {
        return this.activeStep ? 'icon-green' : 'icon-black';
    }
    get lineOneClass() {
        const isMobile = window.innerWidth <= 768;
        return `line ${this.activeStep >= 2 ? 'active-line' : 'inactive-line'} ${isMobile ? 'vertical-line' : 'horizontal-line'}`;
    }

    get lineTwoClass() {
        const isMobile = window.innerWidth <= 768;
        return `line ${this.activeStep >= 3 ? 'active-line' : 'inactive-line'} ${isMobile ? 'vertical-line' : 'horizontal-line'}`;
    }

    get productSelectionTextClass() {
        return `step-text ${this.activeStep >= 1 ? 'active-text' : ''}`;
    }

    get shoppingCartTextClass() {
        return `step-text ${this.activeStep >= 2 ? 'active-text' : ''}`;
    }

    get salesOrderTextClass() {
        return `step-text ${this.activeStep >= 3 ? 'active-text' : ''}`;
    }

    handleClick(event) {
        const step = parseInt(event.currentTarget.dataset.step, 10);
        if (step == 1) {
            if (confirm("Se continuar, você perderá os dados do seu carrinho de compras. Deseja continuar?")) {
                this.backToList();
            }
            else {
                this.activeStep = 2;
            }
        }
        else if (step == 2) {
            this.activeStep = step;
        }
        else if (step == 3) {
            this.completeOrder();
        }
    }

    async loadFeaturedProducts() {
        this.isSpinner = true;
        this.error = undefined;
        this.products = [];

        try {
            const data = await getFeaturedProducts({
                usrId: this.newSalesOrder?.OwnerId,
                accId: this.selItem?.Id
            });

            console.log('Featured Products data:', data);

            if (data && Array.isArray(data.lista)) {
                this.products = [...data.lista];
                console.log('Products from Integration:', this.products);
                console.log('Products from Integration:', this.products.length);

                this.categoria = data.categoria || null;
                this.totalPages = Math.ceil(this.products.length / this.productsPerPage);
                this.updatePaginatedProducts();
                console.log('Products from IntegrationPagi:' + JSON.stringify(this.paginatedProducts));
                this.featuredProudcts = true;
            } else {
                console.warn('No product list found in response:', data);
            }

        } catch (error) {
            console.error('Error fetching featured products:', error);
            this.error = error;
        } finally {
            this.isSpinner = false;
        }
    }

    showToast(variant, title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    get isCurrencyBRL() {
        return this.newSalesOrder.CurrencyIsoCode === 'BRL' ? true : false;
    }
    get showMoreOrLess() {
        return this.productVariants.length > 4 && this.visibleRows.length <= this.productVariants.length;
    }
    get tableExpandLabel() {
        return this.isExpanded ? this.labelsJson2.Show_Less : this.labelsJson2.Show_More;
    }
    showMoreProducts() {
        if (this.isExpanded) {
            this.visibleRows = this.productVariants.slice(0, 4);
        } else {
            this.visibleRows = [...this.productVariants];
        }
        console.log('Visible Row--->', this.visibleRows);
        console.log('isExpanded Row--->', this.isExpanded);
        this.isExpanded = !this.isExpanded;
        console.log('isExpanded Row--->#####', this.isExpanded);
    }

    updatePaginatedProducts() {
        const start = (this.currentPage - 1) * this.productsPerPage;
        const end = start + this.productsPerPage;
        this.paginatedProducts = this.products.slice(start, end);
    }
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updatePaginatedProducts();
        }
    }
    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updatePaginatedProducts();
        }
    }
    @track currentDeliveryDate;
    async sendDataForIntegration(productBrandName) {
        this.isSpinner = true;
        try {
            console.log('this.selItem.Brazil_Region__c===>', this.selItem.Id);
            const result = await getSelectedProductData({ brandName: productBrandName, regionCode: this.selItem.Id, usrId: this.newSalesOrder.OwnerId, accountId: this.selItem.Id });
            this.productData = result;
            this.selectedImage = result.logo;
            this.productStyle = result.bg;
            this.infoColor = result.color1;
            this.currentDeliveryDate = result.ddate;
            console.log('Product Data---->', this.productData);
            // this.currentProductMrktVariation = result.productMarketVariation;
            // console.log('currentProductMrktVariation----->', this.currentProductMrktVariation);
            this.productDescription = result.description;
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            this.productVariants = JSON.parse(JSON.stringify(result.inventory.root.item))
                .filter(variant => {
                    const expireDate = new Date(variant.Batch_Expire_date);
                    console.log('Expire Date---->', expireDate);
                    expireDate.setHours(0, 0, 0, 0);
                    return expireDate >= today;
                }).sort((a, b) => new Date(a.Batch_Expire_date) - new Date(b.Batch_Expire_date));
            console.log('tempFilteredProducts---->', this.productVariants);
            if (this.salesOrderLineItems.length > 0) {
                let lineItems = [...this.salesOrderLineItems];
                const quantityMap = lineItems.reduce((acc, item) => {
                    acc[item.uid] = (acc[item.uid] || 0) + item.qty;
                    return acc;
                }, {});
                this.productVariants = this.productVariants.map(variant => ({
                    ...variant,
                    Available_Quantity: variant.Available_Quantity - (quantityMap[variant.uid] || 0),
                    BRL_Entered_Price: 0,
                    USD_Entered_Price: 0,
                }));
                this.totalQty = 0;
                this.totalPrice = 0;
            }
            if (!this.isShowShoppingCart) {
                this.productVariants = this.mergeRowsWithPriceList(this.productVariants);
                this.updateRowCalculations(this.productVariants);
            }
            this.visibleRows = this.productVariants.slice(0, 4);
        } catch (error) {
            console.error('Error after Integration------------->', error);
        } finally {
            this.isSpinner = false;
        }
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }
    toggleMenu() {
        this.isMenuOpen = !this.isMenuOpen;
    }
    get accountKeyyOptions() {
        return [
            { label: No, value: No, id: 'keyNo' },
            { label: Yes, value: Yes, id: 'keyYes' }
        ];
    }
    validateModalFields() {
        let flag = true;
        const customerName = this.template.querySelector('[data-id="custitem"]');
        if (customerName && (!this.selectedCustomer || this.selectedCustomer === '')) {
            flag = false;
            customerName.classList.add('slds-has-error');
        }
        var showSeller = this.showSeller;
        if (showSeller) {
            var sellerOptions = this.template.querySelector('[data-id="sellerOptions"]');
            if (sellerOptions) {
                if (this.selectedUser == undefined || this.selectedUser === '') {
                    flag = false;
                    sellerOptions.classList.add('slds-has-error');
                }
            }
        }
        const paymentTerms = this.template.querySelector('[data-id="paymentTerm"]');
        if (paymentTerms && (paymentTerms.value === None || paymentTerms.value === undefined || paymentTerms.value === '')) {
            flag = false;
            paymentTerms.classList.add('slds-has-error');
        }
        if (this.isMature) {
            const maturityDate = this.template.querySelector('[data-id="maturityDateOmModal"]');
            if ((maturityDate && (maturityDate.value === None || maturityDate.value === undefined || maturityDate.value === '')) || !this.isValidMaturity) {
                flag = false;
                maturityDate.classList.add('slds-has-error');
            }
        }
        return flag;
    }
    resetvalue() {
        this.selectedCurrency = 'Billing BRL / Payment BRL';
        this.newSalesOrder.Currency_Brazil__c = this.selectedCurrency;
        this.newSalesOrder.CurrencyIsoCode = this.newSalesOrder.Currency_Brazil__c === "Billing BRL / Payment BRL" ? "BRL" : "USD";
        this.newSalesOrder.AVEC_Order__c = true;
        this.newSalesOrder.Created_from_portal__c = true;
        this.newSalesOrder.Campaign_Type__c = 'None';
        this.newSalesOrder.Directed_Sales__c = true;
        this.newSalesOrder.sobjectType = 'Sales_Order__c';
        this.newSalesOrder.Product_Mix__c = this.selectedPriceList;
        this.selItem5 = { sobjectType: "Shipping_Location__c" }
        this.newSalesOrder.Order_Status__c = 'Submitted';
        this.selectedTech = this.labelsJson2.All;
        const date = new Date();

        const month = String(date.getMonth() + 1).padStart(2, '0'); // Ensure two-digit month
        const day = String(date.getDate()).padStart(2, '0'); // Ensure two-digit day
        let year = date.getFullYear();

        let currentDate = `${year}-${month}-${day}`;
        const lastDate = new Date(year, month + 1, 0).toISOString().split('T')[0];;
        this.newSalesOrder.Valid_From__c = currentDate;
        this.newSalesOrder.Valid_To__c = lastDate;
    }
    get computedClass() {
        return 'slds-text-body_regular slds-p-horizontal_small dropdown-toggle';
    }
    get computedMobileClass() {
        return 'slds-text-body_regular dropdown-mobile-toggle';
    }
    get accountKeyyOptions() {
        return [
            { label: Yes, value: Yes, id: 'keyYes' },
            { label: No, value: No, id: 'keyNo' }
        ];
    }

    get paymentTermOptions() {
        return this.paymentTermOptions;
    }
    @track showEditLineItemModal = false
    updateLineItem() {
        this.showEditLineItemModal = true;
    }
    handleSaveLineItemsData() {
        this.showEditLineItemModal = false;
    }
    hideEditLineItemModalBox() {
        this.showEditLineItemModal = false;
    }



    async retrieveCurrentUserInfo() {
        this.isSpinner = true;
        try {
            const result = await getCurentUserInfo(); // Wait for user info
            this.loggedInUser = result.userInfo;
            this.showKeyAccount = result.isKeyAccountManager;
            this.cropYearList = result.cropYearList;
            this.avecValue = result.avecValue;
            this.nonAvecValue = result.nonAvecValue;
            this.regionValue = result.regionValue;
            this.adminMPTParameter = result.adminparameters;
            let currenyOpts = [];
            if (result.currencyList.length > 0) {
                result.currencyList.forEach(element => {
                    let splitValues = element.split("*");
                    if (splitValues[1] !== 'Billing USD / Payment BRL') {
                        let tempOpt = splitValues[1].includes('BRL') ? 'BRL' : 'USD';
                        currenyOpts.push({
                            label: tempOpt,
                            value: splitValues[1],
                            checked: false
                        });
                    }
                });
            }
            if (currenyOpts.length > 0) {
                currenyOpts[0].checked = true;
            }
            this.currencyList = currenyOpts;

            let incotermsOpts = [];
            if (result.incoTermsList.length > 0) {
                let incoTerm = result.incoTermsList[0].split("*")[1];
                result.incoTermsList.forEach(element => {
                    let splitValues = element.split("*");
                    let tempOpt = splitValues[0].includes('CIP') ? this.labelsJson2.Delivery : this.labelsJson2.Pickup;
                    incotermsOpts.push({
                        label: tempOpt,
                        value: splitValues[1],
                        checked: false
                    });
                });
            }
            console.log('Delivery-->', incotermsOpts);
            if (incotermsOpts.length > 0) {
                this.selectedDelivery = incotermsOpts[0].value;
                incotermsOpts[0].checked = true;
                this.newSalesOrder.Inco_Term__c = this.selectedDelivery;
                this.defaultDelivery = incotermsOpts[0].value;
                this.selectedDeliveryLabel = incotermsOpts[0].label;
            }
            console.log('Selected Delivery label-->', this.selectedDeliveryLabel);
            this.deliveryOptions = incotermsOpts;

            this.newSalesOrder.Type_of_Order__c = 'VENDA NORMAL';
            this.newSalesOrder.OwnerId = this.loggedInUser.Id;
            this.newSalesOrder.Crop_Year__c = this.selectedCropYear;

            if ([
                "Brazil Partner Community Distributor Supply Profile",
                "Brazil Partner Community Distributor Profile New",
                "Brazil Partner Community Distributor Finance Profile"
            ].includes(this.loggedInUser.Profile.Name)) {
                this.isCommunityUser = true;
                this.isShowSOList = true;
                this.newSalesOrder.OwnerId = this.loggedInUser.Id;
                this.newSalesOrder.Created_by_Portal_User__c = true;
                this.disableCustomerLookup = true;
            } else {
                if ([
                    "Brazil Sales Office Manager",
                    "Brazil Sales District Manager",
                    "Brazil Barter Manager"
                ].includes(this.loggedInUser.Profile.Name)) {
                    this.showSeller = true;
                    if (!this.selectedUser) {
                        await this.getsellerData();
                    }
                } else if (this.loggedInUser.Profile.Name === "Brazil Sales Person") {
                    this.showSeller = false;
                }

                if (this.showKeyAccount) {
                    if (this.defaultValue === Yes) {
                        await this.getsellerData();
                    }
                    if (this.defaultValue === No) {
                        this.showSeller = false;
                    }
                }
                this.isShowModal = true;
            }
            await this.fetchAccounts();
            this.tempAccountList = this.accountList;
            console.log('Account List--->', this.tempAccountList);
        } catch (error) {
            console.error('Error in fetching Current User Info Data:', error);
        } finally {
            this.isSpinner = false;
        }
        console.log('Current User ---->', this.loggedInUser);
    }

    createNewSalesOrder() {
        this.showSpinnerWithDelay();
        this.isShowModal = true;
        this.isShowSOList = false;
    }

    getPriceListVal() {
        const keyAccount = this.showSeller;
        let sellerId = this.selectedUser;
        if (this.selectedCropYear == 'None') {
            // this.showCustomToastMessage(false,true,'Selecione o ano-safra.');
        } else {
            getPriceListValues({
                cropYear: this.selectedCropYear,
                priceBookType: this.selectedPriceBook
            }).then((result) => {
                console.log('==> Call Price List ==> ' + JSON.stringify(result));
                if (result.success) {
                    this.priceList = result.data;
                    var opts = [];
                    opts.push({
                        label: Select_A_Price_List,
                        value: "None",
                    })
                    if (this.priceList && this.priceList.length > 0) {
                        this.priceList.forEach(element => {
                            opts.push({
                                label: element.Name,
                                value: element.Id,
                            });
                        });

                    }
                    console.log('Options----->', opts);
                    this.priceListOptions = opts;
                } else {
                    // this.showCustomToastMessage(false,true,result.message);
                }
            })
                .catch((error) => {
                    console.log('Error in getting Price List value::::', error);
                });
        }
    }
    @track paymentTermsMapDY = [];
    @track productMix;
    async getPBPayMent(currentValue) {
        this.isSpinner = true;
        this.paymentTermOptions = [];
        let opts = [];

        try {
            const result = await getPBPaymentTerms({
                productMixId: currentValue,
                accId: this.selItem?.Id
            });

            this.pbPaymentTerms = result;
            console.log('PB payTermsDays =>', result.payTermsDays);
            console.log('PB payTermsDates =>', result.payTermsDates);
            console.log('PB payTermBR71 =>', result.payTermBR71);
            console.log('PB productMix =>', result.productMix);
            console.log('PB SalesrepId =>', result.salesRepUserId);
            console.log('productMixData =>', this.productMixData);
            await this.loadFeaturedProducts();
            this.salesRepUserId = result.salesRepUserId;
            this.productMix = result.productMix;
            let isBR71Applied = false;
            console.log('Product Mix Data--->', this.productMixData);
            if (this.productMixData) {
                this.newSalesOrder.Price_Book__c = this.productMixData.Price_Book__c;
                const intrestDD = this.productMixData.Interest_Date_Value__c;
                isBR71Applied = this.productMixData.Is_BR71_Applied__c;
                this.fetchPriceBookDetails();
                this.newSalesOrder.Product_Mix_Name__c = this.productMixData.Name;
                if (intrestDD && intrestDD.includes('/')) {
                    var intrestData = intrestDD.split('/');
                    this.interestDate = intrestData[2] + '-' + intrestData[1] + '-' + intrestData[0];
                    this.newSalesOrder.Interest_Date_Value__c = this.interestDate;   // Updated  by Grz(Dheeraj Sharma) for RITM1003366 on 10 july 2025

                } else if (intrestDD) {
                    this.interestDate = intrestDD;
                }
                console.log('this.interestDate =>', this.interestDate);
            }
            // if (result.productMix) {
            //     const intrestDD = result.productMix.Interest_Date_Value__c;
            //     isBR71Applied = result.productMix.Is_BR71_Applied__c;
            //     this.newSalesOrder.Price_Book__c = result.productMix.Price_Book__c;
            //     this.fetchPriceBookDetails();
            //     console.log('this.intrestDD =>', intrestDD);
            //     if (intrestDD?.includes('/')) {
            //         const [dd, mm, yyyy] = intrestDD.split('/');
            //         this.interestDate = `${yyyy}-${mm}-${dd}`;
            //         this.interestFixedDate = this.interestDate;
            //     } else if (intrestDD) {
            //         const today = new Date();
            //         console.log('1234567 =>', intrestDD);
            //         this.interestRunningDays = intrestDD;
            //         const resultdd = new Date(today.setDate(today.getDate() + parseInt(intrestDD)));
            //         const dd = String(resultdd.getDate()).padStart(2, '0');
            //         const MM = String(resultdd.getMonth() + 1).padStart(2, '0');
            //         const yyyy = resultdd.getFullYear();
            //         this.interestDate = `${yyyy}-${MM}-${dd}`;
            //     }

            //     this.newSalesOrder.Interest_Date_Value__c = this.interestDate;
            //     this.newSalesOrder.Product_Mix_Name__c = result.productMix.Name;
            //     console.log('this.interestDate =>', this.interestDate);
            //     console.log('this.interestFixedDate =>', this.interestFixedDate);
            //     console.log('this.interestRunningDay =>', this.interestRunningDays);
            // }

            // Process payTermsDays
            if (result.payTermsDays) {
                this.paymentTermsMapDY = result.payTermsDays;
                for (const key in this.paymentTermsMapDY) {
                    if (key !== 'null null') {
                        opts.push({ label: key, value: key });
                    }
                }
            }

            // Process payTermsDates
            const fixedDaysOpts = [];
            const paymentTermsMapDT = result.payTermsDates || {};
            for (const key in paymentTermsMapDT) {
                if (key !== 'null') {
                    const [yyyy, mm, dd] = key.split('-');
                    fixedDaysOpts.push({
                        label: `${dd}/${mm}/${yyyy}`,
                        value: key
                    });
                }
            }
            this.paymentTermsMapDT = paymentTermsMapDT;
            this.fixDaysOptions = fixedDaysOpts;

            // Handle BR71 term
            if (result.payTermBR71 && isBR71Applied) {
                const paymentTermBR71 = result.payTermBR71;
                const key = `${paymentTermBR71.Payterms_Desc__c}`;
                const val = `${paymentTermBR71.Payment_Term_Code__c} ${paymentTermBR71.Payterms_Desc__c}`;
                fixedDaysOpts.push({ label: key, value: val });
                this.paymentTermBR71 = paymentTermBR71;
            }

            opts.push(...fixedDaysOpts);
            this.paymentTermOptions = opts.sort((a, b) => {
                if (a.label < b.label) return -1;
                if (a.label > b.label) return 1;
                return 0;
            });

            const paymentTerms = this.template.querySelector('[data-id="paymentTerm"]');
            paymentTerms?.classList.remove('slds-has-error');
            const index = this.paymentTermOptions.findIndex(opt => opt.label === 'A Vista');
            const pmKey = this.paymentTermOptions[index]?.value;
            const pmObj = this.paymentTermsMapDY?.[pmKey];

            if (pmObj) {
                const isMaturityRequired =
                    (pmKey !== 'BR00 SEM PAGAMENTO' && (pmObj.Payment_Term__r?.Maturity_Date_Mandatory__c === 'Yes' || pmObj.Payment_Term__r?.Maturity_Date_Mandatory__c === Yes)) ||
                    (pmKey === 'BR00 SEM PAGAMENTO' && (pmObj.Maturity_Date_Mandatory__c === 'Yes' || pmObj.Maturity_Date_Mandatory__c === Yes));

                this.isMature = isMaturityRequired;

                if (!this.isMature) {
                    this.newSalesOrder.Maturity_Date__c = null;
                }
                this.newSalesOrder.Campaign_Payment_Term__c = '';
                this.newSalesOrder.Campaign_Payment_Term_Date__c = '';
                this.selectedPaymentTermChangeDate = 'None';
                if (pmKey !== 'BR00 SEM PAGAMENTO') {
                    this.newSalesOrder.Payment_Term__c = pmObj.Payment_Term__c;
                    this.days = pmObj.Payment_Term__r?.Days_to_calc_interest__c || 0;
                } else {
                    this.newSalesOrder.Payment_Term__c = pmObj.Id;
                    this.days = pmObj.Days_to_calc_interest__c || 0;
                }
            }
            if (this.paymentTermOptions?.length > 0) {
                this.paymentTermOptions[index].checked = true;
                this.selectedPaymentTerm = this.paymentTermOptions[index].value;
                this.newSalesOrder.ReloadPaymentTerms__c = this.selectedPaymentTerm;
                this.selectedPayTm = this.paymentTermOptions.find(item => item.checked);
                var tempPaymentList = [];
                tempPaymentList.push(this.selectedPayTm);
                this.paymentTermOptions.forEach(currentItem => {
                    const exists = tempPaymentList.some(item => item.value === currentItem.value);
                    if (!exists) {
                        tempPaymentList.push(currentItem);
                    }
                });
                this.paymentTermOptions = tempPaymentList;
            }

        } catch (error) {
            console.error('Error retrieving getPBPaymentTerms:', error);
        } finally {
            this.isSpinner = false;
        }
    }
    @track notMatchingProductList;
    fetchPriceBookDetails() {
        var params;
        var priceBookId = this.newSalesOrder.Price_Book__c;
        console.log('Pricebook Parms=> ' + priceBookId + ' => ' + this.selectedPriceList + '=> ' + this.selectedCurrency);
        var depotCode = this.selItem.Depot_Code__c;
        let accountState = this.selItem.Customer_Region__c;
        console.log('depocode=> ' + depotCode);
        console.log('accountState=> ' + accountState);
        console.log('accountState=> ' + this.selItem.Brazil_Region__c);
        console.log('selItem=> ' + JSON.stringify(this.selItem));
        var selected;
        if (null != this.selectedUser) {
            selected = this.selectedUser.split("~~");
        }
        let userIdToPass = this.isCommunityUser ? this.salesRepUserId : (this.loggedInUser.Profile.Name === 'Brazil Sales District Manager' && selected && selected.length > 1)
            ? selected[1]
            : this.loggedInUser.Id;
        console.log('User to pass---->', userIdToPass);
        params = {
            userId: userIdToPass,
            priceBookId: priceBookId,
            productMixId: this.selectedPriceList,
            selectedCurrency: this.selectedCurrency,
            depotCode: depotCode,
            accountState: accountState,
            accid: this.newSalesOrder.Sold_to_Party__c,
            isSimulated: false
        }
        getPriceBookDetails(params)
            .then((result) => {
                console.log('result--->', result);
                const brandMap = new Map();
                const filterPro = [];
                const addedProductBrands = new Set();
                const invalidBrands = new Set();

                console.log('products BEFORE--->', this.products);
                const productNamesSet = new Set(this.products.map((product) => product.Name));
                console.log('Heyyyy ProductName Set----->', productNamesSet);
                result.forEach((product) => {
                    console.log('ExclusiveBrandNameSet---->', product.exclusiveBrandNameSet);
                    if (!brandMap.has(product.brand)) {
                        brandMap.set(product.brand, []);
                    }
                    brandMap.get(product.brand).push(product);
                    const { materialPlnRplcCost: replc, materialActive, isValid, kitProduct } = product;
                    if (!materialActive || replc == null || replc <= 0 || (!isValid && !kitProduct)) {
                        invalidBrands.add(product.brand);
                    }
                });
                //console.log('🚫Filtered out Brands due to Material Registration failed, Invalid Replacement Cost, Not Valid and Not a kit Product---->', [...invalidBrands]);
                for (const [brand, products] of brandMap.entries()) {
                    if (this.isCommunityUser && invalidBrands.has(brand)) {
                        console.log(`⚠️ Filtered out [${brand}] — Invalid brand for community user`);
                        continue;
                    }

                    for (const product of products) {

                        const matchingProduct = this.products.find((p) => p.Name === product.brand);
                        if (this.isCommunityUser && !matchingProduct) {
                            console.log(`❌ Skipping [${product.brand}] — No matching product from Integration`);
                            continue;
                        }
                        let isAvailableProduct = product;
                        if (this.isCommunityUser) {
                            if (!productNamesSet.has(isAvailableProduct.brand)) {
                                console.log(`❌ [${product.brand}] — Brand not found in Integration data`);
                                continue;
                            }
                            if (!isAvailableProduct.avail) {
                                console.log(`❌ Skipping [${product.brand}] — Region SKU Not Available`);
                                continue;
                            }
                            if (isAvailableProduct.itemStatus && isAvailableProduct.itemStatus !== 'Active') {
                                console.log(`❌ Skipping [${product.brand}] — Item is cancelled`);
                                continue;
                            }
                            const sameRegionOrKit = !(
                                isAvailableProduct.regState !== this.selItem.Customer_Region__c &&
                                !isAvailableProduct.kitProduct
                            );

                            if (!sameRegionOrKit) {
                                console.log(`❌ Skipping [${product.brand}] — Region mismatch (${isAvailableProduct.regState} ≠ ${this.selItem.Customer_Region__c}) and not a kit`);
                                continue;
                            }
                            if (addedProductBrands.has(matchingProduct.Name)) {
                                console.log(`ℹ️ Skipping duplicate [${product.brand}] — Already added`);
                                continue;
                            }
                            console.log(`✅ Added [${matchingProduct.Name}] — Passed all Community filters`);
                            filterPro.push(matchingProduct);
                            addedProductBrands.add(matchingProduct.Name);

                        }
                        else {
                            if (matchingProduct && !addedProductBrands.has(matchingProduct.Name)) {
                                filterPro.push(matchingProduct);
                                addedProductBrands.add(matchingProduct.Name);
                            }
                            const nonMatchingList = this.products.filter(
                                (p) => p.Name !== product.brand
                            );

                            for (const nonMatch of nonMatchingList) {
                                if (!addedProductBrands.has(nonMatch.Name)) {
                                    filterPro.push(nonMatch);
                                    addedProductBrands.add(nonMatch.Name);
                                }
                            }
                        }
                    }
                }

                this.priceDetailList = result;
                console.log('✅ Filtered product list (filterPro):', filterPro);
                //this.products = filterPro;
                this.products = [...filterPro].sort((a, b) => {
                    const orderA = Number(a.sortOrder) || 0;
                    const orderB = Number(b.sortOrder) || 0;
                    return orderA - orderB;
                });
                console.log('✅ Products AFTER filtration -->', this.products);
                this.updatePaginatedProducts();
                console.log('✅ Products AFTER filtration -->' + JSON.stringify(this.paginatedProducts));
            })
            .catch((error) => {
                console.error('❌ Error fetching price book details:', error);
            });



    }
    handleKeyPress(event) {
        const charCode = event.charCode;
        if ((charCode < 48 || charCode > 57) && charCode != 46 && charCode != 44) {
            event.preventDefault();
        }
    }
    handleKeyAccountSelection(event) {
        this.template.querySelector('[data-id="custitem"]').clearlookup();
        this.selItem = new Object();
        this.selectedCustomer = '';
        if (event.target.value == Yes) {
            this.defaultValue = Yes;
            this.getsellerData();
            this.showSeller = true;
        }
        if (event.target.value == No) {
            this.defaultValue = No;
            this.newSalesOrder.OwnerId = this.loggedInUser.Id;
            this.showSeller = false;
            this.selectedUser = '';
            this.comboBoxAccounts = this.tempAccountList.map(account => ({
                label: account.Name,
                value: account.Id,
                record: account
            }));
            var userId;
            if (this.loggedInUser) {
                userId = this.loggedInUser.Id;
            }
            if (userId && userId != '' && userId != undefined) {
                this.fetchBusinessRule(userId);
            }
        }
        this.newSalesOrder.Key_Account__c = this.showSeller;
    }
    getsellerData() {
        this.isSpinner = true;
        const cols = [
            { type: "button", label: Select, typeAttributes: { label: Select, name: 'Select', variant: 'Neutral' } },
            { label: Name, fieldName: 'sellerName', sortable: "true" },
            { label: Territory_Code, fieldName: 'TerritoryCode__c' }
        ];

        getSeller()
            .then((data) => {
                console.log('getSeller data : ', data);
                if (data && data.length > 0) {
                    this.sellerData = data;
                    this.sellerOptionsList = this.processSellerData(data);
                    this.sellerColumns = cols;
                    const profileName = this.loggedInUser.Profile.Name;
                    this.showSeller = this.shouldShowSeller(profileName, this.defaultValue, Yes);
                }
                this.isSpinner = false;
            })
            .catch((error) => {
                console.error('Error While retrieving Seller Data--->', error);
                this.isSpinner = false;
            });
    }

    processSellerData(data) {
        data = JSON.parse(JSON.stringify(data));
        return data.map(res => {
            const [sellerInfo, managerId] = res.split("*");
            const [territoryCode, sellerName] = sellerInfo.split(" - ");
            console.log('Seller name--->', sellerName)
            return {
                Name: sellerInfo,
                sellerName: sellerName,
                TerritoryCode__c: territoryCode,
                Id: managerId
            };
        });
    }
    shouldShowSeller(profileName, defaultValue, Yes) {
        if (defaultValue === Yes) return true;
        return (
            profileName === "Brazil Sales District Manager" ||
            profileName === "Brazil Barter Manager" ||
            profileName === "Brazil Sales Office Manager" ||
            profileName === "Brazil Sales Price Admin"
        );
    }
    handleClear() {
        if (confirm(Are_you_sure_you_want_to_reset_the_details)) {
            this.defaultValue = No;
            this.showSeller = false;
            this.selectedCustomer = '';
            this.selectedDelivery = this.defaultDelivery;
            this.selectedCurrency = 'Billing BRL / Payment BRL';
            this.paymentTermOptions = [];
            this.selectedPaymentTerm = '';
            this.template.querySelector('[data-id="custitem"]').clearlookup();
            this.selItem = new Object();
        }
    }
    @track TCForBarterProcess;
    handleSellerChange(event) {
        this.selectedUser = event.detail.Id;
        console.log('Selected Seller---->', this.selectedUser);
        this.newSalesOrder.OwnerId = this.selectedUser.includes("~~") ? this.loggedInUser.Id : this.selectedUser;
        this.template.querySelector('[data-id="sellerOptions"]').classList.remove('slds-has-error');
        this.template.querySelector('[data-id="custitem"]').clearlookup();
        this.selItem = new Object();
        this.selectedCustomer = '';
        var selected;
        var territoryCode = "";
        var territoryUser = "";
        var profileName = this.loggedInUser.Profile.Name;
        if (profileName == "Brazil Barter Manager" || profileName == "Brazil Sales Office Manager" || profileName == "Brazil Sales Price Admin") {
            this.customerRegionForSOM = this.selectedTerritoryCode;
            this.TCForBarterProcess = this.selectedTerritoryCode;
        }
        this.selectedTerritoryCode = event.detail.TerritoryCode__c;
        if (this.selectedUser) {
            selected = this.selectedUser.split("~~");
            territoryCode = selected[1];
            territoryUser = selected[0];
            this.newSalesOrder.KeyAccountDesOwnerBrazil__c = territoryUser;
            this.fetchBusinessRule(territoryUser);
            this.newSalesOrder.TM_Code__c = territoryCode;
            if (territoryCode) {
                this.customerRegionForSDM = territoryCode;
            } else {
                this.customerRegionForSDM = null;
            }
            var isKeyAccount = this.newSalesOrder.Key_Account__c;
            if (isKeyAccount || this.selectedUser) {
                this.selItem = new Object();
                this.newSalesOrder.Sold_to_Party__c = null;
                this.fetchAccounts();
            }
        }
        console.log('Sales Order Owner---->', this.newSalesOrder);
    }

    get currencyOptions() {
        return this.currencyList;
    }

    handleDeliveryChange(event) {
        const selectedOption = this.deliveryOptions.find(opt => opt.value === event.detail.value);
        this.selectedDelivery = selectedOption ? selectedOption.value : '';
        this.selectedDeliveryLabel = selectedOption ? selectedOption.label : '';
        this.newSalesOrder.Inco_Term__c = this.selectedDelivery;
        this.deliveryOptions.forEach(opt => {
            opt.checked = (opt.value === this.selectedDelivery);
        });
    }
    @track paymentTermDY;
    handlePaymentTermChange(event) {
        const exists = this.fixDaysOptions.some(item => item.value === event.detail.value);
        console.log('PaymentTermChange exists----->', exists);
        if (exists) {
            this.selectedPaymentTermChangeDate = event.detail.value;
            this.isMature = false;
            var paymentTerm = this.selectedPaymentTermChangeDate;
            if (paymentTerm != 'None' && paymentTerm != None) {
                this.paymentTermDY = 'None';
                if (paymentTerm === "BR71 INFORMAR VENCIMENTO") {
                    this.isMature = true;
                    this.newSalesOrder.Campaign_Payment_Term_Date__c = null;
                    this.newSalesOrder.Campaign_Payment_Term__c = null;
                } else {
                    this.newSalesOrder.ReloadPaymentTerms__c = '';
                    this.newSalesOrder.Payment_Term__c = '';
                    var paymentTermsMap1 = this.paymentTermsMapDT
                    var pmObj = paymentTermsMap1[paymentTerm];
                    if (pmObj != undefined) {
                        this.isMature = false;
                        this.newSalesOrder.Maturity_Date__c = null;
                        this.newSalesOrder.Campaign_Payment_Term_Date__c = paymentTerm
                        this.newSalesOrder.Campaign_Payment_Term__c = pmObj.Id;
                    }
                }
            }
        }
        else {
            this.paymentTermDY = event.detail.value;
            var paymentTerm = this.paymentTermDY;
            this.isMature = false;
            this.newSalesOrder.ReloadPaymentTerms__c = paymentTerm;
            if (paymentTerm != "None") {
                var paymentTermsMap2 = this.paymentTermsMapDY;
                var pmObj = paymentTermsMap2[paymentTerm];
                var obj2 = new Object();
                obj2 = JSON.stringify(pmObj);
                if (pmObj != undefined) {
                    if (paymentTerm != 'BR00 SEM PAGAMENTO' && (pmObj.Payment_Term__r.Maturity_Date_Mandatory__c == Yes || pmObj.Payment_Term__r.Maturity_Date_Mandatory__c == "Yes")) {
                        this.isMature = true;
                    } else if (paymentTerm == 'BR00 SEM PAGAMENTO' && (pmObj.Maturity_Date_Mandatory__c == Yes || pmObj.Maturity_Date_Mandatory__c == "Yes")) {
                        this.isMature = true;
                    } else {
                        this.isMature = false;
                        this.newSalesOrder.Maturity_Date__c = null;
                    }
                    this.newSalesOrder.Campaign_Payment_Term__c = '';
                    this.newSalesOrder.Campaign_Payment_Term_Date__c = '';
                    this.selectedPaymentTermChangeDate = 'None';
                    if (paymentTerm != 'BR00 SEM PAGAMENTO') {
                        this.newSalesOrder.Payment_Term__c = pmObj.Payment_Term__c;
                        this.days = pmObj.Payment_Term__r.Days_to_calc_interest__c ? pmObj.Payment_Term__r.Days_to_calc_interest__c : 0;
                    } else {
                        this.newSalesOrder.Payment_Term__c = pmObj.Id;
                        this.days = pmObj.Days_to_calc_interest__c ? pmObj.Days_to_calc_interest__c : 0;
                    }
                }
            }
        }
        this.paymentTermOptions.forEach(opt => {
            opt.checked = (opt.value === event.detail.value);
        });
        let tempPaymentList = [];
        this.selectedPayTm = this.paymentTermOptions.find(item => item.checked === true);
        tempPaymentList.push(this.selectedPayTm);
        this.paymentTermOptions.forEach(currentItem => {
            const exists = tempPaymentList.some(item => item.value === currentItem.value);
            if (!exists) {
                tempPaymentList.push(currentItem);
            }
        });
        this.paymentTermOptions = tempPaymentList;
        this.selectedPaymentTerm = this.selectedPayTm.value;
    }
    handleCurrencySelect(event) {
        this.selectedCurrency = event.detail.value;
        this.newSalesOrder.Currency_Brazil__c = this.selectedCurrency;
        this.newSalesOrder.CurrencyIsoCode = this.newSalesOrder.Currency_Brazil__c === "Billing BRL / Payment BRL" ? "BRL" : "USD";
        this.currencyList.forEach(opt => {
            opt.checked = (opt.value === this.selectedCurrency);
        });
        if (this.selectedCurrency == undefined || this.selectedCurrency == 'None' || this.selectedCurrency == None) {
            this.selectedCurrency = "None";
        }
        this.getPriceListVal();
    }
    toggleDropdown(event) {
        const key = event.target.dataset.key;
        this.isDeliveryOpen = key === 'delivery' ? !this.isDeliveryOpen : false;
        this.isCurrencyOpen = key === 'currency' ? !this.isCurrencyOpen : false;
        this.isPaymentOpen = key === 'payment' ? !this.isPaymentOpen : false;
    }
    async handleSelection(event) {
        this.isUpdatePayTm = false;
        this.isUpdateCurrency = false;
        const key = event.currentTarget.dataset.key;
        const selectedValue = event.currentTarget.dataset.value;
        if (this.isCommunityUser) {
            this.updatedProductList = [...this.visibleRows];
        }
        if (key === 'delivery') {
            this.deliveryDropDownList = this.deliveryDropDownList.map(opt => ({
                ...opt,
                checked: opt.value === selectedValue
            }));
            this.newSalesOrder.Inco_Term__c = selectedValue;
            this.selectedDeliveryLabel = this.deliveryDropDownList.find(opt => opt.value === selectedValue).label;
            this.isDeliveryOpen = false;
        }
        if (key === 'currency') {
            this.allViewProductList = new Map(this.tempAllProductQtyMap);
            this.currencyDropDownList = this.currencyDropDownList.map(opt => ({
                ...opt,
                checked: opt.value === selectedValue
            }));
            this.selectedCurrency = selectedValue;
            this.newSalesOrder.Currency_Brazil__c = selectedValue;
            this.newSalesOrder.CurrencyIsoCode = this.newSalesOrder.Currency_Brazil__c === "Billing BRL / Payment BRL" ? "BRL" : "USD";
            this.isCurrencyOpen = false;
            if (this.isShowProductPage) {
                var tempList = [];
                this.updatedProductList.forEach(currentItem => {
                    tempList.push(currentItem);
                });
                this.visibleRows.forEach(currentItem => {
                    const exists = tempList.some(item => item.uid === currentItem.uid);
                    if (!exists) {
                        tempList.push(currentItem);
                    }
                });

                this.updateRowCalculations(tempList);
                this.visibleRows = this.visibleRows.map(item => {
                    const replacement = tempList.find(newItem => newItem.uid === item.uid);
                    return replacement ? replacement : item;
                });
                console.log('visibleRows::::::', this.visibleRows);
            }
            if (!this.isShowProductPage && this.isShowShoppingCart) {
                this.updateRowCalculations(this.salesOrderLineItems);
            }
        }
        if (key === 'payment') {
            console.log('selectedValue---->', selectedValue);
            const exists = this.fixDaysOptions.some(item => item.value === selectedValue);
            console.log('exists---->', exists);
            if (exists) {
                this.selectedPaymentTermChangeDate = selectedValue;
                this.isMature = false;
                var paymentTerm = this.selectedPaymentTermChangeDate;
                if (paymentTerm != 'None' && paymentTerm != None) {
                    this.paymentTermDY = 'None';
                    if (paymentTerm === "BR71 INFORMAR VENCIMENTO") {
                        this.isMature = true;
                        this.isShowModalOnPayTMChange = true;
                        this.newSalesOrder.Campaign_Payment_Term_Date__c = null;
                        this.newSalesOrder.Campaign_Payment_Term__c = null;
                    } else {
                        this.newSalesOrder.ReloadPaymentTerms__c = '';
                        this.newSalesOrder.Payment_Term__c = '';
                        var paymentTermsMap1 = this.paymentTermsMapDT
                        var pmObj = paymentTermsMap1[paymentTerm];
                        if (pmObj != undefined) {
                            this.isMature = false;
                            this.isShowModalOnPayTMChange = false;
                            this.newSalesOrder.Maturity_Date__c = null;
                            this.newSalesOrder.Campaign_Payment_Term_Date__c = paymentTerm
                            this.newSalesOrder.Campaign_Payment_Term__c = pmObj.Id;
                        }
                    }
                }
            }
            else {
                this.paymentTermDY = selectedValue;
                var paymentTerm = this.paymentTermDY;
                this.isMature = false;
                this.newSalesOrder.ReloadPaymentTerms__c = paymentTerm;
                if (paymentTerm != "None") {
                    var paymentTermsMap2 = this.paymentTermsMapDY;
                    var pmObj = paymentTermsMap2[paymentTerm];
                    var obj2 = new Object();
                    obj2 = JSON.stringify(pmObj);
                    if (pmObj != undefined) {
                        if (paymentTerm != 'BR00 SEM PAGAMENTO' && (pmObj.Payment_Term__r.Maturity_Date_Mandatory__c == Yes || pmObj.Payment_Term__r.Maturity_Date_Mandatory__c == "Yes")) {
                            this.isMature = true;

                        } else if (paymentTerm == 'BR00 SEM PAGAMENTO' && (pmObj.Maturity_Date_Mandatory__c == Yes || pmObj.Maturity_Date_Mandatory__c == "Yes")) {
                            this.isMature = true;
                        } else {
                            this.isMature = false;
                            this.newSalesOrder.Maturity_Date__c = null;
                        }
                        this.newSalesOrder.Campaign_Payment_Term__c = '';
                        this.newSalesOrder.Campaign_Payment_Term_Date__c = '';
                        this.selectedPaymentTermChangeDate = 'None';
                        if (paymentTerm != 'BR00 SEM PAGAMENTO') {
                            this.newSalesOrder.Payment_Term__c = pmObj.Payment_Term__c;
                            this.days = pmObj.Payment_Term__r.Days_to_calc_interest__c ? pmObj.Payment_Term__r.Days_to_calc_interest__c : 0;
                        } else {
                            this.newSalesOrder.Payment_Term__c = pmObj.Id;
                            this.days = pmObj.Days_to_calc_interest__c ? pmObj.Days_to_calc_interest__c : 0;
                        }
                    }
                }
            }
            let items = this.isShowProductPage ? this.updatedProductList : this.salesOrderLineItems;
            this.updateRowCalculations(items);
            if (this.isShowProductPage) {
                this.visibleRows = this.visibleRows.map(row => {
                    const updated = this.updatedProductList.find(item => item.uid === row.uid);
                    return updated ? { ...row, ...updated } : row;
                });
            }
            this.paymentTermDropDownList = this.paymentTermDropDownList.map(opt => ({
                ...opt,
                checked: opt.value === selectedValue
            }));
            this.selectedPayTm = this.paymentTermDropDownList.find(item => item.checked === true);
            var tempPaymentList = [];
            tempPaymentList.push(this.selectedPayTm);
            this.paymentTermDropDownList.forEach(currentItem => {
                const exists = tempPaymentList.some(item => item.value === currentItem.value);
                if (!exists) {
                    tempPaymentList.push(currentItem);
                }
            });
            this.paymentTermDropDownList = tempPaymentList;
            this.selectedPaymentTerm = this.selectedPayTm.value;
            console.log('Campaign_Payment_Term_Date__c--->', this.newSalesOrder.Campaign_Payment_Term_Date__c);
            this.isPaymentOpen = false;
        }
        this.showSpinnerWithDelay();
    }
    handleOutsideClick() {
        this.isDeliveryOpen = false;
        this.isCurrencyOpen = false;
        this.isPaymentOpen = false;
    }
    hideCloseMaturityModal() {
        this.isShowModalOnPayTMChange = false;
    }
    async fetchAccounts() {
        this.isSpinner = true
        var sellerId = this.newSalesOrder.KeyAccountDesOwnerBrazil__c;
        var userId = this.loggedInUser.Id;
        var orderType = this.newSalesOrder.Type_of_Order__c;
        var isKeyAccount = this.newSalesOrder.Key_Account__c;
        var showKeyAccount = this.showKeyAccount;
        var tempAccountData = [];
        var keyUserId = userId;
        if (isKeyAccount) {
            keyUserId = sellerId;
        }
        if (showKeyAccount && isKeyAccount && isKeyAccount != null) {
            var params = {
                userId: keyUserId,
                orderType: orderType,
                // customerGroup: this.selItem3.Sold_to_Party__r.Customer_Group__c,
                // accountId: this.selItem3.Sold_to_Party__r.Id
            }
            try {
                tempAccountData = await getKeyCustomers(params);
                this.accountList = tempAccountData;
                //.filter(record => record.Approval_contact_created__c === Yes);
                this.comboBoxAccounts = this.accountList.map(account => ({
                    label: account.Name,
                    value: account.Id,
                    record: account
                }));
                console.log('Combobox accounts--->', this.comboBoxAccounts);
            } catch (error) {
                console.error('Error in getCustomers:', error);
            } finally {
                this.isSpinner = false; // Stop spinner
            }
        }
        else {
            var regionCode;
            if (this.loggedInUser.Profile.Name == "Brazil Sales Office Manager") {
                regionCode = this.customerRegionForSOM
            }
            if (this.loggedInUser.Profile.Name == "Brazil Sales District Manager") {
                regionCode = this.customerRegionForSDM
            } var params = {
                profileName: this.loggedInUser.Profile.Name,
                loggedInUser: this.loggedInUser.Id,
                selectedUser: sellerId,
                orderType: orderType,
                // customerGroup:  this.selItem3.Sold_to_Party__r.Customer_Group__c,
                // accountId: this.selItem3.Sold_to_Party__r.Id,
                customerRegionCode: regionCode ? regionCode : 'null'
            }
            try {
                tempAccountData = await getCustomers(params);
                this.accountList = this.isCommunityUser ? tempAccountData.filter(record => record.Approval_contact_created__c === Yes) : tempAccountData;
                this.comboBoxAccounts = this.accountList.map(account => ({
                    label: account.Name,
                    value: account.Id,
                    record: account
                }));
                console.log('this Community user--->', this.isCommunityUser)
                console.log('Combobox accounts-1111-->', this.comboBoxAccounts);
            } catch (error) {
                console.error('Error in getCustomers:', error);
            } finally {
                this.isSpinner = false; // Stop spinner
            }
        }
        this.accountTableColumns = this.getAccountTableCols();
        return true;
    }
    @track taxNumber = '';
    handleRowAction(event) {
        if (event.detail != null) {
            var itemRow;
            let selectedValue = event.detail.value
            itemRow = this.accountList.find(acc => acc.Id === selectedValue);
            this.selItem = itemRow;
            customerExist({ cusId: itemRow.Id }).then((result) => {
                if (result) {
                    this.selectedCustomer = itemRow.Id;
                    this.newSalesOrder.Sold_to_Party__c = itemRow.Id;
                    this.taxNumber = this.formatCNPJ(itemRow.Tax_Number_1__c);
                    this.newSalesOrder.Program_Margin_Discount__c = itemRow.Program_Margin_Discount__c;
                    this.newSalesOrder.Price_Conversion_Factor__c = itemRow.Price_Conversion_Group__c;
                    this.shippingLocations();
                    this.getPriceListVal();
                    this.getTaxAndFreight();
                    if (this.selectedPriceList) {
                        this.getPBPayMent(this.selectedPriceList);
                    }
                    this.template.querySelector('[data-id="custitem"]').classList.remove('slds-has-error');
                    var userId = '';
                    if (this.selectedUser != null && this.selectedUser != undefined && this.selectedUser != '') {
                        userId = this.selectedUser;
                    } else {
                        userId = this.loggedInUser.Id;
                    }
                    this.fetchBusinessRule(userId);
                }
                else {
                    this.template.querySelector('[data-id="custitem"]').clearlookup();
                    this.selItem = new Object();
                    this.selItem5 = new Object();
                    alert('Cliente sem Contato Aprovador Cadastrado, por favor procure o Customer Services');
                }
            }).catch((error) => {
                console.log('Error in checking if customer exist---->', error);
            });

        }
    }
    getAccountTableCols() {
        this.fieldsList = ['SAP_Code__c', 'BillingCity', 'Tax_Number_1__c', 'Tax_Number_3__c'];
        return [
            { label: BrazilAction, type: "button", initialWidth: 150, typeAttributes: { label: Select, title: "Select", name: "Select", class: "btn_next" } },
            { label: Customer_Code, fieldName: "SAP_Code__c" },
            { label: Name, fieldName: "Name" },
            { label: Group, fieldName: "Customer_Group__c" },
            { label: City, fieldName: "BillingCity" },
            // { label: Region, fieldName: "Customer_Region__c" },
            { label: "DepotCode", fieldName: "Brazil_Depot_Code__r.Depot_Code__c" },
            { label: Tax_Number_3, fieldName: "Tax_Number_3__c" },
            // { label: Approval_contact_created, fieldName: "Approval_contact_created__c" },
            // { label: Brazil_Search_Term, fieldName: "Search_Terms_2__c" }
        ];
    }

    showModalBox() {
        this.isBuyNowSOBtnClicked = true;
    }

    hideModalBox() {
        this.isBuyNowSOBtnClicked = false;
        window.location.replace('https://upl--uat.sandbox.my.site.com/uplpartnerportal/s/');
    }
    // @track daysInDelivery;
    handleSubmit() {
        const isValidOrder = this.validateModalFields();
        if (isValidOrder) {
            this.currencyDropDownList = this.currencyList;
            this.deliveryDropDownList = this.deliveryOptions;
            this.paymentTermDropDownList = this.paymentTermOptions;
            this.isShowModal = false;
            getEstimatedDeliveryDate({ customerRegionCode: this.selItem.Customer_Region__c }).then((result) => {
                //    this.daysInDelivery = result;
                console.log('Result---->', result);
            }).catch((err) => {

            });
        }
        else {
            this.showToast('error', 'Error', Please_provide_valid_input_fill_all_the_mandatory_fields_before_proceeding)
        }
    }
    formatCNPJ(cnpj) {
        cnpj = cnpj.replace(/\D/g, '');
        if (cnpj.length !== 14) {
            throw new Error("CNPJ must be 14 digits");
        }
        return cnpj.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/,
            "$1.$2.$3/$4-$5");
    }
    @track productBrandName = '';
    @track tempAllProductQtyMap = new Map();
    initializedBrands = {};
    async handleViewProduct(event) {
        const clickedElement = event.target.closest('[data-id]');
        this.productBrandName = clickedElement ? clickedElement.dataset.id : null;

        console.log('Clicked product:', this.productBrandName);
        this.oldValueQty = 0;
        let flag = false;
        this.updatedProductList = [];
        this.productTitle = this.productBrandName;
        console.log('this.notMatchingProductList----->', this.notMatchingProductList);
        await this.sendDataForIntegration(this.productBrandName);

        if (this.productVariants.length > 0) {
            for (const product of this.priceDetailList) {
                const matchingProduct = this.products.find((p) => p.Name === product.brand);
                console.log('matchingProduct--->', product.skuId);

                if (matchingProduct && matchingProduct.Name === this.productBrandName) {
                    if (!product.avail) {
                        const toastMsg = product.skuDescription + ' : ' + Brazil_Product_Availability;
                        this.showToast('error', 'Error', toastMsg);
                        return;
                    }

                    /*if (!product.inMVObj) {
                        this.showToast(
                            'error',
                            'Error',
                            'Não há registro na matriz Market Variations para o(s) produto(s): ' +
                            product.brand +
                            '. Entre em contato com o time de Price.'
                        );
                        return;
                    }*/

                    if (product.itemStatus && product.itemStatus !== 'Active') {
                        this.showToast('error', 'Error', product.brand + ' Item cancelado.');
                        return;
                    }
                    const { materialPlnRplcCost: replc, materialActive } = product;
                    if (!materialActive) {
                        this.showToast('error', 'Error', product.skuDescription + ' : ' + Brazil_Material_Inactive_Message);
                        return;
                    }

                    if (replc < 0) {
                        this.showToast('error', 'Error', product.skuDescription + ' : ' + Replacement_Cost_Validation_Error);
                        return;
                    }

                    if (replc == null || replc == 0) {
                        this.showToast(
                            'error',
                            'Error',
                            product.skuDescription +
                            ' : ' +
                            'Não é possível usar este produto com custo zerado. Contacte mark.borges@upl-ltd.com.'
                        );
                        return;
                    }

                    if (!product.isValid && !product.kitProduct) {
                        const errorMessage =
                            product.skuDescription +
                            ' : ' +
                            Registration_date_is_out_of_limit_Please_contact_the_Customer_Service_Team;
                        this.showToast('error', 'Error', errorMessage);
                        return;
                    }

                    flag = true;
                }
            }

            if (flag) {
                if (!this.initializedBrands[this.productBrandName]) {
                    this.productVariants.forEach((currentItem) => {
                        if (!this.allViewProductList.has(currentItem.uid)) {
                            this.allViewProductList.set(currentItem.uid, currentItem.Available_Quantity);
                        }
                        if (!this.tempAllProductQtyMap.has(currentItem.uid)) {
                            this.tempAllProductQtyMap.set(currentItem.uid, currentItem.Available_Quantity);
                        }
                    });
                    this.initializedBrands[this.productBrandName] = true;
                    console.log(`Initialized map for brand: ${this.productBrandName}`, this.tempAllProductQtyMap);
                }
                this.getButtonsWithClass();
                this.isShowProductPage = true;
                this.featuredProudcts = false;
            }
        }

        this.handleOutsideClick();
    }

    backToList() {
        this.isShowProductPage = false;
        this.featuredProudcts = true;
        this.isShowShoppingCart = false;
        this.searchProducts = '';
        this.paginatedProducts = this.products;
        this.allViewProductList = new Map(this.tempAllProductQtyMap);
        console.log('allViewProductList--tempAllProductQtyMap->', this.allViewProductList);
        this.handleOutsideClick();
        this.showSpinnerWithDelay();
    }
    downloadProductInstructions() {
        this.isShowDownloadModal = true;
    }
    downloadFile(event) {
        window.open(
            event.currentTarget.dataset.id, "_blank");
    }

    hideDownloadModalBox() {
        this.isShowDownloadModal = false;
    }
    get items() {
        this.salesOrderLineItems = this.productsInCart;
        this.totalProducts = this.salesOrderLineItems.length;
        return this.salesOrderLineItems;
    }

    createNewRow(element) {
        var minVal = 0;
        var unitVal = 0;
        var monthlyInterestRate = 0;
        if (this.newSalesOrder.Currency_Brazil__c == "Billing BRL / Payment BRL") {
            minVal = element.minValueBRL;
            monthlyInterestRate = element.monthlyInterestRateBRL;
        } else {
            minVal = element.minValueUSD;
            monthlyInterestRate = element.monthlyInterestRateUSD;
        }
        var uniqueId = Math.random().toString(36).substring(2);
        const userTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
        let nowUser = new Date(new Date().toLocaleString("en-US", { timeZone: userTimeZone }));
        nowUser.setDate(nowUser.getDate() + 1);
        //  var delivery = new Date();
        //   var deliveryDays = this.daysInDelivery ? this.daysInDelivery : '0';
        //  tomorrow.setDate(tomorrow.getDate() + 1);
        var tomorrowStr = nowUser.toISOString().split("T")[0];
        //     delivery.setDate(delivery.getDate() + 1 + parseInt(deliveryDays) + 2);
        const newRow = {
            Ids: element.brand + '-' + uniqueId,
            productName: element.skuDescription,
            fatDate: this.isCommunityUser ? tomorrowStr : '',
            fatDateNew: element.fatDateNew,
            qty: (this.newSalesOrder.Type_of_Order__c == 'ORDEM FILHA' || element.qty == 0) ? null : element.qty,
            qtyNew: element.qtyNew,
            unitValue: element.unitValue,
            productImage: this.selectedImage,
            totalValueWithInterest: element.totalValueWithInterest,
            replacementMarginUP: element.replacementMarginUP,
            replacementMargin: element.replacementMargin,
            discount: element.discount,
            DiscountBarter: element.DiscountBarter,
            DDSGrade: element.DDSGrade,
            Recommendedprice: element.Recommendedprice,
            impactgpvslp: element.impactgpvslp,
            days: this.days ? this.days : 0,
            numberOfDays: 0,
            minDate: element.minDate,
            maxDate: element.maxDate,
            kitProduct: element.kitProduct,
            productId: element.skuId,
            CustomerConversionFactor: element.custconversionfator,
            custconversionfatorMin: element.custconversionfatorMin,
            skuCategory: element.skuCategory,
            itemCategory: element.itemCategory,
            brand: element.brand,
            selloutprice: element.currencyCode == 'Only BRL' ? element.selloutprice : element.selloutpriceU,
            unitValueWithInterest: 0,
            aderencia: element.aderencia,//Updated by Grz(Dheeraj Sharma) for RITM0870192 on 20Nov2024
            listValue: unitVal,
            budgetValue: this.newSalesOrder.Currency_Brazil__c == 'Billing BRL / Payment BRL' ? element.budgetValueBRL : element.budgetValueUSD,
            priceBookDetailId: element.pricebookId,
            inventory: element.balanceQty,
            productCode: element.skuCode,
            multipleOf: element.multipleOf,
            itemNo: element.itemNo,
            moItemNo: element.itemNo,
            isMO: element.isMO,
            salesDeductionCost: element.salesDeductionCost,
            cogsCost: element.cogsCost,
            blnkt_EndDate: element.blnkt_EndDate,
            blnkt_StartDate: element.blnkt_StartDate,
            blnkt_Status: element.blnkt_Status,
            isBlanket: element.isBlanket,
            level1Max: this.adminMPTParameter.level1Max,
            level1Min: this.adminMPTParameter.level1Min,
            level2Max: this.adminMPTParameter.level2Max,
            level2Min: this.adminMPTParameter.level2Min,
            level3Below: this.adminMPTParameter.level3Below,
            approvalLevel: this.adminMPTParameter.approvalLevel,
            uom: element.uom,
            baseUOM: element.uom,
            e2eCost: element.e2eCost,
            exchngRate: element.exchangeRate,
            curncyCode: element.currencyCode,
            currency_Code: element.currencyCode,
            materialPlnRplc_Cost: this.loggedInUser.Profile.Name != 'Brazil Sales Person' ? element.materialPlnRplcCost : 0.00,
            create_Date: this.loggedInUser.Profile.Name != 'Brazil Sales Person' ? element.create_Dt : '',
            unitValueBRL: element.unitValueBRL ? element.unitValueBRL : 0,
            unitValueUSD: element.unitValueUSD ? element.unitValueUSD : 0,
            minValue: this.loggedInUser.Profile.Name != 'Brazil Sales Person' ? minVal * element.custconversionfatorMin : 0,
            orderItemId: this.newSalesOrder.Type_of_Order__c == 'ORDEM FILHA' ? element.orderItemId : '',
            interestRate: monthlyInterestRate,
            minFatDate: element.minFatDate,
            deliveryDate: this.currentDeliveryDate
        }
        return newRow;
    }
    validateOrder() {
        var flag = true;
        const poNum = this.template.querySelector('[data-id="poNo"]');
        if (poNum && !poNum.value) {
            flag = false;
            poNum.setCustomValidity(Purchase_Order_No_is_required);
            poNum.classList.add('slds-has-error');
            poNum.reportValidity();
        }
        const poDate = this.template.querySelector('[data-id="poDate"]');
        if (poDate && !poDate.value) {
            flag = false;
            poDate.setCustomValidity(Purchase_Order_date_is_required);
            poDate.classList.add('slds-has-error');
            poDate.reportValidity();
        }
        return flag;
    }
    completeOrder() {
        if (this.validateLineItems() && this.validateOrder()) {
            this.isUpdateCurrency = false;
            this.isUpdatePayTm = false;
            this.showTermsConditions = true;
        }
    }

    mergeRowsWithPriceList(visibleRows) {
        console.log('hello!!!!!!!----> visibleRows---->', visibleRows);
        const priceMap = new Map();
        // this.priceDetailList.forEach(item => {
        //     visibleRows.forEach(currentItem => {
        //          priceMap.set(currentItem.uid, item);
        //     });
        // });
        visibleRows.forEach(item => {
            const existingItem = this.priceDetailList.find(product => product.skuCode === item.Sku_Code);
            console.log('existingItem---->', existingItem);
            priceMap.set(item.uid, existingItem);
        });
        console.log('hello!!!!!!!----> priceMap---->', priceMap);
        const mergedRows = visibleRows.map(visibleItem => {
            var priceItem = priceMap.get(visibleItem.uid);
            console.log('priceItem---->', priceItem);
            if (priceItem !== undefined) {
                console.log('hcjvashjhjhhhhh');
                priceItem = this.createNewRow(priceItem);
                console.log(priceItem);
                return priceItem ? { ...visibleItem, ...priceItem } : visibleItem;
            }
        });
        console.log('mergedRows-->', JSON.stringify(mergedRows));
        return mergedRows.filter(row => row);;
    }
    validateQuantity(event) {
        let inputField = event.target;
        let flag = false;
        let invalidInventory = [];
        let invalidQuantity = [];
        var flagForQuantityErr = false;
        var flagForInv = false;
        let flagForInventory = false;
        let flagForQuantity = false;
        var errorMessage = '';
        console.log('inputField.value--->', inputField.value);
        let enteredQty = parseFloat(inputField.value) || 0;
        enteredQty = Math.abs(enteredQty);
        let index = inputField.dataset.index;
        let row = this.visibleRows[index];
        console.log('Row--->' + JSON.stringify(row));
        // const dateWrapper = this.template.querySelector(`div[data-id="${row.uid}"]`);
        // if (!row.hasOwnProperty('fatDate') || row.fatDate === '' || row.fatDate === undefined || row.fatDate === null) {
        //     inputField.value = '';
        //     row.qty = 0;
        //     this.showToast('error', 'Error', 'Data da fatura é necessária');
        //     if (dateWrapper) {
        //         dateWrapper.classList.add('slds-has-error');
        //     }
        //     return;
        // }
        row.Available_Quantity = this.visibleRows[index].Available_Quantity;
        if (this.oldValueQty == enteredQty) {
            return;
        }
        if (!isNaN(this.oldValueQty) && this.oldValueQty > 0) {
            row.qty = 0;
            row.Available_Quantity += this.oldValueQty;
            inputField.value = '';
        }
        console.log('Enetered Quanitity--->', enteredQty + '=======' + Math.abs(enteredQty));
        if (!enteredQty) {
            console.log('Hiiii');
            this.updatedProductList = this.updatedProductList.filter(product => product.uid !== row.uid);
            console.log('Hiidfdddii');
            this.oldValueQty = 0;
            inputField.value = '';
            row.qty = 0;
            row.totalValue = 0;
            this.updateRowCalculations(this.updatedProductList);
            return;
        }
        if (enteredQty > row.Available_Quantity) {
            flag = true;
            errorMessage = 'A quantidade não pode ser maior que a quantidade disponível : ' + row.Available_Quantity;
        }
        // if (this.isCommunityUser && row.multipleOf && (enteredQty % row.multipleOf !== 0 || enteredQty < row.multipleOf)) {
        //     flag = true;
        //     errorMessage = Qty_should_be_in_multiple_of + ' ' + row.multipleOf;
        // }
        if (flag) {
            inputField.value = '';
            row.qty = 0;
            this.showToast('error', 'Error', errorMessage)
            inputField.classList.add('slds-has-error');
        }
        else {
            row.qty = enteredQty;
            // let price = this.newSalesOrder.CurrencyIsoCode === 'BRL' ? row.unitValueBRL1 : row.unitValueUSD1;
            // row.unitValue = price;
            inputField.classList.remove('slds-has-error');
            let existingProduct = this.updatedProductList.find(product => product.uid === row.uid);
            row.Available_Quantity -= enteredQty;
            if (existingProduct) {
                existingProduct.qty = enteredQty;
                existingProduct.Available_Quantity = row.Available_Quantity;
            } else {
                this.updatedProductList.push({ ...row });
            }
            if (enteredQty !== this.oldValueQty) {
                //this.updatePriceTable(event,result.quantity);
            }
            console.log('this.updatedProductList@@3333' + JSON.stringify(this.updatedProductList));
            this.updateRowCalculations(this.updatedProductList);
            const updatedItem = this.updatedProductList.find(product => product.uid === row.uid);
            if (updatedItem) {
                this.visibleRows = this.visibleRows.map(visibleItem => {
                    return visibleItem.uid === updatedItem.uid ? { ...updatedItem } : visibleItem;
                });
            }
        }
    }

    updateRowCalculations(orderItemList) {
        var punct_Discount = 0;
        var tax = this.businessRule.Taxes__c;
        var freight = this.businessRule.Freight__c;
        var crtDate = '';
        var profileName = this.loggedInUser.Profile.Name;
        var totalValue = 0;
        var totalTaxAmt = 0;
        var totalFreightAmt = 0;
        var TotalPunctualityDiscount = 0;
        var lessPrsntValue = false;
        var intrstDate = this.interestDate;
        var paymntDate = this.newSalesOrder.Campaign_Payment_Term_Date__c;
        var isCampainCheck = this.newSalesOrder.Use_Campaign__c;
        var isAvec = this.newSalesOrder.AVEC_Order__c;
        var customerTaxFreight = this.customerTaxFreight;
        var totalMargin = 0;
        var totalPrice = 0;
        var totalTax = 0;
        var totalPunctualityCal = 0;
        var totalSalesDeductionCal = 0;
        var totalE2eCal = 0;
        var totalFreight = 0;
        var tatalCOGSCal = 0;
        let days = this.days;
        var totalQty = 0
        if (isAvec && this.newSalesOrder.Maturity_Date__c) {
            paymntDate = this.newSalesOrder.Maturity_Date__c;
        }
        console.log('newSalesOrder : ', this.newSalesOrder);
        let newpaymntDate = paymntDate ? new Date(paymntDate) : null;
        var newintrstDate;
        if (!isNaN(intrstDate)) {
            newintrstDate = parseInt(intrstDate);
        } else {
            let parsedDate = new Date(intrstDate);
            newintrstDate = isNaN(parsedDate) ? null : parsedDate;
        }
        console.log('newpaymntDate : ', newpaymntDate);
        console.log('newintrstDate : ', newintrstDate);
        console.log('Days_to_calc_interest__c : ', this.days);
        orderItemList.forEach(item => {
            item.days = this.days;
            let PunctualityDiscountCalculated = 0;
            let taxAmt = 0;
            let freightAmt = 0;
            var prsntValue = 0;
            let flag = true;
            if (flag) {
                var replaceCost, exchRat, totalReplacementCost, unitValueBRL1, unitValueUSD1, unitValAderBRL, unitValAderUSD;
                let nfatDate = new Date(item.fatDate);
                item.unitValueBRL1 = item.unitValueBRL * item.CustomerConversionFactor;
                item.unitValueUSD1 = item.unitValueUSD * item.CustomerConversionFactor;
                item.unitValAderBRL = item.unitValueBRL * item.CustomerConversionFactor;
                item.unitValAderUSD = item.unitValueUSD * item.CustomerConversionFactor;
                item.unitValue = this.newSalesOrder.CurrencyIsoCode === 'BRL' ? item.unitValueBRL1 : item.unitValueUSD1;
                console.log('BRL Unit Value with Customer Conversionfactor--->' + item.unitValueBRL + ' * ' + item.CustomerConversionFactor + '--->' + item.unitValueBRL1);
                console.log('USD Unit Value with Customer Conversionfactor--->' + item.unitValueUSD + ' * ' + item.CustomerConversionFactor + '--->' + item.unitValueUSD1);
                replaceCost = item.materialPlnRplcCost;
                exchRat = item.exchangeRate;
                item.qty = Math.abs(item.qty);
                item.unitValue = Math.abs(item.unitValue);
                item.totalValue = item.qty * item.unitValue;
                item.totalValueWithInterest = item.qty * item.unitValue;
                if (profileName !== "Brazil Sales Person") {
                    taxAmt = (tax * item.totalValue) / 100;     // tax is bussiness rule tax
                    freightAmt = (freight * item.totalValue) / 100;
                    if (!item.kitProduct) {
                        totalTaxAmt += taxAmt;
                        totalFreightAmt += freightAmt;
                        PunctualityDiscountCalculated = (punct_Discount * item.totalValueWithInterest) / 100;
                        TotalPunctualityDiscount += PunctualityDiscountCalculated;
                    }
                    crtDate = item.create_Date ? new Date(item.create_Date).toISOString().split("T")[0] : ''
                    console.log('crtDate : ', crtDate);
                }
                if (newpaymntDate) {

                    if (newintrstDate instanceof Date && !isNaN(newintrstDate)) {
                        item.timeInMonths = nfatDate > newintrstDate
                            ? Math.ceil(newpaymntDate - nfatDate)
                            : Math.ceil(newpaymntDate - newintrstDate);

                        item.timeInMonths = item.timeInMonths / (1000 * 60 * 60 * 24);
                        console.log('log 1 ', item.timeInMonths);
                    } else if (typeof newintrstDate === "number") {
                        let diffDays = Math.ceil((new Date(newpaymntDate) - nfatDate) / (1000 * 60 * 60 * 24)) - newintrstDate;
                        item.timeInMonths = diffDays < 0 ? 0 : diffDays;
                        console.log('log 2 ', item.timeInMonths);
                    }
                    item.unitValueWithInterest = this.calculateUnitValueWithInterest(item);
                    prsntValue = item.unitValue;
                } else if (newpaymntDate == null && days !== '' && days != null) {
                    console.log('New ');
                    if (newintrstDate instanceof Date && !isNaN(newintrstDate)) {
                        console.log('shashank diffday, ', newintrstDate - nfatDate);
                        let diffDays = days - Math.ceil((newintrstDate - nfatDate) / (1000 * 60 * 60 * 24));
                        item.timeInMonths = nfatDate > newintrstDate ? days : diffDays;
                        item.timeInMonths = item.timeInMonths < 0 ? 0 : item.timeInMonths;
                        console.log('log 3 ', item.timeInMonths);
                    } else if (typeof newintrstDate === "number") {
                        nfatDate.setDate(nfatDate.getDate() + days - newintrstDate);
                        let diffDays = (nfatDate - new Date(item.fatDate)) / (1000 * 60 * 60 * 24);
                        item.timeInMonths = diffDays < 0 ? 0 : diffDays;
                        console.log('log 4 ', item.timeInMonths);
                    }
                    item.unitValueWithInterest = this.calculateUnitValueWithInterest(item);
                    prsntValue = item.unitValue;
                } else {
                    item.unitValueWithInterest = item.unitValue;
                    prsntValue = item.unitValue;
                }
            }
            item.convertedQnty = item.qty;
            item.convertedNetPrice = item.unitValueWithInterest;
            if (item.curncyCode == "Only BRL" || item.curncyCode == "BRL") {
                item.salesDeductionCal = item.salesDeductionCost * item.qty * item.exchngRate;
                item.cogsCostCal = item.cogsCost * item.qty * item.exchngRate;
                item.e2eCostCal = item.e2eCost * item.qty * item.exchngRate;
            }
            else {
                item.salesDeductionCal = item.salesDeductionCost * item.qty;
                item.cogsCostCal = item.cogsCost * item.qty;
                item.e2eCostCal = item.e2eCost * item.qty;
            }
            taxAmt = 0; freightAmt = 0; PunctualityDiscountCalculated = 0;
            var totVal = item.unitValueWithInterest * item.qty;
            console.log('Total value11111---->', totVal);
            if (customerTaxFreight.customerRegion) {
                taxAmt = (customerTaxFreight.tax * totVal) / 100;
                freightAmt = (customerTaxFreight.freight * totVal) / 100;
            }
            PunctualityDiscountCalculated = (punct_Discount * totVal) / 100;
            item.totalValue = totVal;
            totalPrice += totVal;
            totalTax += taxAmt;
            totalPunctualityCal += PunctualityDiscountCalculated;
            totalSalesDeductionCal += item.salesDeductionCal;
            totalE2eCal += item.e2eCostCal;
            totalFreight += freightAmt;
            tatalCOGSCal += item.cogsCostCal;
            totalQty += item.qty;
            item.contMargin = (((totVal - taxAmt - PunctualityDiscountCalculated - item.salesDeductionCal) - (item.e2eCostCal + freightAmt + item.cogsCostCal)) / (totVal - taxAmt - PunctualityDiscountCalculated - item.salesDeductionCal)) * 100;

            item.mbLevel1 = false; // reset here..
            item.mbLevel2 = false; // reset here..
            if (item.isBlanket == false) {
                if (item.contMargin >= item.level2Min && item.contMargin <= item.level2Max) {
                    item.mbLevel1 = true;
                }
                else if (item.contMargin <= item.level3Below) {
                    item.mbLevel1 = true;
                }
            }

            if (!item.kitProduct && item.ItemStatus != 'Inactive') {
                totalValue += parseFloat(item.totalValue); //change by Ganesh
            }
            totalMargin = (((totalPrice - totalTax - totalPunctualityCal - totalSalesDeductionCal) - (totalE2eCal + totalFreight + tatalCOGSCal)) / (totalPrice - totalTax - totalPunctualityCal - totalSalesDeductionCal)) * 100;
        });
        console.log('Updated orderItemList : ', orderItemList);
        console.log('Updated orderItemList totalValue: ', totalValue);
        console.log('Updated orderItemList total_Overall_Margin : ', totalMargin);
        console.log('Updated salesOrderLineItems : ', JSON.stringify(orderItemList));
        this.newSalesOrder.Total_Overall_Margin__c = parseFloat(totalMargin).toFixed(2);
        this.totalPrice = totalPrice;
        this.totalQty = totalQty;
    }

    calculateUnitValueWithInterest(item) {
        let time = item.timeInMonths > 0 ? item.timeInMonths : 0;
        let unit = item.unitValue;
        let rate = (item.interestRate / 100) / 30;
        let days = time;
        let result = unit + (unit * rate * days);
        console.log('Calculation-->',
            `${unit} + (${unit} * ${rate} * ${days}) = ${result}`
        );
        return item.unitValue + (item.unitValue * ((item.interestRate / 100) / 30) * time);
    }
    @track customerTaxFreight;
    getTaxAndFreight() {
        if (this.selItem.Customer_Region__c) {
            getCustomerTaxFreight({
                regnName: this.selItem.Customer_Region__c
            }).then(result => {
                this.customerTaxFreight = result;
            })
                .catch(error => {
                    console.error('Error retrieving getCustomerTaxFreight Date::::', error);
                });
        }
    }

    addToCart() {
        let flag = true;
        let copiedProducts = this.updatedProductList.filter(obj => obj.qty > 0 || obj.fatDate != '');
        console.log('copiedProducts----->', copiedProducts);
        copiedProducts.forEach(currentItem => {
            console.log('FAT Date--->', currentItem);
            const dateWrapper = this.template.querySelector(`div[data-id="${currentItem.Ids}"]`);
            if (!currentItem.hasOwnProperty('fatDate') || currentItem.fatDate === '' || currentItem.fatDate === undefined || currentItem.fatDate === null) {
                this.showToast('error', 'Error', 'Data da fatura é necessária');
                flag = false;
                if (dateWrapper) {
                    dateWrapper.classList.add('slds-has-error');
                }
            }
        });
        if (flag) {
            if (this.productsInCart.length <= 0) {
                this.productsInCart = [...copiedProducts];
            } else {
                this.productsInCart = [...this.productsInCart, ...copiedProducts];
            }
            this.salesOrderLineItems = [...this.productsInCart];
            this.addtoCartCounter = this.addtoCartCounter + copiedProducts.length;
            this.oldValueQty = 0;
            this.updatedProductList = [];
            if (!this.isShowShoppingCart) {
                this.sendDataForIntegration(this.productBrandName);
            }
        }
    }

    get isDisableOpenCart() {
        return this.addtoCartCounter > 0 ? true : false;
    }
    updateQuantityMap() {
        this.salesOrderLineItems.forEach(cartItem => {
            if (this.allViewProductList.has(cartItem.uid)) {
                let updatedQty = this.allViewProductList.get(cartItem.uid) - cartItem.qty;
                if (updatedQty < 0) {
                    updatedQty = 0;
                }
                this.allViewProductList.set(cartItem.uid, updatedQty);
            }
        });
        console.log('Updated allViewProductList after Cart Load:', Array.from(this.allViewProductList.entries()));
    }
    @track cartProductsQty;
    buyNow() {
        let flag = true;
        let copiedProducts = this.updatedProductList.filter(obj => obj.qty > 0 || obj.fatDate != '');
        copiedProducts.forEach(currentItem => {
            console.log('FAT Date--->', currentItem);
            const dateWrapper = this.template.querySelector(`div[data-id="${currentItem.Ids}"]`);
            if (!currentItem.hasOwnProperty('fatDate') || currentItem.fatDate === '' || currentItem.fatDate === undefined || currentItem.fatDate === null) {
                this.showToast('error', 'Error', 'Data da fatura é necessária');
                flag = false;
                if (dateWrapper) {
                    dateWrapper.classList.add('slds-has-error');
                }
            }
        });
        if (flag) {
            this.isShowShoppingCart = true;
            this.isShowProductPage = false;
            this.isBuyNowClicked = true;
            this.addToCart();
            this.updateQuantityMap();
            console.log('Line Items---------A->N', JSON.stringify(this.salesOrderLineItems));
            this.updateRowCalculations(this.salesOrderLineItems);
            this.showSpinnerWithDelay();
        }
    }
    @track billingAddress = '';
    shippingLocations() {
        getShippingLoations({ accId: this.selItem.Id }).then((result) => {
            if (result.length == 0) {
                this.showToast('error', 'Error', There_is_no_Ship_to_Party_option_available_for_this_Customer);
            }
            if (result.length == 1) {
                this.billingAddress = this.getBillingAdrress(result[0]);
                this.selItem5 = result[0];
                this.newSalesOrder.Ship_To_Party__c = result[0].Id;
            }
        }).catch((err) => {

        });
    }
    getBillingAdrress(data) {
        var billingStreet = '';
        console.log('billingStreet--->', data);
        const streetParts = [
            data.Billing_Street_1__c,
            data.Billing_Street_2__c,
            data.Billing_Street_3__c,
            data.Billing_Street_4__c
        ].filter(part => part && part.trim() !== '');
        billingStreet = streetParts.join(', ');
        console.log('billingStreet--->', billingStreet);
        return billingStreet + ', ' + `${data.City__c}, ${data.State__c}, ${data.Pincode__c}, ${data.Billing_Street_6__c}, ${data.Country__c}`;
    }
    updatePaytm() {
        this.isUpdatePayTm = true;
    }
    updateCurency() {
        this.isUpdateCurrency = true;
    }

    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
        this.newSalesOrder.Currency_Brazil__c = this.selectedCurrency;
        this.newSalesOrder.CurrencyIsoCode = this.newSalesOrder.Currency_Brazil__c === "Billing BRL / Payment BRL" ? "BRL" : "USD";
        this.isUpdateCurrency = false;
        this.currencyDropDownList.forEach(opt => {
            opt.checked = (opt.value === this.selectedCurrency);
        });
        if (this.selectedCurrency == undefined || this.selectedCurrency == 'None' || this.selectedCurrency == None) {
            this.selectedCurrency = "None";
        }
        this.getPriceListVal();
        this.updateRowCalculations(this.salesOrderLineItems);
    }
    handlePayTmSelect(event) {
        this.selectedPaymentTerm = event.detail.value;
        const exists = this.fixDaysOptions.some(item => item.value === event.detail.value);
        if (exists) {
            this.selectedPaymentTermChangeDate = event.detail.value;
            this.isMature = false;
            var paymentTerm = this.selectedPaymentTermChangeDate;
            if (paymentTerm != 'None' && paymentTerm != None) {
                this.paymentTermDY = 'None';
                if (paymentTerm === "BR71 INFORMAR VENCIMENTO") {
                    this.isMature = true;
                    this.isShowModalOnPayTMChange = true;
                    this.newSalesOrder.Campaign_Payment_Term_Date__c = null;
                    this.newSalesOrder.Campaign_Payment_Term__c = null;
                } else {
                    this.newSalesOrder.ReloadPaymentTerms__c = '';
                    this.newSalesOrder.Payment_Term__c = '';
                    var paymentTermsMap1 = this.paymentTermsMapDT
                    var pmObj = paymentTermsMap1[paymentTerm];
                    if (pmObj != undefined) {
                        this.isMature = false;
                        this.isShowModalOnPayTMChange = false;
                        this.newSalesOrder.Maturity_Date__c = null;
                        this.newSalesOrder.Campaign_Payment_Term_Date__c = paymentTerm
                        this.newSalesOrder.Campaign_Payment_Term__c = pmObj.Id;
                    }
                }
            }
        }
        else {
            this.paymentTermDY = event.detail.value;
            var paymentTerm = this.paymentTermDY;
            this.isMature = false;
            this.newSalesOrder.ReloadPaymentTerms__c = paymentTerm;
            if (paymentTerm != "None") {
                var paymentTermsMap2 = this.paymentTermsMapDY;
                var pmObj = paymentTermsMap2[paymentTerm];
                var obj2 = new Object();
                obj2 = JSON.stringify(pmObj);
                if (pmObj != undefined) {
                    if (paymentTerm != 'BR00 SEM PAGAMENTO' && (pmObj.Payment_Term__r.Maturity_Date_Mandatory__c == Yes || pmObj.Payment_Term__r.Maturity_Date_Mandatory__c == "Yes")) {
                        this.isMature = true;
                    } else if (paymentTerm == 'BR00 SEM PAGAMENTO' && (pmObj.Maturity_Date_Mandatory__c == Yes || pmObj.Maturity_Date_Mandatory__c == "Yes")) {
                        this.isMature = true;
                    } else {
                        this.isMature = false;
                        this.newSalesOrder.Maturity_Date__c = null;
                    }
                    this.newSalesOrder.Campaign_Payment_Term__c = '';
                    this.newSalesOrder.Campaign_Payment_Term_Date__c = '';
                    this.selectedPaymentTermChangeDate = 'None';
                    if (paymentTerm != 'BR00 SEM PAGAMENTO') {
                        this.newSalesOrder.Payment_Term__c = pmObj.Payment_Term__c;
                        this.days = pmObj.Payment_Term__r.Days_to_calc_interest__c ? pmObj.Payment_Term__r.Days_to_calc_interest__c : 0;
                    } else {
                        this.newSalesOrder.Payment_Term__c = pmObj.Id;
                        this.days = pmObj.Days_to_calc_interest__c ? pmObj.Days_to_calc_interest__c : 0;
                    }
                }
                console.log('Campaign_Payment_Term_Date__c--->', this.newSalesOrder.Campaign_Payment_Term_Date__c);
            }
        }
        this.paymentTermDropDownList.forEach(opt => {
            opt.checked = (opt.value === this.selectedPaymentTerm);
        });

        this.selectedPayTm = this.paymentTermDropDownList.find(item => item.checked === true);
        var tempPaymentList = [];
        tempPaymentList.push(this.selectedPayTm);
        this.paymentTermDropDownList.forEach(currentItem => {
            const exists = tempPaymentList.some(item => item.value === currentItem.value);
            if (!exists) {
                tempPaymentList.push(currentItem);
            }
        });
        this.paymentTermDropDownList = tempPaymentList;
        this.newSalesOrder.Payment_Term__c = this.selectedPaymentTerm;
        this.isUpdatePayTm = false;
        this.updateRowCalculations(this.salesOrderLineItems);
        this.showSpinnerWithDelay();
    }

    @track oldValueQty;
    updateOldBalanceQty(event) {
        const value = event.target.value;
        console.log('Hhehhkdfds--->', value);
        this.oldValueQty = parseFloat(value) || 0;
    }
    @track oldValueQtyinCart;
    updateOldBalanceQtyOnCart(event) {
        const value = event.target.value;
        this.oldValueQtyinCart = parseFloat(value) || 0;
    }

    viewCart() {
        this.isShowProductPage = false;
        this.featuredProudcts = false;
        this.salesOrderLineItems = [...this.productsInCart];
        console.log('tempAllProductQtyMap--->', this.tempAllProductQtyMap);
        this.allViewProductList = new Map(this.tempAllProductQtyMap);
        this.updateQuantityMap();
        this.updateRowCalculations(this.salesOrderLineItems);
        this.isShowShoppingCart = true;
        this.showSpinnerWithDelay();
    }
    handleRemove(event) {
        this.totalQty = 0;
        this.totalPrice = 0;
        const index = parseInt(event.target.dataset.index);
        let row = this.salesOrderLineItems[index];
        console.log('heyyy', index)
        if (index >= 0 && index < this.salesOrderLineItems.length) {
            this.salesOrderLineItems.splice(index, 1);
        }
        this.updateRowCalculations(this.salesOrderLineItems);
        if (this.allViewProductList.has(row.uid)) {
            const currentQty = this.allViewProductList.get(row.uid);
            this.allViewProductList.set(row.uid, currentQty + row.qty);
        }
        console.log('allViewProductList--after Delete--->', this.allViewProductList);
        this.addtoCartCounter = this.addtoCartCounter > 0 ? this.addtoCartCounter -= 1 : 0;
    }
    showSpinnerWithDelay() {
        this.isSpinner = true;
        setTimeout(() => {
            this.isSpinner = false;
        }, 1000);
        this.isMenuOpen = false;
    }
    validateLineItems() {
        let isValid = true;
        let inputs = this.template.querySelectorAll('lightning-input[data-field="fatDate"]');

        inputs.forEach(input => {
            if (!input.value) {
                isValid = false;
                input.setCustomValidity("Invoice Date is required");
            } else {
                input.setCustomValidity("");
            }
            input.reportValidity();
        });
        return isValid;
    }
    quantityChange(event) {
        let inputField = event.target;
        let index = inputField.dataset.index;
        let row = this.salesOrderLineItems[index];
        let enteredQty = parseFloat(inputField.value) || 0;
        let productId = row.uid;
        if (this.allViewProductList.has(productId)) {
            let availableQty = this.allViewProductList.get(productId) + (this.oldValueQtyinCart || 0);
            this.allViewProductList.set(productId, availableQty);
        }

        if (!enteredQty) {
            row.qty = 0;
            this.oldValueQtyinCart = 0;
            inputField.value = '';
            this.updateRowCalculations(this.salesOrderLineItems);
            console.log('Hello--on blank and )-->', this.allViewProductList);
            return;
        }
        // if (this.isCommunityUser && row.multipleOf && (enteredQty % row.multipleOf !== 0 || enteredQty < row.multipleOf)) {
        //     row.qty = 0;
        //     this.oldValueQtyinCart = 0;
        //     inputField.value = '';
        //     this.showToast('error', 'Error', Qty_should_be_in_multiple_of + ' ' + row.multipleOf);
        //     inputField.classList.add('slds-has-error');
        //     this.updateRowCalculations(this.salesOrderLineItems);
        //     return;
        // }

        // Check if enteredQty exceeds current available stock
        if (enteredQty > this.allViewProductList.get(productId)) {
            row.qty = 0;
            inputField.value = '';
            this.showToast('error', 'Error', 'A quantidade inserida não pode exceder a quantidade disponível.');
            inputField.classList.add('slds-has-error');
            this.updateRowCalculations(this.salesOrderLineItems);
            return;
        }
        let newAvailable = this.allViewProductList.get(productId) - enteredQty;
        this.allViewProductList.set(productId, newAvailable);
        let price = this.newSalesOrder.CurrencyIsoCode === 'BRL' ? row.unitValueBRL1 : row.unitValueUSD1;
        row.unitValue = price;
        row.qty = enteredQty;
        inputField.classList.remove('slds-has-error');
        console.log('Hello---->', this.allViewProductList);
        this.updateRowCalculations(this.salesOrderLineItems);
    }
    handleMaturityDateChange(event) {
        const maturityDateField = event.target;
        maturityDateField.setCustomValidity('');
        maturityDateField.classList.remove('slds-has-error');
        maturityDateField.reportValidity();
        var priceDetailList = this.priceDetailList;
        var value = event.target.value;
        var toastMsg = "";
        var mDate = this.newSalesOrder.Maturity_Date__c;
        var PriceBook = this.selectedPriceBook;
        console.log('maturity Date value----->', value);
        if (value) {
            console.log('maturity maxMaturityDate value----->', priceDetailList[0].maxMaturityDate);
            if (priceDetailList && priceDetailList.length > 0 && priceDetailList[0].maxMaturityDate != '' && priceDetailList[0].maxMaturityDate != null && mDate != '' && mDate > priceDetailList[0].maxMaturityDate) {

                var labelMessage = Brazil_Max_Date_Message;
                var formattedDate = new Date(priceDetailList[0].maxMaturityDate)
                    .toLocaleDateString('en-GB', {
                        day: '2-digit',
                        month: '2-digit',
                        year: 'numeric'
                    });

                toastMsg = labelMessage + ' ' + formattedDate;
                this.showToast('error', 'Error', toastMsg);
                maturityDateField.classList.add('slds-has-error');
                maturityDateField.setCustomValidity(toastMsg);
                maturityDateField.reportValidity();
                this.newSalesOrder.Maturity_Date__c = '';
            }
            this.newSalesOrder.Maturity_Date__c = value;
            if (this.isShowProductPage) {
                var tempList = [];
                this.updatedProductList.forEach(currentItem => {
                    tempList.push(currentItem);
                });
                this.visibleRows.forEach(currentItem => {
                    const exists = tempList.some(item => item.uid === currentItem.uid);
                    if (!exists) {
                        tempList.push(currentItem);
                    }
                });
                this.updateRowCalculations(tempList);
                this.visibleRows = this.visibleRows.map(item => {
                    const replacement = tempList.find(newItem => newItem.uid === item.uid);
                    return replacement ? replacement : item;
                });
            }
            if (!this.isShowProductPage && this.isShowShoppingCart) {
                this.updateRowCalculations(this.salesOrderLineItems);
            }
            if (mDate != '' && mDate != null) {
                if (PriceBook != 'Normal Price Book') {
                    this.newSalesOrder.ReloadPaymentTerms__c = '';
                    this.newSalesOrder.Payment_Term__c = '';
                }
            }
        }
        else {
            maturityDateField.setCustomValidity(Maturity_date_is_required);
            maturityDateField.classList.add('slds-has-error');
            maturityDateField.reportValidity();
        }
    }
    saveMaturityDate() {
        const maturityDate = this.template.querySelector('[data-id="maturityDate"]');
        if (maturityDate && maturityDate.value != null && this.isValidMaturity && maturityDate.value != '') {
            this.isShowModalOnPayTMChange = false;
        }
    }
    cancelaturityDateModal() {
        this.newSalesOrder.Maturity_Date__c = '';
        this.showToast('warning', 'Warning', 'Por favor, selecione diferentes condições de pagamento');
        this.isShowModalOnPayTMChange = false;
    }
    inputInvoiceDate(event) {
        var target = event.target;
        var selectedDate = target.value;
        var rowIndex = event.target.dataset.index;
        var intrDate = this.interestDate;
        let items = this.isShowProductPage ? this.visibleRows : this.salesOrderLineItems;
        var row = items[rowIndex];
        var selectedPaymentTermDT = this.selectedPaymentTermChangeDate;
        var today = new Date().toISOString().split("T")[0];
        var smplCmp = this.newSalesOrder.Campaign_Type__c;
        let flag = true;
        let dayValue = 0;
        console.log('Line item--->', JSON.stringify(row));
        const dateWrapper = this.template.querySelector(`div[data-id="${row.Ids}"]`);
        if (dateWrapper) {
            dateWrapper.classList.remove('slds-has-error');
        }
        let minDate, minDateError, minFatDate, minFatError, maxFatDate, maxFatError, minCropFatDate, minCropFatError;
        if (row) {
            minDate = row.minDate;
            minFatDate = row.minFatDate;
            console.log('Fat==>' + minFatDate);
            console.log('minDate==>' + minDate);
        }

        if (this.productMix.Min_Date_Of_FAT__c) {
            minFatDate = this.productMix.Min_Date_Of_FAT__c;
        }
        if (minDate) {
            var [year, month, day] = minDate.split('-');
            minDateError = `${day}/${month}/${year}`;
        }
        if (minFatDate) {
            var [year, month, day] = minFatDate.split('-');
            minFatError = `${day}/${month}/${year}`;
        }
        if (this.newSalesOrder.Crop_Year__c) {
            var yy = this.newSalesOrder.Crop_Year__c.split('/');
            maxFatDate = '20' + yy[1] + '-03-31';
            maxFatError = '31/03/20' + yy[1];
            minCropFatDate = '20' + yy[0] + '-04-01';
            minCropFatError = '01/04/20' + yy[0];
        }
        console.log('selectedDate--->', selectedDate);
        console.log('minFatDate-----' + minFatDate);
        console.log('avecValue-----' + this.avecValue);
        console.log('nonAvecValue-----' + this.nonAvecValue);
        console.log('interestDate-----' + this.interestDate);
        console.log('region Value-----' + this.regionValue);
        if (selectedDate) {
            target.classList.remove('slds-has-error');
            target.setCustomValidity("");
            var selectedDateObj = new Date(selectedDate);
            var currentDateObj = new Date(today);
            let maturityDate = this.getMaturityDate();
            console.log('maturity Date--->' + maturityDate);
            let message = Maximum_billing_within_9_months_of_order_creation
            let isAvec = this.newSalesOrder.AVEC_Order__c;
            let differenceDays = this.calculateDateDifference(selectedDateObj, currentDateObj);
            console.log('differenceDays : ', differenceDays);
            if (differenceDays > this.nonAvecValue && !isAvec && this.regionValue === undefined) {
                //flag = this.billingDateError(message, this.nonAvecValue, "custom settings: non avec days");
            } else if (isAvec && differenceDays > this.avecValue && this.regionValue === undefined) {
                console.log('differenceDays' + differenceDays);
                //flag = this.billingDateError(message, this.avecValue, "custom settings: non avec days");
            }
            console.log('minDate :selectedDateObj :::::: ', new Date(minDate));
            const productExpireDate = new Date(row.Batch_Expire_date);
            const minInvoiceDate = new Date(productExpireDate);
            minInvoiceDate.setDate(minInvoiceDate.getDate() - 30);
            const diffTime = productExpireDate - selectedDateObj; // milliseconds
            const diffDays = diffTime / (1000 * 60 * 60 * 24);

            console.log(productExpireDate + 'diffDays' + selectedDateObj); // 5
            console.log('diff=================' + diffDays); // 5
            // if (!this.isCommunityUser && selectedDateObj < minInvoiceDate) {
            //     this.showToast('error', 'Error', 'A data de Faturamento deve ser no mínimo 30 dias da data de vencimento do produto.')
            //     flag = false;
            // }
            if (!this.isCommunityUser) {
                if (diffDays < 30) {
                    this.showToast('error', 'Error', 'A data de faturamento deve ser de pelo menos um mês antes da data de vencimento.')
                    flag = false;
                }
                if (selectedDateObj > productExpireDate) {
                    //this.showToast('error', 'Error', 'A data de Faturamento deve ser no mínimo 30 dias da data de vencimento do produto.')
                    //flag = false;
                }
            }

            if (selectedDateObj <= currentDateObj) {
                // target.classList.add('slds-has-error');
                this.showToast('error', 'Error', 'A data da fatura deve ser posterior a hoje.')
                // target.value = '';
                flag = false;
            }
            else if (minFatDate && selectedDateObj < new Date(minFatDate)) {
                //this.showToast('error', 'Error', 'Data mínima de faturamento para esta lista de preço é ' + minFatError);
                //flag = false;
            } else if (this.newSalesOrder.Type_of_Order__c != 'ORDEM FILHA' && maxFatDate && selectedDateObj > new Date(maxFatDate)) {
                //this.showToast('error', 'Error', 'Data máxima de faturamento deve ser ' + maxFatError);
                //flag = false;
            } else if (minCropFatDate && selectedDateObj < new Date(minCropFatDate)) {
                //this.showToast('error', 'Error', 'Data mínima de faturamento deve ser ' + minCropFatError);
                //flag = false;
            } else if (minDate && selectedDateObj < new Date(minDate)) {
                //this.showToast('error', 'Error', `${Brazil_Validate_Min_Date} ${minDateError}`);
                //flag = false;
            } else {
                target.classList.remove('slds-has-error');
                target.setCustomValidity('');
            }
            if (flag) {
                if (maturityDate && intrDate != '') {
                    console.log('5');
                    let newIntrDt = new Date(intrDate);
                    if (maturityDate < newIntrDt) {
                        dayValue = 0;
                        this.days = dayValue;

                    } else if (selectedDateObj <= newIntrDt) {
                        this.days = this.calculateDateDifference(new Date(maturityDate), newIntrDt);
                    } else if (selectedDateObj > newIntrDt) {
                        let diffDays = this.calculateDateDifference(new Date(maturityDate), selectedDateObj);
                        dayValue = diffDays < 0 ? 0 : diffDays;
                        this.days = dayValue;
                    }

                    if (dayValue > 365) {
                        this.showToast('error', 'Error', `${Date_of_FAT_greater_than_360}: ${dayValue}`);
                        flag = false;
                    }
                    if (smplCmp === "Simple" && selectedPaymentTermDT === "BR71 INFORMAR VENCIMENTO") {
                        if (selectedDateObj > maturityDate) {
                            this.showToast('error', 'Error', Dat_of_Fat_not_be_greater_than_Maturity_Date);
                            flag = false;
                        } else {
                            let diffDays = this.calculateDateDifference(maturityDate, selectedDateObj);
                            diffDays = diffDays < 0 ? 0 : diffDays + 1;
                            if (diffDays > 365) {
                                this.showToast('error', 'Error', `${Date_of_FAT_greater_than_360}: ${diffDays}`);
                                flag = false;
                            } else {
                                target.classList.remove('slds-has-error');
                                target.setCustomValidity('');
                            }
                        }
                    }
                }
            }
            this.isValidFAT = flag;
        }
        if (flag) {
            let itemInList = this.updatedProductList.find(item => item.uid === row.uid);
            if (this.updatedProductList.length > 0 && itemInList != undefined) {
                itemInList.fatDate = selectedDate;
            }
            else {
                row.fatDate = selectedDate;
            }
            target.classList.remove('slds-has-error');
            row.days = this.days;
        }
        else {
            target.classList.add('slds-has-error');
            row.fatDate = '';
            row.qty = 0;
        }
        if (this.isShowProductPage) {
            let existingProduct = this.updatedProductList.find(product => product.uid === row.uid);
            if (!existingProduct) {
                this.updatedProductList.push(row);
            }
            else {
                items = items.map(row => {
                    const updated = this.updatedProductList.find(item => item.uid === row.uid);
                    return updated ? { ...row, ...updated } : row;
                });
            }
        }
        row.totalValue = 0;
        this.updateRowCalculations(items);
        if (this.isShowProductPage) {
            this.visibleRows = this.visibleRows.map(row => {
                const updated = items.find(item => item.uid === row.uid);
                return updated ? { ...row, ...updated } : row;
            });
        }
        console.log('Updated list : ', row);
    }
    inputInvoiceDate2(event) {
        var target = event.target;
        var selectedDate = target.value;
        var rowIndex = event.target.dataset.index;
        var intrDate = this.interestDate;
        let items = this.isShowProductPage ? this.visibleRows : this.salesOrderLineItems;
        var row = items[rowIndex];
        var selectedPaymentTermDT = this.selectedPaymentTermChangeDate;
        var today = new Date().toISOString().split("T")[0];
        var smplCmp = this.newSalesOrder.Campaign_Type__c;
        let flag = true;
        let dayValue = 0;
        console.log('Line item--->', JSON.stringify(row));
        const dateWrapper = this.template.querySelector(`div[data-id="${row.Ids}"]`);
        if (dateWrapper) {
            dateWrapper.classList.remove('slds-has-error');
        }
        let minDate, minDateError, minFatDate, minFatError, maxFatDate, maxFatError, minCropFatDate, minCropFatError;
        if (row) {
            minDate = row.minDate;
            minFatDate = row.minFatDate;
            console.log('Fat==>' + minFatDate);
            console.log('minDate==>' + minDate);
        }

        if (this.productMix.Min_Date_Of_FAT__c) {
            minFatDate = this.productMix.Min_Date_Of_FAT__c;
        }
        if (minDate) {
            var [year, month, day] = minDate.split('-');
            minDateError = `${day}/${month}/${year}`;
        }
        if (minFatDate) {
            var [year, month, day] = minFatDate.split('-');
            minFatError = `${day}/${month}/${year}`;
        }
        if (this.newSalesOrder.Crop_Year__c) {
            var yy = this.newSalesOrder.Crop_Year__c.split('/');
            maxFatDate = '20' + yy[1] + '-03-31';
            maxFatError = '31/03/20' + yy[1];
            minCropFatDate = '20' + yy[0] + '-04-01';
            minCropFatError = '01/04/20' + yy[0];
        }
        console.log('selectedDate--->', selectedDate);
        console.log('minFatDate-----' + minFatDate);
        console.log('avecValue-----' + this.avecValue);
        console.log('nonAvecValue-----' + this.nonAvecValue);
        console.log('interestDate-----' + this.interestDate);
        console.log('region Value-----' + this.regionValue);
        if (selectedDate) {
            target.classList.remove('slds-has-error');
            target.setCustomValidity("");
            var selectedDateObj = new Date(selectedDate);
            var currentDateObj = new Date(today);
            let maturityDate = this.getMaturityDate();
            console.log('maturity Date--->' + maturityDate);
            let message = Maximum_billing_within_9_months_of_order_creation
            let isAvec = this.newSalesOrder.AVEC_Order__c;
            let differenceDays = this.calculateDateDifference(selectedDateObj, currentDateObj);
            console.log('differenceDays : ', differenceDays);
            if (differenceDays > this.nonAvecValue && !isAvec && this.regionValue === undefined) {
                flag = this.billingDateError(message, this.nonAvecValue, "custom settings: non avec days");
            } else if (isAvec && differenceDays > this.avecValue && this.regionValue === undefined) {
                console.log('differenceDays' + differenceDays);
                flag = this.billingDateError(message, this.avecValue, "custom settings: non avec days");
            }
            console.log('minDate :selectedDateObj :::::: ', new Date(minDate));
            const productExpireDate = new Date(row.Batch_Expire_date);
            const minInvoiceDate = new Date(productExpireDate);
            minInvoiceDate.setDate(minInvoiceDate.getDate() - 30);
            const diffTime = productExpireDate - selectedDateObj; // milliseconds
            const diffDays = diffTime / (1000 * 60 * 60 * 24);

            console.log(productExpireDate + 'diffDays' + selectedDateObj); // 5
            console.log('diff=================' + diffDays); // 5
            // if (!this.isCommunityUser && selectedDateObj < minInvoiceDate) {
            //     this.showToast('error', 'Error', 'A data de Faturamento deve ser no mínimo 30 dias da data de vencimento do produto.')
            //     flag = false;
            // }
            if (!this.isCommunityUser) {
                if (selectedDateObj < minInvoiceDate) {
                    this.showToast('error', 'Error', 'A data de Faturamento deve ser no mínimo 30 dias da data de vencimento do produto.')
                    flag = false;
                }
                if (selectedDateObj > productExpireDate) {
                    this.showToast('error', 'Error', 'A data de Faturamento deve ser no mínimo 30 dias da data de vencimento do produto.')
                    flag = false;
                }
            }

            if (selectedDateObj <= currentDateObj) {
                // target.classList.add('slds-has-error');
                this.showToast('error', 'Error', 'A data da fatura deve ser posterior a hoje.')
                // target.value = '';
                flag = false;
            }
            else if (minFatDate && selectedDateObj < new Date(minFatDate)) {
                this.showToast('error', 'Error', 'Data mínima de faturamento para esta lista de preço é ' + minFatError);
                flag = false;
            } else if (this.newSalesOrder.Type_of_Order__c != 'ORDEM FILHA' && maxFatDate && selectedDateObj > new Date(maxFatDate)) {
                this.showToast('error', 'Error', 'Data máxima de faturamento deve ser ' + maxFatError);
                flag = false;
            } else if (minCropFatDate && selectedDateObj < new Date(minCropFatDate)) {
                this.showToast('error', 'Error', 'Data mínima de faturamento deve ser ' + minCropFatError);
                flag = false;
            } else if (minDate && selectedDateObj < new Date(minDate)) {
                this.showToast('error', 'Error', `${Brazil_Validate_Min_Date} ${minDateError}`);
                flag = false;
            } else {
                target.classList.remove('slds-has-error');
                target.setCustomValidity('');
            }
            if (flag) {
                if (maturityDate && intrDate != '') {
                    console.log('5');
                    let newIntrDt = new Date(intrDate);
                    if (maturityDate < newIntrDt) {
                        dayValue = 0;
                        this.days = dayValue;

                    } else if (selectedDateObj <= newIntrDt) {
                        this.days = this.calculateDateDifference(new Date(maturityDate), newIntrDt);
                    } else if (selectedDateObj > newIntrDt) {
                        let diffDays = this.calculateDateDifference(new Date(maturityDate), selectedDateObj);
                        dayValue = diffDays < 0 ? 0 : diffDays;
                        this.days = dayValue;
                    }

                    if (dayValue > 365) {
                        this.showToast('error', 'Error', `${Date_of_FAT_greater_than_360}: ${dayValue}`);
                        flag = false;
                    }
                    if (smplCmp === "Simple" && selectedPaymentTermDT === "BR71 INFORMAR VENCIMENTO") {
                        if (selectedDateObj > maturityDate) {
                            this.showToast('error', 'Error', Dat_of_Fat_not_be_greater_than_Maturity_Date);
                            flag = false;
                        } else {
                            let diffDays = this.calculateDateDifference(maturityDate, selectedDateObj);
                            diffDays = diffDays < 0 ? 0 : diffDays + 1;
                            if (diffDays > 365) {
                                this.showToast('error', 'Error', `${Date_of_FAT_greater_than_360}: ${diffDays}`);
                                flag = false;
                            } else {
                                target.classList.remove('slds-has-error');
                                target.setCustomValidity('');
                            }
                        }
                    }
                }
            }
            this.isValidFAT = flag;
        }
        if (flag) {
            let itemInList = this.updatedProductList.find(item => item.uid === row.uid);
            if (this.updatedProductList.length > 0 && itemInList != undefined) {
                itemInList.fatDate = selectedDate;
            }
            else {
                row.fatDate = selectedDate;
            }
            target.classList.remove('slds-has-error');
            row.days = this.days;
        }
        else {
            target.classList.add('slds-has-error');
            row.fatDate = '';
            row.qty = 0;
        }
        if (this.isShowProductPage) {
            let existingProduct = this.updatedProductList.find(product => product.uid === row.uid);
            if (!existingProduct) {
                this.updatedProductList.push(row);
            }
            else {
                items = items.map(row => {
                    const updated = this.updatedProductList.find(item => item.uid === row.uid);
                    return updated ? { ...row, ...updated } : row;
                });
            }
        }
        row.totalValue = 0;
        this.updateRowCalculations(items);
        if (this.isShowProductPage) {
            this.visibleRows = this.visibleRows.map(row => {
                const updated = items.find(item => item.uid === row.uid);
                return updated ? { ...row, ...updated } : row;
            });
        }
        console.log('Updated list : ', row);
    }
    getMaturityDate() {
        return this.newSalesOrder.Campaign_Payment_Term_Date__c ? this.newSalesOrder.Campaign_Payment_Term_Date__c : this.newSalesOrder.Maturity_Date__c;
    }
    calculateDateDifference(date1, date2) {
        return Math.floor((date1 - date2) / (1000 * 60 * 60 * 24));
    }
    billingDateError(message, replaceValue, placeholder) {
        message = message.replace(placeholder, replaceValue);
        this.showToast('error', 'Error', message);
        return false;
    }
    @track isValidMaturity = true;
    restrictMaturityDate(event) {
        var value = event.target.value;
        if (value) {
            var today = new Date();
            var dd = (today.getDate() < 10 ? "0" : "") + today.getDate();
            var MM = (today.getMonth() + 1 < 10 ? "0" : "") + (today.getMonth() + 1);
            var yyyy = today.getFullYear();
            var currentDate = yyyy + "-" + MM + "-" + dd;
            var x = new Date(value);
            var y = new Date(currentDate);
            var flag = true;
            if (x == "Invalid Date") {
                this.showToast('error', 'Error', Maturity_date_is_required);
                event.target.classList.add('slds-has-error');
                flag = false;
            }
            else if (+x < +y) {
                this.showToast('error', 'Error', Maturity_Date_cannot_be_less_than_today);
                event.target.classList.add('slds-has-error');
                flag = false;
            }
            else if (x.getUTCDate() > 25) {
                this.showToast('error', 'Error', Maximum_payment_date_allowed_the_25th);
                event.target.classList.add('slds-has-error');
                flag = false;
            }
            else if (this.newSalesOrder.Maturity_Date__c != '' && this.priceDetailList && this.priceDetailList.length > 0 && this.priceDetailList[0].maxMaturityDate != '' && this.priceDetailList[0].maxMaturityDate != null && this.priceDetailList[0].maxMaturityDate < this.newSalesOrder.Maturity_Date__c) {
                var formattedDate = new Date(this.priceDetailList[0].maxMaturityDate)
                    .toLocaleDateString('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric' });
                var labelMessage = Brazil_Max_Date_Message;
                this.showToast('error', 'Error', labelMessage + ' ' + formattedDate);
                event.target.classList.add('slds-has-error');
                flag = false;
                this.newSalesOrder.Maturity_Date__c = '';
            }
            else {
                event.target.setCustomValidity('');
                event.target.classList.remove('slds-has-error');
                event.target.reportValidity();
            }
            this.isValidMaturity = flag;
            console.log('maturity--->', this.isValidMaturity);
        }
    }

    get isShowShippingInfo() {
        return this.salesOrderLineItems.length > 0 && this.selectedDeliveryLabel === 'Delivery' ? true : false;
    }
    validatePO(event) {
        var target = event.target;
        var inputPo = target.value;
        var letterNumber = /^[0-9a-zA-Z]+$/;
        if (inputPo.match(letterNumber)) {
            target.classList.remove('slds-has-error');
            target.setCustomValidity('');
            this.newSalesOrder.Purchase_Order_no__c = inputPo;
        } else {
            target.setCustomValidity(Purchase_Order_No_is_required_and_can_contain_only_characters_and_numbers);
            target.classList.add('slds-has-error');
            this.newSalesOrder.Purchase_Order_no__c = '';
        }
        console.log('Total value--->', this.totalPrice);
    }
    restrictPODate(event) {
        var target = event.target;
        var inputPODate = target.value;
        if (inputPODate) {
            var x = new Date(inputPODate);
            if (x == "Invalid Date") {
                target.classList.add('slds-has-error');
                target.setCustomValidity(Purchase_Order_date_is_required);
                this.newSalesOrder.Purchase_Order_Date__c = '';
            } else {
                target.classList.remove('slds-has-error');
                target.setCustomValidity('');
                this.newSalesOrder.Purchase_Order_Date__c = inputPODate;
            }
        } else {
            target.classList.add('slds-has-error');
            target.setCustomValidity(Purchase_Order_date_is_required);

        }
        console.log('Final Sales Order---->', JSON.stringify(this.newSalesOrder));
        console.log('Final Sales Order-Line itemsss--->', JSON.stringify(this.salesOrderLineItems));
    }
    validateInvoiceMessage(event) {
        var inputMessage = event.target.value;
        this.newSalesOrder.Invoice_Message__c = inputMessage.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }
    validateInvoice(event) {
        var inputMessage = event.target.value;
        var isValidInvoice = false
        if (inputMessage) {
            var letterNumber = /^[a-z\d\-_;\s]+$/i;
            if (inputMessage.match(letterNumber)) {
                event.target.classList.remove('slds-has-error');
                event.target.setCustomValidity('');
                isValidInvoice = true;
            } else {
                event.target.classList.add('slds-has-error');
                event.target.setCustomValidity(Invoice_Message_can_contain_only_characters_and_numbers);

            }
        }
    }
    handleCnclOrder() {
        this.showTermsConditions = false;
    }
    async handleSaveOrder() {
        console.log('Terms accepted:', this.isTermsChecked);
        console.log('isAgreedOnNoReturn:', this.isAgreedOnNoReturn);
        if (!(this.isTermsChecked && this.isAgreedOnNoReturn)) {
            return;
        }
        this.isSpinner = true;
        try {
            const tempLineItems = this.salesOrderLineItems.map(item => {
                const clone = { ...item };
                delete clone.Brand;
                return clone;
            });

            const tCForBarterProcess = this.TCForBarterProcess;

            console.log('Sales Order Line Items Before saveSalesOrder:', tempLineItems);
            const result = await saveSalesOrder({
                soObj: this.newSalesOrder,
                salesOrderItemString: JSON.stringify(tempLineItems),
                TCforBarterManagerProcess: tCForBarterProcess
            });

            console.log('Created Sales Order:', JSON.stringify(result));
            await this.fetchSOListCreated();
            this.template
                .querySelector('c-grz_-custom-toast-event')
                .showToast(
                    'success',
                    'Seu pedido de compras foi enviado para aprovação. Após a aprovação você será notificado via email.',
                    'utility:success',
                    15000
                );
            this.refreshComponent();
            this.showTermsConditions = false;

        } catch (error) {
            console.error('Error in CreateSalesOrder:', error);
        } finally {
            this.isSpinner = false;
        }
    }


    refreshComponent() {
        this.resetFields();
        this.resetvalue();
        this.retrieveCurrentUserInfo();
        this.isShowShoppingCart = false;
        this.isShowProductPage = false;
    }
    resetFields() {
        this.productStyle = "background:white;";
        this.categoria = [];
        this.newSalesOrder = {};
        this.selectedCurrency = '';
        this.isShowModal = false;
        this.isBuyNowSOBtnClicked = false;
        this.selItem5 = {};
        this.productTitle = "Gainexa Fc (Powder, Ortho Silicic Acid) Beneficial Nutrient Fertilizer";
        // this.selectedPriceList = 'aBkHE00000001fF0AQ';
        this.showKeyAccount = false;
        this.showSeller = false;
        this.territoryUser = '';
        this.selectedUser = undefined;
        this.sellerOptionsList = [];
        this.accountList = [];
        this.comboBoxAccounts = [];
        this.searchProducts = '';
        this.priceList = [];
        this.featuredProudcts = false
        this.isShowSOList = false;
        this.isShowShoppingCart = false;
        this.adminMPTParameter = undefined;
        this.isTermsChecked = false;
        this.isAgreedOnNoReturn = false;
        this.showTermsConditions = false;
        this.currencyList = [];
        this.cropYearList = [];
        this.avecValue = undefined;
        this.nonAvecValue = undefined;
        this.regionValue = undefined;
        this.isSpinner = true;
        this.isCommunityUser = false;
        this.businessRule = {};
        this.isMature = false;
        this.paymentTermsMapDT = new Map();
        this.selectedTerritoryCode = undefined;
        this.selectedPaymentTermChangeDate = undefined;
        this.selectedImage = undefined;
        this.interestDate = undefined;
        this.interestFixedDate = undefined;
        this.interestRunningDays = undefined;
        this.customerRegionForSOM = undefined;
        this.customerRegionForSDM = undefined;
        this.tempAccountList = [];
        this.sellerData = [];
        this.priceListOptions = [];
        this.isValidFAT = true;
        this.isMultiselect = false;
        this.isShowModalOnPayTMChange = false;
        this.isUpdatePayTm = false;
        this.isUpdateCurrency = false;
        this.paymentTermOptions = [];
        this.AVEC = 'AVEC';
        this.selectedPriceBook = '';
        this.totalProducts = undefined;
        this.days = 0;
        this.selectedCustomer = '';
        this.selItem = {};
        this.erroOnSeller = false;
        this.selectedPaymentTerm = '';
        this.isDeliveryOpen = false;
        this.addtoCartCounter = 0;
        this.isCurrencyOpen = false;
        this.isPaymentOpen = false;
        this.isShowProductPage = false;
        this.salesOrderLineItems = [];
        this.productsInCart = [];
        this.selectedPayTm = undefined;
        this.defaultDelivery = '';
        this.selectedDelivery = '';
        this.fieldsList = [];
        this.paginatedProducts = [];
        this.allViewProductList = new Map();
        this.currencyDropDownList = [];
        this.deliveryDropDownList = [];
        this.paymentTermDropDownList = [];
        this.selectedCropYear = '25/26';
        this.productVariants = [];
        this.visibleRows = [];
        this.products = [];
        this.isExpanded = false;
        this.selectedBrand = '';
        this.isMenuOpen = false;
        this.productDescription = '';
        this.error = undefined;
        this.currentPage = 1;
        this.totalPages = 1;
        this.defaultValue = 'No';
        this.priceDetailList = '';
        this.salesRepUserId = '';
        this.productData = undefined;
        this.isShowDownloadModal = false;
        this.updatedProductList = [];
        this.isBuyNowClicked = false;
        this.currentContent = '';
        this.buttons = [];
        this.infoColor = undefined;
        this.activeStep = 2;
        this.currentInfo = undefined;
        this.showCustomToast = false;
        this.selectedTech = "Todos";
    }

}