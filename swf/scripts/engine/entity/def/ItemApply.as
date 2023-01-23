package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.stat.def.StatModDef;
   import engine.stat.model.StatMod;
   
   public class ItemApply
   {
       
      
      public function ItemApply()
      {
         super();
      }
      
      public static function apply(param1:Item, param2:IBattleEntity) : void
      {
         applyPassive(param1,param2);
         applyStatMods(param1,param2);
      }
      
      public static function applyStatMods(param1:Item, param2:IBattleEntity) : int
      {
         var _loc5_:StatModDef = null;
         var _loc3_:ItemDef = param1.def;
         var _loc4_:int = 0;
         if(!_loc3_.statmods || _loc3_.statmods.length == 0)
         {
            return _loc4_;
         }
         for each(_loc5_ in _loc3_.statmods)
         {
            StatMod.addStatMod(param2.stats,param1,_loc5_);
            _loc4_++;
         }
         return _loc4_;
      }
      
      public static function applyPassive(param1:Item, param2:IBattleEntity) : int
      {
         var _loc8_:IBattleAbilityDef = null;
         var _loc9_:BattleAbility = null;
         var _loc3_:ItemDef = param1.def;
         var _loc4_:int = 0;
         if(!_loc3_.passive)
         {
            return _loc4_;
         }
         var _loc5_:IBattleBoard = param2.board;
         var _loc6_:IBattleAbilityDefFactory = _loc5_.abilityManager.getFactory;
         var _loc7_:ILogger = _loc5_.logger;
         _loc8_ = _loc6_.fetch(_loc3_.passive,false) as IBattleAbilityDef;
         if(!_loc8_)
         {
            _loc7_.error("BattleEntity item [" + param1 + "] passive not found");
         }
         else
         {
            _loc8_ = _loc8_.getBattleAbilityDefLevel(_loc3_.passiveRank);
            if(!_loc8_)
            {
               _loc7_.error("BattleEntity item [" + param1 + "] rank unavailable");
            }
            else
            {
               _loc9_ = new BattleAbility(param2,_loc8_,_loc5_.abilityManager);
               _loc9_.execute(null);
               _loc4_++;
            }
         }
         return _loc4_;
      }
   }
}
