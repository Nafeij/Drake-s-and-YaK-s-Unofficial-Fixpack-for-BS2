package engine.anim.def
{
   import flash.geom.Point;
   
   public interface IAnimDef
   {
       
      
      function get name() : String;
      
      function get flip() : Boolean;
      
      function get clip() : IAnimClipDef;
      
      function set clip(param1:IAnimClipDef) : void;
      
      function get moveSpeed() : Number;
      
      function get clipUrl() : String;
      
      function get offset() : Point;
   }
}
