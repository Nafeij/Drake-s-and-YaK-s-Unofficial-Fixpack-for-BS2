package engine.core.fsm
{
   import avmplus.getQualifiedClassName;
   import engine.core.IUpdateable;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   
   public class State extends EventDispatcher implements IUpdateable
   {
       
      
      internal var m_phase:StatePhase;
      
      private var m_queuedPhase:StatePhase;
      
      internal var m_inputDataReady:Boolean = false;
      
      private var m_data:StateData;
      
      private var m_phaseLocked:Boolean;
      
      private var m_interrupted:Boolean;
      
      public var fsm:Fsm;
      
      private var _percentLoaded:Number = 0;
      
      private var _loading:Boolean;
      
      public var logger:ILogger;
      
      public var name:String;
      
      public var shell:ShellCmdManager;
      
      public var cleanedup:Boolean;
      
      private var _isReadyForTransitionOut:Boolean;
      
      protected var transitioningOut:Boolean;
      
      public var forceTransitionOut:Boolean;
      
      public function State(param1:StateData, param2:Fsm, param3:ILogger)
      {
         this.m_phase = StatePhase.INIT;
         super();
         this.logger = param3;
         this.fsm = param2;
         if(param1)
         {
            this.m_data = param1;
         }
         else
         {
            this.m_data = new StateData();
         }
         this.name = getQualifiedClassName(this);
         var _loc4_:int = this.name.lastIndexOf(":");
         this.name = this.name.substr(_loc4_ + 1);
         this.shell = new ShellCmdManager(param3);
         this.shell.add("data",this.shellCmdFuncState);
      }
      
      final public function cleanup() : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("FSM","State Cleanup " + this);
         }
         this.handleCleanup();
         this.shell.cleanup();
         this.shell = null;
         this.cleanedup = true;
      }
      
      public function handleMessage(param1:Object) : Boolean
      {
         return false;
      }
      
      protected function handleEnteredState() : void
      {
      }
      
      internal function internalHandleEnteredState() : void
      {
         try
         {
            this.handleEnteredState();
         }
         catch(e:Error)
         {
            logger.error("State.internalHandleEnteredState " + this + ": " + e + "\n" + e.getStackTrace());
         }
      }
      
      protected function handleInterrupted() : void
      {
      }
      
      protected function handleCleanup() : void
      {
      }
      
      protected function getRequiredInputDataKeys() : Array
      {
         return null;
      }
      
      final internal function enterState() : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("FSM","State.enterState " + this.fsm + " " + this);
         }
         this.phase = StatePhase.ENTERING;
      }
      
      private function checkEnterState() : void
      {
         if(this.phase == StatePhase.ENTERING)
         {
            if(this.inputDataReady)
            {
               this.phase = StatePhase.ENTERED;
            }
         }
      }
      
      final public function checkInputDataReady() : void
      {
         var _loc2_:StateDataEnum = null;
         if(this.m_phase != StatePhase.ENTERING)
         {
            return;
         }
         var _loc1_:Array = this.getRequiredInputDataKeys();
         if(null != _loc1_)
         {
            for each(_loc2_ in _loc1_)
            {
               if(!this.m_data.hasValue(_loc2_))
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.d("FSM","State " + this.fsm + " " + this + " unready due to missing data " + _loc2_);
                  }
                  this.inputDataReady = false;
                  return;
               }
            }
         }
         this.inputDataReady = true;
      }
      
      private function get inputDataReady() : Boolean
      {
         return this.m_inputDataReady;
      }
      
      private function set inputDataReady(param1:Boolean) : void
      {
         if(this.m_inputDataReady != param1)
         {
            this.m_inputDataReady = param1;
         }
      }
      
      public function set phase(param1:StatePhase) : void
      {
         var _loc2_:StatePhase = null;
         if(this.m_phaseLocked)
         {
            this.m_queuedPhase = param1;
            return;
         }
         if(param1 != this.m_phase)
         {
            if(param1.value < this.m_phase.value)
            {
               throw new IllegalOperationError("cannot phase backwards in the lifecycle from " + this.m_phase + " to " + param1);
            }
            _loc2_ = this.m_phase;
            this.m_phase = param1;
            if(this.fsm)
            {
               this.fsm.onStatePhaseChanged(this,_loc2_);
            }
         }
      }
      
      public function get phase() : StatePhase
      {
         return this.m_phase;
      }
      
      public function get data() : StateData
      {
         return this.m_data;
      }
      
      public function isPhase(param1:StatePhase) : Boolean
      {
         return this.m_phase == param1;
      }
      
      internal function set lockPhase(param1:Boolean) : void
      {
         var _loc2_:StatePhase = null;
         if(param1 == this.m_phaseLocked)
         {
            return;
         }
         if(this.m_phaseLocked && param1)
         {
            throw new IllegalOperationError("already locked");
         }
         this.m_phaseLocked = param1;
         if(!this.m_phaseLocked)
         {
            if(this.m_queuedPhase)
            {
               _loc2_ = this.m_queuedPhase;
               this.m_queuedPhase = null;
               this.phase = _loc2_;
            }
         }
      }
      
      internal function get lockPhase() : Boolean
      {
         return this.m_phaseLocked;
      }
      
      public function get interrupted() : Boolean
      {
         return this.m_interrupted;
      }
      
      public function interrupt() : void
      {
         if(this.m_phase == StatePhase.COMPLETED || this.m_phase == StatePhase.INTERRUPTED || this.m_phase == StatePhase.FAILED)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("State.interrupt " + this.fsm + " with " + this);
         }
         this.handleInterrupted();
         this.phase = StatePhase.INTERRUPTED;
         this.lockPhase = true;
      }
      
      override public function toString() : String
      {
         return this.name;
      }
      
      public function toInfoString() : String
      {
         var _loc1_:String = this.toString();
         _loc1_ += "   phase=" + this.m_phase + "\n";
         _loc1_ += "  qphase=" + this.m_queuedPhase + "\n";
         _loc1_ += "     idr=" + this.m_inputDataReady + "\n";
         _loc1_ += " loading=" + this._loading + "\n";
         return _loc1_ + ("ploading=" + this._percentLoaded + "\n");
      }
      
      public function get percentLoaded() : Number
      {
         return this._percentLoaded;
      }
      
      public function set percentLoaded(param1:Number) : void
      {
         if(this._percentLoaded != param1)
         {
            this._percentLoaded = param1;
            if(this.fsm)
            {
               this.fsm.onStateLoadingChanged(this);
            }
         }
      }
      
      public function get loading() : Boolean
      {
         return this._loading;
      }
      
      public function set loading(param1:Boolean) : void
      {
         if(this._loading != param1)
         {
            this._loading = param1;
            if(this.fsm)
            {
               this.fsm.onStateLoadingChanged(this);
            }
         }
      }
      
      public function update(param1:int) : void
      {
      }
      
      private function shellCmdFuncState(param1:CmdExec) : *
      {
         var _loc3_:* = null;
         var _loc2_:Array = param1.param;
         this.logger.info(this.toString());
         this.logger.info("data: " + this.data);
         if(this.data)
         {
            for(_loc3_ in this.data.values)
            {
               this.logger.info("    " + _loc3_ + ": " + this.data.values[_loc3_]);
            }
         }
      }
      
      public function handleTransitioningOut() : void
      {
         this._isReadyForTransitionOut = true;
      }
      
      public function get isReadyForTransitionOut() : Boolean
      {
         this.handleTransitioningOut();
         if(this.forceTransitionOut && !this._isReadyForTransitionOut)
         {
            this.logger.info("State FORCING _isReadyForTransitionOut");
            this._isReadyForTransitionOut = true;
         }
         return this._isReadyForTransitionOut;
      }
      
      public function set isReadyForTransitionOut(param1:Boolean) : void
      {
         if(this._isReadyForTransitionOut == param1)
         {
            return;
         }
         this._isReadyForTransitionOut = param1;
         if(!this.cleanedup)
         {
            this.fsm.handleReadyForTransitionOut(this);
         }
      }
   }
}
