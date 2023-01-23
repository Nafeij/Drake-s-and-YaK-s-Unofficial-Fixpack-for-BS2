package engine.saga.action
{
   import engine.core.BoxString;
   import engine.saga.Saga;
   import engine.saga.happening.Happening;
   import engine.saga.happening.HappeningDef;
   import flash.events.Event;
   
   public class Action_Happening extends Action
   {
      
      private static var _prereqReasons:BoxString = new BoxString();
       
      
      private var h:Happening;
      
      public function Action_Happening(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc2_:String = null;
         if(!def.happeningId)
         {
            throw new ArgumentError("Null happeningId for " + this);
         }
         var _loc1_:HappeningDef = saga.getHappeningDefById(def.happeningId,happeningDefProvider);
         if(!_loc1_)
         {
            throw new ArgumentError("Cannot find happening " + def.happeningId + " for " + this);
         }
         if(_loc1_.automatic)
         {
            throw new ArgumentError("Cannot execute automatic happening");
         }
         if(!_loc1_.checkPrereq(saga,_prereqReasons))
         {
            logger.info("Happening " + _loc1_ + " skipped due to prereq " + _prereqReasons.value + " by " + this);
            end();
            return;
         }
         if(def.makesave)
         {
            if(_loc1_.bag != saga.def.happenings)
            {
               throw new ArgumentError("Cannot makesave for non-global happening");
            }
            _loc2_ = Saga.SAVE_ID_RESUME;
            if(def.makesaveId)
            {
               _loc2_ = def.makesaveId;
            }
            logger.info("Happening Makesave id [" + _loc2_ + "] from " + this);
            if(!saga.saveSaga(_loc2_,happening,_loc1_.id,true))
            {
               logger.error("Happening Makesave [" + _loc2_ + "] FAILED reason=" + saga.cannotSaveReason);
            }
         }
         this.h = saga.preExecuteHappeningDef(_loc1_,this) as Happening;
         if(this.h)
         {
            this.h.execute();
         }
         if(def.instant || !this.h || this.h.ended)
         {
            this.h = null;
            end();
         }
         else if(this.h)
         {
            this.h.addEventListener(Event.COMPLETE,this.happeningCompleteHandler);
         }
      }
      
      private function happeningCompleteHandler(param1:Event) : void
      {
         this.h.removeEventListener(Event.COMPLETE,this.happeningCompleteHandler);
         this.h = null;
         end();
      }
   }
}
