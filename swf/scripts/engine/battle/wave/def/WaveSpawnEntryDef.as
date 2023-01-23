package engine.battle.wave.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   
   public class WaveSpawnEntryDef
   {
      
      public static const schema:Object = {
         "name":"WaveSpawnEntryDef",
         "type":"object",
         "properties":{
            "entityId":{"type":"string"},
            "weight":{
               "type":"number",
               "optional":true
            },
            "lootTableOverride":{
               "type":"array",
               "items":LootTableEntryDef.schema,
               "optional":true
            }
         }
      };
       
      
      public var entityId:String;
      
      public var weight:int;
      
      public var lootTableOverride:Vector.<LootTableEntryDef>;
      
      public function WaveSpawnEntryDef()
      {
         this.lootTableOverride = new Vector.<LootTableEntryDef>();
         super();
         this.weight = 1;
      }
      
      public static function vctor() : Vector.<WaveSpawnEntryDef>
      {
         return new Vector.<WaveSpawnEntryDef>();
      }
      
      public function clone(param1:WaveSpawnEntryDef) : WaveSpawnEntryDef
      {
         if(!param1)
         {
            return null;
         }
         this.entityId = param1.entityId;
         this.weight = param1.weight;
         this.lootTableOverride.length = 0;
         var _loc2_:int = 0;
         while(_loc2_ < param1.lootTableOverride.length)
         {
            this.lootTableOverride.push(new LootTableEntryDef().clone(param1.lootTableOverride[_loc2_]));
            _loc2_++;
         }
         return this;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : WaveSpawnEntryDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(param1.entityId)
         {
            this.entityId = param1.entityId;
         }
         else
         {
            this.entityId = "unknown_entity";
         }
         if(param1.weight)
         {
            this.weight = param1.weight;
         }
         if(param1.lootTableOverride)
         {
            this.lootTableOverride = ArrayUtil.arrayToDefVector(param1.lootTableOverride,LootTableEntryDef,param2,this.lootTableOverride) as Vector.<LootTableEntryDef>;
         }
         if(this.weight < 0)
         {
            param2.error("ERROR: WaveSpawnEntry configured with invalid weight!\nentityId: " + this.entityId + "\tweight: " + this.weight);
            this.weight = 1;
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {};
         if(this.entityId)
         {
            _loc1_.entityId = this.entityId;
         }
         if(this.weight != 1 && Boolean(this.weight))
         {
            _loc1_.weight = this.weight;
         }
         if(Boolean(this.lootTableOverride) && Boolean(this.lootTableOverride.length))
         {
            _loc1_.lootTableOverride = ArrayUtil.defVectorToArray(this.lootTableOverride,false);
         }
         return _loc1_;
      }
   }
}
