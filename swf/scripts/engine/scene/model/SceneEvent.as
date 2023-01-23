package engine.scene.model
{
   import flash.events.Event;
   
   public class SceneEvent extends Event
   {
      
      public static const NUM_ENABLED_BOARDS:String = "SceneEvent.NUM_ENABLED_BOARDS";
      
      public static const FOCUSED_BOARD:String = "SceneEvent.FOCUSED_BOARD";
      
      public static const EXIT:String = "SceneEvent.EXIT";
      
      public static const READY:String = "SceneEvent.READY";
       
      
      public function SceneEvent(param1:String)
      {
         super(param1);
      }
      
      public function get scene() : Scene
      {
         return target as Scene;
      }
      
      public function get sceneUniqueId() : int
      {
         var _loc1_:Scene = this.scene;
         return !!_loc1_ ? _loc1_.uniqueId : 0;
      }
   }
}
