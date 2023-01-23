package game.gui.page
{
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiPairingPrompt extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaPairingPromptListener) : void;
   }
}
