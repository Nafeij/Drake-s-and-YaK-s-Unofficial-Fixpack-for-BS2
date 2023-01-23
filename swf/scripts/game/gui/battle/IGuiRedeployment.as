package game.gui.battle
{
   import engine.battle.fsm.BattleFsmEvent;
   import flash.display.DisplayObject;
   import game.gui.IGuiContext;
   import game.gui.page.BattleHudPage;
   
   public interface IGuiRedeployment
   {
       
      
      function init(param1:IGuiContext, param2:BattleHudPage) : void;
      
      function cleanup() : void;
      
      function get displayObject() : DisplayObject;
      
      function resizeHandler(param1:Number, param2:Number) : void;
      
      function setRedeploymentEntityFrameClazz(param1:Class) : void;
      
      function interactHandler(param1:BattleFsmEvent) : void;
      
      function refresh() : void;
      
      function activateGp() : void;
      
      function deactivateGp() : void;
   }
}
