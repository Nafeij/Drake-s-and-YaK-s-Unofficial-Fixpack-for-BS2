package engine.gui
{
   import engine.core.locale.IlocaleChangeListener;
   import flash.display.MovieClip;
   
   public interface IGuiButton extends IGuiGpNavButton, IlocaleChangeListener
   {
       
      
      function set buttonToken(param1:String) : void;
      
      function get buttonToken() : String;
      
      function set buttonText(param1:String) : void;
      
      function get buttonText() : String;
      
      function setDownFunction(param1:Function) : void;
      
      function get movieClip() : MovieClip;
      
      function set clickSound(param1:String) : void;
      
      function pulseHover(param1:int) : void;
      
      function get centerTextVertically() : Boolean;
      
      function set centerTextVertically(param1:Boolean) : void;
      
      function get scaleTextToFit() : Boolean;
      
      function set scaleTextToFit(param1:Boolean) : void;
      
      function set guiButtonContext(param1:*) : void;
      
      function cleanup() : void;
      
      function resetListeners() : void;
   }
}
