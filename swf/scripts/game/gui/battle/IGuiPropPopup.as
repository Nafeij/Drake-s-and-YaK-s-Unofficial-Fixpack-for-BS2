package game.gui.battle
{
   import engine.battle.fsm.IBattleFsm;
   import game.gui.IGuiContext;
   
   public interface IGuiPropPopup extends IGuiPopup
   {
       
      
      function init(param1:IGuiContext, param2:IGuiPropPopupListener) : void;
      
      function set fsm(param1:IBattleFsm) : void;
      
      function show() : void;
      
      function hide() : void;
      
      function cleanup() : void;
   }
}
