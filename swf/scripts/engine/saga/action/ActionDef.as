package engine.saga.action
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.expression.exp.Exp;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.RenameVariableInfo;
   import engine.saga.vars.IVariableProvider;
   import engine.saga.vars.VariableKey;
   import flash.utils.Dictionary;
   
   public class ActionDef
   {
      
      private static var propsByType:Dictionary = null;
      
      private static var propsDictByType:Dictionary = null;
       
      
      public var type:ActionType;
      
      public var prereqs:Vector.<VariableKey>;
      
      public var weights:Vector.<VariableKey>;
      
      public var url:String;
      
      public var scene:String;
      
      public var varname:String;
      
      public var varvalue:Number = 0;
      
      public var varother:String;
      
      public var id:String;
      
      public var enabled:Boolean = true;
      
      public var msg:String;
      
      public var anchor:String;
      
      public var time:Number = 0;
      
      public var location:String;
      
      public var instant:Boolean;
      
      public var happeningId:String;
      
      public var param:String;
      
      public var also_party:Boolean;
      
      public var restore_scene:Boolean = true;
      
      public var speaker:String;
      
      public var bucket:String;
      
      public var spawn_tags:String;
      
      public var board_id:String;
      
      public var suppress_flytext:Boolean;
      
      public var assemble_heroes:Boolean = true;
      
      public var loops:int = 0;
      
      public var frame:int = 0;
      
      public var battle_vitalities:String;
      
      public var battle_snap:String;
      
      public var battle_skip_finished:Boolean;
      
      public var battle_music:String;
      
      public var battle_music_override:Boolean;
      
      public var subtitle:String;
      
      public var makesave:Boolean;
      
      public var makesaveId:String;
      
      public var appearance:int;
      
      public var expression:String;
      
      public var prereq:String;
      
      public var exp_prereq:Exp;
      
      public var exp_expression:Exp;
      
      public var poppening_top:int;
      
      public var battle_scenario_id:String;
      
      public var war:Boolean;
      
      public var bucket_quota:int;
      
      public var battle_sparring:Boolean;
      
      public var sound_volume:Number = 1;
      
      public var parentHappeningDef:HappeningDef;
      
      public function ActionDef(param1:HappeningDef)
      {
         this.type = ActionType.NONE;
         super();
         this.parentHappeningDef = param1;
      }
      
      public static function hasPropByType(param1:ActionType, param2:String) : Boolean
      {
         var _loc3_:Array = getPropsByType(param1);
         return Boolean(_loc3_) && _loc3_.indexOf(param2) >= 0;
      }
      
      public static function getPropsByType(param1:ActionType) : Array
      {
         var _loc3_:Object = null;
         var _loc4_:ActionType = null;
         var _loc5_:Array = null;
         var _loc6_:Dictionary = null;
         var _loc7_:String = null;
         if(!propsByType)
         {
            propsByType = new Dictionary();
            propsByType[ActionType.BATTLE] = ["scene","happeningId","restore_scene","bucket","spawn_tags","board_id","assemble_heroes","battle_vitalities","battle_skip_finished","battle_scenario_id","battle_music","battle_music_override"];
            propsByType[ActionType.BATTLE_ITEMS_DISABLED] = ["varvalue"];
            propsByType[ActionType.BATTLE_WALKABLE] = ["anchor","varvalue","param"];
            propsByType[ActionType.WAR] = ["scene","happeningId","restore_scene","bucket","spawn_tags","board_id","url","poppening_top","battle_music","battle_music_override"];
            propsByType[ActionType.CAMP] = ["scene","happeningId","location","restore_scene","param"];
            propsByType[ActionType.CARAVAN] = ["id"];
            propsByType[ActionType.CONVO] = ["url","scene","restore_scene","poppening_top"];
            propsByType[ActionType.DECAMP] = ["restore_scene"];
            propsByType[ActionType.HALT] = ["location","varvalue","param"];
            propsByType[ActionType.HAPPENING] = ["happeningId","makesave","makesaveId"];
            propsByType[ActionType.HAPPENING_STOP] = ["happeningId"];
            propsByType[ActionType.BOOKMARK] = ["happeningId"];
            propsByType[ActionType.KILL] = ["id"];
            propsByType[ActionType.ANNIHILATE] = ["id"];
            propsByType[ActionType.NONE] = [];
            propsByType[ActionType.PARTY_ADD] = ["id","param"];
            propsByType[ActionType.PARTY_REMOVE] = ["id"];
            propsByType[ActionType.POPUP] = ["url","poppening_top","war"];
            propsByType[ActionType.ROSTER_ADD] = ["id","also_party","param"];
            propsByType[ActionType.ROSTER_REMOVE] = ["id"];
            propsByType[ActionType.ROSTER_CLEAR] = [];
            propsByType[ActionType.SCENE] = ["scene","happeningId"];
            propsByType[ActionType.SPEAK] = ["speaker","msg","time","anchor","param"];
            propsByType[ActionType.TOWN] = [];
            propsByType[ActionType.TRAVEL] = ["location","scene","happeningId","param"];
            propsByType[ActionType.VARIABLE_MODIFY] = ["varname","varvalue","varother","suppress_flytext","param"];
            propsByType[ActionType.VARIABLE_SET] = ["varname","varvalue","varother","suppress_flytext","param","expression"];
            propsByType[ActionType.VARIABLE_TWEEN] = ["varname","varvalue","varother","suppress_flytext","param","time"];
            propsByType[ActionType.VIDEO] = ["url","subtitle","param"];
            propsByType[ActionType.WAIT] = ["time"];
            propsByType[ActionType.WAIT_PAGE] = ["id"];
            propsByType[ActionType.WAIT_OPTIONS_SHOWING] = ["varvalue"];
            propsByType[ActionType.WAIT_CLICK] = ["id","param"];
            propsByType[ActionType.WAIT_MAP_INFO] = ["id"];
            propsByType[ActionType.SOUND_PLAY] = ["id","param","varvalue"];
            propsByType[ActionType.SOUND_PLAY_EVENT] = ["id","param","varvalue","scene","location"];
            propsByType[ActionType.SOUND_PLAY_SCENE] = ["id"];
            propsByType[ActionType.SOUND_STOP] = ["id"];
            propsByType[ActionType.SOUND_PARAM] = ["id","param","varvalue"];
            propsByType[ActionType.SOUND_PARAM_EVENT] = ["id","param","varvalue"];
            propsByType[ActionType.ENABLE_LAYER] = ["id","varvalue"];
            propsByType[ActionType.ENABLE_SPRITE] = ["id","varvalue","time"];
            propsByType[ActionType.ENABLE_CLICKABLE] = ["id","varvalue","expression"];
            propsByType[ActionType.SHOW_CARAVAN] = ["varvalue"];
            propsByType[ActionType.CAMP_MAP] = ["restore_scene","happeningId","anchor","id","varvalue","param"];
            propsByType[ActionType.FLASH_PAGE] = ["url","time","msg","param"];
            propsByType[ActionType.MUSIC_START] = ["id","param","varvalue"];
            propsByType[ActionType.MUSIC_STOP] = ["id","varvalue"];
            propsByType[ActionType.MUSIC_PARAM] = ["id","param","varvalue"];
            propsByType[ActionType.MUSIC_ONESHOT] = ["id","param","varvalue"];
            propsByType[ActionType.MUSIC_OUTRO] = ["id"];
            propsByType[ActionType.VO] = ["id","param","varvalue","subtitle"];
            propsByType[ActionType.ANIM_PLAY] = ["id","frame","loops"];
            propsByType[ActionType.ANIM_PATH_START] = ["id"];
            propsByType[ActionType.WAIT_READY] = [];
            propsByType[ActionType.WAIT_TRAVEL_FALL_COMPLETE] = [];
            propsByType[ActionType.WAIT_VARIABLE_INCREMENT] = ["id","varvalue"];
            propsByType[ActionType.WAIT_SCENE_VISIBLE] = [];
            propsByType[ActionType.WAIT_BATTLE_SETUP] = [];
            propsByType[ActionType.PARTY_CLEAR] = ["param"];
            propsByType[ActionType.CAMERA_PAN] = ["anchor","varvalue"];
            propsByType[ActionType.CAMERA_SPLINE] = ["id","varvalue","time"];
            propsByType[ActionType.CAMERA_SPLINE_PAUSE] = ["varvalue"];
            propsByType[ActionType.CAMERA_CARAVAN_LOCK] = ["varvalue"];
            propsByType[ActionType.CAMERA_GLOBAL_LOCK] = ["varvalue"];
            propsByType[ActionType.CAMERA_ZOOM] = ["varvalue","time"];
            propsByType[ActionType.CAMERA_CARAVAN_ANCHOR] = ["varvalue"];
            propsByType[ActionType.ITEM_ADD] = ["id","speaker","suppress_flytext"];
            propsByType[ActionType.ITEM_REMOVE] = ["id","param"];
            propsByType[ActionType.ITEM_ALL] = [];
            propsByType[ActionType.MARKET_RESET_ITEMS] = [];
            propsByType[ActionType.SAVE_STORE] = ["id","happeningId"];
            propsByType[ActionType.SAVE_LOAD] = ["id"];
            propsByType[ActionType.SAVE_LOAD_MOST_RECENT] = [];
            propsByType[ActionType.SAVE_LOAD_SHOW_GUI] = ["varvalue","param"];
            propsByType[ActionType.DRIVING_SPEED] = ["varvalue"];
            propsByType[ActionType.MAP_SPLINE] = ["id","anchor","varvalue","time"];
            propsByType[ActionType.LEADER] = ["id"];
            propsByType[ActionType.ACHIEVEMENT] = ["id"];
            propsByType[ActionType.UNIT_KILL_ADD] = ["id","varvalue"];
            propsByType[ActionType.UNIT_ABILITY_ADD] = ["id","param","varvalue","anchor"];
            propsByType[ActionType.UNIT_ABILITY_REMOVE] = ["id","param"];
            propsByType[ActionType.UNIT_ABILITY_ENABLED] = ["id","param","varvalue"];
            propsByType[ActionType.UNIT_PASSIVE_ENABLED] = ["id","param","varvalue"];
            propsByType[ActionType.UNIT_INJURE] = ["id"];
            propsByType[ActionType.UNIT_UNINJURE] = ["id"];
            propsByType[ActionType.UNIT_STAT] = ["id","param","varvalue"];
            propsByType[ActionType.UNIT_APPEARANCE] = ["id","varvalue"];
            propsByType[ActionType.END_CREDITS] = [];
            propsByType[ActionType.END_CREDITS_WAITABLE] = ["id","varvalue","url"];
            propsByType[ActionType.GA_EVENT] = ["id","param","location","varvalue","varother"];
            propsByType[ActionType.GA_PAGE] = ["id"];
            propsByType[ActionType.GMA_EVENT] = ["id","varvalue"];
            propsByType[ActionType.WIPE_IN_CONFIG] = ["time","varvalue"];
            propsByType[ActionType.START_PAGE] = ["varvalue"];
            propsByType[ActionType.CARAVAN_MERGE] = ["id","speaker","param"];
            propsByType[ActionType.UNIT_COPY_STAT] = ["id","speaker","param"];
            propsByType[ActionType.UNIT_TRANSFER_ITEM] = ["id","speaker"];
            propsByType[ActionType.FLYTEXT] = ["msg","time","varvalue","param"];
            propsByType[ActionType.BATTLE_MUSIC] = ["id"];
            propsByType[ActionType.BATTLE_STOP_MUSIC] = [];
            propsByType[ActionType.BATTLE_WIN_MUSIC] = [];
            propsByType[ActionType.BATTLE_LOSE_MUSIC] = [];
            propsByType[ActionType.BATTLE_HALT] = [];
            propsByType[ActionType.BATTLE_SURRENDER] = [];
            propsByType[ActionType.BATTLE_UNIT_ON_START_TURN] = ["id"];
            propsByType[ActionType.BATTLE_UNIT_ON_END_TURN] = ["id"];
            propsByType[ActionType.BATTLE_UNIT_ENABLE] = ["id","varvalue","param"];
            propsByType[ActionType.BATTLE_UNIT_VISIBLE] = ["id","param","varvalue","time"];
            propsByType[ActionType.BATTLE_UNIT_REMOVE] = ["id","param"];
            propsByType[ActionType.BATTLE_UNIT_TELEPORT] = ["id","anchor"];
            propsByType[ActionType.BATTLE_UNIT_ACTIVATE] = ["id","varvalue","param"];
            propsByType[ActionType.BATTLE_UNIT_INTERACT] = ["id"];
            propsByType[ActionType.BATTLE_SPAWN] = ["id","anchor","param","varname"];
            propsByType[ActionType.BATTLE_READY] = [];
            propsByType[ActionType.BATTLE_UNIT_ABILITY] = ["id","param","anchor","varvalue"];
            propsByType[ActionType.BATTLE_UNIT_MOVE] = ["id","anchor","param"];
            propsByType[ActionType.BATTLE_UNIT_USE] = ["id","anchor","param"];
            propsByType[ActionType.BATTLE_NEXT_TURN] = [];
            propsByType[ActionType.BATTLE_GUI_ENABLE] = ["varvalue","param"];
            propsByType[ActionType.BATTLE_HUD_CONFIG] = ["param"];
            propsByType[ActionType.BATTLE_CAMERA_CENTER] = ["id","param"];
            propsByType[ActionType.BATTLE_UNIT_STAT] = ["id","param","varvalue"];
            propsByType[ActionType.BATTLE_INITIATIVE_RESET] = ["id"];
            propsByType[ActionType.BATTLE_WAIT_OBJECTIVE_OPENED] = [];
            propsByType[ActionType.BATTLE_WAIT_MOVE_STOP] = ["id"];
            propsByType[ActionType.BATTLE_WAIT_MOVE_START] = ["id"];
            propsByType[ActionType.BATTLE_WAIT_UNIT_KILLED] = ["id"];
            propsByType[ActionType.BATTLE_WAIT_UNIT_INTERACTED] = ["id"];
            propsByType[ActionType.BATTLE_WAIT_TURN_ABILITY] = ["id","param"];
            propsByType[ActionType.BATTLE_MATCH_RESOLUTION_ENABLE] = ["varvalue"];
            propsByType[ActionType.BATTLE_WAIT_DEPLOYMENT_START] = [];
            propsByType[ActionType.BATTLE_END] = ["param"];
            propsByType[ActionType.BATTLE_RESPAWN] = ["varvalue","bucket","spawn_tags","param"];
            propsByType[ActionType.BATTLE_TRIGGER_ENABLE] = ["id","varvalue","expression"];
            propsByType[ActionType.BATTLE_ATTRACTOR_ENABLE] = ["anchor","varvalue"];
            propsByType[ActionType.BATTLE_CONTROLLER_CONFIG] = ["param"];
            propsByType[ActionType.BATTLE_TILE_MARKER] = ["param"];
            propsByType[ActionType.BATTLE_SUPPRESS_TURN_END] = ["varvalue"];
            propsByType[ActionType.BATTLE_SUPPRESS_PILLAGE] = ["varvalue"];
            propsByType[ActionType.BATTLE_SUPPRESS_FINISH] = ["varvalue"];
            propsByType[ActionType.BATTLE_AI_ENABLE] = ["varvalue"];
            propsByType[ActionType.TUTORIAL_POPUP] = ["msg","anchor","location","varvalue","param"];
            propsByType[ActionType.TUTORIAL_REMOVE_ALL] = [];
            propsByType[ActionType.ENABLE_SNOW] = ["varvalue"];
            propsByType[ActionType.CINEMA_FF_MARKER] = [];
            propsByType[ActionType.FADEOUT] = ["time"];
            propsByType[ActionType.FASTALL] = ["varvalue"];
            propsByType[ActionType.BATTLE_DIFFICULTY_ENABLE] = ["varvalue"];
            propsByType[ActionType.BATTLE_MORALE_ENABLE] = ["varvalue"];
            propsByType[ActionType.DISPLAY_SHATTER_GUI] = ["param"];
            propsByType[ActionType.DISPLAY_TALLY] = ["param"];
            propsByType[ActionType.DARKNESS_GUI_TRANSITION] = [];
            propsByType[ActionType.BATTLE_SNAPSHOT_STORE] = ["id"];
            propsByType[ActionType.BATTLE_SNAPSHOT_LOAD] = ["id"];
            propsByType[ActionType.TRAINING_SPAR] = [];
            propsByType[ActionType.MARKET_SHOW] = ["param"];
            propsByType[ActionType.GUI_DIALOG] = ["msg","param","anchor","speaker"];
            propsByType[ActionType.GUI_SURVIVAL_SETUP] = [];
            propsByType[ActionType.GUI_SURVIVAL_BATTLE_POPUP] = ["msg"];
            propsByType[ActionType.SURVIVAL_WIN_PAGE] = [];
            propsByType[ActionType.SURVIVAL_COMPUTE_SCORE] = [];
            propsByType[ActionType.BATTLE_UNIT_ATTRACT] = ["id","anchor"];
            propsByType[ActionType.BATTLE_UNIT_SHITLIST] = ["id","anchor"];
            propsByType[ActionType.OPEN_URL] = ["url"];
            propsByType[ActionType.SUBTITLE] = ["subtitle","param"];
            propsByType[ActionType.PROP_SET_USABILITY] = ["id","varvalue"];
            propsByType[ActionType.ASSET_BUNDLE_CREATE] = ["id","param"];
            propsByType[ActionType.ASSET_BUNDLE_RELEASE] = ["id"];
            propsByType[ActionType.ASSET_BUNDLE_MANIFEST] = ["id","param"];
            propsByType[ActionType.ASSET_BUNDLE_WAIT] = ["id"];
            propsDictByType = new Dictionary();
            for(_loc3_ in propsByType)
            {
               _loc4_ = _loc3_ as ActionType;
               _loc5_ = propsByType[_loc3_];
               _loc6_ = new Dictionary();
               propsDictByType[_loc4_] = _loc6_;
               for each(_loc7_ in _loc5_)
               {
                  _loc6_[_loc7_] = true;
               }
            }
         }
         return propsByType[param1];
      }
      
      public function addPrereq(param1:VariableKey) : void
      {
         if(!this.prereqs)
         {
            this.prereqs = new Vector.<VariableKey>();
         }
         this.prereqs.push(param1);
      }
      
      public function addWeight(param1:VariableKey) : void
      {
         if(!this.weights)
         {
            this.weights = new Vector.<VariableKey>();
         }
         this.weights.push(param1);
      }
      
      public function clone() : ActionDef
      {
         var _loc1_:ActionDef = new ActionDef(this.parentHappeningDef);
         _loc1_.copy(this);
         return _loc1_;
      }
      
      public function setProperty(param1:String, param2:*) : ActionDef
      {
         this[param1] = param2;
         return this;
      }
      
      public function toString() : String
      {
         return this.labelString;
      }
      
      public function copy(param1:ActionDef) : ActionDef
      {
         var _loc3_:String = null;
         var _loc4_:* = undefined;
         var _loc5_:VariableKey = null;
         var _loc6_:VariableKey = null;
         this.type = param1.type;
         this.instant = param1.instant;
         this.enabled = param1.enabled;
         var _loc2_:Array = getPropsByType(this.type);
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = param1[_loc3_];
               this[_loc3_] = _loc4_;
            }
         }
         this.prereq = param1.prereq;
         if(param1.prereqs)
         {
            for each(_loc5_ in param1.prereqs)
            {
               this.addPrereq(_loc5_.clone());
            }
         }
         if(param1.weights)
         {
            for each(_loc6_ in param1.weights)
            {
               this.addWeight(_loc6_.clone());
            }
         }
         return this;
      }
      
      public function get linkString() : String
      {
         return this.parentHappeningDef.linkString + " : " + this.type;
      }
      
      public function get labelString() : String
      {
         var _loc3_:String = null;
         var _loc4_:* = undefined;
         var _loc5_:String = null;
         if(!this.type)
         {
            return "TYPELESS";
         }
         var _loc1_:String = this.type.name;
         var _loc2_:Array = getPropsByType(this.type);
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = this[_loc3_];
               if(_loc4_ is Boolean)
               {
                  if(_loc4_)
                  {
                     _loc5_ += " " + _loc3_.substr(0,3);
                  }
               }
               else
               {
                  _loc5_ = String(this[_loc3_]);
                  if(_loc5_)
                  {
                     if(_loc3_ == "msg")
                     {
                        _loc5_ = _loc5_.replace(/\n/g,"\\n");
                     }
                     _loc5_ = StringUtil.getShortPath(_loc5_);
                     if(Boolean(_loc5_) && _loc5_.charAt(0) != "$")
                     {
                        _loc5_ = StringUtil.truncate(_loc5_,30);
                     }
                     _loc1_ += " " + _loc5_;
                  }
               }
            }
         }
         if(this.prereq)
         {
            _loc1_ += " [" + this.prereq + "]";
         }
         return _loc1_;
      }
      
      public function checkPrereqs(param1:IVariableProvider, param2:Array) : Boolean
      {
         var _loc3_:VariableKey = null;
         if(this.prereq)
         {
            if(this.exp_prereq)
            {
               if(this.exp_prereq.evaluate(param1,true) == 0)
               {
                  if(Boolean(param2) && param2.length > 0)
                  {
                     param2[0] = this.prereq;
                  }
                  return false;
               }
               return true;
            }
            throw new ArgumentError("Action prereq is unavailable for evaluation.  See earlier errors on loading: " + this);
         }
         if(!this.prereqs || this.prereqs.length == 0)
         {
            return true;
         }
         for each(_loc3_ in this.prereqs)
         {
            if(!_loc3_.check(param1))
            {
               if(Boolean(param2) && param2.length > 0)
               {
                  param2[0] = _loc3_.toString();
               }
               return false;
            }
         }
         return true;
      }
      
      public function computeWeight(param1:IVariableProvider) : Number
      {
         var _loc3_:VariableKey = null;
         if(!this.weights || this.weights.length == 0)
         {
            return 1;
         }
         var _loc2_:Number = 0;
         for each(_loc3_ in this.weights)
         {
            _loc2_ += _loc3_.compute(param1);
         }
         return Math.max(1,_loc2_);
      }
      
      public function handleRenameCaravan(param1:String, param2:String) : void
      {
         if(this.type == ActionType.CARAVAN)
         {
            if(this.id == param1)
            {
               this.id = param2;
            }
         }
      }
      
      public function handleRenameBucket(param1:String, param2:String) : void
      {
         if(this.bucket == param1)
         {
            this.bucket = param2;
         }
      }
      
      public function handleRenameVariable(param1:String, param2:String, param3:RenameVariableInfo) : void
      {
         ++param3.visited_actions;
         if(this.type == ActionType.VARIABLE_MODIFY || this.type == ActionType.VARIABLE_SET || this.type == ActionType.VARIABLE_TWEEN)
         {
            if(this.varname == param1)
            {
               ++param3.modified_actions;
               this.varname = param2;
            }
         }
      }
      
      public function handleRemoveHappening(param1:HappeningDef) : void
      {
         if(this.happeningId == param1.id)
         {
            this.happeningId = null;
         }
      }
      
      public function handleRenameHappening(param1:String, param2:String) : void
      {
         if(this.happeningId == param1)
         {
            if(this.type == ActionType.HAPPENING)
            {
               this.happeningId = param2;
            }
         }
      }
      
      public function removePrereq(param1:VariableKey) : void
      {
         var _loc2_:int = 0;
         if(this.prereqs)
         {
            _loc2_ = this.prereqs.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.prereqs.splice(_loc2_,1);
            }
         }
      }
      
      public function promotePrereq(param1:VariableKey) : void
      {
         var _loc2_:int = 0;
         if(this.prereqs)
         {
            _loc2_ = this.prereqs.indexOf(param1);
            if(_loc2_ > 0)
            {
               this.prereqs.splice(_loc2_,1);
               this.prereqs.splice(_loc2_ - 1,0,param1);
            }
         }
      }
      
      public function demotePrereq(param1:VariableKey) : void
      {
         var _loc2_:int = 0;
         if(this.prereqs)
         {
            _loc2_ = this.prereqs.indexOf(param1);
            if(_loc2_ >= 0 && _loc2_ < this.prereqs.length - 1)
            {
               this.prereqs.splice(_loc2_,1);
               this.prereqs.splice(_loc2_ + 1,0,param1);
            }
         }
      }
      
      public function removeWeight(param1:VariableKey) : void
      {
         var _loc2_:int = 0;
         if(this.weights)
         {
            _loc2_ = this.weights.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.weights.splice(_loc2_,1);
            }
         }
      }
      
      public function promoteWeight(param1:VariableKey) : void
      {
         var _loc2_:int = 0;
         if(this.weights)
         {
            _loc2_ = this.weights.indexOf(param1);
            if(_loc2_ > 0)
            {
               this.weights.splice(_loc2_,1);
               this.weights.splice(_loc2_ - 1,0,param1);
            }
         }
      }
      
      public function demoteWeight(param1:VariableKey) : void
      {
         var _loc2_:int = 0;
         if(this.weights)
         {
            _loc2_ = this.weights.indexOf(param1);
            if(_loc2_ >= 0 && _loc2_ < this.weights.length - 1)
            {
               this.weights.splice(_loc2_,1);
               this.weights.splice(_loc2_ + 1,0,param1);
            }
         }
      }
      
      public function stringifyAction(param1:String, param2:Locale, param3:ILogger) : void
      {
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         if(!hasPropByType(this.type,"msg"))
         {
            return;
         }
         if(!this.msg)
         {
            return;
         }
         if(this.msg.indexOf("$") == 0)
         {
            return;
         }
         var _loc4_:String = !!param1 ? param1 + "_" : "";
         var _loc5_:LocaleCategory = LocaleCategory.GUI;
         switch(this.type)
         {
            case ActionType.SPEAK:
               _loc5_ = LocaleCategory.SPEAK;
               _loc12_ = "";
               if(this.speaker)
               {
                  _loc13_ = this.speaker.indexOf(",");
                  if(_loc13_ > 0)
                  {
                     _loc12_ = this.speaker.substr(0,_loc13_);
                  }
                  else
                  {
                     _loc12_ = this.speaker;
                  }
               }
               if(this.anchor)
               {
                  _loc12_ = this.anchor;
                  _loc12_ = _loc12_.replace("landscape.anchor_");
               }
               if(_loc12_)
               {
                  if(_loc4_.indexOf("deets") < 0)
                  {
                     _loc4_ += _loc12_ + "_";
                  }
               }
               break;
            case ActionType.TUTORIAL_POPUP:
               _loc5_ = LocaleCategory.TUTORIAL;
               break;
            case ActionType.FLASH_PAGE:
               _loc5_ = LocaleCategory.GUI;
               break;
            case ActionType.FLYTEXT:
               _loc5_ = LocaleCategory.FLYTEXT;
         }
         _loc4_ = _loc4_.replace("$","");
         var _loc6_:Localizer = param2.getLocalizer(_loc5_,true);
         var _loc9_:String = _loc6_.findTranslationId(this.msg);
         if(_loc9_)
         {
            _loc7_ = true;
            _loc8_ = _loc9_;
         }
         else
         {
            _loc14_ = 0;
            while(_loc14_ < 100)
            {
               _loc8_ = _loc4_ + StringUtil.padLeft(_loc14_.toString(),"0",2);
               if(this._attemptAddToken(_loc8_,this.msg,_loc6_))
               {
                  _loc7_ = true;
                  break;
               }
               _loc14_++;
            }
         }
         if(!_loc7_)
         {
            param3.error("Unable to find a string for " + _loc4_ + " in " + _loc6_);
            return;
         }
         var _loc10_:String = _loc6_.id + ":" + _loc8_;
         param3.info("STRINGIFY [" + this.parentHappeningDef.linkString + " : " + this.toString() + "] [" + _loc10_ + "] [" + this.msg.replace(/\n/g,"\\n") + "]" + (!!_loc9_ ? " PRE-EXIST " + _loc9_ : ""));
         var _loc11_:String = this.msg.toLowerCase();
         if(_loc11_.indexOf("click") >= 0 || _loc11_.indexOf("mouse") >= 0)
         {
            param3.info("STR-CLICK [" + _loc10_ + "]");
            switch(_loc6_.id)
            {
               case LocaleCategory.GUI:
                  this._attemptAddTokenCat(_loc8_,this.msg,param2,LocaleCategory.GUI_GP);
                  this._attemptAddTokenCat(_loc8_,this.msg,param2,LocaleCategory.GUI_MOBILE);
                  break;
               case LocaleCategory.TUTORIAL:
                  this._attemptAddTokenCat(_loc8_,this.msg,param2,LocaleCategory.TUTORIAL_GP);
                  this._attemptAddTokenCat(_loc8_,this.msg,param2,LocaleCategory.TUTORIAL_MOBILE);
            }
         }
         this.msg = "$" + _loc10_;
      }
      
      private function _attemptAddTokenCat(param1:String, param2:String, param3:Locale, param4:LocaleCategory) : Boolean
      {
         var _loc5_:Localizer = param3.getLocalizer(param4,false);
         return this._attemptAddToken(param1,param2,_loc5_);
      }
      
      private function _attemptAddToken(param1:String, param2:String, param3:Localizer) : Boolean
      {
         if(!param3)
         {
            return false;
         }
         if(param3.hasToken(param1))
         {
            return false;
         }
         param3.addTranslation(param1,param2);
         return true;
      }
      
      public function gatherActionProperties(param1:ActionType, param2:String, param3:Array) : void
      {
         if(this.type != param1)
         {
            return;
         }
         var _loc4_:* = this[param2];
         var _loc5_:Object = {
            "type":param1,
            "prop":param2
         };
         _loc5_[param2] = _loc4_;
         param3.push(_loc5_);
      }
   }
}
