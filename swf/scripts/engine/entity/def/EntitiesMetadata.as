package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   
   public class EntitiesMetadata
   {
      
      public static const DEFAULT_BASE_UPGRADES:int = 9;
      
      public static var instance:EntitiesMetadata;
       
      
      public var partyTagLimits:Array;
      
      public var locale:Locale;
      
      public var useBaseUpgradeStat:Boolean;
      
      public var defaultBaseUpgrade:int = 9;
      
      public function EntitiesMetadata(param1:Locale)
      {
         this.partyTagLimits = [];
         super();
         instance = this;
         this.locale = param1;
      }
      
      public static function _getBaseUpgrades(param1:IEntityDef, param2:Boolean, param3:int) : int
      {
         var _loc4_:Stat = null;
         var _loc5_:StatRange = null;
         if(param2)
         {
            _loc4_ = param1.stats.getStat(StatType.BASE_UPGRADES,false);
            if(_loc4_)
            {
               return _loc4_.value;
            }
            if(param1.entityClass)
            {
               _loc5_ = param1.entityClass.statRanges.getStatRange(StatType.BASE_UPGRADES);
               if(_loc5_)
               {
                  return _loc5_.max;
               }
            }
         }
         return param3;
      }
      
      public function getPartyTagLimit(param1:String) : int
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.partyTagLimits)
         {
            if(_loc2_.tag == param1)
            {
               return _loc2_.limit;
            }
         }
         return 0;
      }
      
      public function setPartyTagLimit(param1:String, param2:int) : void
      {
         var _loc3_:Object = null;
         for each(_loc3_ in this.partyTagLimits)
         {
            if(_loc3_.tag == param1)
            {
               _loc3_.limit = param2;
               return;
            }
         }
         this.partyTagLimits.push({
            "tag":param1,
            "limit":param2
         });
      }
      
      public function getBaseUpgrades(param1:IEntityDef) : int
      {
         return _getBaseUpgrades(param1,this.useBaseUpgradeStat,this.defaultBaseUpgrade);
      }
   }
}
