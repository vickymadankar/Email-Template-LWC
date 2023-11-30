import { LightningElement, api, wire, track } from 'lwc';
import getEmailTemplates from '@salesforce/apex/Vicky_EmailTemplateController.getEmailTemplates';
import getEmailTemplateDetails from '@salesforce/apex/Vicky_EmailTemplateController.getEmailTemplateDetails';
import getContacts from '@salesforce/apex/Vicky_EmailTemplateController.getContacts';
import getContactDetails from '@salesforce/apex/Vicky_EmailTemplateController.getContactDetails';
import sendEmail from '@salesforce/apex/Vicky_EmailTemplateController.sendEmail';

export default class SendEmailToVendor extends LightningElement {
    @api recordId; // Record Id of the Electronic Transfer

    @track contacts=[];
    @track selectedContact;
    @track emailTemplates = [];
    @track selectedTemplate;
    @track subject;
    @track body;

    // Fetch email templates on component initialization
    connectedCallback() {
        getEmailTemplates()
            .then(result => {
                this.emailTemplates = result.map(template =>({label:template.Name, value:template.Id}));
                //console.log('EMAIL TEMPLATES==='+JSON.stringify(result));
            })
            .catch(error => {
                console.error('Error fetching email templates:', error);
            });

        getContacts()
            .then(res =>{
                this.contacts = res.map(contact =>({label:contact.Name, value:contact.Id}));
                //console.log('ContactS==='+JSON.stringify(res));
            })
            .catch(error => {
                console.error('Error fetching email templates:', error);
            });
    }

    handleContactSelection(event){
        this.selectedContact= event.detail.value;
        console.log('SELECTED CONTACT===',this.selectedContact);
    }

    handleTemplateSelection(event) {
        this.selectedTemplate = event.detail.value;
        // Fetch and set subject and body based on selected email template
        // that retrieves template details based on the selectedTemplate and recordId.
        getEmailTemplateDetails({ templateId: this.selectedTemplate, recordId: this.recordId })
            .then(result => {
                this.subject = result.subject;
                this.body = this.unescapeHtml(result.body);
                console.log('EMAIL TEMPLATE DETAILS===',this.subject,this.body);
            })
            .catch(error => {
                console.error('Error fetching email template details:', error);
            });
    }

    unescapeHtml(escapedHtml){
        const div= document.createElement('div');
        div.innerHTML= escapedHtml;
        return div.textContent || div.innerText;
    }

    renderedCallback(){
        const bodyContainer = this.template.querySelector('.body-container');
        if(bodyContainer){
            bodyContainer.innerHTML= this.body;
        }
    }

    sendEmail() {
        // You may need to call an Apex method here to handle email sending.
        getContactDetails({contactId:this.selectedContact})
            .then(result =>{
            const toEmail= result.Email;
            console.log('EMAIL===',toEmail);
        sendEmail({
                toEmail,
                templateId: this.selectedTemplate,
                recordId: this.recordId
            })
            .then(()=>{
                console.log('Email sent successfully');
            })
            .catch(error => {
                console.error('Error in sending Email:', error);
            });
        })
        .catch(error => {
            console.error('Error fetching contact details:', error);
        });
    }
}