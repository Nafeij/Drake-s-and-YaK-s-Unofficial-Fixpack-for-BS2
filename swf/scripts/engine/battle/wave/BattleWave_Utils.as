package engine.battle.wave
{
   import engine.battle.wave.def.LootTableEntryDef;
   import engine.battle.wave.def.WaveSpawnEntryDef;
   import engine.core.logging.ILogger;
   import engine.entity.def.ItemDef;
   import engine.entity.def.ItemListDef;
   import engine.math.Rng;
   
   public class BattleWave_Utils
   {
       
      
      public function BattleWave_Utils()
      {
         super();
      }
      
      public static function VerifyLootTable(param1:Vector.<LootTableEntryDef>, param2:ItemListDef, param3:ILogger) : void
      {
         var _loc4_:ItemDef = null;
         var _loc5_:LootTableEntryDef = null;
         if(!param1)
         {
            return;
         }
         for each(_loc5_ in param1)
         {
            if(!(_loc5_.randomItem || _loc5_.itemId == ""))
            {
               _loc4_ = param2.getItemDef(_loc5_.itemId);
               if(!_loc4_)
               {
                  param3.error("ERROR: Invalid item ID for item " + _loc5_.itemId + ". Replacing with random generation.");
                  _loc5_.randomItem = true;
               }
            }
         }
      }
      
      public static function selectRandomEntry(param1:Vector.<WaveSpawnEntryDef>, param2:Rng, param3:ILogger) : WaveSpawnEntryDef
      {
         var tw:int;
         var i:int;
         var randomIndex:int = 0;
         var entity:WaveSpawnEntryDef = null;
         var entityList:Vector.<WaveSpawnEntryDef> = param1;
         var rng:Rng = param2;
         var logger:ILogger = param3;
         if(!entityList || entityList.length < 1)
         {
            return null;
         }
         tw = 0;
         i = 0;
         while(i < entityList.length)
         {
            tw += entityList[i].weight;
            i++;
         }
         try
         {
            randomIndex = rng.nextMinMax(0,tw - 1);
         }
         catch(e:Error)
         {
            logger.error("ERROR: invalid weighting in GuaranteedSpawnDef! Falling back to 0th entry: " + entityList[randomIndex]);
         }
         for each(entity in entityList)
         {
            randomIndex -= entity.weight;
            if(randomIndex < 0)
            {
               return entity;
            }
         }
         logger.error("ERROR: In BattleWave.SelectRandomEntry failed to generate random entry from entityList");
         return null;
      }
      
      public static function generateItemIdFromLootTable(param1:Vector.<LootTableEntryDef>, param2:Rng, param3:ILogger) : String
      {
         var totalWeight:int = 0;
         var loot:LootTableEntryDef = null;
         var randomIndex:int = 0;
         var table:Vector.<LootTableEntryDef> = param1;
         var rng:Rng = param2;
         var logger:ILogger = param3;
         if(!table || table.length <= 0)
         {
            return null;
         }
         for each(loot in table)
         {
            totalWeight += loot.weight;
         }
         try
         {
            randomIndex = rng.nextMinMax(0,totalWeight - 1);
         }
         catch(e:Error)
         {
            logger.error("ERROR: invalid weighting in loot table! Aborting item creation.\n" + e.message + "\n" + e.getStackTrace());
            return null;
         }
         for each(loot in table)
         {
            randomIndex -= loot.weight;
            if(randomIndex < 0)
            {
               if(loot.randomItem)
               {
                  return "";
               }
               if(loot.itemId == "")
               {
                  return null;
               }
               return loot.itemId;
            }
         }
         logger.error("ERROR: Failed to generate item from loot table!");
         return null;
      }
   }
}
