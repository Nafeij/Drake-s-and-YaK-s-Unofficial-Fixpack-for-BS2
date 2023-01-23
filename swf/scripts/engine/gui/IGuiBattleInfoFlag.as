package engine.gui
{
   import engine.stat.model.Stats;
   import flash.display.MovieClip;
   
   public interface IGuiBattleInfoFlag
   {
       
      
      function setEntityAndStats(param1:String, param2:Stats, param3:Boolean, param4:Boolean) : void;
      
      function get movieClip() : MovieClip;
      
      function cleanup() : void;
      
      function get y() : Number;
      
      function set y(param1:Number) : void;
      
      function get x() : Number;
      
      function set x(param1:Number) : void;
      
      function get dirty() : Boolean;
      
      function set dirty(param1:Boolean) : void;
      
      function get entityId() : String;
      
      function set scale_zoom(param1:Number) : void;
      
      function set scale_emphasis(param1:Number) : void;
      
      function update(param1:int) : void;
      
      function set visible(param1:Boolean) : void;
      
      function get visible() : Boolean;
      
      function set ctorClazz(param1:Class) : void;
      
      function get ctorClazz() : Class;
   }
}
