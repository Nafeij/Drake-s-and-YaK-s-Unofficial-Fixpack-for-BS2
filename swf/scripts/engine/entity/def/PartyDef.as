package engine.entity.def
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class PartyDef extends EventDispatcher implements IPartyDef
   {
       
      
      public var memberIds:Vector.<String>;
      
      private var memberIdSet:Dictionary;
      
      private var _roster:IEntityListDef;
      
      public function PartyDef(param1:IEntityListDef)
      {
         this.memberIds = new Vector.<String>();
         this.memberIdSet = new Dictionary();
         super();
         this._roster = param1;
      }
      
      public function cleanup() : void
      {
         this.memberIds = null;
         this.memberIdSet = null;
         this._roster = null;
      }
      
      override public function toString() : String
      {
         return this.memberIds.toString();
      }
      
      public function get roster() : IEntityListDef
      {
         return this._roster;
      }
      
      public function hasMemberId(param1:String) : Boolean
      {
         return this.memberIds.indexOf(param1) >= 0;
      }
      
      public function getEntityListDef() : IEntityListDef
      {
         var _loc3_:IEntityDef = null;
         var _loc1_:Vector.<IEntityDef> = this.getMembersFromRoster();
         var _loc2_:EntityListDef = new EntityListDef(this._roster.locale,this._roster.classes,this._roster.logger);
         for each(_loc3_ in _loc1_)
         {
            _loc2_.addEntityDef(_loc3_);
         }
         return _loc2_;
      }
      
      public function getMembersFromRoster() : Vector.<IEntityDef>
      {
         var _loc2_:String = null;
         var _loc3_:IEntityDef = null;
         var _loc1_:Vector.<IEntityDef> = new Vector.<IEntityDef>();
         for each(_loc2_ in this.memberIds)
         {
            _loc3_ = this.roster.getEntityDefById(_loc2_);
            if(_loc3_)
            {
               _loc1_.push(_loc3_);
            }
         }
         return _loc1_;
      }
      
      public function get numMembers() : int
      {
         return this.memberIds.length;
      }
      
      public function getMemberIndex(param1:String) : int
      {
         return this.memberIds.indexOf(param1);
      }
      
      public function getMemberId(param1:int) : String
      {
         if(param1 < 0 || param1 >= this.memberIds.length)
         {
            return null;
         }
         return this.memberIds[param1];
      }
      
      public function getMember(param1:int) : IEntityDef
      {
         return this.roster.getEntityDefById(this.getMemberId(param1));
      }
      
      public function getMemberById(param1:String) : IEntityDef
      {
         return this.roster.getEntityDefById(param1);
      }
      
      public function reset(param1:Vector.<String>) : void
      {
         var _loc2_:String = null;
         this.memberIds.splice(0,this.memberIds.length);
         this.memberIdSet = new Dictionary();
         for each(_loc2_ in param1)
         {
            if(!this.roster.getEntityDefById(_loc2_))
            {
               throw new ArgumentError("No such roster member: " + _loc2_);
            }
            this.memberIds.push(_loc2_);
            this.memberIdSet[_loc2_] = _loc2_;
         }
         this.notifyChange();
      }
      
      public function notifyChange() : void
      {
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function updateMemberSlotPosition(param1:IEntityDef, param2:IEntityDef) : Boolean
      {
         if(param2 == null)
         {
            this.removeMember(param1.id);
            this.addMember(param1.id);
            return true;
         }
         if(param1.id == param2.id)
         {
            return false;
         }
         var _loc3_:Number = this.memberIds.indexOf(param1.id);
         var _loc4_:Number = this.memberIds.indexOf(param2.id);
         if(_loc3_ >= 0)
         {
            this.memberIds[_loc3_] = param2.id;
            this.memberIds[_loc4_] = param1.id;
         }
         else if(this.memberIds.length >= 6)
         {
            if(param2.partyRequired)
            {
               return false;
            }
            this.memberIds[_loc4_] = param1.id;
         }
         else
         {
            this.memberIds.splice(_loc4_,0,param1.id);
         }
         this.notifyChange();
         return true;
      }
      
      public function addMember(param1:String) : Boolean
      {
         if(this.hasMemberId(param1))
         {
            return false;
         }
         if(Boolean(this._roster) && !this._roster.getEntityDefById(param1))
         {
            return false;
         }
         this.memberIds.push(param1);
         this.memberIdSet[param1] = param1;
         this.notifyChange();
         return true;
      }
      
      public function setEntityIdIndex(param1:String, param2:int) : void
      {
         var _loc3_:int = this.memberIds.indexOf(param1);
         if(param2 == _loc3_)
         {
            return;
         }
         this.memberIds.splice(_loc3_,1);
         if(param2 < _loc3_)
         {
            this.memberIds.splice(param2,0,param1);
         }
         else
         {
            this.memberIds.splice(param2,0,param1);
         }
         this.notifyChange();
      }
      
      public function clear() : void
      {
         this.memberIdSet = new Dictionary();
         this.memberIds.splice(0,this.memberIds.length);
         this.notifyChange();
      }
      
      public function removeMember(param1:String) : Boolean
      {
         var _loc2_:IEntityDef = null;
         var _loc3_:int = 0;
         if(this.hasMemberId(param1))
         {
            _loc2_ = this.getMemberById(param1);
            if(Boolean(_loc2_) && _loc2_.partyRequired)
            {
               return false;
            }
            delete this.memberIdSet[param1];
            _loc3_ = this.memberIds.indexOf(param1);
            this.memberIds.splice(_loc3_,1);
            this.notifyChange();
            return true;
         }
         return false;
      }
      
      public function get totalPower() : int
      {
         var _loc2_:IEntityDef = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.getMembersFromRoster())
         {
            _loc1_ += _loc2_.power;
         }
         return _loc1_;
      }
      
      public function get partyLimitsExceeded() : String
      {
         var _loc2_:IEntityDef = null;
         var _loc3_:int = 0;
         var _loc1_:Dictionary = new Dictionary();
         for each(_loc2_ in this.getMembersFromRoster())
         {
            _loc3_ = 0;
            if(_loc2_.entityClass.partyTag in _loc1_)
            {
               _loc3_ = int(_loc1_[_loc2_.entityClass.partyTag]);
            }
            _loc3_++;
            if(_loc3_ > _loc2_.entityClass.getPartyTagLimit(this.roster.classes.meta))
            {
               return _loc2_.entityClass.partyTagDisplay;
            }
            _loc1_[_loc2_.entityClass.partyTag] = _loc3_;
         }
         return null;
      }
      
      public function get copyMemberIds() : Vector.<String>
      {
         return this.memberIds.concat();
      }
   }
}
