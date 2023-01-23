package game.saga
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import engine.saga.IBattleTutorial;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import game.session.states.SceneState;
   
   public class TutorialBattleStrandGreatHall implements IBattleTutorial
   {
       
      
      private var pc:TutorialBattleStrandGreatHall_pc;
      
      private var gp:TutorialBattleStrandGreatHall_gp;
      
      public function TutorialBattleStrandGreatHall(param1:SceneState)
      {
         super();
         var _loc2_:GpDevice = GpSource.primaryDevice;
         var _loc3_:Boolean = PlatformInput.lastInputGp;
         if(Boolean(_loc2_) && _loc3_)
         {
            this.gp = new TutorialBattleStrandGreatHall_gp(param1);
         }
         else
         {
            this.pc = new TutorialBattleStrandGreatHall_pc(param1);
         }
      }
      
      public function get isActive() : Boolean
      {
         if(this.pc)
         {
            return this.pc.isActive;
         }
         if(this.gp)
         {
            return this.gp.isActive;
         }
         return false;
      }
      
      public function cleanup() : void
      {
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            _loc1_.setVar(SagaVar.VAR_ACHIEVEMENTS_SUPPRESSED,false);
         }
         if(this.pc)
         {
            this.pc.cleanup();
         }
         if(this.gp)
         {
            this.gp.cleanup();
         }
      }
   }
}
