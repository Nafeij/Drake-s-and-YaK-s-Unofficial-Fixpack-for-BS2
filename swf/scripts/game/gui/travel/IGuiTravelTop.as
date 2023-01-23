package game.gui.travel
{
   import engine.saga.ISaga;
   import flash.display.MovieClip;
   import game.gui.IGuiContext;
   
   public interface IGuiTravelTop
   {
       
      
      function init(param1:IGuiContext, param2:IGuiTravelTopListener, param3:ISaga) : void;
      
      function cleanup() : void;
      
      function set campEnabled(param1:Boolean) : void;
      
      function set mapEnabled(param1:Boolean) : void;
      
      function set extended(param1:Boolean) : void;
      
      function get extended() : Boolean;
      
      function get animating() : Boolean;
      
      function set guiEnabled(param1:Boolean) : void;
      
      function get guiEnabled() : Boolean;
      
      function get movieClip() : MovieClip;
      
      function set days(param1:Number) : void;
      
      function get days() : Number;
      
      function set travelGuiSoundPlayer(param1:IGuiTravelSoundPlayer) : void;
      
      function get shatterInProgress() : Boolean;
      
      function set shatterInProgress(param1:Boolean) : void;
      
      function activateGp() : void;
      
      function deactivateGp() : void;
      
      function resizeHandler() : void;
      
      function handleOptionsButton() : void;
      
      function playRange(param1:String, param2:String, param3:Function) : void;
      
      function playDarknessTransition(param1:Function) : void;
   }
}
