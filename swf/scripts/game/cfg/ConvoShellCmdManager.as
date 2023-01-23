package game.cfg
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoAudio;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneAudio;
   import game.gui.page.ConvoPage;
   import game.gui.page.ScenePage;
   
   public class ConvoShellCmdManager extends ShellCmdManager
   {
       
      
      private var config:GameConfig;
      
      public function ConvoShellCmdManager(param1:GameConfig)
      {
         super(param1.logger);
         this.config = param1;
         add("info",this.shellFuncInfo);
         add("pitch",this.shellFuncPitch);
      }
      
      private function shellFuncInfo(param1:CmdExec) : void
      {
         var _loc2_:ScenePage = this.config.pageManager.currentPage as ScenePage;
         var _loc3_:ConvoPage = !!_loc2_ ? _loc2_.convoPage : null;
         if(!_loc3_)
         {
            logger.info("no convo page");
            return;
         }
         var _loc4_:Array = param1.param;
         var _loc5_:String = _loc3_.getDebugString();
         logger.info(_loc5_);
      }
      
      private function shellFuncPitch(param1:CmdExec) : void
      {
         var _loc7_:Number = NaN;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: convo pitch <multiple>");
         }
         else
         {
            _loc7_ = Number(_loc2_[1]);
            ConvoAudio.SEMITONE_MULTIPLE = _loc7_;
         }
         logger.info("ConvoAudio.SEMITONE_MULTIPLE=" + ConvoAudio.SEMITONE_MULTIPLE);
         var _loc3_:Convo = !!this.config.saga ? this.config.saga.convo : null;
         var _loc4_:ConvoAudio = !!_loc3_ ? _loc3_.audio : null;
         var _loc5_:Scene = this.config.saga.getScene();
         var _loc6_:SceneAudio = !!_loc5_ ? _loc5_.audio : null;
         if(!_loc4_ || !_loc6_)
         {
            logger.info("no convo audio active, will apply to next loaded convo");
            return;
         }
         _loc4_.generatePitches();
         _loc6_.pitchSemitones = _loc4_.pitch;
      }
   }
}
