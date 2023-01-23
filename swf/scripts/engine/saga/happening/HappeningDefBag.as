package engine.saga.happening
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   import engine.saga.SagaTriggerDef;
   import engine.saga.SagaTriggerType;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class HappeningDefBag extends EventDispatcher implements IHappeningDefProvider
   {
       
      
      public var list:Vector.<HappeningDef>;
      
      public var byId:Dictionary;
      
      public var dirty:Boolean;
      
      private var _providerName:String;
      
      private var _owner;
      
      public function HappeningDefBag(param1:String, param2:*)
      {
         this.list = new Vector.<HappeningDef>();
         this.byId = new Dictionary();
         super();
         this._providerName = param1;
         this._owner = param2;
      }
      
      public static function getHappeningsUrl(param1:String) : String
      {
         return param1.replace(".json",".hap.json");
      }
      
      public function get linkString() : String
      {
         if("linkString" in this._owner)
         {
            return this._owner.linkString;
         }
         return this._owner.toString();
      }
      
      override public function toString() : String
      {
         return this._providerName;
      }
      
      public function get providerName() : String
      {
         return this._providerName;
      }
      
      public function addHappeningDef(param1:HappeningDef, param2:int = -1) : void
      {
         param1.bag = this;
         if(param2 > -1 && param2 < this.list.length)
         {
            this.list.splice(param2,0,param1);
         }
         else
         {
            this.list.push(param1);
         }
         this.byId[param1.id] = param1;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function removeHappeningDefById(param1:String) : void
      {
         var _loc2_:HappeningDef = this.byId[param1];
         if(_loc2_)
         {
            this.removeHappeningDef(_loc2_);
         }
      }
      
      public function removeHappeningDef(param1:HappeningDef) : void
      {
         var _loc3_:HappeningDef = null;
         delete this.byId[param1.id];
         var _loc2_:int = this.list.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.list.splice(_loc2_,1);
         }
         for each(_loc3_ in this.list)
         {
            _loc3_.handleRemoveHappening(param1);
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function getHappeningDef(param1:String) : HappeningDef
      {
         return this.byId[param1];
      }
      
      public function get numHappenings() : int
      {
         return this.list.length;
      }
      
      public function executeAutomatics(param1:ISaga) : void
      {
         var _loc2_:HappeningDef = null;
         var _loc3_:IHappening = null;
         for each(_loc2_ in this.list)
         {
            if(_loc2_.automatic)
            {
               _loc3_ = param1.preExecuteHappeningDef(_loc2_,this);
               if(_loc3_)
               {
                  _loc3_.execute();
               }
            }
         }
      }
      
      public function handleRenameCaravan(param1:String, param2:String) : void
      {
         var _loc3_:HappeningDef = null;
         for each(_loc3_ in this.list)
         {
            _loc3_.handleRenameCaravan(param1,param2);
         }
      }
      
      public function handleRenameBucket(param1:String, param2:String) : void
      {
         var _loc3_:HappeningDef = null;
         for each(_loc3_ in this.list)
         {
            _loc3_.handleRenameBucket(param1,param2);
         }
      }
      
      public function handleRenameVariable(param1:String, param2:String, param3:RenameVariableInfo) : void
      {
         var _loc4_:HappeningDef = null;
         ++param3.visited_happeningbags;
         for each(_loc4_ in this.list)
         {
            _loc4_.handleRenameVariable(param1,param2,param3);
         }
      }
      
      public function createNewHappening(param1:String = null, param2:int = -1) : HappeningDef
      {
         var _loc3_:HappeningDef = null;
         param1 = this.generateNewHappeningId(param1);
         if(param1)
         {
            _loc3_ = new HappeningDef(this);
            _loc3_.id = param1;
            this.addHappeningDef(_loc3_,param2);
            dispatchEvent(new Event(Event.CHANGE));
            return _loc3_;
         }
         return null;
      }
      
      public function generateNewHappeningId(param1:String = null) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc2_:* = "New_Happening_";
         if(Boolean(param1) && Boolean(this.getHappeningDef(param1)))
         {
            _loc2_ = param1 + "_";
            param1 = null;
         }
         if(param1)
         {
            return param1;
         }
         if(!param1)
         {
            _loc3_ = 1;
            while(_loc3_ < 1000)
            {
               _loc4_ = _loc2_ + _loc3_;
               if(!this.byId[_loc4_])
               {
                  return _loc4_;
               }
               _loc3_++;
            }
         }
         return null;
      }
      
      public function renameHappening(param1:HappeningDef, param2:String) : void
      {
         var _loc4_:HappeningDef = null;
         if(this.byId[param2])
         {
            return;
         }
         var _loc3_:String = param1.id;
         delete this.byId[param1.id];
         param1.id = param2;
         this.byId[param1.id] = param1;
         for each(_loc4_ in this.list)
         {
            _loc4_.handleRenameHappening(_loc3_,param2);
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function getHappeningDefByIndex(param1:int) : HappeningDef
      {
         return this.list[param1];
      }
      
      public function getTriggersByType(param1:SagaTriggerType, param2:Vector.<SagaTriggerDef>, param3:String) : Vector.<SagaTriggerDef>
      {
         var _loc4_:HappeningDef = null;
         if(!param2)
         {
            param2 = new Vector.<SagaTriggerDef>();
         }
         for each(_loc4_ in this.list)
         {
            _loc4_.triggers.getTriggersByType(param1,param2,param3,null,null);
         }
         return param2;
      }
      
      public function get owner() : *
      {
         return this._owner;
      }
      
      public function getSpeechBubbleEntities(param1:Dictionary) : void
      {
         var _loc2_:HappeningDef = null;
         for each(_loc2_ in this.list)
         {
            _loc2_.getSpeechBubbleEntities(param1);
         }
      }
      
      public function findActionsByType(param1:ActionType, param2:Vector.<ActionDef>) : Vector.<ActionDef>
      {
         var _loc3_:HappeningDef = null;
         if(this.list)
         {
            for each(_loc3_ in this.list)
            {
               param2 = _loc3_.findActionsByType(param1,param2);
            }
         }
         return param2;
      }
      
      public function findActionsForSceneUrl(param1:String, param2:Vector.<ActionDef>) : void
      {
         var _loc3_:HappeningDef = null;
         if(this.list)
         {
            for each(_loc3_ in this.list)
            {
               _loc3_.findActionsForSceneUrl(param1,param2);
            }
         }
      }
      
      public function findActionsForHappening(param1:HappeningDef, param2:Vector.<ActionDef>) : void
      {
         var _loc3_:HappeningDef = null;
         var _loc4_:HappeningDef = null;
         if(this.list)
         {
            if(param1.bag != this)
            {
               _loc4_ = this.getHappeningDef(param1.id);
               if(!_loc4_)
               {
               }
            }
            for each(_loc3_ in this.list)
            {
               _loc3_.findActionsForHappening(param1,_loc4_,param2);
            }
         }
      }
      
      public function stringifyActions(param1:String, param2:Locale, param3:ILogger) : void
      {
         var _loc4_:HappeningDef = null;
         if(!this.list)
         {
            return;
         }
         for each(_loc4_ in this.list)
         {
            _loc4_.stringifyActions(param1,param2,param3);
         }
      }
      
      public function gatherActionProperties(param1:ActionType, param2:String, param3:Array) : void
      {
         var _loc4_:HappeningDef = null;
         for each(_loc4_ in this.list)
         {
            _loc4_.gatherActionProperties(param1,param2,param3);
         }
      }
   }
}
