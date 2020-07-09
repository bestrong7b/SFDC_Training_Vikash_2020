/** 
 * Test class for AccountTriggerHandler
 * 1. Add @IsTest annotation in the class beginning
 * 2. Create a test setup for initial test records creation by using @TestSetup
 * 3. Create seperate test methods for each functionalitie s from apex classes
*/
@IsTest
private with sharing class AccountTriggerHandler_Test {

    // Create method for records setup
    @TestSetup
    private static void createTestData() {
        // Create Account record with "Create Next Contact Interval" Checkbox is false
        Account objAcc1 = new Account();
        objAcc1.Name = 'Test Acc with UnChecked Checkbox';
        objAcc1.Phone = '19891023778';
        objAcc1.Create_Next_contact_Interval__c = false;
        insert objAcc1;

        // Create Account record with "Create Next Contact Interval" Checkbox is true
        Account objAcc_2 = new Account();
        objAcc_2.Name = 'Test Acc with Checked Checkbox';
        objAcc_2.Phone = '19891023778';
        objAcc_2.Create_Next_contact_Interval__c = true;
        insert objAcc_2;

        // Create 3 more account with checkbox as true
        // List<Account> lstAccToBeInserted = new List<Account>();

        // Account objAcc_3 = new Account();
        // objAcc_3.Name = 'Test Acc with Checked Checkbox 3';
        // objAcc_3.Phone = '19891023778';
        // objAcc_3.Create_Next_contact_Interval__c = true;
        // lstAccToBeInserted.add(objAcc_3);
        
        // lstAccToBeInserted.add(
        //     new Account(
        //         Name = 'Test Acc with Checked Checkbox 3',
        //         Create_Next_contact_Interval__c = true,
        //         Phone = '19891023778'
        //     )
        // );

        // List<String> lstStr = new List<String>();
        // List<String> lstStr_2 = new List<String>{
        //     'Value_1', 
        //     'Value_2', 
        //     'Value_3'
        // };

        List<Account> lstAccToBeInserted = new List<Account>{
            new Account(
                Name = 'Test Acc with Checkbox TRUE 3',
                Create_Next_contact_Interval__c = true,
                Phone = '19891023778'
            ),
            new Account(
                Name = 'Test Acc with Checkbox TRUE 4',
                Create_Next_contact_Interval__c = true,
                Phone = '19891023778'
            ),
            new Account(
                Name = 'Test Acc with Checkbox TRUE 5',
                Create_Next_contact_Interval__c = true,
                Phone = '19891023778'
            )
        };
    }

    // Test method for createCaseTaskUpdateAccount method
    @IsTest
    private static void createCaseTaskUpdateAccount_Test() {
        List<Account> lstAccs = [SELECT Id, Name, Phone, Create_Next_contact_Interval__c
                                FROM Account
                                WHERE Phone = '19891023778'];

        // This should return 1 case for ObjAcc_2
        List<Case> lstCases = [SELECT Id, Subject, AccountId, Status
                                FROM Case
                                WHERE AccountId IN :lstAccs];
        
        // Validate the cases created count
        System.assertEquals(4, lstCases.size());
        System.assertEquals('In Progress', lstCases[0].Status);
        // Add assertion for other case fields

        // Get the tasks for Account
        List<Task> lstTasks = [SELECT id, Subject, WhatId
                                FROM Task
                                WHERE WhatId IN :lstAccs];

        // Vlaidate task created count
        System.assertEquals(4, lstTasks.size());
                    
    }

    // Test method for UpdateAddressFields method
    @IsTest
    private static void UpdateAddressFields_Test() {

    }
}
