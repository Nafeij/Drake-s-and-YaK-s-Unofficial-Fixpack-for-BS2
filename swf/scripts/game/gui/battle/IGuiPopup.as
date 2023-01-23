package game.gui.battle
{
   import engine.battle.board.model.IBattleEntity;
   import engine.core.gp.GpControlButton;
   import flash.display.MovieClip;
   
   public interface IGuiPopup
   {
       
      
      function set entity(param1:IBattleEntity) : void;
      
      function get entity() : IBattleEntity;
      
      function moveTo(param1:Number, param2:Number) : void;
      
      function get movieClip() : MovieClip;
      
      function handleConfirm() : Boolean;
      
      function updatePopup(param1:int) : void;
      
      function handleGpButton(param1:GpControlButton) : Boolean;
      
      function set scale(param1:Number) : void;
      
      function get scale() : Number;
   }
}
