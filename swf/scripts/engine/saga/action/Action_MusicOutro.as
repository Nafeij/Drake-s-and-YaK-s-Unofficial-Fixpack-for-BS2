package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_MusicOutro extends Action
   {
       
      
      public function Action_MusicOutro(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.id;
         var _loc2_:String = def.location;
         saga.sound.outroMusic(_loc2_,_loc1_);
         end();
      }
      
      private function tweenHandler() : void
      {
         end();
      }
   }
}
