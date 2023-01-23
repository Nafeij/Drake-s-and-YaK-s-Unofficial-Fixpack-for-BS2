package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.SagaCreditsDef;
   import engine.sound.config.ISoundSystem;
   import engine.sound.view.ISound;
   
   public class Action_EndCreditsWaitable extends BaseAction_Sound
   {
       
      
      private var _url:String = null;
      
      private var _retain_music:Boolean;
      
      private var _unskippable:Boolean;
      
      private var _credits_index:int;
      
      public function Action_EndCreditsWaitable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         this._retain_music = Boolean(def.param) && def.param.indexOf("retain_music") >= 0;
         this._unskippable = Boolean(def.param) && def.param.indexOf("unskippable") >= 0;
         this._credits_index = def.varvalue;
         this._url = def.url;
         if(this._url)
         {
            saga.sound.stopAllSounds();
            saga.sound.system.vo = null;
            saga.sound.system.music = null;
            startLoadingSound(null,this._url,null,0);
         }
         else
         {
            this.handleShowCredits();
         }
      }
      
      override protected function handlePlaySound() : Boolean
      {
         var _loc1_:ISoundSystem = null;
         var _loc2_:ISound = null;
         if(this._url)
         {
            _loc1_ = saga.sound.system;
            if(_loc1_.enabled)
            {
               _loc2_ = saga.sound.playMusicOneShot(null,this._url,null,0);
               if(!_loc2_)
               {
                  saga.logger.error("Action_SoundPlayEvent Failed to play sound: " + event);
               }
            }
         }
         this.handleShowCredits();
         return true;
      }
      
      private function handleShowCredits() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:* = def.varvalue > 0;
         var _loc3_:SagaCreditsDef = saga.def.getCreditsDef(this._credits_index);
         if(!_loc3_)
         {
            throw new ArgumentError("failure credits index " + this._credits_index);
         }
         saga.performEndCredits(_loc3_,_loc2_,!this._unskippable);
      }
      
      override public function triggerCreditsComplete() : void
      {
         if(this._url)
         {
            if(!this._retain_music)
            {
               saga.sound.stopMusic(null,this._url);
            }
         }
         end();
      }
   }
}
