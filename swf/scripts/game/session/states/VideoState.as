package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.saga.VideoParams;
   import game.session.GameState;
   
   public class VideoState extends GameState
   {
      
      public static var USE_1080_MP4:Boolean;
       
      
      public var url_actual:String;
      
      public var vp:VideoParams;
      
      public function VideoState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override public function toString() : String
      {
         return super.toString() + " " + this.url_actual;
      }
      
      override protected function handleCleanup() : void
      {
      }
      
      override protected function handleEnteredState() : void
      {
         this.vp = data.getValue(GameStateDataEnum.VIDEO_PARAMS);
         if(!this.vp)
         {
            this.vp = new VideoParams();
         }
         if(USE_1080_MP4)
         {
            this.url_actual = this.vp.url.replace(".720.flv",".mp4");
         }
         else
         {
            this.url_actual = this.vp.url;
         }
      }
      
      public function handleVideoComplete() : void
      {
         var _loc1_:Class = data.getValue(GameStateDataEnum.VIDEO_NEXT_STATE);
         if(_loc1_)
         {
            fsm.transitionTo(_loc1_,data);
         }
         else
         {
            phase = StatePhase.COMPLETED;
         }
         if(config.saga)
         {
            config.saga.triggerVideoFinished(this.vp.url);
         }
      }
   }
}
