package engine.gui
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public interface IGuiGpNavButton
   {
       
      
      function press() : void;
      
      function get enabled() : Boolean;
      
      function setHovering(param1:Boolean) : void;
      
      function getNavRectangle(param1:DisplayObject) : Rectangle;
      
      function localToGlobal(param1:Point) : Point;
      
      function get visible() : Boolean;
      
      function set visible(param1:Boolean) : void;
   }
}
