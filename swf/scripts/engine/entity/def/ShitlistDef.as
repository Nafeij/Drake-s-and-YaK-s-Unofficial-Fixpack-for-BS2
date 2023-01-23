package engine.entity.def
{
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   
   public class ShitlistDef
   {
      
      public static const schema:Object = {
         "name":"ShitlistDef",
         "properties":{
            "id":{"type":"string"},
            "entries":{
               "type":"array",
               "items":ShitlistEntryDef.schema
            }
         }
      };
       
      
      public var entries:Vector.<ShitlistEntryDef>;
      
      public var id:String;
      
      public function ShitlistDef()
      {
         this.entries = new Vector.<ShitlistEntryDef>();
         super();
      }
      
      public static function vctor() : *
      {
         return new Vector.<ShitlistDef>();
      }
      
      public function clone() : ShitlistDef
      {
         var _loc1_:ShitlistDef = new ShitlistDef().fromJson(this.toJson(),null);
         _loc1_.id = this.id;
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ShitlistDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         ArrayUtil.arrayToDefVector(param1.entries,ShitlistEntryDef,param2,this.entries);
         return this;
      }
      
      public function toJson(param1:Boolean = false) : Object
      {
         return {
            "id":(!!this.id ? this.id : ""),
            "entries":ArrayUtil.defVectorToArray(this.entries,true,param1)
         };
      }
      
      public function computeShitlistWeight(param1:IBattleEntity, param2:ILogger) : int
      {
         var _loc4_:ShitlistEntryDef = null;
         var _loc3_:int = 0;
         for each(_loc4_ in this.entries)
         {
            if(_loc4_.target.checkExecutionConditions(param1,param2,true))
            {
               _loc3_ += _loc4_.weight;
            }
         }
         return _loc3_;
      }
   }
}
