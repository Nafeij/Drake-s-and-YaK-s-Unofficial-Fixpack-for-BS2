package engine.battle.board.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class Usability
   {
       
      
      public var def:UsabilityDef;
      
      public var enabled:Boolean = true;
      
      public var abilityDef:IBattleAbilityDef;
      
      public var logger:ILogger;
      
      public var useCount:int;
      
      public var using:IBattleEntity;
      
      public function Usability(param1:IBattleEntity, param2:UsabilityDef, param3:IBattleAbilityDefFactory, param4:ILogger)
      {
         super();
         this.logger = param4;
         this.def = param2;
         this.using = param1;
         if(param2.abilityId)
         {
            this.abilityDef = param3.fetchIBattleAbilityDef(param2.abilityId);
         }
      }
      
      public function toString() : String
      {
         return this.using + " " + this.def;
      }
      
      public function cleanup() : void
      {
         this.using = null;
         this.abilityDef = null;
         this.def = null;
      }
      
      public function canUse(param1:IBattleEntity) : Boolean
      {
         if(!this.enabled)
         {
            return false;
         }
         if(!this.isInRange(param1))
         {
            return false;
         }
         return true;
      }
      
      public function handleUsing(param1:IBattleEntity) : Boolean
      {
         if(!this.canUse(param1))
         {
            return false;
         }
         ++this.useCount;
         if(this.def.limit > 0)
         {
            if(this.useCount >= this.def.limit)
            {
               this.enabled = false;
            }
         }
         return true;
      }
      
      public function isInRange(param1:IBattleEntity) : Boolean
      {
         if(this.def.range <= 0)
         {
            return true;
         }
         var _loc2_:TileRect = param1.rect;
         var _loc3_:TileRect = this.using.rect;
         var _loc4_:int = TileRectRange.computeRange(_loc2_,_loc3_);
         if(_loc4_ > this.def.range)
         {
            return false;
         }
         return true;
      }
   }
}
