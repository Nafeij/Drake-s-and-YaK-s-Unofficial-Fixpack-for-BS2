package game.gui
{
   import engine.battle.board.model.IBattleScenario;
   
   public interface IGuiSagaOptions
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaOptionsListener, param3:IGuiSagaOptionsShareListener) : void;
      
      function cleanup() : void;
      
      function set enableQuitButton(param1:Boolean) : void;
      
      function set enableTrainingExitButton(param1:Boolean) : void;
      
      function set enableTutorialExitButton(param1:Boolean) : void;
      
      function set enableSurvivalReloadButton(param1:Boolean) : void;
      
      function set battleScenario(param1:IBattleScenario) : void;
      
      function get visible() : Boolean;
      
      function ensureTopGp() : void;
      
      function set googlePlaySignedIn(param1:Boolean) : void;
      
      function get googlePlaySignedIn() : Boolean;
   }
}
