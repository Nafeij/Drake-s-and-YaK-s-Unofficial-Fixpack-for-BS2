package game.cfg
{
   import engine.anim.AnimDispatcherEvent;
   import engine.battle.music.BattleMusicSimulator;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   
   public class BattleMusicShellCmdManager extends ShellCmdManager
   {
       
      
      private var config:GameConfig;
      
      private var _music:BattleMusicSimulator;
      
      public function BattleMusicShellCmdManager(param1:GameConfig)
      {
         super(param1.logger);
         this.config = param1;
         add("start",this.shellFuncStart);
         add("stop",this.shellFuncStop);
         add("trauma",this.shellFuncTrauma);
         add("win",this.shellFuncWin);
         add("lose",this.shellFuncLose);
         add("pillaging",this.shellFuncPillaging);
         add("pillaged",this.shellFuncPillaged);
         add("front",this.shellFuncFrontify);
      }
      
      private function shellFuncStart(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage:");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         if(this._music)
         {
            this._music.cleanup();
            this._music = null;
         }
         this._music = new BattleMusicSimulator(this.config.resman,this.config.soundSystem,this.config.animDispatcher);
         this._music.load(_loc3_);
         this._frontify();
      }
      
      private function shellFuncStop(param1:CmdExec) : void
      {
         if(this._music)
         {
            this._music.cleanup();
            this._music = null;
         }
         this._frontify();
      }
      
      private function shellFuncTrauma(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <trauma> [winning]");
            return;
         }
         var _loc3_:Number = Number(_loc2_[1]);
         var _loc4_:Boolean = _loc2_.length < 3 || _loc2_[2] != "0";
         if(this._music)
         {
            this._music.music.internal_handleTraumaChange(_loc3_,_loc4_);
         }
         this._frontify();
      }
      
      private function shellFuncWin(param1:CmdExec) : void
      {
         this._music.music.handleBattleFinished(true);
         this._frontify();
      }
      
      private function shellFuncLose(param1:CmdExec) : void
      {
         this._music.music.handleBattleFinished(false);
         this._frontify();
      }
      
      private function shellFuncPillaging(param1:CmdExec) : void
      {
         this._music.music.handleBattlePillage(true);
         this._frontify();
      }
      
      private function shellFuncPillaged(param1:CmdExec) : void
      {
         this._music.music.handleBattlePillage(false);
         this._frontify();
      }
      
      private function shellFuncFrontify(param1:CmdExec) : void
      {
         this._frontify();
      }
      
      private function _frontify() : void
      {
         if(this._music)
         {
            this._music.animDispatcher.dispatchEvent(new AnimDispatcherEvent(AnimDispatcherEvent.FRONTIFY_GUI,null,null,null,null));
         }
      }
      
      public function update() : void
      {
         if(this._music)
         {
            this._music.update();
         }
      }
   }
}
