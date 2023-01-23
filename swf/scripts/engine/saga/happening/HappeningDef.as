package engine.saga.happening
{
   import engine.core.BoxString;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.expression.exp.Exp;
   import engine.saga.SagaTriggerDefBag;
   import engine.saga.SagaTriggerType;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.vars.IVariableProvider;
   import flash.utils.Dictionary;
   
   public class HappeningDef
   {
       
      
      public var id:String;
      
      public var random:Boolean;
      
      public var actions:Vector.<ActionDef>;
      
      public var triggers:SagaTriggerDefBag;
      
      public var keepalive:Boolean;
      
      public var transcendent:Boolean = true;
      
      public var automatic:Boolean;
      
      public var bag:IHappeningDefProvider;
      
      public var enabled:Boolean = true;
      
      public var outliveBattle:Boolean;
      
      public var prereq:String;
      
      public var exp_prereq:Exp;
      
      public var allow_saves:Boolean;
      
      public var bagName:String;
      
      public function HappeningDef(param1:IHappeningDefProvider)
      {
         this.actions = new Vector.<ActionDef>();
         super();
         this.bag = param1;
         this.triggers = new SagaTriggerDefBag(param1);
      }
      
      public function get hasTriggers() : Boolean
      {
         return Boolean(this.triggers) && Boolean(this.triggers.list) && Boolean(this.triggers.list.length);
      }
      
      public function hasTriggersForType(param1:SagaTriggerType) : Boolean
      {
         return Boolean(this.triggers) && this.triggers.hasTriggersForType(param1);
      }
      
      public function get linkString() : String
      {
         return this.bag.linkString + " : " + this.id;
      }
      
      public function toString() : String
      {
         return "[" + this.id + " bag=" + this.bag + "]";
      }
      
      public function clone() : HappeningDef
      {
         var _loc2_:ActionDef = null;
         var _loc1_:HappeningDef = new HappeningDef(this.bag);
         _loc1_.id = this.id;
         _loc1_.random = this.random;
         for each(_loc2_ in this.actions)
         {
            _loc1_.actions.push(_loc2_.clone());
         }
         _loc1_.triggers = this.triggers.clone();
         _loc1_.keepalive = this.keepalive;
         _loc1_.transcendent = this.transcendent;
         _loc1_.automatic = this.automatic;
         _loc1_.bag = this.bag;
         _loc1_.enabled = this.enabled;
         _loc1_.outliveBattle = this.outliveBattle;
         _loc1_.prereq = this.prereq;
         return _loc1_;
      }
      
      public function addActionDef(param1:ActionDef, param2:int = -1) : ActionDef
      {
         if(param2 > -1 && param2 < this.actions.length)
         {
            this.actions.splice(param2,0,param1);
         }
         else
         {
            this.actions.push(param1);
         }
         return param1;
      }
      
      public function removeActionDef(param1:ActionDef) : void
      {
         var _loc2_:int = this.actions.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.actions.splice(_loc2_,1);
         }
      }
      
      public function handleRenameBucket(param1:String, param2:String) : void
      {
         var _loc3_:ActionDef = null;
         for each(_loc3_ in this.actions)
         {
            _loc3_.handleRenameBucket(param1,param2);
         }
      }
      
      public function handleRenameCaravan(param1:String, param2:String) : void
      {
         var _loc3_:ActionDef = null;
         for each(_loc3_ in this.actions)
         {
            _loc3_.handleRenameCaravan(param1,param2);
         }
      }
      
      public function handleRenameVariable(param1:String, param2:String, param3:RenameVariableInfo) : void
      {
         var _loc4_:ActionDef = null;
         ++param3.visited_happenings;
         for each(_loc4_ in this.actions)
         {
            _loc4_.handleRenameVariable(param1,param2,param3);
         }
      }
      
      public function handleRemoveHappening(param1:HappeningDef) : void
      {
         var _loc2_:ActionDef = null;
         for each(_loc2_ in this.actions)
         {
            _loc2_.handleRemoveHappening(param1);
         }
      }
      
      public function handleRenameHappening(param1:String, param2:String) : void
      {
         var _loc3_:ActionDef = null;
         for each(_loc3_ in this.actions)
         {
            _loc3_.handleRenameHappening(param1,param2);
         }
      }
      
      public function createNewAction(param1:int = -1) : ActionDef
      {
         return this.addActionDef(new ActionDef(this),param1);
      }
      
      public function getSpeechBubbleEntities(param1:Dictionary) : void
      {
         var _loc2_:ActionDef = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         for each(_loc2_ in this.actions)
         {
            if(_loc2_.type == ActionType.SPEAK)
            {
               if(_loc2_.speaker)
               {
                  _loc3_ = _loc2_.speaker.split(",");
                  for each(_loc4_ in _loc3_)
                  {
                     param1[_loc4_] = true;
                  }
               }
            }
         }
      }
      
      public function findActionsByType(param1:ActionType, param2:Vector.<ActionDef>) : Vector.<ActionDef>
      {
         var _loc3_:ActionDef = null;
         if(this.actions)
         {
            for each(_loc3_ in this.actions)
            {
               if(_loc3_.type == param1)
               {
                  if(!param2)
                  {
                     param2 = new Vector.<ActionDef>();
                  }
                  param2.push(_loc3_);
               }
            }
         }
         return param2;
      }
      
      public function findActionsForSceneUrl(param1:String, param2:Vector.<ActionDef>) : void
      {
         var _loc3_:ActionDef = null;
         if(this.actions)
         {
            for each(_loc3_ in this.actions)
            {
               if(ActionDef.hasPropByType(_loc3_.type,"scene"))
               {
                  if(_loc3_.scene == param1)
                  {
                     param2.push(_loc3_);
                  }
               }
            }
         }
      }
      
      public function findActionsForHappening(param1:HappeningDef, param2:HappeningDef, param3:Vector.<ActionDef>) : void
      {
         var _loc4_:ActionDef = null;
         if(this.actions)
         {
            for each(_loc4_ in this.actions)
            {
               if(ActionDef.hasPropByType(_loc4_.type,"happeningId"))
               {
                  if(_loc4_.happeningId == param1.id)
                  {
                     if(param2)
                     {
                        if(_loc4_.type == ActionType.HAPPENING)
                        {
                           continue;
                        }
                     }
                     param3.push(_loc4_);
                  }
               }
            }
         }
      }
      
      public function checkPrereq(param1:IVariableProvider, param2:BoxString) : Boolean
      {
         if(this.prereq)
         {
            if(this.exp_prereq)
            {
               if(this.exp_prereq.evaluate(param1,true) == 0)
               {
                  if(param2)
                  {
                     param2.value = this.prereq;
                  }
                  return false;
               }
               return true;
            }
            throw new ArgumentError("Happening prereq is unavailable for evaluation.  See earlier errors on loading: " + this);
         }
         return true;
      }
      
      public function stringifyActions(param1:String, param2:Locale, param3:ILogger) : void
      {
         var _loc4_:ActionDef = null;
         if(!this.actions)
         {
            return;
         }
         param1 = !!param1 ? param1 + "_" + this.id : this.id;
         for each(_loc4_ in this.actions)
         {
            _loc4_.stringifyAction(param1,param2,param3);
         }
      }
      
      public function gatherActionProperties(param1:ActionType, param2:String, param3:Array) : void
      {
         var _loc4_:ActionDef = null;
         for each(_loc4_ in this.actions)
         {
            _loc4_.gatherActionProperties(param1,param2,param3);
         }
      }
   }
}
