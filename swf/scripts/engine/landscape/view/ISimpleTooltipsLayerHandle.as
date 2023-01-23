package engine.landscape.view
{
   public interface ISimpleTooltipsLayerHandle
   {
       
      
      function get groupId() : String;
      
      function remove() : void;
      
      function set visible(param1:Boolean) : void;
      
      function get width() : Number;
      
      function set scaleX(param1:Number) : void;
      
      function get scaleX() : Number;
      
      function set x(param1:Number) : void;
      
      function set y(param1:Number) : void;
      
      function get x() : Number;
      
      function get y() : Number;
      
      function setGroupPos(param1:Number, param2:Number) : void;
   }
}
