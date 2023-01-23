package engine.saga.action
{
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.Saga;
   import engine.sound.def.SoundDef;
   import engine.sound.view.ISound;
   import engine.subtitle.SubtitleSequenceResource;
   
   public class Action_Vo extends BaseAction_Sound
   {
       
      
      public var sound:ISound;
      
      public function Action_Vo(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         startLoadingSound(def.location,def.id,def.param,def.varvalue);
      }
      
      override protected function handlePlaySound() : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:SubtitleSequenceResource = null;
         var _loc1_:SoundDef = new SoundDef().setup(sku,event,event);
         var _loc2_:ISound = saga.sound.system.playVoDef(_loc1_);
         if(!_loc2_)
         {
            saga.sound.system.playVoDef(_loc1_);
            throw new ArgumentError("Failed to play VO sound: [" + event + "]");
         }
         if(def.param)
         {
            _loc2_.setParameter(def.param,def.varvalue);
         }
         if(def.subtitle)
         {
            if(def.subtitle.indexOf(".sbv") > 0)
            {
               _loc3_ = saga.resman.localeId.translateLocaleUrl(def.subtitle);
               _loc4_ = saga.resman.getResource(_loc3_,SubtitleSequenceResource) as SubtitleSequenceResource;
               _loc4_.addResourceListener(this.subtitleSequenceHandler);
            }
            else
            {
               logger.info("IGNORING MALFORMED SUBTITLE [" + def.subtitle + "]");
            }
         }
         end();
         return false;
      }
      
      private function subtitleSequenceHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:SubtitleSequenceResource = param1.resource as SubtitleSequenceResource;
         _loc2_.removeResourceListener(this.subtitleSequenceHandler);
         _loc2_.release();
         saga.ccs.subtitle.sequence = _loc2_.sequence;
      }
   }
}
