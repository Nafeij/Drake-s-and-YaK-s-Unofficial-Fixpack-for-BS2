package as3isolib.core
{
   import as3isolib.bounds.IBounds;
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.geom.Rectangle;
   
   public interface IIsoDisplayObject extends IIsoContainer
   {
       
      
      function get renderAsOrphan() : Boolean;
      
      function set renderAsOrphan(param1:Boolean) : void;
      
      function get isoBounds() : IBounds;
      
      function get screenBounds() : Rectangle;
      
      function getBounds(param1:DisplayObjectWrapper) : Rectangle;
      
      function get inverseOriginX() : Number;
      
      function get inverseOriginY() : Number;
      
      function moveTo(param1:Number, param2:Number, param3:Number) : void;
      
      function moveBy(param1:Number, param2:Number, param3:Number) : void;
      
      function get x() : Number;
      
      function set x(param1:Number) : void;
      
      function get y() : Number;
      
      function set y(param1:Number) : void;
      
      function get z() : Number;
      
      function set z(param1:Number) : void;
      
      function get screenX() : Number;
      
      function get screenY() : Number;
      
      function get distance() : Number;
      
      function set distance(param1:Number) : void;
      
      function setSize(param1:Number, param2:Number, param3:Number) : void;
      
      function get width() : Number;
      
      function set width(param1:Number) : void;
      
      function get length() : Number;
      
      function set length(param1:Number) : void;
      
      function get height() : Number;
      
      function set height(param1:Number) : void;
      
      function invalidatePosition() : void;
      
      function invalidateSize() : void;
      
      function clone() : *;
   }
}
