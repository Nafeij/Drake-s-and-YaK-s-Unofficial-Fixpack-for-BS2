package engine.battle.board.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.tile.def.TileLocation;
   import flash.events.EventDispatcher;
   
   public class BattleBoardTriggerSpawnerDefs extends EventDispatcher
   {
      
      public static const schema:Object = {
         "name":"BattleBoardDefVars",
         "type":"object",
         "properties":{"triggers":{
            "type":"array",
            "items":BattleBoardTriggerSpawnerDef.schema
         }}
      };
       
      
      public var triggers:Vector.<BattleBoardTriggerSpawnerDef>;
      
      public function BattleBoardTriggerSpawnerDefs()
      {
         this.triggers = new Vector.<BattleBoardTriggerSpawnerDef>();
         super();
      }
      
      public function get hasTriggerSpawnerDefs() : Boolean
      {
         return Boolean(this.triggers) && Boolean(this.triggers.length);
      }
      
      public function cleanup() : void
      {
      }
      
      public function notifyTriggerSpawnerAdded(param1:BattleBoardTriggerSpawnerDef) : void
      {
         dispatchEvent(new BattleBoardTriggerSpawnersEvent(BattleBoardTriggerSpawnersEvent.EVENT_ADDED,param1,null));
      }
      
      public function notifyTriggerSpawnerRemoved(param1:String) : void
      {
         dispatchEvent(new BattleBoardTriggerSpawnersEvent(BattleBoardTriggerSpawnersEvent.EVENT_REMOVED,null,param1));
      }
      
      public function notifyTriggerSpawnerChanged(param1:BattleBoardTriggerSpawnerDef) : void
      {
         dispatchEvent(new BattleBoardTriggerSpawnersEvent(BattleBoardTriggerSpawnersEvent.EVENT_CHANGED,param1,null));
      }
      
      public function notifyTriggerSpawnerRectChanged(param1:BattleBoardTriggerSpawnerDef) : void
      {
         dispatchEvent(new BattleBoardTriggerSpawnersEvent(BattleBoardTriggerSpawnersEvent.EVENT_RECT,param1,null));
      }
      
      public function clone() : BattleBoardTriggerSpawnerDefs
      {
         var _loc2_:BattleBoardTriggerSpawnerDef = null;
         var _loc1_:BattleBoardTriggerSpawnerDefs = new BattleBoardTriggerSpawnerDefs();
         for each(_loc2_ in this.triggers)
         {
            _loc1_.addTrigger(_loc2_.clone());
         }
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleBoardTriggerSpawnerDefs
      {
         this.fromJsonArray(param1.triggers,param2);
         return this;
      }
      
      public function fromJsonArray(param1:Array, param2:ILogger) : BattleBoardTriggerSpawnerDefs
      {
         var _loc3_:Object = null;
         var _loc4_:BattleBoardTriggerSpawnerDef = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = new BattleBoardTriggerSpawnerDef().fromJson(_loc3_,param2);
            this.addTrigger(_loc4_);
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {};
         _loc1_.triggers = ArrayUtil.defVectorToArray(this.triggers,true);
         return _loc1_;
      }
      
      public function addTrigger(param1:BattleBoardTriggerSpawnerDef) : void
      {
         this.triggers.push(param1);
         param1.triggerSpawnerDefs = this;
         this.notifyTriggerSpawnerAdded(param1);
      }
      
      public function removeTrigger(param1:BattleBoardTriggerSpawnerDef) : void
      {
         var _loc2_:String = param1.trigger_id;
         var _loc3_:int = this.triggers.indexOf(param1);
         if(_loc3_ >= 0)
         {
            this.triggers.splice(_loc3_,1);
         }
         this.notifyTriggerSpawnerRemoved(_loc2_);
      }
      
      public function visitTriggerSpawnerDefs(param1:Function) : void
      {
         var _loc2_:BattleBoardTriggerSpawnerDef = null;
         for each(_loc2_ in this.triggers)
         {
            param1(_loc2_);
         }
      }
      
      public function findTriggerSpawnerDef(param1:Function) : BattleBoardTriggerSpawnerDef
      {
         var _loc2_:BattleBoardTriggerSpawnerDef = null;
         for each(_loc2_ in this.triggers)
         {
            if(param1(_loc2_))
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function findTriggerForLocation(param1:TileLocation) : BattleBoardTriggerSpawnerDef
      {
         var tl:TileLocation = param1;
         return this.findTriggerSpawnerDef(function(param1:BattleBoardTriggerSpawnerDef):Boolean
         {
            return param1.rect.contains(tl._x,tl._y);
         });
      }
   }
}
