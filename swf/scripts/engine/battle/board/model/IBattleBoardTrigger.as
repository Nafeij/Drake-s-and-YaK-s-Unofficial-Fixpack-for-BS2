package engine.battle.board.model
{
   import engine.ability.IAbilityDef;
   import engine.anim.def.IAnimFacing;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.phantasm.def.VfxSequenceDefs;
   import engine.battle.board.def.BattleBoardTriggerDef;
   import engine.tile.def.TileRect;
   
   public interface IBattleBoardTrigger
   {
       
      
      function get rect() : TileRect;
      
      function clearEntitiesHitThisTurn() : void;
      
      function pulseCheck(param1:IBattleEntity, param2:TileRect) : Boolean;
      
      function check(param1:IBattleEntity, param2:TileRect) : Boolean;
      
      function isHazardToEntity(param1:IBattleEntity) : Boolean;
      
      function get id() : String;
      
      function get triggerId() : String;
      
      function get effect() : IEffect;
      
      function get facing() : IAnimFacing;
      
      function get vfxds() : VfxSequenceDefs;
      
      function get def() : BattleBoardTriggerDef;
      
      function getDisplayAbilities() : Vector.<IAbilityDef>;
      
      function validate() : void;
      
      function get numEnemies() : int;
      
      function get numAllies() : int;
      
      function get numUnits() : int;
      
      function intersectsEntity(param1:IBattleEntity) : Boolean;
      
      function intersectsRect(param1:TileRect) : Boolean;
      
      function checkResetCounts() : void;
      
      function clearVars() : void;
      
      function get triggers() : IBattleBoardTriggers;
      
      function get enabled() : Boolean;
      
      function set enabled(param1:Boolean) : void;
      
      function updateTurnEntity(param1:IBattleEntity) : void;
      
      function get fadeAlpha() : Number;
      
      function set fadeAlpha(param1:Number) : void;
      
      function get expired() : Boolean;
      
      function turnCountIncrease(param1:int) : void;
   }
}
