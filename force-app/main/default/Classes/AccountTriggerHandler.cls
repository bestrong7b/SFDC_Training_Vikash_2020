public class AccountTriggerHandler {
    
    public static void onBeforeInsert(List<account> lstNewAcc) {
        UpdateAddressFields(lstNewAcc, null);
    }
    
    public static void onBeforeUpdate(List<account> lstNewAcc, Map<Id, Account> oldMapAcc) {
        UpdateAddressFields(lstNewAcc, oldMapAcc);
    }
    
    public static void onAfterInsert(Map<id,Account> newMap) {
        createCaseTaskUpdateAccount(newMap, null);
    }
    
    public static void onAfterUpdate(Map<id,Account> newMap, Map<id, Account> oldMap) {
        createCaseTaskUpdateAccount(newMap , oldMap);
    }
    
    /** 
     * Description: Create a new case and task whenevr Create Next Contact Interval is true
     *              It is handled for account creation with "Create Next Contact Interval" is true
     *              and also on update of this field.
    */
    public static void createCaseTaskUpdateAccount(Map<Id, account> newMap, Map<id, account> oldMap){
        // list of accounts with checked box 
        List<account> CheckedAct = new List<Account>();
        for(Account Acc : newMap.values()){
            
            // if(Acc.Create_Next_contact_Interval__c==true){
                // checkedAct.add(Acc);
            // }
            // On insert -> Trigger.isInsert
            // On Update -> Trigger.isUpdate
            
            if(Trigger.isInsert) {
                //if(acc.Create_Next_contact_Interval__c==true)
                if(Acc.Create_Next_contact_Interval__c) {
                	checkedAct.add(Acc);
                }
            }
            
            if(Trigger.isUpdate) {
                // Handle scenario where Checkbox will be unchecked from checked
                if(Acc.Create_Next_contact_Interval__c != oldMap.get(Acc.Id).Create_Next_contact_Interval__c &&
                   Acc.Create_Next_contact_Interval__c ) {
                       checkedAct.add(Acc);
                }
            }
        }
        
        // Create new case record for these accounts
        List<case> lstNewCase = new List<case>();
        for(Account acc : checkedAct){
            Case objCase = new Case();
            objCase.OwnerId = acc.OwnerId;
            objCase.AccountId = acc.Id;
            objCase.Subject = 'Scheduled contact interval for ' + acc.Name;
            objCase.Status = 'In Progress';
            
            lstNewCase.add(objCase);
        }
        insert lstNewCase;
        
        // Create new task record for above cases
        List <Task> lstNewTask=new List<Task>();
        for(Case objCase : lstNewCase) {
            Task objTask = new Task();
            objTask.OwnerId = objCase.OwnerId;
            objTask.Status='Open';
            objTask.Subject= 'Patient call';
            objTask.WhatId=objcase.AccountId;
            
            lstNewTask.add(objTask);
        }
        insert lstNewTask;
        
        // Uncheck the Create next interval checkbox
        for(Account acc : checkedAct) {
            acc.Create_Next_contact_Interval__c = False;
        }
        update checkedAct;
    }
    
    /**
     * Copy address fields data from Zip Code object when Account Address's Zip Code filed match es wiht any exisiting ZIp OCde record
     */
    public static void UpdateAddressFields(List<account> lstNewAcc, Map<Id, Account> oldMapAcc){
      
        /* We don not need this extra query for before trigger
        List<Account> acc=new List<Account>([SELECT Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, 
        ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, 
        ShippingCountry FROM Account]);
        */
        Set<String> setZipCodes = new Set<String>();
        for(Account accs : lstNewAcc) {
            if(oldMapAcc == null	// Insert trigger is running
               ||
              //Update of billing or shipping postal code field
              ( accs.BillingPostalCode != oldMapAcc.get(accs.Id).BillingPostalCode || 
               accs.ShippingPostalCode != oldMapAcc.get(accs.Id).ShippingPostalCode) ) {
                   // Get all the Zip code values in one set -> BillingZipCode or ShippingZipCode
                   setZipCodes.add(accs.BillingPostalCode);
                   setZipCodes.add(accs.ShippingPostalCode);
                   
            }
        }
        
        // Map --> zip_Code__c.Name : zip_Code__c
        Map<String, zip_Code__c> mapZipCodeNameToZipCode = new Map<String, zip_Code__c>();  //??
        List<zip_Code__c> lstZips = new List<zip_Code__c>([SELECT Id, Name, Street__c, City__c, States__c, Country__c
                                                           FROM zip_Code__c
                                                           WHERE Name IN :setZipCodes]); //name is the zipcode field in here
        for(zip_Code__c zip : lstZips) {
            mapZipCodeNameToZipCode.put(zip.Name, zip);// key->zip.name and value-->lstZips 
            system.debug('key and value ' + mapZipCodeNameToZipCode);
        }
        
        for(Account accs : lstNewAcc){
            if(String.isNotBlank(accs.BillingPostalCode) && mapZipCodeNameToZipCode.containsKey(accs.BillingPostalCode)) {
                zip_Code__c billingAddress = mapZipCodeNameToZipCode.get(accs.BillingPostalCode);
                accs.BillingStreet = billingAddress.Street__c;
                accs.BillingCity = billingAddress.City__c;
                accs.BillingState = billingAddress.States__c;
                accs.BillingCountry = billingAddress.Country__c;
                
               /*
 				accs.BillingStreet = zip.Street__c;
                accs.BillingCity=zip.City__c;
                accs.BillingState=zip.States__c;
                accs.BillingCountry=zip.Country__c;
				*/
            } 
            
            if(String.isNotBlank(accs.ShippingPostalCode) && mapZipCodeNameToZipCode.containsKey(accs.ShippingPostalCode)) {
				zip_Code__c shippingAddress = mapZipCodeNameToZipCode.get(accs.ShippingPostalCode);
                accs.ShippingStreet = shippingAddress.Street__c;
                accs.ShippingCity = shippingAddress.City__c;
                accs.ShippingState = shippingAddress.States__c;
                accs.ShippingCountry = shippingAddress.Country__c;
                
                /*
                accs.ShippingStreet=zip.Street__c;
                accs.ShippingCity=zip.City__c;
                accs.ShippingState=zip.States__c;
                accs.ShippingCountry=zip.Country__c;
				*/
            } 
        }
    }
    
    
}