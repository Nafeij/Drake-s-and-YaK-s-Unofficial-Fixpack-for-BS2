package engine.entity.def
{
   import flash.events.IEventDispatcher;
   
   public interface IPartyDef extends IEventDispatcher
   {
       
      
      function get roster() : IEntityListDef;
      
      function hasMemberId(param1:String) : Boolean;
      
      function getMembersFromRoster() : Vector.<IEntityDef>;
      
      function get numMembers() : int;
      
      function getMemberId(param1:int) : String;
      
      function getMember(param1:int) : IEntityDef;
      
      function getMemberById(param1:String) : IEntityDef;
      
      function getMemberIndex(param1:String) : int;
      
      function updateMemberSlotPosition(param1:IEntityDef, param2:IEntityDef) : Boolean;
      
      function addMember(param1:String) : Boolean;
      
      function removeMember(param1:String) : Boolean;
      
      function getEntityListDef() : IEntityListDef;
      
      function get totalPower() : int;
      
      function clear() : void;
      
      function get partyLimitsExceeded() : String;
      
      function reset(param1:Vector.<String>) : void;
      
      function get copyMemberIds() : Vector.<String>;
      
      function notifyChange() : void;
   }
}
