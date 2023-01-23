package engine.saga
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.core.analytic.Ga;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.entity.def.Legend;
   import engine.entity.def.LegendSave;
   import engine.stat.def.StatPurchaseInfo;
   import engine.stat.def.StatType;
   
   public class SagaLegend extends Legend
   {
       
      
      private var saga:Saga;
      
      public function SagaLegend(param1:Saga, param2:BattleAbilityDefFactory)
      {
         super(9,param1.logger,param1.def.locale,param1.def.classes,param1.def.unitStatCosts,param2,param1.def.itemDefs);
         this.saga = param1;
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         this.saga = null;
      }
      
      override public function purchaseStat(param1:String, param2:StatType, param3:int) : void
      {
         internalPurchaseStat(param1,param2,param3);
      }
      
      override public function purchaseStats(param1:String, param2:Vector.<StatPurchaseInfo>) : void
      {
         var _loc3_:StatPurchaseInfo = null;
         for each(_loc3_ in param2)
         {
            internalPurchaseStat(param1,_loc3_.stat,_loc3_.delta);
         }
      }
      
      override public function promote(param1:String, param2:String, param3:String, param4:Function) : void
      {
         internalPromote(param1,param2,param3);
         if(this.saga.isSurvival)
         {
            Ga.normal("game","promote",param1,0);
         }
         if(param4 != null)
         {
            param4(null);
         }
      }
      
      public function loadFromSave(param1:LegendSave, param2:Boolean) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Item = null;
         var _loc7_:IEntityDef = null;
         _items.clearItems();
         for each(_loc3_ in param1.items)
         {
            _loc6_ = this.saga.createItemByName(_loc3_);
            if(_loc6_)
            {
               _items.addItem(_loc6_);
            }
         }
         roster.clear();
         for each(_loc4_ in param1.roster)
         {
            _loc7_ = this.saga.def.cast.getEntityDefById(_loc4_);
            if(!_loc7_)
            {
               if(param2)
               {
                  logger.error("Failed to find saved cast member [" + _loc4_ + "]");
               }
            }
            else
            {
               roster.addEntityDef(_loc7_);
            }
         }
         party.clear();
         for each(_loc5_ in param1.party)
         {
            if(roster.getEntityDefById(_loc5_))
            {
               party.addMember(_loc5_);
            }
         }
         renown = param1.renown;
      }
   }
}
