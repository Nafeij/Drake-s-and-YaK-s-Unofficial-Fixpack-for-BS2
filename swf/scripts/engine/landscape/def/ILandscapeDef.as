package engine.landscape.def
{
   import engine.landscape.travel.def.ITravelDef;
   import engine.scene.def.ISceneDef;
   import flash.events.IEventDispatcher;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public interface ILandscapeDef extends IEventDispatcher
   {
       
      
      function get sceneDef() : ISceneDef;
      
      function getLayerDef(param1:int) : ILandscapeLayerDef;
      
      function getLayer(param1:String) : ILandscapeLayerDef;
      
      function cropToBoundary(param1:String, param2:Number, param3:Number, param4:Number, param5:Number) : Dictionary;
      
      function reduceTextures(param1:String, param2:Number) : Dictionary;
      
      function tileLandscapeBitmaps(param1:String) : Array;
      
      function get boundary() : Rectangle;
      
      function set boundary(param1:Rectangle) : void;
      
      function get numTravelDefs() : int;
      
      function getTravels() : Vector.<ITravelDef>;
      
      function getSpriteDef(param1:String) : ILandscapeSpriteDef;
      
      function get numLayerDefs() : int;
      
      function getSplineDef(param1:String) : LandscapeSplineDef;
      
      function findClickable(param1:String) : ILandscapeSpriteDef;
      
      function get numClickables() : int;
      
      function getClickableAt(param1:int) : ILandscapeSpriteDef;
      
      function visitClickables(param1:Function) : void;
      
      function notifyLayersEditorHidden() : void;
   }
}
