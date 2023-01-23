package engine.landscape.view
{
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.landscape.def.LandscapeLayerDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.model.ILandscapeLayerVisibility;
   import engine.landscape.model.Landscape;
   import engine.landscape.travel.view.TravelView;
   import engine.resource.ResourceManager;
   import engine.saga.SpeakEvent;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public interface ILandscapeView extends ILandscapeLayerVisibility, IEventDispatcher
   {
       
      
      function update(param1:int) : void;
      
      function cleanup() : void;
      
      function set visible(param1:Boolean) : void;
      
      function getAnchorPoint(param1:String) : Point;
      
      function localToGlobal(param1:Point) : Point;
      
      function globalToLocal(param1:Point) : Point;
      
      function setPosition(param1:Number, param2:Number) : void;
      
      function get visible() : Boolean;
      
      function enableSceneElement(param1:Boolean, param2:String, param3:Boolean, param4:Number) : void;
      
      function getSpriteDefFromPath(param1:String, param2:Boolean) : LandscapeSpriteDef;
      
      function handleSpeak(param1:SpeakEvent, param2:String) : Boolean;
      
      function sceneAnimPlay(param1:String, param2:int, param3:int) : void;
      
      function set showHelp(param1:Boolean) : void;
      
      function get landscape() : Landscape;
      
      function set weatherEnabled(param1:Boolean) : void;
      
      function get travelView() : TravelView;
      
      function displayHover(param1:LandscapeSpriteDef) : void;
      
      function setDisplayHoverStagePosition(param1:Number, param2:Number) : void;
      
      function setDisplayHoverStagePositionEnabled(param1:Boolean) : void;
      
      function get hoverClickable() : LandscapeSpriteDef;
      
      function addExtraToLayer(param1:String, param2:DisplayObjectWrapper) : Point;
      
      function getClickableDef(param1:String) : LandscapeSpriteDef;
      
      function getClickableUnderMouse(param1:Number, param2:Number) : LandscapeSpriteDef;
      
      function isClickableEnabled(param1:LandscapeSpriteDef) : Boolean;
      
      function hasLayerSprite(param1:String) : Boolean;
      
      function get pressedClickable() : LandscapeSpriteDef;
      
      function set pressedClickable(param1:LandscapeSpriteDef) : void;
      
      function get clickableDefs() : Vector.<LandscapeSpriteDef>;
      
      function getClickablePair(param1:LandscapeSpriteDef) : ClickablePair;
      
      function setClickableEnabled(param1:LandscapeSpriteDef, param2:Boolean) : Boolean;
      
      function get isSceneReady() : Boolean;
      
      function get weather() : WeatherManager;
      
      function get camera() : BoundedCamera;
      
      function get selectedLayerDefs() : Vector.<LandscapeLayerDef>;
      
      function get shell() : ShellCmdManager;
      
      function get logger() : ILogger;
      
      function get resman() : ResourceManager;
      
      function get lookingForReady() : Boolean;
      
      function setClickableHasBeenClicked(param1:LandscapeSpriteDef) : void;
      
      function handleSceneViewResize() : void;
      
      function selectClickable_next(param1:LandscapeSpriteDef, param2:Point) : LandscapeSpriteDef;
      
      function selectClickable_prev(param1:LandscapeSpriteDef, param2:Point) : LandscapeSpriteDef;
      
      function getClickablePointGlobal(param1:LandscapeSpriteDef) : Point;
      
      function getClickableRectGlobal(param1:LandscapeSpriteDef) : Rectangle;
      
      function getClickablePointLocal(param1:LandscapeSpriteDef) : Point;
      
      function updateClickables() : void;
      
      function set hasInjuries(param1:Boolean) : void;
      
      function get hasTalkies() : Boolean;
      
      function get showTooltips() : Boolean;
      
      function set showTooltips(param1:Boolean) : void;
      
      function updateTooltipForClickable(param1:LandscapeSpriteDef) : void;
      
      function get defaultTooltipStyleId() : String;
   }
}
