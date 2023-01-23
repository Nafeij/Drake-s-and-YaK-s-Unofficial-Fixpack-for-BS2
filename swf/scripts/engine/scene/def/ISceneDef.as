package engine.scene.def
{
   import engine.landscape.def.ILandscapeDef;
   import engine.landscape.travel.def.ITravelLocationDef;
   import engine.saga.happening.IHappeningDefProvider;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   
   public interface ISceneDef extends IEventDispatcher
   {
       
      
      function get url() : String;
      
      function get id() : String;
      
      function get hasSceneBattle() : Boolean;
      
      function get hasSceneTravel() : Boolean;
      
      function get isSceneMap() : Boolean;
      
      function get isSceneStage() : Boolean;
      
      function get getHappeningDefProvider() : IHappeningDefProvider;
      
      function get landscape() : ILandscapeDef;
      
      function getLocationDefs(param1:String, param2:Vector.<ITravelLocationDef>) : Vector.<ITravelLocationDef>;
      
      function get cameraAnchor() : Point;
      
      function set cameraAnchor(param1:Point) : void;
      
      function get cameraStart() : Point;
      
      function set cameraStart(param1:Point) : void;
      
      function get cameraAnchorOnce() : Boolean;
   }
}
