package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_BattleMusic extends Action
   {
       
      
      public function Action_BattleMusic(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.battleMusicDefUrl = def.id;
         end();
      }
   }
}
