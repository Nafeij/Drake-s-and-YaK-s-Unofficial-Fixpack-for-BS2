package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.SagaMarket;
   import flash.events.Event;
   
   public class Action_MarketShow extends Action
   {
       
      
      public function Action_MarketShow(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.showSagaMarket();
         if(def.instant || !saga.market.showing)
         {
            end();
            return;
         }
         saga.market.addEventListener(SagaMarket.EVENT_SHOWING,this.showingHandler);
      }
      
      private function showingHandler(param1:Event) : void
      {
         if(!saga.market.showing)
         {
            saga.market.removeEventListener(SagaMarket.EVENT_SHOWING,this.showingHandler);
            end();
         }
      }
   }
}
