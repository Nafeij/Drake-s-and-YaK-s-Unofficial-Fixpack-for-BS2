package game.cfg
{
   import engine.core.fsm.FsmEvent;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.Enum;
   import engine.session.Alert;
   import engine.session.AlertEvent;
   import engine.session.AlertOrientationType;
   import engine.session.AlertStyleType;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import game.gui.page.VsMonitorTypeEntry;
   import game.session.GameFsm;
   import game.session.actions.VsType;
   import game.session.states.ProvingGroundsState;
   import game.session.states.SceneLoadState;
   import game.session.states.SceneState;
   import game.session.states.VersusFindMatchState;
   import game.session.states.VersusMatchedState;
   
   public class VsMonitor
   {
       
      
      public var entriesByVsType:Dictionary;
      
      public var factions:FactionsConfig;
      
      private var lastFsmClazz:Class;
      
      private var okBattleStr_tok:String = "match_go_proving_grounds";
      
      private var okProvingGroundsStr_tok:String = "match_go_battle";
      
      public function VsMonitor(param1:FactionsConfig)
      {
         this.entriesByVsType = new Dictionary();
         super();
         this.factions = param1;
         param1.legend.party.addEventListener(Event.CHANGE,this.partyChangeHandler);
         param1.config.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         this.addType(VsType.QUICK);
         this.addType(VsType.RANKED);
         this.addType(VsType.TOURNEY);
      }
      
      private static function getAlertMsg(param1:VsMonitorTypeEntry, param2:int, param3:int, param4:VsType, param5:Locale) : String
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(param4 != param1.type)
         {
            param3 = 0;
         }
         var _loc6_:* = param5.translate(LocaleCategory.GUI,"at_power") + " ";
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         while(_loc8_ < param1.powers.length)
         {
            _loc9_ = int(param1.powers[_loc8_]);
            _loc10_ = param1.getCount(_loc9_);
            if(_loc9_ == param3 && _loc10_ < 2)
            {
               _loc8_ = _loc8_;
            }
            else
            {
               if(_loc7_ > 0)
               {
                  _loc6_ += ", ";
               }
               if(param2 == _loc9_)
               {
                  _loc6_ += "<u>" + _loc9_ + "</u>";
               }
               else
               {
                  _loc6_ += _loc9_;
               }
               _loc7_++;
            }
            _loc8_++;
         }
         return _loc6_ + ".";
      }
      
      private static function getAlertName(param1:VsType, param2:Locale) : String
      {
         switch(param1)
         {
            case VsType.QUICK:
               return param2.translate(LocaleCategory.GUI,"match_available_quick");
            case VsType.RANKED:
               return param2.translate(LocaleCategory.GUI,"match_available_ranked");
            case VsType.TOURNEY:
               return param2.translate(LocaleCategory.GUI,"match_available_tourney");
            default:
               return null;
         }
      }
      
      private static function getAlertStyleType(param1:VsType) : AlertStyleType
      {
         switch(param1)
         {
            case VsType.QUICK:
               return AlertStyleType.VS_QUICK;
            case VsType.RANKED:
               return AlertStyleType.VS_RANKED;
            case VsType.TOURNEY:
               return AlertStyleType.VS_TOURNEY;
            default:
               return null;
         }
      }
      
      private static function getVsTypeFromAlertStyleType(param1:AlertStyleType) : VsType
      {
         switch(param1)
         {
            case AlertStyleType.VS_QUICK:
               return VsType.QUICK;
            case AlertStyleType.VS_RANKED:
               return VsType.RANKED;
            case AlertStyleType.VS_TOURNEY:
               return VsType.TOURNEY;
            default:
               return null;
         }
      }
      
      private function partyChangeHandler(param1:Event) : void
      {
         this.updateAll();
      }
      
      private function fsmCurrentHandler(param1:FsmEvent) : void
      {
         if(this.lastFsmClazz != VersusFindMatchState)
         {
         }
         this.lastFsmClazz = this.factions.config.fsm.currentClass;
         this.factions.config.guiAlerts.updateVsCanUse(this.canUse);
      }
      
      private function updateAll() : void
      {
         var _loc1_:VsMonitorTypeEntry = null;
         for each(_loc1_ in this.entriesByVsType)
         {
            this.updateAlert(_loc1_);
         }
      }
      
      private function addType(param1:VsType) : void
      {
         this.entriesByVsType[param1] = new VsMonitorTypeEntry(param1);
      }
      
      public function cleanup() : void
      {
         this.factions.legend.party.removeEventListener(Event.CHANGE,this.partyChangeHandler);
         this.factions.config.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
      }
      
      public function setPlayerQueuePower(param1:VsType, param2:int) : void
      {
         var _loc3_:VsMonitorTypeEntry = null;
         for each(_loc3_ in this.entriesByVsType)
         {
            if(_loc3_.type == param1)
            {
               _loc3_.playerQueuePower = param2;
            }
            else
            {
               _loc3_.playerQueuePower = 0;
            }
         }
         this.updateAll();
      }
      
      public function debugUpdateEnry(param1:String, param2:String, param3:String) : void
      {
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:Array = null;
         var _loc11_:String = null;
         var _loc4_:VsType = Enum.parse(VsType,param1) as VsType;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         if(param2)
         {
            _loc8_ = param2.split(",");
            for each(_loc9_ in _loc8_)
            {
               _loc5_.push(int(_loc9_));
            }
         }
         if(param3)
         {
            _loc10_ = param3.split(",");
            for each(_loc11_ in _loc10_)
            {
               _loc6_.push(int(_loc11_));
            }
         }
         var _loc7_:int = int(_loc6_.length);
         while(_loc7_ < _loc5_.length)
         {
            _loc6_.push(1);
            _loc7_++;
         }
         this.updateEntry(_loc4_,_loc5_,_loc6_);
      }
      
      public function updateEntry(param1:VsType, param2:Array, param3:Array) : void
      {
         var _loc4_:VsMonitorTypeEntry = this.entriesByVsType[param1];
         if(!_loc4_.setPowers(param2,param3))
         {
            return;
         }
         this.updateAlert(_loc4_);
      }
      
      private function updateAlert(param1:VsMonitorTypeEntry) : void
      {
         var _loc6_:VsType = null;
         var _loc7_:Boolean = false;
         var _loc2_:AlertStyleType = getAlertStyleType(param1.type);
         var _loc3_:Alert = this.factions.config.alerts.getAlertByStyle(_loc2_);
         if(param1.powers.length == 0)
         {
            if(_loc3_)
            {
               _loc3_.removeEventListener(AlertEvent.ALERT_RESPONSE,this.alertResponseHandler);
               this.factions.config.alerts.removeAlert(_loc3_);
            }
            return;
         }
         var _loc4_:VersusFindMatchState = this.factions.config.fsm.current as VersusFindMatchState;
         var _loc5_:int = 0;
         if(_loc4_)
         {
            _loc5_ = _loc4_.vs_power;
            _loc6_ = _loc4_.vs_type;
            if(param1.hasOnePower(_loc5_) && param1.getCount(_loc5_) < 2)
            {
               if(_loc3_)
               {
                  _loc3_.removeEventListener(AlertEvent.ALERT_RESPONSE,this.alertResponseHandler);
                  this.factions.config.alerts.removeAlert(_loc3_);
               }
               return;
            }
         }
         if(!_loc3_)
         {
            _loc7_ = true;
            _loc3_ = new Alert();
            _loc3_.removeOnResponse = false;
            _loc3_.addEventListener(AlertEvent.ALERT_RESPONSE,this.alertResponseHandler);
         }
         var _loc8_:Locale = this.factions.config.context.locale;
         var _loc9_:int = this.factions.config.legend.party.totalPower;
         _loc3_.sender_display_name = getAlertName(param1.type,_loc8_);
         _loc3_.msg = getAlertMsg(param1,_loc9_,_loc5_,_loc6_,this.factions.config.context.locale);
         _loc3_.style = _loc2_;
         _loc3_.orientation = AlertOrientationType.RIGHT_BOTTOM_VS;
         var _loc10_:* = this.factions.config.legend.party.numMembers == 6;
         if(param1.hasPower(_loc9_) && _loc10_ && _loc6_ != param1.type)
         {
            _loc3_.okColor = 9563772;
            _loc3_.okMsg = _loc8_.translate(LocaleCategory.GUI,this.okBattleStr_tok);
         }
         else
         {
            _loc3_.okColor = 6597865;
            _loc3_.okMsg = _loc8_.translate(LocaleCategory.GUI,this.okProvingGroundsStr_tok);
         }
         if(_loc7_)
         {
            this.factions.config.alerts.addAlert(_loc3_);
         }
         else
         {
            _loc3_.notifyChanged();
         }
      }
      
      public function get canUse() : Boolean
      {
         var _loc1_:SceneState = this.factions.config.fsm.current as SceneState;
         if(this.factions.config.fsm.currentClass == VersusMatchedState)
         {
            return false;
         }
         if(this.factions.config.fsm.currentClass == SceneLoadState)
         {
            return false;
         }
         if(_loc1_)
         {
            if(Boolean(_loc1_.battleHandler) && Boolean(_loc1_.battleHandler.fsm))
            {
               return false;
            }
         }
         return true;
      }
      
      private function alertResponseHandler(param1:AlertEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:VsType = null;
         if(!this.canUse)
         {
            return;
         }
         var _loc2_:GameFsm = this.factions.config.fsm;
         if(param1.alert.response == Alert.RESPONSE_OK)
         {
            _loc3_ = this.factions.context.locale.translate(LocaleCategory.GUI,this.okBattleStr_tok);
            if(param1.alert.okMsg == _loc3_)
            {
               _loc4_ = getVsTypeFromAlertStyleType(param1.alert.style);
               VersusFindMatchState.restartFind(_loc4_,this.factions.config);
            }
            else if(_loc2_.currentClass != ProvingGroundsState)
            {
               _loc2_.transitionTo(ProvingGroundsState,_loc2_.current.data);
            }
         }
      }
   }
}
