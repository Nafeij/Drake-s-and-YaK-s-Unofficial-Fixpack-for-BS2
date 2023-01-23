package engine.battle.wave.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   
   public class GuaranteedSpawnDef
   {
      
      public static const schema:Object = {
         "name":"GuaranteedSpawnDef",
         "type":"object",
         "properties":{
            "entityList":{
               "type":"array",
               "items":WaveSpawnEntryDef.schema
            },
            "name":{"type":"string"},
            "spawnInLoss":{"type":"boolean"},
            "lootTable":{
               "type":"array",
               "items":LootTableEntryDef.schema,
               "optional":true
            }
         }
      };
       
      
      public var name:String = "new_spawn";
      
      public var entityList:Vector.<WaveSpawnEntryDef>;
      
      public var lootTable:Vector.<LootTableEntryDef>;
      
      public var spawnInLoss:Boolean = false;
      
      public function GuaranteedSpawnDef()
      {
         this.entityList = new Vector.<WaveSpawnEntryDef>();
         this.lootTable = new Vector.<LootTableEntryDef>();
         super();
      }
      
      public static function vctor() : Vector.<GuaranteedSpawnDef>
      {
         return new Vector.<GuaranteedSpawnDef>();
      }
      
      public function GetTotalEntityWeight() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.entityList.length)
         {
            _loc1_ += this.entityList[_loc2_].weight;
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function clone(param1:GuaranteedSpawnDef) : GuaranteedSpawnDef
      {
         if(!param1)
         {
            return null;
         }
         this.lootTable.length = 0;
         this.entityList.length = 0;
         var _loc2_:int = 0;
         while(_loc2_ < param1.lootTable.length)
         {
            this.lootTable.push(new LootTableEntryDef().clone(param1.lootTable[_loc2_]));
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.entityList.length)
         {
            this.entityList.push(new WaveSpawnEntryDef().clone(param1.entityList[_loc3_]));
            _loc3_++;
         }
         return this;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : GuaranteedSpawnDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(param1.lootTable)
         {
            this.lootTable = ArrayUtil.arrayToDefVector(param1.lootTable,LootTableEntryDef,param2,this.lootTable) as Vector.<LootTableEntryDef>;
         }
         if(this.entityList)
         {
            this.entityList = ArrayUtil.arrayToDefVector(param1.entityList,WaveSpawnEntryDef,param2,this.entityList) as Vector.<WaveSpawnEntryDef>;
         }
         if(param1.name)
         {
            this.name = param1.name;
         }
         if(param1.spawnInLoss)
         {
            this.spawnInLoss = param1.spawnInLoss;
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "name":(!!this.name ? this.name : "new_spawn"),
            "spawnInLoss":this.spawnInLoss
         };
         if(this.lootTable)
         {
            _loc1_.lootTable = ArrayUtil.defVectorToArray(this.lootTable,false);
         }
         if(this.entityList)
         {
            _loc1_.entityList = ArrayUtil.defVectorToArray(this.entityList,false);
         }
         return _loc1_;
      }
   }
}
