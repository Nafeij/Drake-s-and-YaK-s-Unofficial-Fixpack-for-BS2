package engine.landscape.def
{
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public interface ILandscapeLayerDef extends IEventDispatcher
   {
       
      
      function getOffset() : Point;
      
      function getSprite(param1:String) : LandscapeSpriteDef;
      
      function setClickBlockerMask(param1:ClickMask, param2:Dictionary) : void;
      
      function get numSprites() : int;
      
      function getSpriteAt(param1:int) : ILandscapeSpriteDef;
      
      function getNameId() : String;
   }
}
