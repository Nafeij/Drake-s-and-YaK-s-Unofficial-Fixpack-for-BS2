package engine.battle.board.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class BattleBoardTriggerDefList extends EventDispatcher
   {
      
      public static const schema:Object = {
         "name":"BattleBoardTriggerDefList",
         "type":"object",
         "properties":{"triggerdefs":{
            "type":"array",
            "items":BattleBoardTriggerDef.schema
         }}
      };
       
      
      public var defs:Vector.<BattleBoardTriggerDef>;
      
      public var defsById:Dictionary;
      
      public var loadedJson:String;
      
      public var url:String;
      
      public function BattleBoardTriggerDefList()
      {
         this.defs = new Vector.<BattleBoardTriggerDef>();
         this.defsById = new Dictionary();
         super();
      }
      
      public function cleanup() : void
      {
      }
      
      public function clone() : BattleBoardTriggerDefList
      {
         var _loc2_:BattleBoardTriggerDef = null;
         var _loc1_:BattleBoardTriggerDefList = new BattleBoardTriggerDefList();
         for each(_loc2_ in this.defs)
         {
            _loc1_.addTriggerDef(_loc2_.clone());
         }
         return _loc1_;
      }
      
      public function get numTriggerDefs() : int
      {
         return this.defs.length;
      }
      
      public function getDefById(param1:String) : BattleBoardTriggerDef
      {
         return this.defsById[param1];
      }
      
      public function renameTriggerDef(param1:String, param2:String) : Boolean
      {
         if(this.defsById[param2])
         {
            return false;
         }
         var _loc3_:BattleBoardTriggerDef = this.defsById[param1];
         _loc3_.id = param2;
         delete this.defsById[param1];
         this.defsById[param2] = _loc3_;
         return true;
      }
      
      public function addTriggerDef(param1:BattleBoardTriggerDef) : void
      {
         if(this.getDefById(param1.id))
         {
            throw new IllegalOperationError("Duplicate trigger id [" + param1.id + "]");
         }
         this.defs.push(param1);
         param1.triggerDefs = this;
         this.defsById[param1.id] = param1;
      }
      
      public function removeTriggerDef(param1:BattleBoardTriggerDef) : void
      {
         var _loc2_:int = this.defs.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.defs.splice(_loc2_,1);
         }
         delete this.defsById[param1.id];
      }
      
      public function findCopyName(param1:String) : String
      {
         var _loc2_:String = param1;
         if(!this.defsById[_loc2_])
         {
            return _loc2_;
         }
         var _loc3_:int = 0;
         while(_loc3_ < 1000)
         {
            _loc2_ = param1 + "_" + _loc3_;
            if(!this.defsById[_loc2_])
            {
               return _loc2_;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleBoardTriggerDefList
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         ArrayUtil.arrayProcessDefs(param1.triggerdefs,BattleBoardTriggerDef,param2,this.addTriggerDef);
         return this;
      }
      
      public function toJson() : Object
      {
         return {"triggerdefs":ArrayUtil.defVectorToArray(this.defs,true)};
      }
   }
}
