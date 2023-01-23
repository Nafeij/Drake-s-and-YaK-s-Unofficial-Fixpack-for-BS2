package engine.saga.happening
{
   import engine.core.logging.ILogger;
   import engine.saga.ISagaSound;
   import engine.saga.Saga;
   import engine.saga.SagaTriggerDef;
   import engine.saga.action.Action;
   import engine.saga.action.ActionDef;
   import engine.saga.action.BaseAction_Sound;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.def.ISoundDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class Happening extends EventDispatcher implements IHappening, ISoundDefBundleListener
   {
       
      
      public var def:HappeningDef;
      
      public var index:int = -1;
      
      public var action:Action;
      
      public var saga:Saga;
      
      public var ended:Boolean;
      
      private var soundBundle:ISoundDefBundle;
      
      private var _hasRandomized:Boolean;
      
      private var _executing:Boolean;
      
      private var _prereqReason:Array;
      
      public function Happening(param1:Saga, param2:HappeningDef, param3:*)
      {
         this._prereqReason = [""];
         super();
         this.def = param2;
         this.saga = param1;
         param1.slog.appendItemStart(this,param3);
         param1.logger.i("SAGA","   *>  HAPPENING START " + this);
         this.preloadHappeningSounds();
      }
      
      private function preloadHappeningSounds() : void
      {
         var _loc3_:Vector.<ISoundDef> = null;
         var _loc4_:ActionDef = null;
         var _loc1_:ISagaSound = this.saga.sound;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:int = !!_loc3_ ? _loc3_.length : 0;
         for each(_loc4_ in this.def.actions)
         {
            if(_loc4_.enabled)
            {
               _loc3_ = BaseAction_Sound.getSoundDefsForActionDef(_loc4_,this.saga.sound,_loc3_);
            }
         }
         if(_loc3_)
         {
            if(this.saga.logger.isDebugEnabled)
            {
               this.saga.logger.debug("Happening PRELOAD Sound Bundle Defs " + _loc3_.join(", "));
            }
            this.soundBundle = _loc1_.system.driver.preloadSoundDefData("happening:" + this.def.id,_loc3_);
            this.soundBundle.addListener(this);
         }
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
      }
      
      override public function toString() : String
      {
         return !!this.def ? this.def.toString() : "null";
      }
      
      public function end(param1:Boolean) : void
      {
         this.saga.slog.appendItemEnd(this);
         this.saga.logger.i("SAGA","   <*  happening end " + this);
         this.ended = true;
         if(Boolean(this.action) && !this.action.ended)
         {
            this.action.end(param1);
            this.action = null;
         }
         if(this.soundBundle)
         {
            this.soundBundle.removeListener(this);
            this.soundBundle = null;
         }
         if(!this.saga._endingAllHappenings)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function selectRandomAction() : Action
      {
         var _loc4_:ActionDef = null;
         var _loc7_:Number = NaN;
         var _loc8_:Object = null;
         var _loc1_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:Number = 0;
         _loc1_ = 0;
         while(_loc1_ < this.def.actions.length)
         {
            _loc4_ = this.def.actions[_loc1_];
            if(_loc4_.enabled)
            {
               if(_loc4_.checkPrereqs(this.saga,null))
               {
                  _loc7_ = _loc4_.computeWeight(this.saga);
                  _loc3_ += _loc7_;
                  _loc2_.push({
                     "ad":_loc4_,
                     "tw":_loc3_
                  });
               }
            }
            _loc1_++;
         }
         var _loc5_:Number = this.saga.rng.nextNumber() * _loc3_;
         var _loc6_:Number = 0;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc8_ = _loc2_[_loc1_];
            _loc6_ = Number(_loc8_.tw);
            if(_loc6_ >= _loc5_)
            {
               _loc4_ = _loc8_.ad;
               return Action.factory(_loc4_,this.saga,this,null);
            }
            _loc1_++;
         }
         return null;
      }
      
      public function execute() : void
      {
         if(this._executing || this.ended || this.saga._endingAllHappenings)
         {
            return;
         }
         this._executing = true;
         try
         {
            while(!this.ended && (!this.action || this.action.ended))
            {
               this.next();
            }
         }
         catch(e:Error)
         {
            saga.logger.error("Failed to execute " + this + "\n" + e.getStackTrace());
            _executing = false;
            end(true);
         }
         this._executing = false;
      }
      
      private function next() : void
      {
         var ad:ActionDef;
         if(this.ended)
         {
            return;
         }
         this.action = null;
         if(this.def.random)
         {
            if(!this._hasRandomized)
            {
               this._hasRandomized = true;
               this.action = this.selectRandomAction();
               if(this.action)
               {
                  this.action.happening = this;
                  this.saga.actions.push(this.action);
                  this.action.start();
                  return;
               }
            }
            this.end(false);
            return;
         }
         ++this.index;
         if(this.index >= this.def.actions.length)
         {
            if(this.def.keepalive)
            {
               return;
            }
            this.end(false);
            return;
         }
         ad = this.def.actions[this.index];
         if(!ad.enabled)
         {
            if(this.saga.logger.isDebugEnabled)
            {
               this.saga.logger.debug("   *>> HAPPENING SKIP " + this + " action=[" + ad + "] disabled");
            }
            return;
         }
         if(!ad.checkPrereqs(this.saga,this._prereqReason))
         {
            if(this.saga.logger.isDebugEnabled)
            {
               this.saga.logger.debug("   *>> HAPPENING SKIP " + this + " action=[" + ad + "] prereq " + this._prereqReason[0]);
            }
            return;
         }
         try
         {
            this.action = Action.factory(ad,this.saga,this,null);
            this.action.happening = this;
            this.saga.actions.push(this.action);
            this.action.start();
         }
         catch(error:Error)
         {
            saga.logger.error("   *** HAPPENING NEXT ERROR " + error.getStackTrace());
         }
      }
      
      public function handleActionEnd(param1:Action) : void
      {
         if(this.ended)
         {
            return;
         }
         if(param1 != this.action)
         {
            return;
         }
         if(this.action.ended)
         {
            this.action = null;
         }
      }
      
      public function debugPrintLog(param1:ILogger) : void
      {
         var _loc2_:SagaTriggerDef = null;
         param1.i("SAGA","*** Happening [" + this.def.id + "] in [" + this.def.bag.providerName + "]");
         param1.i("SAGA","      Action: " + this.action);
         if(Boolean(this.def.triggers) && this.def.triggers.list.length > 0)
         {
            param1.i("SAGA","    Triggers: ");
            for each(_loc2_ in this.def.triggers.list)
            {
               param1.i("SAGA","              " + _loc2_);
            }
         }
         param1.i("SAGA","--------------------------------------------------------------");
      }
      
      public function get isEnded() : Boolean
      {
         return this.ended;
      }
      
      public function get isTranscendent() : Boolean
      {
         return Boolean(this.def) && this.def.transcendent;
      }
   }
}
