import { LightningElement, api, track } from 'lwc';
const delay = 350;
export default class Grz_CustomReusableComboBox extends LightningElement {

    @api fieldLabel;
    @api disabled = false;
    @track openDropDown = false;
    @track inputValue = "";
    @api placeholder = "";
    @track isLoading = true;
    @api options;
    @track optionsToDisplay;
    @api value = "";
    @track label = "";
    delaytimeout;
    @api iconname= '';
    @api fields = [];

    //constructor
    constructor() {
        super();
    }
   
    connectedCallback() {
        this.setOptionsAndValues();
        console.log('The Clients====>',this.options);
    }
    @api clearlookup(){
        this.label = '';
        this.value = '';
    }

    renderedCallback() {
        if (this.openDropDown) {
            this.template.querySelectorAll('.search-input-class').forEach(inputElem => {
                inputElem.focus();
            });
        }
    }
    @api setOptionsAndValues() {
        this.optionsToDisplay = (this.options && this.options.length > 0 ? this.processOptions(this.options) : []);
        this.isLoading = false;
        if (this.value && this.value != "") {
            let label = this.getLabel(this.value);
            if (label && label != "") {
                this.label = label;
            }
        }
        else {
            this.label = "";
        }
    }


 processOptions(options) {
        return options.map(option => ({
            ...option,
            fieldValues: this.fields.map(field => ({
                name: field,
                value: option.record ? option.record[field] || 'N/A' : 'N/A'
            }))
        }));
    }
    getLabel(value) {
        let selectedObjArray = this.options.filter(obj => obj.value === value);
        if (selectedObjArray && selectedObjArray.length > 0) {
            return selectedObjArray[0].label;
        }
        return null;
    }
    openDropDown(event) {
        
        this.toggleOpenDropDown(true);
    }
    closeDropdown(event) {
	
        if (event.relatedTarget && event.relatedTarget.tagName == "UL" && event.relatedTarget.className.includes('customClass')) {
            console.log(JSON.stringify(event.relatedTarget.className));
            if (this.openDropDown) {
                this.template.querySelectorAll('.search-input-class').forEach(inputElem => {
                    inputElem.focus();
                });
            }
        }
        else {
            window.setTimeout(() => {
                this.toggleOpenDropDown(false);
            }, 300);
        }
    }

    handleInputClick(event) {
          if (!this.isLoading) {
        this.resetParameters();
        this.toggleOpenDropDown(true);
          }
    }
    handleKeyPress(event) {
        const searchKey = event.target.value;
        this.setInputValue(searchKey);
        if (this.delaytimeout) {
            window.clearTimeout(this.delaytimeout);
        }

        this.delaytimeout = setTimeout(() => {
            this.filterDropdownList(searchKey);
        }, delay);
    }
    filterDropdownList(key) {
        const filteredOptions = this.options.filter(item => item.label.toLowerCase().includes(key.toLowerCase()));
        this.optionsToDisplay = filteredOptions;
    }
    optionsClickHandler(event) {
        const value = event.target.closest('li').dataset.value;
        const label = event.target.closest('li').dataset.label;
        this.setValues(value, label);
        this.toggleOpenDropDown(false);
        const detail = {};
        detail["value"] = value;
        detail["label"] = label;
        this.dispatchEvent(new CustomEvent('change', { detail: detail }));
    }

    resetParameters() {
        this.setInputValue("");
        this.optionsToDisplay = this.options;
    }
    setInputValue(value) {
        this.inputValue = value;
    }
    setValues(value, label) {
        this.label = label;
        this.value = value;
    }
    toggleOpenDropDown(toggleState) {
        this.openDropDown = toggleState;
    }
    get labelClass() {
        return (this.fieldLabel && this.fieldLabel != "" ? "slds-form-element__label slds-show" : "slds-form-element__label slds-hide")
    }
    get dropDownClass() {
        return (this.openDropDown ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open" : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click");
    }
    get isValueSelected() {
        return (this.label && this.label != "" ? true : false);
    }

    get isDropdownOpen() {
        return (this.openDropDown ? true : false);
    }

}