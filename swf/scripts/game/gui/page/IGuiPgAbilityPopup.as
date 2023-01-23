package game.gui.page
{
   import engine.entity.def.IEntityDef;
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiPgAbilityPopup extends IEventDispatcher
   {
       
      
      function get mc() : MovieClip;
      
      function init(param1:IGuiContext) : void;
      
      function activateAbilityPopup(param1:IEntityDef) : void;
      
      function deactivateAbilityPopup() : void;
      
      function hitTestAbilityPopup(param1:Number, param2:Number) : Boolean;
      
      function cleanup() : void;
      
      function update(param1:int) : void;
   }
}
