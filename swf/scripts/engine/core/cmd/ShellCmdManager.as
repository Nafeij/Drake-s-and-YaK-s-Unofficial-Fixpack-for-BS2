package engine.core.cmd
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class ShellCmdManager extends Cmder
   {
       
      
      private var cmdlist:Vector.<String>;
      
      private var lowerSortedCmds:Array;
      
      private var lowerCmds:Dictionary;
      
      public var shellCmdHistory:ShellCmdHistory;
      
      public var subshells:Array;
      
      private var _cmdlist_dirty:Boolean;
      
      protected var _aliases:Dictionary;
      
      protected var _alias_count:int;
      
      public function ShellCmdManager(param1:ILogger, param2:Boolean = false)
      {
         this.cmdlist = new Vector.<String>();
         this.lowerSortedCmds = [];
         this.lowerCmds = new Dictionary();
         this.subshells = [];
         this._aliases = new Dictionary();
         super(param1);
         this.add("",this.shellCmdFuncHelp);
         this.add("?",this.shellCmdFuncHelp);
         this.add("help",this.shellCmdFuncHelp);
         this.add("history",this.shellCmdFuncHistory);
      }
      
      public function cleanup() : void
      {
         var _loc1_:ShellCmdSubshell = null;
         while(this.subshells.length > 0)
         {
            _loc1_ = this.subshells[0];
            _loc1_.cleanup();
         }
         dispatchEvent(new Event(Event.COMPLETE));
         this.subshells = null;
         this.cmdlist = null;
         this.lowerCmds = null;
         logger = null;
         this.shellCmdHistory = null;
         this.lowerSortedCmds = null;
         super.cleanupCmder();
      }
      
      public function addAlias(param1:String, param2:String) : void
      {
         var _loc3_:String = param1.toLowerCase();
         var _loc4_:ShellCmd = this.lowerCmds[_loc3_];
         if(_loc4_)
         {
            if(!_loc4_.isAlias)
            {
               logger.error("Cannot override command [" + _loc4_.name + "] with an alias");
               return;
            }
         }
         else
         {
            _loc4_ = new ShellCmd(param1,this._aliasCmdFunc);
            _loc4_.isAlias = true;
            registerCmd(_loc4_);
            this.lowerSortedCmds.push(_loc3_);
         }
         if(!(_loc3_ in this._aliases))
         {
            ++this._alias_count;
         }
         this._aliases[_loc3_] = param2;
         this.lowerCmds[_loc3_] = _loc4_;
         this._cmdlist_dirty = true;
      }
      
      public function removeAlias(param1:String) : void
      {
         var _loc2_:String = param1.toLowerCase();
         if(this._aliases[_loc2_])
         {
            --this._alias_count;
            delete this._aliases[_loc2_];
            this.removeShell(_loc2_);
         }
      }
      
      public function getAlias(param1:String) : String
      {
         var _loc2_:String = param1.toLowerCase();
         return this._aliases[_loc2_];
      }
      
      public function add(param1:String, param2:Function, param3:Boolean = false) : Cmd
      {
         var _loc4_:String = param1.toLowerCase();
         if(_loc4_ in this.lowerCmds)
         {
            return this.lowerCmds[_loc4_];
         }
         var _loc5_:ShellCmd = new ShellCmd(param1,param2);
         if(param3 || this.cheat)
         {
            _loc5_.setShellCheat();
         }
         this.lowerCmds[_loc4_] = _loc5_;
         this.cmdlist.push(param1);
         this.lowerSortedCmds.push(_loc4_);
         registerCmd(_loc5_);
         this._cmdlist_dirty = true;
         return _loc5_;
      }
      
      private function findSubshellByName(param1:String) : ShellCmdSubshell
      {
         var _loc3_:ShellCmdSubshell = null;
         var _loc2_:String = param1.toLowerCase();
         for each(_loc3_ in this.subshells)
         {
            if(_loc2_ == _loc3_.lowerName)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function removeShell(param1:String) : void
      {
         var _loc7_:int = 0;
         var _loc2_:ShellCmdSubshell = this.findSubshellByName(param1);
         if(_loc2_)
         {
            _loc7_ = this.subshells.indexOf(_loc2_);
            this.subshells.splice(_loc7_);
            _loc2_.cleanup();
            _loc2_ = null;
         }
         var _loc3_:String = param1.toLowerCase();
         var _loc4_:Cmd = this.lowerCmds[_loc3_];
         delete this.lowerCmds[_loc3_];
         if(_loc4_)
         {
            unregisterCmd(_loc4_);
         }
         var _loc5_:int = this.cmdlist.indexOf(param1);
         if(_loc5_ >= 0)
         {
            this.cmdlist.splice(_loc5_,1);
         }
         var _loc6_:int = this.lowerSortedCmds.indexOf(_loc3_);
         if(_loc6_ >= 0)
         {
            this.lowerSortedCmds.splice(_loc6_,1);
         }
         this._cmdlist_dirty = true;
      }
      
      public function addShell(param1:String, param2:ShellCmdManager) : void
      {
         if(!param2)
         {
            throw new ArgumentError("null shell");
         }
         var _loc3_:ShellCmdSubshell = new ShellCmdSubshell(param1,param2,this);
         this.subshells.push(_loc3_);
      }
      
      public function execSubShell(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         _loc2_ = _loc2_.slice(1);
         this.execArgv(param1.cmdline,_loc2_);
      }
      
      private function findLowerCmd(param1:String) : ShellCmd
      {
         var _loc2_:String = null;
         this.checkDirty();
         for each(_loc2_ in this.lowerSortedCmds)
         {
            if(param1.length <= _loc2_.length)
            {
               if(param1 == _loc2_.substr(0,param1.length))
               {
                  return this.lowerCmds[_loc2_];
               }
            }
         }
         return null;
      }
      
      public function execArgv(param1:String, param2:Array) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc3_:String = "";
         if(param2.length > 0)
         {
            _loc3_ = (param2[0] as String).toLowerCase();
         }
         var _loc4_:ShellCmd = this.findLowerCmd(_loc3_);
         if(!_loc4_)
         {
            return false;
         }
         if(_loc4_.isAlias)
         {
            _loc5_ = this.getAlias(_loc3_);
            if(_loc5_)
            {
               logger.info("Executing alias [" + _loc3_ + "]");
               param2.shift();
               _loc6_ = param2.join(" ");
               if(_loc6_)
               {
                  _loc6_ = " " + _loc6_;
               }
               if(!this.exec(_loc5_ + _loc6_,true))
               {
                  logger.error("Alias [" + _loc3_ + "] failed to execute [" + _loc5_ + "]");
               }
               return true;
            }
         }
         this.execute(_loc4_,param1,param2);
         return true;
      }
      
      public function exec(param1:String, param2:Boolean = false) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(!param2)
         {
            if(this.shellCmdHistory)
            {
               this.shellCmdHistory.insert(param1);
            }
            logger.info("> " + param1);
         }
         var _loc3_:Array = param1.split(" ");
         return this.execArgv(param1,_loc3_);
      }
      
      private function checkDirty() : void
      {
         if(this._cmdlist_dirty)
         {
            this._cmdlist_dirty = false;
            this.cmdlist.sort(Array.CASEINSENSITIVE);
            this.lowerSortedCmds.sort(0);
         }
      }
      
      private function shellCmdFuncHelp(param1:CmdExec) : void
      {
         var _loc4_:Cmd = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:* = null;
         this.checkDirty();
         logger.info("[" + param1.cmd.name + "] Available Commands: ");
         var _loc2_:int = 4;
         var _loc3_:int = 2;
         for each(_loc6_ in this.lowerSortedCmds)
         {
            _loc8_ = _loc6_.length;
            _loc4_ = this.lowerCmds[_loc6_];
            if(_loc4_.isShell)
            {
               _loc8_ += _loc2_;
            }
            _loc5_ = Math.max(_loc8_,_loc5_);
         }
         _loc5_ += _loc3_;
         _loc7_ = StringUtil.repeat(" ",_loc3_);
         for each(_loc6_ in this.lowerSortedCmds)
         {
            if(_loc6_ != "developer")
            {
               _loc4_ = this.lowerCmds[_loc6_];
               _loc9_ = _loc7_ + _loc6_;
               if(_loc4_.isShell)
               {
                  _loc9_ = StringUtil.padRight(_loc9_," ",_loc5_ - _loc2_) + " ...";
               }
               if(_loc4_ && _loc4_.cheat || this.cheat)
               {
                  _loc9_ = StringUtil.padRight(_loc9_," ",_loc5_) + " << CHEAT >>";
               }
               logger.info(_loc9_);
            }
         }
         if(this._alias_count)
         {
            logger.info("Additionally there are " + this._alias_count + " aliases.");
         }
      }
      
      private function shellCmdFuncHistory(param1:CmdExec) : void
      {
         var _loc3_:String = null;
         logger.info("History: ");
         if(!this.shellCmdHistory)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.shellCmdHistory.cmdlines.length)
         {
            _loc3_ = this.shellCmdHistory.cmdlines[_loc2_];
            logger.info(_loc2_.toString() + " " + _loc3_);
            _loc2_++;
         }
      }
      
      private function _aliasCmdFunc(param1:CmdExec) : void
      {
         throw new ArgumentError("Don\'t call this");
      }
   }
}
