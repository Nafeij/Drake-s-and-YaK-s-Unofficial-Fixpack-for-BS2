package engine.scene
{
   import engine.entity.model.IEntity;
   import engine.tile.Tile;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SceneControllerConfig extends EventDispatcher
   {
      
      public static const EVENT_CHANGED:String = "SceneControllerConfig.EVENT_CHANGED";
      
      public static var instance:SceneControllerConfig;
       
      
      public var restrictInput:Boolean = false;
      
      public var allowHover:Boolean = false;
      
      public var redeployRosterInFocus:Boolean = false;
      
      public var allowMoveTile:Tile = null;
      
      public var allowWaypointTile:Tile;
      
      public var allowEntities:Vector.<IEntity>;
      
      public function SceneControllerConfig()
      {
         this.allowEntities = new Vector.<IEntity>();
         super();
         instance = this;
      }
      
      public function notify() : void
      {
         dispatchEvent(new Event(EVENT_CHANGED));
      }
      
      public function reset() : void
      {
         this.restrictInput = false;
         this.allowHover = false;
         this.allowMoveTile = null;
         this.allowWaypointTile = null;
         this.allowEntities = new Vector.<IEntity>();
         dispatchEvent(new Event(EVENT_CHANGED));
      }
   }
}
