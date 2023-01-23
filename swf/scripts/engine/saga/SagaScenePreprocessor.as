package engine.saga
{
   import engine.saga.happening.IHappening;
   
   public class SagaScenePreprocessor implements ISagaScenePreprocessor
   {
       
      
      public var saga:Saga;
      
      public var def:SagaScenePreprocessorDef;
      
      public var cleanedup:Boolean;
      
      public function SagaScenePreprocessor(param1:Saga)
      {
         super();
         this.saga = param1;
         this.def = param1.def.scenePreprocessorDef;
      }
      
      public function cleanup() : void
      {
         this.cleanedup = true;
      }
      
      public function handleScenePreprocessing(param1:String, param2:Function) : void
      {
         var _loc4_:IHappening = null;
         if(!this.def)
         {
            this.finish(param2);
            return;
         }
         var _loc3_:SagaScenePreprocessorEntryDef = this.def.getEntry(param1);
         if(!_loc3_)
         {
            this.finish(param2);
            return;
         }
         if(_loc3_.happening)
         {
            _loc4_ = this.saga.executeHappeningById(_loc3_.happening,null,null);
            if(!_loc4_ || _loc4_.isEnded)
            {
               this.finish(param2);
               return;
            }
            new Waiter(this,param1,param2,_loc4_);
         }
      }
      
      private function finish(param1:Function) : void
      {
         if(param1 != null)
         {
            param1();
         }
      }
   }
}

import engine.saga.SagaScenePreprocessor;
import engine.saga.happening.IHappening;
import flash.events.Event;

class Waiter
{
    
   
   public var id:String;
   
   public var callback:Function;
   
   public var happening:IHappening;
   
   public var ssp:SagaScenePreprocessor;
   
   public function Waiter(param1:SagaScenePreprocessor, param2:String, param3:Function, param4:IHappening)
   {
      super();
      this.ssp = param1;
      this.id = param2;
      this.callback = param3;
      this.happening = param4;
      if(param4.isEnded)
      {
         this.finish(param3);
         return;
      }
      param4.addEventListener(Event.COMPLETE,this.happeningCompleteHandler);
   }
   
   private function happeningCompleteHandler(param1:Event) : void
   {
      this.happening.removeEventListener(Event.COMPLETE,this.happeningCompleteHandler);
      if(this.ssp.cleanedup)
      {
         return;
      }
      this.finish(this.callback);
   }
   
   private function finish(param1:Function) : void
   {
      if(param1 != null)
      {
         param1();
      }
   }
}
