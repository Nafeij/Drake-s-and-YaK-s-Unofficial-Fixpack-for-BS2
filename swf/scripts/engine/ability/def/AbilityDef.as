package engine.ability.def
{
   import engine.ability.IAbilityDef;
   import engine.core.locale.LocaleInfo;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.Stats;
   
   public class AbilityDef implements IAbilityDef
   {
       
      
      private var _id:String;
      
      private var _displayDamageUI:Boolean = false;
      
      private var _name:String;
      
      private var _descriptionRank:String;
      
      protected var _descriptionBrief:String;
      
      private var _root:AbilityDef;
      
      private var _level:int;
      
      protected var _iconUrl:String;
      
      protected var _iconLargeUrl:String;
      
      protected var _iconBuffUrl:String;
      
      protected var _costs:Stats;
      
      protected var _artifactChargeCost:int = 0;
      
      protected var _optionalStars:int = 0;
      
      public var localizer:Localizer;
      
      public var levels:Vector.<AbilityDef>;
      
      public var factory:AbilityDefFactory;
      
      private var _abl_rank:int;
      
      private var _doLocalizeName:Boolean;
      
      private var _doLocalizeRanks:Boolean;
      
      public function AbilityDef(param1:AbilityDef, param2:Localizer)
      {
         this.levels = new Vector.<AbilityDef>();
         super();
         if(!param1)
         {
            param1 = this;
         }
         this.localizer = param2;
         this._root = param1;
      }
      
      public function get displayDamageUI() : Boolean
      {
         return this._displayDamageUI;
      }
      
      public function set displayDamageUI(param1:Boolean) : void
      {
         this._displayDamageUI = param1;
      }
      
      private function _checkEnd(param1:int, param2:int) : int
      {
         if(param2 > 0 && (param2 < param1 || param1 < 0))
         {
            param1 = param2;
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
      
      private function getTokenBreakPos(param1:String, param2:int) : int
      {
         var _loc4_:String = null;
         var _loc5_:LocaleInfo = null;
         var _loc3_:int = -1;
         for each(_loc4_ in LocaleInfo.terminators_en)
         {
            _loc3_ = this.findEndPlace(_loc3_,param1.indexOf(_loc4_,param2));
         }
         _loc5_ = !!this.localizer ? this.localizer.info : null;
         if(Boolean(_loc5_) && Boolean(_loc5_.terminators))
         {
            for each(_loc4_ in _loc5_.terminators)
            {
               _loc3_ = this.findEndPlace(_loc3_,param1.indexOf(_loc4_,param2));
            }
         }
         return _loc3_;
      }
      
      private function makeOneSubstitution(param1:String, param2:ILogger) : String
      {
         var _loc5_:String = null;
         var _loc7_:Boolean = false;
         var _loc3_:int = param1.indexOf("$");
         if(_loc3_ < 0)
         {
            return param1;
         }
         var _loc4_:int = -1;
         if(param1.charAt(_loc3_ + 1) == "{")
         {
            _loc4_ = param1.indexOf("}",_loc3_ + 2);
            if(_loc4_ < 0)
            {
               param2.error("No terminator for subst var at [" + param1.substring(_loc3_) + "]");
               return param1;
            }
            _loc5_ = param1.substring(_loc3_ + 2,_loc4_);
            _loc4_++;
         }
         if(!_loc5_)
         {
            _loc4_ = this.getTokenBreakPos(param1,_loc3_);
            if(_loc4_ < 0)
            {
               _loc5_ = param1.substring(_loc3_ + 1);
            }
            else
            {
               _loc5_ = param1.substring(_loc3_ + 1,_loc4_);
            }
         }
         var _loc6_:String = "(ABS)";
         if(StringUtil.startsWith(_loc5_,_loc6_))
         {
            _loc7_ = true;
            _loc5_ = _loc5_.substr(_loc6_.length);
         }
         var _loc8_:* = "**" + _loc5_ + "**";
         if(_loc5_ in this.factory.params)
         {
            _loc8_ = String(this.factory.params[_loc5_]);
            if(_loc7_)
            {
               if(Boolean(_loc8_) && _loc8_.charAt(0) == "-")
               {
                  _loc8_ = _loc8_.substr(1);
               }
            }
         }
         var _loc9_:String = param1.substring(0,_loc3_) + _loc8_;
         if(_loc4_ > _loc3_)
         {
            _loc9_ += param1.substring(_loc4_);
         }
         return _loc9_;
      }
      
      public function makeSubstitutions(param1:String, param2:ILogger) : String
      {
         var _loc3_:String = null;
         if(!this.factory || !this.factory.params)
         {
            return param1;
         }
         while(true)
         {
            _loc3_ = this.makeOneSubstitution(param1,param2);
            if(_loc3_ == param1)
            {
               break;
            }
            param1 = _loc3_;
         }
         return param1;
      }
      
      protected function setId(param1:String, param2:int, param3:Boolean, param4:Boolean, param5:ILogger) : void
      {
         this._id = param1;
         this._abl_rank = param2;
         this._doLocalizeName = param3;
         this._doLocalizeRanks = param4;
         this.updateLocalizedStrings(param5);
      }
      
      public function changeLocale(param1:Localizer, param2:ILogger) : void
      {
         this.localizer = param1;
         this.updateLocalizedStrings(param2);
      }
      
      private function updateLocalizedStrings(param1:ILogger) : void
      {
         this._descriptionBrief = null;
         if(Boolean(this.localizer) && this._doLocalizeName)
         {
            this._name = this.localizer.translate(this.id);
         }
         this.updateRankDescription(param1);
      }
      
      public function updateRankDescription(param1:ILogger) : void
      {
         if(Boolean(this.localizer) && this._doLocalizeRanks)
         {
            this._descriptionRank = this.localizer.translate(this.id + "_description_rank_" + this._abl_rank);
            this._descriptionRank = this.makeSubstitutions(this._descriptionRank,param1);
         }
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function set level(param1:int) : void
      {
         this._level = param1;
      }
      
      final public function get maxLevel() : int
      {
         if(this.root != this)
         {
            return this.root.maxLevel;
         }
         return this.levels.length;
      }
      
      public function toString() : String
      {
         return this.id + "/" + this.level;
      }
      
      public function addLevel(param1:AbilityDef) : void
      {
         this.levels.push(param1);
         param1.level = this.levels.length;
      }
      
      public function link(param1:AbilityDefFactory) : void
      {
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get descriptionRank() : String
      {
         return this._descriptionRank;
      }
      
      public function get descriptionBrief() : String
      {
         if(!this._descriptionBrief)
         {
            if(Boolean(this.localizer) && this._doLocalizeName)
            {
               this._descriptionBrief = this.localizer.translate(this.id + "_description_brief");
            }
         }
         return this._descriptionBrief;
      }
      
      public function set descriptionBrief(param1:String) : void
      {
         if(Boolean(param1) && param1.charAt(0) == "{")
         {
            return;
         }
         this._descriptionBrief = param1;
         if(Boolean(this.localizer) && this._doLocalizeName)
         {
            this.localizer.setValue(this.id + "_description_brief",param1);
         }
      }
      
      public function get root() : IAbilityDef
      {
         return this._root;
      }
      
      public function get iconUrl() : String
      {
         return this._iconUrl;
      }
      
      public function get iconLargeUrl() : String
      {
         return this._iconLargeUrl;
      }
      
      public function getAbilityDefForLevel(param1:int) : IAbilityDef
      {
         if(this.root != this)
         {
            return this.root.getAbilityDefForLevel(param1);
         }
         if(param1 - 1 >= this.levels.length || param1 <= 0)
         {
            throw new ArgumentError("invalid ability level " + param1 + " for " + this.id + ". Must be in [1," + this.maxLevel + "]");
         }
         return this.levels[param1 - 1];
      }
      
      public function getCost(param1:StatType) : int
      {
         return !!this._costs ? this._costs.getValue(param1) : 0;
      }
      
      public function get costs() : Stats
      {
         return this._costs;
      }
      
      public function ensureCosts() : Stats
      {
         if(!this._costs)
         {
            this._costs = new Stats(null,true);
         }
         return this._costs;
      }
      
      public function checkCosts(param1:Stats) : StatType
      {
         var _loc2_:int = 0;
         var _loc3_:Stat = null;
         var _loc4_:StatType = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(Boolean(this._costs) && Boolean(param1))
         {
            _loc2_ = 0;
            while(_loc2_ < this._costs.numStats)
            {
               _loc3_ = this._costs.getStatByIndex(_loc2_);
               _loc4_ = _loc3_.type;
               _loc5_ = _loc3_.value;
               _loc6_ = param1.getValue(_loc4_);
               if(_loc6_ < _loc5_)
               {
                  return _loc4_;
               }
               _loc2_++;
            }
         }
         return null;
      }
      
      public function get artifactChargeCost() : int
      {
         return this._artifactChargeCost;
      }
      
      public function get iconBuffUrl() : String
      {
         return this._iconBuffUrl;
      }
      
      public function get optionalStars() : int
      {
         return this._optionalStars;
      }
   }
}
