package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_FlyText extends Action
   {
       
      
      public function Action_FlyText(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         super.handleStarted();
         var _loc1_:String = translateMsg(def.msg);
         _loc1_ = saga.performStringReplacement_SagaVar(_loc1_);
         saga.showFlyText(_loc1_,def.varvalue,def.param,def.time);
         end();
      }
   }
}
