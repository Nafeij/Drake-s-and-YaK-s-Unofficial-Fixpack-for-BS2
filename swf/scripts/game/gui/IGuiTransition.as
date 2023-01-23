package game.gui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   
   public interface IGuiTransition
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function cleanup() : void;
      
      function get displayObjectContainer() : DisplayObjectContainer;
      
      function get bannerHeight() : Number;
      
      function get textTopLocation() : DisplayObject;
      
      function get textBottomLocation() : DisplayObject;
      
      function get textAboveLocation() : DisplayObject;
      
      function get textSumLocation() : DisplayObject;
      
      function animateOnScreen(param1:Function) : void;
      
      function killTweens() : void;
      
      function displayMessage(param1:String, param2:Function) : void;
      
      function displayCompleteButton(param1:Function) : void;
   }
}
