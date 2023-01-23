package engine.saga.convo
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleInfo;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.math.Rng;
   import engine.saga.ISaga;
   import engine.saga.ISagaExpression;
   import engine.saga.convo.def.ConvoConditionsDef;
   import engine.saga.convo.def.ConvoLinkDef;
   import engine.saga.convo.def.ConvoNodeDef;
   import engine.saga.convo.def.ConvoOptionDef;
   import engine.saga.convo.def.audio.ConvoAudioCmdDef;
   import engine.saga.convo.def.audio.ConvoAudioCmdsDef;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableProvider;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class ConvoCursor extends EventDispatcher
   {
      
      public static const EVENT_JUMP:String = "Convo.EVENT_JUMP";
      
      public static var USE_RUNON_INKLE:Boolean = true;
       
      
      public var convo:Convo;
      
      public var text:String = "";
      
      public var _node:ConvoNodeDef;
      
      public var started:Boolean;
      
      public var speaker:IEntityDef;
      
      public var speakerId:String;
      
      public var options:Vector.<ConvoOptionDef>;
      
      public var audioCmds:Vector.<ConvoAudioCmdDef>;
      
      public var camera:String;
      
      public var cameraStageIndex:int;
      
      public var cameraMarkFacing:int;
      
      public var link:ConvoLinkDef;
      
      public var nodeIds:String = "";
      
      public var saga:ISaga;
      
      public var logger:ILogger;
      
      public var vars:IVariableProvider;
      
      public var _skipResolveSpeaker:Boolean;
      
      public var visitFf:Dictionary;
      
      public var suffix:String;
      
      public var WAR_URL:String = "saga1/convo/war/cnv_war.json.z";
      
      public var isFf:Boolean;
      
      private var processed:Vector.<ConvoNodeDef>;
      
      public function ConvoCursor(param1:Convo, param2:ISaga, param3:ILogger)
      {
         this.options = new Vector.<ConvoOptionDef>();
         this.audioCmds = new Vector.<ConvoAudioCmdDef>();
         this.processed = new Vector.<ConvoNodeDef>();
         super();
         this.convo = param1;
         this.saga = param2;
         this.logger = param3;
         this.suffix = param1.suffix;
      }
      
      override public function toString() : String
      {
         return "node=" + this._node;
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "speaker=" + this.speaker + " (id=" + this.speakerId + ")\n";
         _loc1_ += "camera=" + this.camera + "\n";
         _loc1_ += "cameraStageIndex=" + this.cameraStageIndex + "\n";
         return _loc1_ + ("cameraMarkFacing=" + this.cameraMarkFacing + "\n");
      }
      
      public function start() : void
      {
         if(this.started)
         {
            throw new IllegalOperationError("Already started");
         }
         this.started = true;
         var _loc1_:ConvoNodeDef = this.convo.def.nodesById[this.convo.def.initial];
         this.process(_loc1_);
         this.resolveOptions();
         dispatchEvent(new Event(EVENT_JUMP));
      }
      
      private function resolveSpeaker() : void
      {
         if(this._node)
         {
            this.speakerId = this._node.speaker;
            if(!this._skipResolveSpeaker)
            {
               this.speaker = !!this.saga ? this.saga.getCastMember(this.speakerId) : null;
               if(Boolean(this.speakerId) && !this.speaker)
               {
                  this.logger.error("ConvoCursor " + this + " invalid speaker [" + this.speakerId + "]");
               }
            }
         }
         else
         {
            this.speakerId = null;
            this.speaker = null;
         }
      }
      
      private function resolveOptions() : void
      {
         var _loc1_:ISagaExpression = null;
         var _loc2_:IVariableProvider = null;
         var _loc3_:ConvoOptionDef = null;
         var _loc4_:ConvoConditionsDef = null;
         var _loc5_:String = null;
         this.options.splice(0,this.options.length);
         if(this._node)
         {
            _loc1_ = this.convo.expression;
            _loc2_ = this.convo.vars;
            for each(_loc3_ in this._node.options)
            {
               _loc4_ = Boolean(_loc3_.link) && Boolean(_loc3_.link.conditions) ? _loc3_.link.conditions : null;
               _loc5_ = _loc3_.varString;
               if(!_loc4_ || _loc4_.checkConditions(_loc5_,_loc1_,this.logger))
               {
                  if(_loc3_.branch)
                  {
                     this.link = _loc3_.link;
                     return;
                  }
                  this.options.push(_loc3_);
               }
            }
         }
      }
      
      public function ff() : void
      {
         this.isFf = true;
         this.visitFf = new Dictionary();
         this.internalFf();
         this.isFf = false;
         dispatchEvent(new Event(EVENT_JUMP));
      }
      
      public function internalFf() : void
      {
         var _loc1_:ConvoNodeDef = null;
         var _loc3_:int = 0;
         var _loc4_:ConvoOptionDef = null;
         if(!this._node || !this.convo || !this.convo.def)
         {
            return;
         }
         this.visitFf[this._node] = this._node;
         if(Boolean(this.options) && this.options.length > 0)
         {
            _loc3_ = 0;
            if(this.options.length == 5)
            {
               if(this.convo.def.url == this.WAR_URL)
               {
                  _loc3_ = 4;
               }
            }
            _loc4_ = this.options[_loc3_];
            if(!_loc4_)
            {
               return;
            }
            this.convo.select(_loc4_);
            this.convo.finishSelection();
            if(!this.convo.finished)
            {
               this.internalFf();
            }
            return;
         }
         if(this.link)
         {
            _loc1_ = this.convo.def.getNodeDef(this.link.path);
         }
         if(_loc1_ == this._node)
         {
            return;
         }
         var _loc2_:Boolean = Boolean(this.visitFf[_loc1_]);
         this.visitFf[_loc1_] = _loc1_;
         this.jump(_loc1_,true);
         if(_loc2_)
         {
            return;
         }
         this.internalFf();
      }
      
      public function next() : void
      {
         if(!this.started)
         {
            throw new IllegalOperationError("Not started");
         }
         if(!this._node)
         {
            this.logger.error("Failed to next from [" + this + "] convo=[" + this.convo + "]");
            return;
         }
         var _loc1_:ConvoNodeDef = this._node.advanceLink(this.convo,this.link,this.convo.suffix,this.convo.expression,this.logger);
         if(_loc1_ == this.node)
         {
            this.logger.error("Unable to advance node " + _loc1_);
            this.convo.finish();
            return;
         }
         if(_loc1_ == null)
         {
         }
         this.jump(_loc1_);
      }
      
      public function jump(param1:ConvoNodeDef, param2:Boolean = false) : void
      {
         this.audioCmds.splice(0,this.audioCmds.length);
         this.text = "";
         this.nodeIds = "";
         this.camera = null;
         this.cameraStageIndex = 0;
         this.cameraMarkFacing = 0;
         this.link = null;
         this.processed.splice(0,this.processed.length);
         this.process(param1);
         this.resolveOptions();
         if(!param2)
         {
            dispatchEvent(new Event(EVENT_JUMP));
         }
      }
      
      public function reprocess() : void
      {
         var _loc1_:ConvoNodeDef = null;
         this.text = "";
         for each(_loc1_ in this.processed)
         {
            if(this.text)
            {
               if(!_loc1_.runOn)
               {
                  this.text += "\n\n";
               }
               else
               {
                  this.text += " ";
               }
            }
            this.text += this.makeSubstitutions(_loc1_.getText(this.suffix,this.logger));
         }
      }
      
      public function isAudioBlockingInput() : Boolean
      {
         var _loc1_:ConvoAudioCmdDef = null;
         for each(_loc1_ in this.audioCmds)
         {
            if(_loc1_.blockInput)
            {
               return true;
            }
         }
         return false;
      }
      
      private function process(param1:ConvoNodeDef) : void
      {
         var _loc6_:ConvoNodeDef = null;
         var _loc7_:ConvoOptionDef = null;
         var _loc8_:* = null;
         var _loc9_:ConvoNodeDef = null;
         var _loc10_:* = false;
         if(!param1)
         {
            this.node = null;
            return;
         }
         var _loc2_:Boolean = Boolean(this._node) && this._node.runOn;
         var _loc3_:ISagaExpression = this.convo.expression;
         var _loc4_:Boolean = Boolean(param1.conditions) && !param1.conditions.checkConditions(param1.toString(),_loc3_,this.logger);
         if(!_loc4_)
         {
            this.node = param1;
         }
         var _loc5_:Boolean = _loc4_ || param1.skip || param1.isEmptyText;
         if(_loc5_)
         {
            if(param1.options)
            {
               if(!param1.skip)
               {
                  this.node = param1;
                  return;
               }
               for each(_loc7_ in param1.options)
               {
                  if(!_loc7_.link.conditions || _loc7_.link.conditions.checkConditions(_loc7_.toString(),_loc3_,this.logger))
                  {
                     _loc6_ = this.convo.def.getNodeDef(_loc7_.link.path);
                  }
               }
               if(!_loc6_)
               {
                  throw new ArgumentError("Skip node [" + param1 + "] was unable to traverse any options");
               }
            }
            else
            {
               if(!(!this.text || param1.advanceIfSkipped))
               {
                  return;
               }
               _loc6_ = param1.advance(this.convo,this.convo.suffix,this.convo.expression,this.logger);
            }
            if(!_loc6_)
            {
               this.node = null;
               return;
            }
            if(Boolean(_loc6_) && _loc6_ != param1)
            {
               this.process(_loc6_);
               return;
            }
         }
         if(!_loc5_)
         {
            if(Boolean(this.text) && Boolean(this._node))
            {
               if(USE_RUNON_INKLE)
               {
                  if(!_loc2_)
                  {
                     this.text += "\n\n";
                  }
                  else
                  {
                     this.text += " ";
                  }
               }
               else if(!param1.runOn)
               {
                  this.text += "\n\n";
               }
               else
               {
                  this.text += " ";
               }
            }
            _loc8_ = param1.getText(this.suffix,this.logger);
            if(!_loc8_)
            {
               this.logger.error("ConvoCursor.process unable to get text for node " + param1);
               _loc8_ = "[NO TEXT FOR " + param1 + "]";
            }
            this.text += this.makeSubstitutions(_loc8_);
            this.processed.push(param1);
         }
         this.node = param1;
         if(param1 && param1.link && !param1.pageBreak)
         {
            _loc9_ = this.convo.def.nodesById[param1.link.path];
            _loc10_ = param1.runOn && USE_RUNON_INKLE;
            _loc10_ = _loc10_ || param1.joinNext;
            if(!_loc10_)
            {
               _loc10_ = !this.speaker && !_loc9_.speaker;
            }
            if(!_loc10_ && Boolean(_loc9_.conditions))
            {
               _loc10_ = !_loc9_.conditions.checkConditions(_loc9_.toString(),_loc3_,this.logger);
               if(!_loc10_)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("ConvoCursor " + param1 + " not following link " + _loc9_);
                  }
               }
            }
            if(_loc10_)
            {
               this.process(_loc9_);
               return;
            }
         }
      }
      
      public function makeSubstitutions(param1:String) : String
      {
         var _loc2_:String = null;
         while(true)
         {
            _loc2_ = this.makeOneSubstitution(param1);
            if(_loc2_ == param1)
            {
               break;
            }
            param1 = _loc2_;
         }
         return param1;
      }
      
      private function findEndPlace(param1:int, param2:int) : int
      {
         if(param2 >= 0)
         {
            if(param1 < 0 || param1 > param2)
            {
               return param2;
            }
         }
         return param1;
      }
      
      public function makeOneSubstitution(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc8_:String = null;
         var _loc9_:Locale = null;
         var _loc10_:LocaleInfo = null;
         if(!param1)
         {
            return param1;
         }
         var _loc2_:int = param1.indexOf("$");
         if(_loc2_ < 0)
         {
            return param1;
         }
         var _loc4_:int = -1;
         if(param1.charAt(_loc2_ + 1) == "{")
         {
            _loc4_ = param1.indexOf("}",_loc2_ + 2);
            if(_loc4_ < 0)
            {
               this.logger.error("No terminator for subst var at [" + param1.substring(_loc2_) + "]");
               return param1;
            }
            _loc3_ = param1.substring(_loc2_ + 2,_loc4_);
            _loc4_++;
         }
         if(!_loc3_)
         {
            for each(_loc8_ in LocaleInfo.terminators_en)
            {
               _loc4_ = this.findEndPlace(_loc4_,param1.indexOf(_loc8_,_loc2_));
            }
            _loc9_ = !!this.saga ? this.saga.locale : null;
            _loc10_ = !!_loc9_ ? _loc9_.info : null;
            if(Boolean(_loc10_) && Boolean(_loc10_.terminators))
            {
               for each(_loc8_ in _loc10_.terminators)
               {
                  _loc4_ = this.findEndPlace(_loc4_,param1.indexOf(_loc8_,_loc2_));
               }
            }
            if(_loc4_ < 0)
            {
               _loc3_ = param1.substring(_loc2_ + 1);
            }
            else
            {
               _loc3_ = param1.substring(_loc2_ + 1,_loc4_);
            }
         }
         var _loc5_:* = "**" + _loc3_ + "**";
         var _loc6_:IVariable = this.convo.vars.getVar(_loc3_,null);
         if(_loc6_)
         {
            _loc5_ = _loc6_.value;
         }
         var _loc7_:String = param1.substring(0,_loc2_) + _loc5_;
         if(_loc4_ > _loc2_)
         {
            _loc7_ += param1.substring(_loc4_);
         }
         return _loc7_;
      }
      
      private function set node(param1:ConvoNodeDef) : void
      {
         var expression:ISagaExpression;
         var failConditional:Boolean = false;
         var rng:Rng = null;
         var cmds:ConvoAudioCmdsDef = null;
         var cmd:ConvoAudioCmdDef = null;
         var value:ConvoNodeDef = param1;
         if(value == this._node)
         {
            return;
         }
         expression = this.convo.expression;
         if(this._node)
         {
            failConditional = Boolean(this._node.conditions) && !this.node.conditions.checkConditions(this._node.toString(),expression,this.logger);
            if(!failConditional)
            {
               rng = !!this.saga ? this.saga.rng : null;
               try
               {
                  this._node.applyFlags(this.convo.happs,this.convo.vars,this.convo,rng);
               }
               catch(e:Error)
               {
                  logger.error("Failed to apply flags to node " + _node + "\n" + e.getStackTrace());
               }
            }
         }
         this._node = value;
         if(this._node)
         {
            this.nodeIds += this._node.id + ".";
            failConditional = Boolean(this._node.conditions) && !this.node.conditions.checkConditions(this._node.toString(),expression,this.logger);
            if(!failConditional)
            {
               this.camera = this._node.camera;
               this.link = this._node.link;
               this.cameraMarkFacing = this._node.cameraMarkFacing;
               this.cameraStageIndex = this._node.cameraStageIndex;
               this.resolveSpeaker();
               if(Boolean(this.convo.audio) && Boolean(this.convo.audio.def))
               {
                  cmds = this.convo.audio.def.getCmdsByStitchOption(this._node.id,-1);
                  if(cmds)
                  {
                     for each(cmd in cmds.cmds)
                     {
                        this.audioCmds.push(cmd);
                     }
                  }
               }
            }
         }
      }
      
      private function get node() : ConvoNodeDef
      {
         return this._node;
      }
      
      public function get hasOptions() : Boolean
      {
         return Boolean(this.options) && this.options.length > 0;
      }
   }
}
