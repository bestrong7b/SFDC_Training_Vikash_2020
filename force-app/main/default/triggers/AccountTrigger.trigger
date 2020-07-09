trigger AccountTrigger on Account (before insert, before update, after update, after Insert) {
    // identify which event is occuring, occordingly call the handler methods to opertae
    /*
    insert --> after and before
    update --> after and before
    delete --> after and before
    
    after events ---> insert/update/delete/undelete
    before events --> insert/update/delete
    */ 
    
    
    if(Trigger.IsBefore) {
        if(Trigger.IsInsert) {
            AccountTriggerHandler.onBeforeInsert(trigger.new);
        }
        
        if(Trigger.IsUpdate) {
            AccountTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
        }
        
        // if(Trigger.isDelete) {}
    }
      
   
    if(Trigger.IsAfter) {
        if(Trigger.IsInsert) {
            AccountTriggerHandler.onAfterInsert(trigger.newMap);
        }
        
        if(Trigger.IsUpdate) {
            AccountTriggerHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
        }
        
        if(Trigger.isDelete) {}
        
        if(Trigger.IsUndelete) {}
    }
}