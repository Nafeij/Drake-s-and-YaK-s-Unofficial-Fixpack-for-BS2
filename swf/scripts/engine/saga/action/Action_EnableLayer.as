package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_EnableLayer extends Action
   {
       
      
      public function Action_EnableLayer(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:* = def.varvalue != 0;
         saga.performEnableSceneElement(_loc1_,def.id,true,false,def.time,this.toString());
         end();
      }
   }
}
