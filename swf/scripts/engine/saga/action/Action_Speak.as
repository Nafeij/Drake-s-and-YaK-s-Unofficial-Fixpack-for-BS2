package engine.saga.action
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.saga.Saga;
   import engine.saga.SagaLegend;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Action_Speak extends Action
   {
       
      
      private var t:Timer;
      
      private var direction:String;
      
      private var camera:Boolean;
      
      private var instant:Boolean;
      
      private var offsetX:int;
      
      private var offsetY:int;
      
      private var notranslate:Boolean;
      
      private var allcast:Boolean;
      
      private var races:String;
      
      public function Action_Speak(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleEnded() : void
      {
         if(this.t)
         {
            this.t.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
            this.t.stop();
            this.t = null;
         }
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:IEntityDef = null;
         var _loc2_:IBattleEntity = null;
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:BattleBoardView = null;
         super.handleStarted();
         if(!def.msg)
         {
            end();
            return;
         }
         this._processParams();
         if(def.speaker)
         {
            if(saga.getBattleBoard())
            {
               if(!this.races)
               {
                  this.races = "human,varl,horseborn";
               }
               _loc2_ = super.findBattleEntityFromList(def.speaker,true,this.races);
               if(_loc2_)
               {
                  _loc1_ = _loc2_.def;
               }
            }
            if(!_loc1_)
            {
               _loc1_ = this._getRosterCastMemberFromList(def.speaker,this.allcast);
            }
            if(!_loc1_)
            {
               logger.info("Unknown roster member [" + def.speaker + "] for " + this);
               end();
               return;
            }
            _loc7_ = _loc1_.entityClass.race;
            if(def.speaker == "*player" && !(_loc7_ == "human" || _loc7_ == "varl" || _loc7_ == "horseborn"))
            {
               logger.info("No valid roster members for \'*player\' for " + this);
               end();
               return;
            }
         }
         var _loc3_:String = def.msg;
         var _loc4_:Boolean = Boolean(_loc3_) && _loc3_.charAt(0) == "$";
         if(_loc4_)
         {
            _loc9_ = saga.convoNodeIdSuffix;
            if(_loc9_)
            {
               _loc8_ = _loc3_ + _loc9_;
            }
            if(_loc8_)
            {
               _loc5_ = translateMsg(_loc8_,true);
            }
            if(!_loc5_)
            {
               _loc5_ = translateMsg(_loc3_);
            }
         }
         else
         {
            _loc5_ = _loc3_;
         }
         _loc5_ = saga.performStringReplacement_SagaVar(_loc5_);
         var _loc6_:Number = def.time;
         saga.performSpeak(_loc2_,_loc1_,_loc5_,_loc6_,def.anchor,this.direction,this.notranslate);
         if(this.camera)
         {
            _loc10_ = BattleBoardView.instance;
            if(Boolean(_loc10_) && Boolean(_loc2_))
            {
               _loc10_.cameraCenterOnEntity(_loc2_,this.instant,this.offsetX,this.offsetY);
            }
         }
         if(!Action_Wait.DISABLE && !def.instant && def.time > 0)
         {
            this.t = new Timer(def.time * 1000,1);
            this.t.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
            this.t.start();
         }
         else
         {
            this.timerCompleteHandler(null);
         }
      }
      
      private function _processParams() : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc1_:String = def.param;
         var _loc2_:Array = !!_loc1_ ? _loc1_.split(" ") : [];
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_ == "right")
            {
               this.direction = "right";
            }
            else if(_loc3_ == "left")
            {
               this.direction = "left";
            }
            else if(_loc3_ == "instant")
            {
               this.instant = true;
            }
            else if(_loc3_ == "allcast")
            {
               this.allcast = true;
            }
            else if(_loc3_.indexOf("camera") == 0)
            {
               this.camera = true;
               if(_loc3_.indexOf("camera=") == 0)
               {
                  _loc4_ = _loc3_.substr("camera=".length);
                  if(_loc4_)
                  {
                     _loc5_ = _loc4_.split(",");
                     if(_loc5_)
                     {
                        if(_loc5_.length != 2)
                        {
                           throw new ArgumentError("Invalid camera point [" + _loc3_ + "] in param [" + _loc1_ + "]: " + this);
                        }
                        this.offsetX = int(_loc5_[0]);
                        this.offsetY = int(_loc5_[1]);
                     }
                  }
               }
            }
            else if(_loc3_ == "notranslate")
            {
               this.notranslate = true;
            }
            else
            {
               if(_loc3_ != "races")
               {
                  throw new ArgumentError("Invalid arg [" + _loc3_ + "] in param [" + _loc1_ + "]: " + this);
               }
               if(_loc3_.indexOf("races=") == 0)
               {
                  this.races = _loc3_.substr("races=".length);
               }
            }
         }
      }
      
      private function _getRosterCastMemberFromList(param1:String, param2:Boolean) : IEntityDef
      {
         var _loc6_:String = null;
         var _loc7_:IEntityDef = null;
         var _loc3_:SagaLegend = !!saga.caravan ? saga.caravan._legend : null;
         var _loc4_:IEntityListDef = !!_loc3_ ? _loc3_.roster : null;
         if(!_loc4_)
         {
            return null;
         }
         var _loc5_:Array = param1.split(",");
         for each(_loc6_ in _loc5_)
         {
            _loc7_ = saga.getCastMember(def.speaker);
            if(_loc7_)
            {
               if(param2 || Boolean(_loc4_.getEntityDefById(_loc7_.id)))
               {
                  return _loc7_;
               }
            }
         }
         return null;
      }
      
      private function timerCompleteHandler(param1:TimerEvent) : void
      {
         if(this.t)
         {
            this.t.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
            this.t.stop();
            this.t = null;
         }
         end();
      }
      
      override public function fastForward() : Boolean
      {
         if(!ended && !def.instant)
         {
            end(true);
            return true;
         }
         return false;
      }
   }
}
