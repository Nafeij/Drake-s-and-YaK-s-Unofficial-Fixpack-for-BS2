package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_EnableSprite extends Action
   {
       
      
      public function Action_EnableSprite(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:* = def.varvalue != 0;
         var _loc2_:String = this.toString();
         saga.performEnableSceneElement(_loc1_,def.id,false,false,def.time,_loc2_);
         end();
      }
   }
}
