package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   import engine.saga.happening.IHappening;
   import flash.events.Event;
   
   public class Op_SagaHappening extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SagaHappening",
         "properties":{
            "happening":{"type":"string"},
            "nonblocking":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var saga:ISaga;
      
      private var happening:String;
      
      private var nonblocking:Boolean;
      
      private var h:IHappening;
      
      public function Op_SagaHappening(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.saga = SagaInstance.instance;
         this.happening = param1.params.happening;
         this.nonblocking = param1.params.nonblocking;
      }
      
      override public function execute() : EffectResult
      {
         if(!this.saga)
         {
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(fake || !this.saga)
         {
            return;
         }
         if(!this.nonblocking)
         {
            effect.blockComplete();
         }
         this.h = this.saga.executeHappeningById(this.happening,null,ability);
         if(!this.nonblocking)
         {
            if(!this.h.isEnded)
            {
               this.h.addEventListener(Event.COMPLETE,this.completeHandler);
            }
            else
            {
               effect.unblockComplete();
            }
         }
      }
      
      private function completeHandler(param1:Event) : void
      {
         this.h.removeEventListener(Event.COMPLETE,this.completeHandler);
         effect.unblockComplete();
      }
   }
}
