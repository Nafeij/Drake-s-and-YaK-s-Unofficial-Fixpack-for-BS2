package engine.saga.action
{
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.Saga;
   import engine.subtitle.SubtitleSequenceResource;
   
   public class Action_Subtitle extends Action
   {
       
      
      private var isSupertitle:Boolean;
      
      public function Action_Subtitle(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc2_:String = null;
         var _loc3_:SubtitleSequenceResource = null;
         if(!def.subtitle)
         {
            throw new ArgumentError("subtitle url required");
         }
         var _loc1_:String = def.param;
         if(_loc1_)
         {
            this.isSupertitle = _loc1_.indexOf("supertitle") >= 0;
         }
         if(def.subtitle.indexOf(".sbv") > 0)
         {
            _loc2_ = saga.resman.localeId.translateLocaleUrl(def.subtitle);
            _loc3_ = saga.resman.getResource(_loc2_,SubtitleSequenceResource) as SubtitleSequenceResource;
            _loc3_.addResourceListener(this.subtitleSequenceHandler);
            end();
            return;
         }
         throw new ArgumentError("IGNORING MALFORMED SUBTITLE [" + def.subtitle + "]");
      }
      
      private function subtitleSequenceHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:SubtitleSequenceResource = param1.resource as SubtitleSequenceResource;
         _loc2_.removeResourceListener(this.subtitleSequenceHandler);
         _loc2_.release();
         if(this.isSupertitle)
         {
            saga.ccs.supertitle.sequence = _loc2_.sequence;
         }
         else
         {
            saga.ccs.subtitle.sequence = _loc2_.sequence;
         }
         end();
      }
   }
}
