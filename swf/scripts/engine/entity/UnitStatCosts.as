package engine.entity
{
   public class UnitStatCosts
   {
      
      public static var USE_REBUILD_STATS:Boolean;
      
      public static var instance:UnitStatCosts;
       
      
      protected var stats:Vector.<int>;
      
      protected var promotes:Vector.<int>;
      
      protected var killsToPromote:Vector.<int>;
      
      protected var abilityLevels:Vector.<int>;
      
      protected var titleRenownCosts:Vector.<int>;
      
      protected var rename:int;
      
      public var variation:int;
      
      public var roster_row_cost:int;
      
      public var max_num_roster_rows:int;
      
      public var roster_slots_per_row:int;
      
      public var allowRemoveStatPoints:Boolean = true;
      
      public var RANK_REBUILD:int = 7;
      
      public function UnitStatCosts()
      {
         this.stats = new Vector.<int>();
         this.promotes = new Vector.<int>();
         this.killsToPromote = new Vector.<int>();
         this.abilityLevels = new Vector.<int>();
         this.titleRenownCosts = new Vector.<int>();
         super();
         instance = this;
      }
      
      public function getAbilityLevel(param1:int, param2:int) : int
      {
         var _loc3_:int = param1 - param2;
         if(_loc3_ < 0)
         {
            return 0;
         }
         var _loc4_:int = _loc3_ + 1;
         _loc4_ = Math.min(_loc4_,this.abilityLevels.length - 1);
         return this.abilityLevels[_loc4_];
      }
      
      public function getTotalCost(param1:int, param2:int) : int
      {
         if(param2 < 0)
         {
            return 0;
         }
         var _loc3_:int = param1 - 1;
         if(_loc3_ < 0 || _loc3_ >= this.stats.length)
         {
            throw new ArgumentError("invalid rank " + param1);
         }
         return this.stats[_loc3_] * param2;
      }
      
      public function getPromotionCost(param1:int) : int
      {
         var _loc2_:int = param1 - 1;
         if(_loc2_ < 0 || _loc2_ >= this.promotes.length)
         {
            throw new ArgumentError("invalid rank " + param1);
         }
         return this.promotes[_loc2_];
      }
      
      public function getKillsRequiredToPromote(param1:int) : int
      {
         var _loc2_:int = param1 - 1;
         if(_loc2_ < 0)
         {
            throw new ArgumentError("invalid rank " + param1);
         }
         if(this.killsToPromote.length <= _loc2_)
         {
            return -1;
         }
         return this.killsToPromote[_loc2_];
      }
      
      public function getTitleCost(param1:int) : int
      {
         var _loc2_:int = param1 - 1;
         if(param1 >= this.titleRenownCosts.length)
         {
            param1 = this.titleRenownCosts.length - 1;
         }
         if(_loc2_ < 0)
         {
            throw new ArgumentError("invalid Heroic Title Rank " + param1);
         }
         return this.titleRenownCosts[_loc2_];
      }
      
      public function getRenameCost() : int
      {
         return this.rename;
      }
      
      public function getVariationCost() : int
      {
         return this.variation;
      }
   }
}
