package game.saga
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import engine.saga.IBattleTutorial;
   import game.session.states.SceneState;
   
   public class TutorialBattleVedrfell implements IBattleTutorial
   {
       
      
      private var pc:TutorialBattleVedrfell_pc;
      
      private var gp:TutorialBattleVedrfell_gp;
      
      public function TutorialBattleVedrfell(param1:SceneState)
      {
         super();
         var _loc2_:GpDevice = GpSource.primaryDevice;
         var _loc3_:Boolean = PlatformInput.lastInputGp;
         if(Boolean(_loc2_) && _loc3_)
         {
            this.gp = new TutorialBattleVedrfell_gp(param1);
         }
         else
         {
            this.pc = new TutorialBattleVedrfell_pc(param1);
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
