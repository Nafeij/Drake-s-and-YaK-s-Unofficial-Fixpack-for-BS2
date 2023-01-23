package engine.battle
{
   import engine.battle.board.model.IBattleEntity;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BattleCameraEvent extends Event
   {
      
      public static const CAMERA_CENTER_ON_ISO_POINT:String = "BattleCameraEvent.CAMERA_CENTER_ON_ISO_POINT";
      
      public static const CAMERA_ZOOM_OUT_MAX:String = "BattleCameraEvent.BOARD_CAMERA_MAX_ZOOM";
      
      public static const CAMERA_ZOOM_IN_TO:String = "BattleCameraEvent.CAMERA_ZOOM_TO";
      
      public static const CAMERA_SHOW_ALL_ENEMIES:String = "BattleCameraEvent.CAMERA_SHOW_ALL_ENEMIES";
      
      public static const CAMERA_PAN_TO_DEPLOYMENT_AREA:String = "BattleCameraEvent.CAMERA_PAN_TO_DEPLOYMENT_AREA";
       
      
      public var onComplete:Function;
      
      public var delay:Number = 0;
      
      public var duration:Number = 1;
      
      public var targetEntity:IBattleEntity;
      
      public var targetString:String;
      
      public var isoPoint:Point;
      
      public function BattleCameraEvent(param1:String, param2:Function)
      {
         super(param1,false,false);
         this.onComplete = param2;
      }
      
      public function setIsoPoint(param1:Number, param2:Number) : BattleCameraEvent
      {
         this.isoPoint = new Point(param1,param2);
         return this;
      }
   }
}
