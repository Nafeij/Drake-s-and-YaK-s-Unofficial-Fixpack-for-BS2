package engine.saga
{
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.action.Action_MusicIncidental;
   import flash.utils.getTimer;
   
   public class SagaCampMusic
   {
       
      
      private var def:SagaCampMusicDef;
      
      private var saga:Saga;
      
      private var lastCheckTime:int = 0;
      
      public var THRESHOLD_MS:int = 20000;
      
      public var next_threshold:int;
      
      public var lastCampMusic:String;
      
      public function SagaCampMusic(param1:Saga)
      {
         this.next_threshold = this.THRESHOLD_MS;
         super();
         this.saga = param1;
         this.def = param1.def.campMusic;
      }
      
      public function resetCampMusicTimer() : void
      {
         this.lastCheckTime = getTimer();
      }
      
      public function checkCampMusic() : Action_MusicIncidental
      {
         var _loc2_:Action_MusicIncidental = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:ActionDef = null;
         if(!this.def || !this.saga)
         {
            return null;
         }
         var _loc1_:int = getTimer();
         if(this.lastCheckTime)
         {
            if(!this.saga.sound.system.music || !this.saga.sound.system.music.playing)
            {
               _loc3_ = _loc1_ - this.lastCheckTime;
               if(_loc3_ > this.next_threshold)
               {
                  _loc4_ = this.def.pickOneMusic(this.saga,this.lastCampMusic);
                  this.lastCampMusic = _loc4_;
                  if(_loc4_)
                  {
                     _loc5_ = new ActionDef(null);
                     _loc5_.type = ActionType.MUSIC_INCIDENTAL;
                     _loc5_.id = _loc4_;
                     _loc2_ = this.saga.executeActionDef(_loc5_,null,null) as Action_MusicIncidental;
                     this.next_threshold = this.THRESHOLD_MS + this.THRESHOLD_MS * this.saga.rng.nextNumber();
                  }
                  this.lastCheckTime = _loc1_;
               }
            }
         }
         else
         {
            this.lastCheckTime = _loc1_;
         }
         return _loc2_;
      }
   }
}
