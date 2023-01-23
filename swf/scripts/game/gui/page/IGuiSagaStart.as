package game.gui.page
{
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiSagaStart extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaStartListener, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean, param7:String = null) : void;
      
      function updateState(param1:Boolean, param2:Boolean) : void;
      
      function handleStartPageResized() : void;
      
      function cleanup() : void;
      
      function setupButtonSizes() : void;
      
      function set visible(param1:Boolean) : void;
      
      function updateUsernameText() : void;
   }
}
