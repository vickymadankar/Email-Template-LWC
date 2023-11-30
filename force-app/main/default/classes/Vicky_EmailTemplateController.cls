public with sharing class Vicky_EmailTemplateController {
    public Vicky_EmailTemplateController() {}

    //Method to send Email
    @AuraEnabled
    public static void sendEmail(String toEmail, String templateId, Id recordId){
        //fetch EmailTemplate Details
        EmailTemplateDetails  templateDetails= getEmailTemplateDetails(templateId, recordId);
       // ContactDetails contactDetails= getContactDetails(contactId);Id contactId
        
       //create new singleEmailMessage
       Messaging.singleEmailMessage emailMessage = new Messaging.singleEmailMessage();
       // emailMessage.setToAddresses(contactDetails.Email);
        emailMessage.setToAddresses(new String[]{toEmail});
        emailMessage.setSubject(templateDetails.subject);
        emailMessage.setHtmlBody(templateDetails.body);
        //send Email
        Messaging.sendEmail(new Messaging.singleEmailMessage[]{emailMessage});
    }
    
    //Method to fetch contact/vendor
     @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(){
        List<Contact> contactsList= [SELECT Id,Name,Email FROM Contact];
        system.debug('CONTACTS==='+contactsList );
        return contactsList;
    }
    
    
    //Method to fetch contact/vendor Email details
    @AuraEnabled(cacheable=true)
    public static ContactDetails getContactDetails(Id contactId) {
        ContactDetails contactDetails= new ContactDetails();
        Contact contact= [SELECT Id,Name,Email FROM Contact WHERE Id=:contactId LIMIT 1];
        contactDetails.Email=contact.Email;
        system.debug('CONTACT DETAILS==='+contactDetails );
        return ContactDetails;
    }
    
     // Method to fetch email templates
     @AuraEnabled(cacheable=true)
     public static List<EmailTemplateWrapper> getEmailTemplates() {
         List<EmailTemplateWrapper> result = new List<EmailTemplateWrapper>();
         // Query EmailTemplate object to get Id and Name
         List<EmailTemplate> templates = [SELECT Id, Name FROM EmailTemplate];
         for(EmailTemplate template:templates){
             result.add(new EmailTemplateWrapper(template.Id, template.Name));
         }
         system.debug('TEMPLATES LIST_: '+result);
         return result;
     }
 
     // Method to fetch email template details based on templateId and recordId
     @AuraEnabled(cacheable=true)
     public static EmailTemplateDetails getEmailTemplateDetails(String templateId, Id recordId) {
         EmailTemplateDetails result = new EmailTemplateDetails();
 
         // Fetch relevant fields from the Electronic Transfer record based on recordId
         Electronic_Transfer__c electronicTransfer = [SELECT Transfer_Number__c, Address__c FROM Electronic_Transfer__c WHERE Id = :recordId LIMIT 1];
         // system.debug('ET RECORD==='+electronicTransfer);
         // Query EmailTemplate to get the body and subject based on templateId
         EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Id = :templateId LIMIT 1];
          //  system.debug('ETemplate==='+emailTemplate);
         // Populate subject with the template subject
         result.subject = emailTemplate.Subject;
 
         result.body = emailTemplate.HtmlValue.replace('{!Electronic_Transfer__c.Transfer_Number__c}', String.valueOf(electronicTransfer.Transfer_Number__c))
                                           .replace('{!Electronic_Transfer__c.Address__c}', String.valueOf(electronicTransfer.Address__c));
         //system.debug('ETemplate Details==='+result);
         return result;
     }
 
     // Wrapper class for email templates
     public class EmailTemplateWrapper {
         @AuraEnabled public Id Id;
         @AuraEnabled public String Name;
 
         public EmailTemplateWrapper(Id Id, String Name) {
             this.Id = Id;
             this.Name = Name;
         }
     }
 
     // Inner class to hold email template details (subject and body)
     public class EmailTemplateDetails {
         @AuraEnabled public String subject;
         @AuraEnabled public String body;
     } 
    
    // Inner class to hold contact details (email)
     public class ContactDetails {
         @AuraEnabled public String Email;
     }
}