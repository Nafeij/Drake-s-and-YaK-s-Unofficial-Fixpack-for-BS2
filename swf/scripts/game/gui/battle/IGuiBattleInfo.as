package game.gui.battle
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.IEntityDef;
   import game.gui.IGuiContext;
   
   public interface IGuiBattleInfo
   {
       
      
      function init(param1:IGuiContext, param2:IGuiInitiativeListener) : void;
      
      function set text(param1:String) : void;
      
      function setEntityName(param1:String, param2:uint) : void;
      
      function setVisible(param1:Boolean) : void;
      
      function get isVisible() : Boolean;
      
      function handleLocaleChange() : void;
      
      function showBattleEntityAbilities(param1:IBattleEntity, param2:Boolean) : void;
      
      function showEntityDefAbilities(param1:IEntityDef, param2:Boolean) : void;
      
      function showAbilityInfo(param1:BattleAbilityDef, param2:int) : void;
   }
}
