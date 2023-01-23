package engine.saga.convo
{
   import engine.core.logging.ILogger;
   import engine.math.Rng;
   import engine.saga.ISaga;
   import engine.saga.ISagaExpression;
   import engine.saga.SagaPresenceManager;
   import engine.saga.SagaPresenceState;
   import engine.saga.convo.def.ConvoDef;
   import engine.saga.convo.def.ConvoNodeDef;
   import engine.saga.convo.def.ConvoOptionDef;
   import engine.saga.convo.def.audio.ConvoAudioCmdDef;
   import engine.saga.convo.def.audio.ConvoAudioDef;
   import engine.saga.convo.def.audio.ConvoAudioListDef;
   import engine.saga.happening.IHappeningProvider;
   import engine.saga.vars.IVariableProvider;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class Convo extends EventDispatcher
   {
      
      public static const EVENT_AUDIO_BLOCK:String = "Convo.AudioEventBlockInput";
      
      public static const EVENT_AUDIO_UNBLOCK:String = "Convo.AudioEventUnblockInput";
       
      
      public var def:ConvoDef;
      
      public var saga:ISaga;
      
      public var happs:IHappeningProvider;
      
      public var cursor:ConvoCursor;
      
      public var finished:Boolean;
      
      public var sceneUrl:String;
      
      private var _logger:ILogger;
      
      private var _selectedNode:ConvoNodeDef;
      
      private var _selectedOption:ConvoOptionDef;
      
      private var visibleActors:Dictionary;
      
      public var audio:ConvoAudio;
      
      public var poppening_top:int;
      
      public var suffix:String;
      
      private var presenceState:SagaPresenceState;
      
      public var expression:ISagaExpression;
      
      public var vars:IVariableProvider;
      
      public var rng:Rng;
      
      private var _pendingBlockingAudioEventProcessing:Boolean;
      
      public function Convo(param1:ConvoDef, param2:ISaga, param3:ISagaExpression, param4:IVariableProvider, param5:IHappeningProvider, param6:String, param7:ILogger)
      {
         var _loc9_:ConvoAudioDef = null;
         var _loc10_:Vector.<String> = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:ConvoAudioListDef = null;
         this.visibleActors = new Dictionary();
         super();
         this.def = param1;
         this.saga = param2;
         this.rng = !!param2 ? param2.rng : null;
         this.happs = param5;
         this.sceneUrl = param6;
         this.suffix = !!param2 ? param2.convoNodeIdSuffix : null;
         this._logger = param7;
         this.expression = param3;
         this.vars = param4;
         this._pendingBlockingAudioEventProcessing = false;
         var _loc8_:int = 1;
         while(_loc8_ <= 4)
         {
            _loc10_ = param1.getUnitsFromMark(_loc8_);
            _loc11_ = 0;
            while(_loc11_ < _loc10_.length)
            {
               _loc12_ = _loc10_[_loc11_];
               if(_loc12_)
               {
                  this.setActorVisible(_loc12_,_loc11_ == 0,false);
               }
               _loc11_++;
            }
            _loc8_++;
         }
         if(param2)
         {
            _loc13_ = param2.convoAudioListDef;
            _loc9_ = !!_loc13_ ? _loc13_.getAudioForConvo(param1.url) : null;
            this.audio = new ConvoAudio(param2.sound.system,_loc13_,_loc9_,this);
         }
         this.cursor = new ConvoCursor(this,param2,param7);
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "def=" + this.toString() + "\n";
         _loc1_ += "MARKS:\n" + this.def.getDebugStringMarks();
         return _loc1_ + ("CURSOR:\n" + this.cursor.getDebugString());
      }
      
      override public function toString() : String
      {
         return !!this.def ? this.def.url : "null";
      }
      
      public function cleanup() : void
      {
         if(this.audio)
         {
            this.audio.cleanup();
            this.audio = null;
         }
      }
      
      public function handleCursorAudioCmds() : void
      {
         var _loc1_:ConvoAudioCmdDef = null;
         if(!this.audio || !this.cursor)
         {
            return;
         }
         for each(_loc1_ in this.cursor.audioCmds)
         {
            this.audio.handleCmd(_loc1_);
         }
         this._pendingBlockingAudioEventProcessing = false;
      }
      
      public function isActorVisible(param1:String) : Boolean
      {
         return param1 in this.visibleActors;
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function start() : void
      {
         this.presenceState = SagaPresenceManager.pushNewState(SagaPresenceManager.StateInConversation);
         this.cursor.start();
         this._pendingBlockingAudioEventProcessing = this.cursor.isAudioBlockingInput();
      }
      
      public function next() : void
      {
         if(this.audio && this.audio.isPlayingBlockingAudioEvent() || this._pendingBlockingAudioEventProcessing)
         {
            return;
         }
         this.cursor.next();
         this._pendingBlockingAudioEventProcessing = this.cursor.isAudioBlockingInput();
      }
      
      public function finishSelection() : void
      {
         if(!this._selectedOption)
         {
            throw new IllegalOperationError("Cannot finish selection with no options");
         }
         var _loc1_:String = "cnvn." + this._selectedOption.varString;
         this.vars.setVar(_loc1_,this.vars.getVarInt(_loc1_) + 1);
         this._selectedOption.applyFlags(this.happs,this.vars,this,this.rng);
         this.selectedOption = null;
         var _loc2_:ConvoNodeDef = this.selectedNode;
         this.selectedNode = null;
         if(_loc2_)
         {
            this.cursor.jump(_loc2_);
         }
         else
         {
            this.finish();
         }
      }
      
      public function select(param1:ConvoOptionDef) : void
      {
         if(this.audio && this.audio.isPlayingBlockingAudioEvent() || this._pendingBlockingAudioEventProcessing)
         {
            return;
         }
         if(!this.cursor.options || this.cursor.options.indexOf(param1) < 0)
         {
            throw new ArgumentError("option mismatch");
         }
         this.selectedOption = param1;
         if(!param1.link)
         {
            this.selectedNode = null;
         }
         else
         {
            this.selectedNode = this.def.getNodeDef(param1.link.path);
         }
         dispatchEvent(new ConvoEvent(ConvoEvent.OPTION,this));
      }
      
      public function finish() : void
      {
         if(!this.finished)
         {
            if(this.presenceState)
            {
               this.presenceState.remove();
               this.presenceState = null;
            }
            this.finished = true;
            dispatchEvent(new ConvoEvent(ConvoEvent.FINISHED,this));
         }
      }
      
      public function get readyToFinish() : Boolean
      {
         return this.cursor._node == null;
      }
      
      public function get selectedNode() : ConvoNodeDef
      {
         return this._selectedNode;
      }
      
      public function set selectedNode(param1:ConvoNodeDef) : void
      {
         this._selectedNode = param1;
      }
      
      public function get selectedOption() : ConvoOptionDef
      {
         return this._selectedOption;
      }
      
      public function set selectedOption(param1:ConvoOptionDef) : void
      {
         this._selectedOption = param1;
      }
      
      public function setActorVisible(param1:String, param2:Boolean, param3:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Vector.<String> = null;
         var _loc7_:String = null;
         if(!param1)
         {
            return;
         }
         var _loc4_:String = param2 ? ConvoEvent.SHOW_ACTOR : ConvoEvent.HIDE_ACTOR;
         if(param3)
         {
            this.logger.info("Convo setting actor " + (param2 ? "SHOW" : "HIDE") + ":  [" + param1 + "]");
         }
         if(!this.def.getMarkFromUnit(param1))
         {
            this.logger.error("Convo invalid actor " + (param2 ? "SHOW" : "HIDE") + ":  [" + param1 + "]");
            return;
         }
         if(param2)
         {
            this.visibleActors[param1] = param1;
            _loc5_ = this.def.getMarkFromUnit(param1);
            _loc6_ = this.def.getUnitsFromMark(_loc5_);
            for each(_loc7_ in _loc6_)
            {
               if(_loc7_ != param1)
               {
                  this.setActorVisible(_loc7_,false,param3);
               }
            }
         }
         else
         {
            delete this.visibleActors[param1];
         }
         dispatchEvent(new ConvoEvent(_loc4_,this,param1));
      }
   }
}
