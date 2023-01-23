package engine.core.fsm
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class Fsm extends EventDispatcher implements IFsm
   {
      
      public static const TRANS_COMPLETE:uint = 1;
      
      public static const TRANS_FAILED:uint = 2;
      
      public static const TRANS_ALL:uint = 3;
      
      public static var NO_START:Boolean;
       
      
      public var states:Dictionary;
      
      public var transitionsComplete:Dictionary;
      
      public var transitionsFailed:Dictionary;
      
      private var m_current:State;
      
      public var logger:ILogger;
      
      public var entering:State;
      
      public var name:String;
      
      public var errors:Vector.<String>;
      
      public var ok:Boolean = true;
      
      public var shell:ShellCmdManager;
      
      private var msgQueue:FsmMsgQueue;
      
      protected var clobberStates:Dictionary;
      
      private var m_initialState:Class;
      
      public var stopping:Boolean;
      
      private var _settingCurrentState:Boolean;
      
      private var _queuedSetCurrentStateData:Object;
      
      private var _queuedSetCurrentStateClazz:Class;
      
      private var _nextState:State;
      
      private var _checkingNextState:Boolean;
      
      public var _currentClass:Class;
      
      public function Fsm(param1:String, param2:ILogger)
      {
         this.states = new Dictionary();
         this.transitionsComplete = new Dictionary();
         this.transitionsFailed = new Dictionary();
         this.errors = new Vector.<String>();
         this.clobberStates = new Dictionary();
         super();
         if(!param2)
         {
            throw new ArgumentError("All Fsms need a logger");
         }
         this.name = param1;
         this.logger = param2;
         this.shell = new ShellCmdManager(param2);
         this.shell.add("get",this.shellFuncGetFsm);
         this.shell.add("info",this.shellFuncInfo);
         this.shell.add("state",this.shellFuncStateFsm);
      }
      
      protected function useMsgQueue() : void
      {
         if(!this.msgQueue)
         {
            this.msgQueue = new FsmMsgQueue(this);
         }
      }
      
      protected function cleanup() : void
      {
         this.setCurrent(null);
         if(this.msgQueue)
         {
            this.msgQueue = null;
         }
         this.shell.removeShell("get");
         this.shell.removeShell("state");
         this.shell.cleanup();
         this.shell = null;
         this.logger = null;
         this.states = null;
         this.transitionsComplete = null;
         this.transitionsFailed = null;
         this.errors = null;
         this.clobberStates = null;
      }
      
      final public function handleMessages(param1:Array) : Boolean
      {
         var _loc3_:Object = null;
         var _loc2_:Boolean = true;
         for each(_loc3_ in param1)
         {
            if(!this.handleMessage(_loc3_))
            {
               _loc2_ = false;
            }
         }
         return _loc2_;
      }
      
      final public function handleMessage(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param1 is Array)
         {
            return this.handleMessages(param1 as Array);
         }
         this.logger.debug("Fsm HANDLE MSG " + this.current + ": " + param1["class"]);
         if(!this.handleMsgReceived(param1))
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("FSM IGNORE DUPE " + param1);
            }
         }
         if(this.msgQueue)
         {
            return this.msgQueue.pushMessage(param1);
         }
         return this.handleOneMessage(param1);
      }
      
      protected function handleMsgReceived(param1:Object) : Boolean
      {
         return true;
      }
      
      public function handleOneMessage(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(Boolean(this.current) && this.current.phase.value < StatePhase.COMPLETING.value)
         {
            return this.current.handleMessage(param1);
         }
         return false;
      }
      
      override public function toString() : String
      {
         return "[" + this.name + "/" + this.m_current + "]";
      }
      
      public function toInfoString() : String
      {
         var _loc1_:String = this.toString();
         if(this.m_current)
         {
            _loc1_ += this.m_current.toInfoString();
         }
         return _loc1_;
      }
      
      private function clazzName(param1:Class) : String
      {
         var _loc2_:String = getQualifiedClassName(param1);
         var _loc3_:int = _loc2_.indexOf("::");
         if(_loc3_ > 0)
         {
            _loc2_ = _loc2_.substr(_loc3_ + 2);
         }
         return _loc2_;
      }
      
      public function registerState(param1:Class) : void
      {
         if(this.states[param1])
         {
            throw new ArgumentError("state already registered: " + this.clazzName(param1));
         }
         this.states[param1] = param1;
      }
      
      public function registerTransition(param1:Class, param2:Class, param3:uint) : void
      {
         if(param1 == param2)
         {
            throw new ArgumentError("transitioning to yourself is pretty fail");
         }
         if(param1)
         {
            this.findState(param1,true);
         }
         this.findState(param2,true);
         if(param3 & TRANS_COMPLETE)
         {
            this.transitionsComplete[param1] = param2;
         }
         if(param3 & TRANS_FAILED)
         {
            this.transitionsFailed[param1] = param2;
         }
      }
      
      public function set initialState(param1:Class) : void
      {
         if(!this.findState(param1,true))
         {
            throw new IllegalOperationError("Can\'t set initial state before registering it!");
         }
         this.m_initialState = param1;
      }
      
      public function startFsm(param1:Object) : void
      {
         if(NO_START)
         {
            this.logger.info("Fsm ignoring start due to NO_START");
            return;
         }
         if(this.current)
         {
            throw new IllegalOperationError("Already started!");
         }
         if(this.m_initialState == null)
         {
            throw new IllegalOperationError("Attempt to startFsm with no initial state");
         }
         this.setCurrentState(param1,this.m_initialState);
      }
      
      public function stopFsm(param1:Boolean) : void
      {
         this.logger.info("Fsm.stopFsm " + this + " " + param1);
         this.ok = param1;
         if(!this.current)
         {
            throw new IllegalOperationError("Not started!");
         }
         this.stopping = true;
         this.setCurrent(null);
         if(!param1)
         {
            dispatchEvent(new FsmEvent(FsmEvent.FAIL));
         }
         dispatchEvent(new FsmEvent(FsmEvent.STOP));
         this.cleanup();
      }
      
      public function startInitialState(param1:Class, param2:Object) : void
      {
         this.initialState = param1;
         this.startFsm(param2);
      }
      
      public function transitionTo(param1:Class, param2:Object) : void
      {
         if(this.stopping)
         {
            return;
         }
         var _loc3_:Class = this.findState(param1,true);
         this.setCurrentState(param2,_loc3_);
      }
      
      private function setCurrentState(param1:Object, param2:Class) : void
      {
         var ns:State = null;
         var wc:State = null;
         var nextclazz:Class = null;
         var nextdata:Object = null;
         var data:Object = param1;
         var clazz:Class = param2;
         if(this._settingCurrentState)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Fsm.setCurrentState QUEING " + this + " to=" + this.clazzName(clazz));
            }
            this._queuedSetCurrentStateData = data;
            this._queuedSetCurrentStateClazz = clazz;
            return;
         }
         this.logger.i("FSM ","Current " + this + " -> " + this.clazzName(clazz));
         if(clazz == null)
         {
            throw new ArgumentError("invalid clazz");
         }
         if(this.currentClass == clazz)
         {
            if(!this.clobberStates[clazz])
            {
               this.logger.info("Fsm.setCurrentState Already in state " + clazz);
               return;
            }
         }
         this._settingCurrentState = true;
         try
         {
            this._queuedSetCurrentStateClazz = null;
            this._queuedSetCurrentStateData = null;
            ns = new clazz(data,this,this.logger) as State;
            this.nextState = ns;
            if(this.checkNextState())
            {
               if(this.m_current)
               {
                  wc = this.m_current;
                  this.m_current.enterState();
                  if(wc == this.m_current && this.m_current.phase == StatePhase.ENTERING)
                  {
                     this.m_current.checkInputDataReady();
                     if(this.m_current.m_inputDataReady)
                     {
                        this.m_current.phase = StatePhase.ENTERED;
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
            _settingCurrentState = false;
            if(logger)
            {
               logger.error("Fsm.setCurrentState problem:\n" + e.getStackTrace());
            }
            throw e;
         }
         this._settingCurrentState = false;
         if(this._queuedSetCurrentStateClazz != null)
         {
            nextclazz = this._queuedSetCurrentStateClazz;
            nextdata = this._queuedSetCurrentStateData;
            this._queuedSetCurrentStateData = null;
            this._queuedSetCurrentStateClazz = null;
            this.setCurrentState(nextdata,nextclazz);
         }
      }
      
      public function handleReadyForTransitionOut(param1:State) : void
      {
         var _loc2_:State = null;
         if(this.m_current != param1)
         {
            return;
         }
         if(this.checkNextState())
         {
            if(this.m_current)
            {
               _loc2_ = this.m_current;
               this.m_current.enterState();
               if(_loc2_ == this.m_current && this.m_current.phase == StatePhase.ENTERING)
               {
                  this.m_current.checkInputDataReady();
                  if(this.m_current.m_inputDataReady)
                  {
                     this.m_current.phase = StatePhase.ENTERED;
                  }
               }
            }
         }
      }
      
      private function set nextState(param1:State) : void
      {
         if(this._nextState == param1)
         {
            return;
         }
         if(this._nextState)
         {
            this._nextState.cleanup();
         }
         this._nextState = param1;
      }
      
      private function get nextState() : State
      {
         return this._nextState;
      }
      
      private function checkNextState() : Boolean
      {
         if(!this._nextState || this._checkingNextState)
         {
            return false;
         }
         this._checkingNextState = true;
         var _loc1_:Boolean = Boolean(this.current) && !this.current.isReadyForTransitionOut;
         this._checkingNextState = false;
         if(_loc1_)
         {
            return false;
         }
         this.setCurrent(this._nextState);
         return true;
      }
      
      public function onStateLoadingChanged(param1:State) : void
      {
         if(param1 == this.current)
         {
            dispatchEvent(new FsmEvent(FsmEvent.LOADING));
         }
      }
      
      public function onStatePhaseChanged(param1:State, param2:StatePhase) : void
      {
         if(param1 != this.m_current)
         {
            if(Boolean(this.logger) && this.logger.isDebugEnabled)
            {
               this.logger.debug("Ignoring state phase [" + param2.name + "->" + param1.phase.name + "] change on non-current state " + param1);
            }
            return;
         }
         param1.lockPhase = true;
         dispatchEvent(new StatePhaseEvent(param1,param2));
         if(param1.isPhase(StatePhase.ENTERING))
         {
            this.entering = param1;
         }
         else
         {
            this.entering = null;
         }
         switch(param1.phase)
         {
            case StatePhase.COMPLETING:
               break;
            case StatePhase.COMPLETED:
               dispatchEvent(new FsmEvent(FsmEvent.COMPLETED));
               if(param1 == this.current)
               {
                  this.performCompletedTransition();
               }
               break;
            case StatePhase.FAILED:
               this.performFailedTransition();
               break;
            case StatePhase.ENTERED:
               param1.internalHandleEnteredState();
               this.popMessages();
               this.handleCurrentChanged();
               dispatchEvent(new FsmEvent(FsmEvent.CURRENT));
               break;
            case StatePhase.INTERRUPTED:
         }
         param1.lockPhase = false;
      }
      
      public function get currentClass() : Class
      {
         return this._currentClass;
      }
      
      public function set currentClass(param1:Class) : void
      {
         this._currentClass = param1;
      }
      
      private function performCompletedTransition() : void
      {
         var _loc1_:Class = this.transitionsComplete[this.currentClass];
         if(_loc1_)
         {
            this.transitionTo(_loc1_,this.m_current.data);
         }
      }
      
      private function performFailedTransition() : void
      {
         var _loc1_:Class = this.transitionsFailed[this.currentClass];
         if(_loc1_)
         {
            this.transitionTo(_loc1_,this.current.data);
         }
         else
         {
            _loc1_ = this.transitionsFailed[null];
            if(_loc1_)
            {
               this.transitionTo(_loc1_,this.current.data);
            }
         }
      }
      
      public function update(param1:int) : void
      {
         if(this.entering)
         {
            if(this.entering.phase == StatePhase.ENTERING)
            {
               this.entering.checkInputDataReady();
               if(this.entering.m_inputDataReady)
               {
                  this.entering.phase = StatePhase.ENTERED;
               }
            }
         }
         if(this.current)
         {
            this.current.update(param1);
         }
      }
      
      private function findState(param1:Class, param2:Boolean) : Class
      {
         var _loc3_:Class = this.states[param1];
         if(!_loc3_ || _loc3_ != param1)
         {
            if(param2)
            {
               throw new ArgumentError("no such state registered: " + this.clazzName(param1));
            }
         }
         return _loc3_;
      }
      
      public function get current() : State
      {
         return this.m_current;
      }
      
      private function setCurrent(param1:State) : void
      {
         var old:State = null;
         var value:State = param1;
         if(this.m_current)
         {
            old = this.m_current;
            this.m_current = null;
            this.currentClass = null;
            dispatchEvent(new FsmEvent(FsmEvent.CURRENT));
            try
            {
               old.interrupt();
               old.cleanup();
            }
            catch(e:Error)
            {
               logger.error("Fsm.setCurrent failed to interrupt/cleanup old: " + old);
               logger.error(e.getStackTrace());
            }
         }
         if(Boolean(value) || value == this._nextState)
         {
            this._nextState = null;
         }
         this.m_current = value;
         if(this.m_current)
         {
            this.currentClass = getDefinitionByName(getQualifiedClassName(this.m_current)) as Class;
         }
         else
         {
            this.currentClass = null;
         }
      }
      
      protected function handleCurrentChanged() : void
      {
      }
      
      public function popMessages() : void
      {
         if(this.msgQueue)
         {
            this.msgQueue.popMessages();
         }
      }
      
      public function addErrorMsg(param1:String) : void
      {
         this.errors.push(param1);
      }
      
      public function shellFuncGetFsm(param1:CmdExec) : void
      {
         this.logger.info(this.toString());
      }
      
      public function shellFuncInfo(param1:CmdExec) : void
      {
         this.logger.info(this.toInfoString());
      }
      
      public function shellFuncStateFsm(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(Boolean(this.current) && Boolean(this.current.shell))
         {
            this.current.shell.execArgv(param1.cmdline,_loc2_.slice(1));
         }
         else
         {
            this.logger.info("Current has no shell handler");
         }
      }
      
      public function getLogger() : ILogger
      {
         return this.logger;
      }
   }
}
