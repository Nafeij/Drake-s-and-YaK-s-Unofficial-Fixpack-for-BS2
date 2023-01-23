package game.gui.battle
{
   import engine.ability.IAbilityDef;
   import engine.core.gp.GpControlButton;
   import flash.display.MovieClip;
   import game.gui.IGuiContext;
   
   public interface IGuiAbilityPopup
   {
       
      
      function init(param1:IGuiContext, param2:IGuiAbilityPopupListener) : void;
      
      function show(param1:IAbilityDef, param2:int, param3:int, param4:int, param5:Boolean = true) : void;
      
      function hide() : void;
      
      function moveTo(param1:Number, param2:Number) : void;
      
      function get movieClip() : MovieClip;
      
      function handleConfirm() : Boolean;
      
      function cleanup() : void;
      
      function doConfirmClick() : void;
      
      function doHighlight(param1:Boolean) : void;
      
      function updatePopup(param1:int) : void;
      
      function handleGpButton(param1:GpControlButton) : Boolean;
      
      function starsMod(param1:int) : void;
   }
}
