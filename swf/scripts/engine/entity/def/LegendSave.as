package engine.entity.def
{
   import engine.core.logging.ILogger;
   
   public class LegendSave
   {
       
      
      public var renown:int;
      
      public var roster:Array;
      
      public var party:Array;
      
      public var items:Array;
      
      public function LegendSave()
      {
         this.roster = [];
         this.party = [];
         this.items = [];
         super();
      }
      
      public function fromLegend(param1:Legend) : LegendSave
      {
         var _loc3_:EntityDef = null;
         this.renown = param1.renown;
         var _loc2_:int = 0;
         while(_loc2_ < param1.roster.numEntityDefs)
         {
            _loc3_ = param1.roster.getEntityDef(_loc2_) as EntityDef;
            this.roster.push(_loc3_.id);
            _loc2_++;
         }
         this.fromLegendParty(param1);
         this.fromLegendItems(param1);
         return this;
      }
      
      private function fromLegendParty(param1:Legend) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.party.numMembers)
         {
            _loc3_ = param1.party.getMemberId(_loc2_);
            this.party.push(_loc3_);
            _loc2_++;
         }
      }
      
      private function fromLegendItems(param1:Legend) : void
      {
         var _loc3_:Item = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1._items.items.length)
         {
            _loc3_ = param1._items.items[_loc2_];
            this.items.push(_loc3_.id);
            _loc2_++;
         }
      }
      
      public function fromJson(param1:Object, param2:ILogger) : LegendSave
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         this.renown = param1.renown;
         if(param1.roster)
         {
            for each(_loc3_ in param1.roster)
            {
               this.roster.push(_loc3_);
            }
         }
         if(param1.party)
         {
            for each(_loc4_ in param1.party)
            {
               this.party.push(_loc4_);
            }
         }
         if(param1.items)
         {
            for each(_loc5_ in param1.items)
            {
               this.items.push(_loc5_);
            }
         }
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "renown":this.renown,
            "roster":this.roster,
            "party":this.party,
            "items":this.items
         };
      }
   }
}
