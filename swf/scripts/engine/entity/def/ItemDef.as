package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.ColorUtil;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.stat.def.StatModDef;
   import engine.stat.def.StatType;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class ItemDef extends EventDispatcher
   {
      
      public static var unlockAll:Boolean;
      
      private static var passiveFontStr:String;
      
      private static var statmodPosFontStr:String;
      
      private static var statmodNegFontStr:String;
      
      private static var colors:Array = [9342606,9342606,2722089,2722089,3436990,3436990,9382344,9382344,11811617,11811617,14416127];
      
      private static var SUPPRESS_NUMBERS:Dictionary;
      
      private static var prices:Array = [2,4,6,8,10,12,14,16,18,20];
       
      
      protected var _id:String;
      
      protected var _icon:String;
      
      protected var _passive:String;
      
      protected var _passiveRank:int = 1;
      
      protected var _rank:int;
      
      public var omitFromMarketplace:Boolean;
      
      public var statmods:Vector.<StatModDef>;
      
      public var passive_abl:IBattleAbilityDef;
      
      private var _brief:String;
      
      private var _name:String;
      
      private var _desc:String;
      
      private var locale:Locale;
      
      private var factory:IBattleAbilityDefFactory;
      
      public function ItemDef(param1:Locale)
      {
         super();
         this.locale = param1;
         if(!passiveFontStr)
         {
            passiveFontStr = "<font color=\'" + ColorUtil.colorStr(16762368) + "\'>";
            statmodPosFontStr = "<font color=\'" + ColorUtil.colorStr(10349377) + "\'>";
            statmodNegFontStr = "<font color=\'" + ColorUtil.colorStr(16711680) + "\'>";
         }
      }
      
      public static function getColorForRank(param1:int) : uint
      {
         var _loc2_:int = Math.min(param1 - 1,colors.length - 1);
         return colors[_loc2_];
      }
      
      public static function _printStatModDef(param1:StatModDef, param2:Boolean, param3:Locale) : String
      {
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc4_:* = "";
         if(param2)
         {
            _loc7_ = param1.stat == StatType.AI_AGGRO_MOD || param1.stat == StatType.MISS_CHANCE_MINIMUM;
            _loc8_ = param1.amount;
            if(_loc7_)
            {
               _loc8_ *= -1;
            }
            if(_loc8_ >= 0)
            {
               _loc4_ += statmodPosFontStr;
            }
            else if(_loc8_ < 0)
            {
               _loc4_ += statmodNegFontStr;
            }
            else
            {
               _loc4_ += statmodNegFontStr;
            }
         }
         var _loc5_:String = param3.translate(LocaleCategory.STAT,"abbrev_" + param1.stat.name,true);
         if(!_loc5_)
         {
            _loc5_ = param3.translate(LocaleCategory.STAT,param1.stat.name);
         }
         var _loc6_:int = _loc5_.indexOf("$");
         if(_loc6_ >= 0)
         {
            _loc9_ = "AMOUNT";
            _loc10_ = "SIGNED_AMOUNT";
            _loc11_ = "?????";
            _loc12_ = "";
            if(_loc5_.indexOf(_loc9_,_loc6_ + 1) == _loc6_ + 1)
            {
               _loc12_ = _loc9_;
               _loc11_ = param1.amount.toString();
            }
            else if(_loc5_.indexOf(_loc10_,_loc6_ + 1) == _loc6_ + 1)
            {
               _loc12_ = _loc10_;
               _loc11_ = StringUtil.numberWithSign(param1.amount,0);
            }
            _loc4_ += _loc5_.substring(0,_loc6_) + _loc11_ + _loc5_.substring(_loc6_ + _loc12_.length + 1);
         }
         else if(SUPPRESS_NUMBERS[param1.stat])
         {
            _loc4_ += _loc5_;
         }
         else
         {
            _loc4_ += StringUtil.numberWithSign(param1.amount,0);
            _loc4_ += " ";
            _loc4_ += _loc5_;
         }
         if(param2)
         {
            _loc4_ += "</font>";
         }
         return _loc4_;
      }
      
      public function get canonicalIcon() : String
      {
         return "common/item/icon/" + this.id + ".png";
      }
      
      override public function toString() : String
      {
         return this.id + "/R" + this.rank;
      }
      
      public function clone() : ItemDef
      {
         var _loc2_:StatModDef = null;
         var _loc1_:ItemDef = new ItemDef(this.locale);
         _loc1_.locale = this.locale;
         _loc1_.factory = this.factory;
         _loc1_._id = this.id;
         _loc1_._icon = this.icon;
         _loc1_._passive = this.passive;
         _loc1_._passiveRank = this.passiveRank;
         _loc1_._rank = this.rank;
         _loc1_.passive_abl = this.passive_abl;
         if(this.statmods)
         {
            _loc1_.statmods = new Vector.<StatModDef>();
            for each(_loc2_ in this.statmods)
            {
               _loc1_.statmods.push(_loc2_.clone());
            }
         }
         _loc1_.doResolve(false);
         return _loc1_;
      }
      
      public function get name() : String
      {
         if(!this._name)
         {
            this._name = this.locale.translate(LocaleCategory.ITEM,this.id);
         }
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         if(Boolean(param1) && param1.charAt(0) == "{")
         {
            return;
         }
         this._name = param1;
         this.locale.getLocalizer(LocaleCategory.ITEM).setValue(this.id,param1);
         this.notifyChanged();
      }
      
      public function get description() : String
      {
         if(!this._desc)
         {
            this._desc = this.locale.translate(LocaleCategory.ITEM,this.id + "_desc");
         }
         return this._desc;
      }
      
      public function set description(param1:String) : void
      {
         if(Boolean(param1) && param1.charAt(0) == "{")
         {
            return;
         }
         this._desc = param1;
         this.locale.getLocalizer(LocaleCategory.ITEM).setValue(this.id + "_desc",param1);
         this.notifyChanged();
      }
      
      public function get brief() : String
      {
         return this._brief;
      }
      
      public function get color() : uint
      {
         return getColorForRank(this.rank);
      }
      
      public function get colorizedName() : String
      {
         var _loc1_:String = ColorUtil.colorStr(this.color);
         return "<font color=\'" + _loc1_ + "\'>" + this.name + "</font>";
      }
      
      public function resolve(param1:IBattleAbilityDefFactory) : void
      {
         this.factory = param1;
         this.doResolve(true);
      }
      
      private function setupSuppressNumbers() : void
      {
         if(SUPPRESS_NUMBERS)
         {
            return;
         }
         SUPPRESS_NUMBERS = new Dictionary();
         SUPPRESS_NUMBERS[StatType.NEVER_MISS] = true;
      }
      
      public function createBrief(param1:Boolean, param2:Boolean) : String
      {
         var _loc4_:StatModDef = null;
         var _loc3_:* = "";
         if(!this.factory)
         {
            return _loc3_;
         }
         if(this.passive)
         {
            this.passive_abl = this.factory.fetchIBattleAbilityDef(this.passive,false) as IBattleAbilityDef;
            if(!this.passive_abl)
            {
               if(param1)
               {
                  this.factory.logger.error("Item [" + this + "] passive not found");
               }
            }
            else
            {
               try
               {
                  this.passive_abl = this.passive_abl.getIBattleAbilityDefLevel(this.passiveRank);
               }
               catch(error:Error)
               {
               }
               if(!this.passive_abl)
               {
                  if(param1)
                  {
                     this.factory.logger.error("Item [" + this + "] passive rank unavailable");
                  }
               }
               else if(param2)
               {
                  _loc3_ = passiveFontStr + this.passive_abl.descriptionBrief + "</font>";
               }
               else
               {
                  _loc3_ = String(this.passive_abl.descriptionBrief);
               }
            }
         }
         if(this.statmods)
         {
            for each(_loc4_ in this.statmods)
            {
               if(_loc3_)
               {
                  _loc3_ += "; ";
               }
               _loc3_ += _printStatModDef(_loc4_,param2,this.locale);
            }
         }
         return _loc3_;
      }
      
      public function doResolve(param1:Boolean) : void
      {
         if(!SUPPRESS_NUMBERS)
         {
            this.setupSuppressNumbers();
         }
         this._brief = this.createBrief(param1,true);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
         this._name = null;
         this._desc = null;
         this.notifyChanged();
      }
      
      private function notifyChanged() : void
      {
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get passive() : String
      {
         return this._passive;
      }
      
      public function set passive(param1:String) : void
      {
         this._passive = param1;
         this.doResolve(false);
         this.notifyChanged();
      }
      
      public function get passiveRank() : int
      {
         return this._passiveRank;
      }
      
      public function set passiveRank(param1:int) : void
      {
         param1 = Math.max(1,param1);
         this._passiveRank = param1;
         this.doResolve(false);
         this.notifyChanged();
      }
      
      public function get rank() : int
      {
         if(unlockAll)
         {
            return 1;
         }
         return this._rank;
      }
      
      public function set rank(param1:int) : void
      {
         this._rank = param1;
         this.notifyChanged();
      }
      
      public function get icon() : String
      {
         return this._icon;
      }
      
      public function set icon(param1:String) : void
      {
         this._icon = param1;
         this.notifyChanged();
      }
      
      public function getStatModDefByType(param1:StatType) : StatModDef
      {
         var _loc2_:StatModDef = null;
         if(this.statmods)
         {
            for each(_loc2_ in this.statmods)
            {
               if(_loc2_.stat == param1)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      public function createStatModDef(param1:String) : StatModDef
      {
         var _loc2_:StatType = Enum.parse(StatType,param1,false) as StatType;
         if(!_loc2_)
         {
            return null;
         }
         if(this.getStatModDefByType(_loc2_))
         {
            return null;
         }
         var _loc3_:StatModDef = new StatModDef();
         _loc3_.stat = _loc2_;
         if(!this.statmods)
         {
            this.statmods = new Vector.<StatModDef>();
         }
         this.statmods.push(_loc3_);
         this.doResolve(false);
         this.notifyChanged();
         return _loc3_;
      }
      
      public function removeStatModDef(param1:int) : void
      {
         if(Boolean(this.statmods) && this.statmods.length > param1)
         {
            this.statmods.splice(param1,1);
            this.doResolve(false);
            this.notifyChanged();
         }
      }
      
      public function setStatModDefStat(param1:int, param2:String) : void
      {
         var _loc3_:StatType = Enum.parse(StatType,param2,false) as StatType;
         if(!_loc3_)
         {
            return;
         }
         if(this.getStatModDefByType(_loc3_))
         {
            return;
         }
         if(Boolean(this.statmods) && this.statmods.length > param1)
         {
            this.statmods[param1].stat = _loc3_;
            this.doResolve(false);
            this.notifyChanged();
         }
      }
      
      public function setStatModDefAmount(param1:int, param2:int) : void
      {
         if(Boolean(this.statmods) && this.statmods.length > param1)
         {
            this.statmods[param1].amount = param2;
            this.doResolve(false);
            this.notifyChanged();
         }
      }
      
      public function get price() : int
      {
         if(this.rank <= prices.length)
         {
            return prices[this.rank - 1];
         }
         return prices[prices.length - 1];
      }
      
      public function changeLocale(param1:Locale) : void
      {
         this.locale = param1;
         this._name = null;
         this._desc = null;
         this._brief = this.createBrief(false,true);
      }
   }
}
