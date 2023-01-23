package game.gui.pages
{
   import engine.core.locale.Locale;
   import engine.core.util.ColorUtil;
   import engine.entity.def.EntityDefEvent;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.gui.GuiContextEvent;
   import engine.stat.def.StatModDef;
   import engine.stat.def.StatType;
   import engine.talent.BonusedTalents;
   import engine.talent.Talent;
   import engine.talent.TalentDef;
   import engine.talent.TalentDefs;
   import engine.talent.Talents;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiChitsGroup;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.GuiStatButton;
   import game.gui.IGuiContext;
   
   public class GuiPgTalents extends GuiBase
   {
      
      public static var BUTTON_POSITION:Boolean;
      
      private static var tokens:Dictionary;
       
      
      private var _buttons_stat:Dictionary;
      
      private var _text_stat:TextField;
      
      private var _text_name:TextField;
      
      private var _text_item:TextField;
      
      private var _text_desc:TextField;
      
      private var _text_ranks:TextField;
      
      private var _text$talent_locked:TextField;
      
      private var _numbers:MovieClip;
      
      private var _numbers_numerator:TextField;
      
      private var _numbers_denominator:TextField;
      
      private var _placeholder:MovieClip;
      
      private var _chits:GuiChitsGroup;
      
      private var _guiIcon:GuiIcon;
      
      private var _callback_visible:Function;
      
      private var _callback_pointsAllocator:Function;
      
      public var _pointsAvailable:int;
      
      public var _originalPointsAvailable:int;
      
      private var talentDefs:TalentDefs;
      
      private var _talentDefsForStat:Vector.<TalentDef>;
      
      private var _talentDef:TalentDef;
      
      public var _button_right:ButtonWithIndex;
      
      public var _button_left:ButtonWithIndex;
      
      public var _button_plus:ButtonWithIndex;
      
      public var _button_minus:ButtonWithIndex;
      
      public var _button$close:ButtonWithIndex;
      
      private var _talents:Talents;
      
      private var _entitydef:IEntityDef;
      
      private var gp:GuiPgTalents_Gp;
      
      private var _lastStat:StatType;
      
      public function GuiPgTalents()
      {
         var _loc1_:* = null;
         var _loc2_:StatType = null;
         var _loc3_:GuiStatButton = null;
         this._buttons_stat = new Dictionary();
         this.gp = new GuiPgTalents_Gp();
         super();
         this.visible = false;
         if(!tokens)
         {
            tokens = new Dictionary();
            tokens[StatType.STRENGTH] = "pg_q_stat_strength";
            tokens[StatType.ARMOR] = "pg_q_stat_armor";
            tokens[StatType.WILLPOWER] = "pg_q_stat_willpower";
            tokens[StatType.EXERTION] = "pg_q_stat_exertion";
            tokens[StatType.ARMOR_BREAK] = "pg_q_stat_break";
         }
         for(_loc1_ in tokens)
         {
            _loc2_ = _loc1_ as StatType;
            _loc3_ = requireGuiChild("button_" + _loc2_.abbrev_lower) as GuiStatButton;
            this._buttons_stat[_loc2_] = _loc3_;
         }
         this._text_stat = requireGuiChild("text_stat") as TextField;
         this._text_name = requireGuiChild("text_name") as TextField;
         this._text_item = requireGuiChild("text_item") as TextField;
         this._text_desc = requireGuiChild("text_desc") as TextField;
         this._text_ranks = requireGuiChild("text_ranks") as TextField;
         this._text$talent_locked = requireGuiChild("text$talent_locked") as TextField;
         this._text$talent_locked.mouseEnabled = false;
         this._placeholder = requireGuiChild("placeholder") as MovieClip;
         this._placeholder.visible = false;
         this._chits = requireGuiChild("chits") as GuiChitsGroup;
         this._button_right = requireGuiChild("button_right") as ButtonWithIndex;
         this._button_left = requireGuiChild("button_left") as ButtonWithIndex;
         this._button_minus = requireGuiChild("button_minus") as ButtonWithIndex;
         this._button_plus = requireGuiChild("button_plus") as ButtonWithIndex;
         this._button$close = requireGuiChild("button$close") as ButtonWithIndex;
         this._numbers = requireGuiChild("numbers") as MovieClip;
         this._numbers_denominator = this._numbers.getChildByName("denominator") as TextField;
         this._numbers_numerator = this._numbers.getChildByName("numerator") as TextField;
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.updateStatTalentDisplay(this._lastStat);
         this.updateRanksDisplay();
         scaleTextfields();
      }
      
      public function setPointsAvailable(param1:int) : void
      {
         if(param1 == this._pointsAvailable)
         {
            return;
         }
         this._pointsAvailable = param1;
         this._pointsAvailable = param1;
         this.updateUpgradable();
      }
      
      public function setStatValue(param1:StatType, param2:int, param3:int, param4:int, param5:int, param6:int) : void
      {
         var _loc7_:GuiStatButton = null;
         this._pointsAvailable = param5;
         this._originalPointsAvailable = param6;
         if(param1)
         {
            _loc7_ = this._buttons_stat[param1];
            if(_loc7_)
            {
               _loc7_.setStatValue(param2,param3,param4,param5,param6);
            }
         }
      }
      
      public function updateUpgradable() : void
      {
         var _loc1_:GuiStatButton = null;
         var _loc2_:Talent = null;
         if(!visible)
         {
            return;
         }
         for each(_loc1_ in this._buttons_stat)
         {
            _loc1_.availablePoints = this._pointsAvailable;
            _loc2_ = this._talents.getTalentByParentStatType(_loc1_.statType);
            _loc1_.rank = !!_loc2_ ? _loc2_.rank : 0;
         }
         if(this._talentDef)
         {
            this.updateStatTalentDisplay(this._talentDef.parentStatType);
         }
         this.updateTalentControls();
      }
      
      private function updateTalentControls() : void
      {
         var _loc5_:String = null;
         var _loc1_:Talent = this._talents.getTalentByDef(this._talentDef,true);
         var _loc2_:GuiStatButton = !!_loc1_ ? this._buttons_stat[_loc1_.def.parentStatType] : null;
         var _loc3_:String = "ui_generic";
         if(_loc1_)
         {
            _loc5_ = this.talentDefs.getSoundUiByParentStatType(_loc1_.def.parentStatType);
            if(_loc5_)
            {
               _loc3_ = _loc5_;
            }
         }
         this._button_minus.clickSound = _loc3_;
         this._button_plus.clickSound = _loc3_;
         this._button_right.clickSound = _loc3_;
         this._button_left.clickSound = _loc3_;
         var _loc4_:int = !!_loc1_ ? _loc1_.rank : 0;
         this._button_minus.enabled = Boolean(_loc1_) && _loc1_.isUpgraded;
         this._button_plus.enabled = Boolean(_loc2_) && _loc2_.isUpgradable;
         this._text$talent_locked.visible = Boolean(_loc2_) && !_loc4_ && _loc2_._value < _loc2_._max;
         this._numbers.visible = Boolean(_loc2_) && Boolean(_loc1_) && !this._text$talent_locked.visible;
         if(this._numbers.visible)
         {
            this._numbers_denominator.htmlText = "/" + _loc1_.def.maxUpgradableRankIndex.toString();
            this._numbers_numerator.htmlText = _loc1_.rank.toString();
         }
      }
      
      public function init(param1:IGuiContext, param2:Function, param3:Function) : void
      {
         var _loc4_:* = null;
         var _loc5_:StatType = null;
         var _loc6_:GuiStatButton = null;
         super.initGuiBase(param1);
         this.talentDefs = param1.saga.def.talentDefs;
         if(!this.talentDefs)
         {
            throw new ArgumentError("GuiPgTalents requires talentDefs and talents");
         }
         for(_loc4_ in tokens)
         {
            _loc5_ = _loc4_ as StatType;
            _loc6_ = this._buttons_stat[_loc4_];
            _loc6_.init(param1,_loc5_);
            _loc6_.setDownFunction(this.buttonStatHandler);
         }
         this._button_right.guiButtonContext = _context;
         this._button_left.guiButtonContext = _context;
         this._button_minus.guiButtonContext = _context;
         this._button_plus.guiButtonContext = _context;
         this._button$close.guiButtonContext = _context;
         this._button_right.setDownFunction(this.buttonRightHandler);
         this._button_left.setDownFunction(this.buttonLeftHandler);
         this._button_minus.setDownFunction(this.buttonMinusHandler);
         this._button_plus.setDownFunction(this.buttonPlusHandler);
         this._button$close.setDownFunction(this.buttonCloseHandler);
         this._chits.init(_context);
         this._callback_visible = param2;
         this._callback_pointsAllocator = param3;
         registerScalableTextfield(this._text_name);
         registerScalableTextfield(this._text_item);
         registerScalableTextfield2d(this._text_stat,false);
         registerScalableTextfield2d(this._text_ranks,false);
         registerScalableTextfield(this._text$talent_locked,false);
         this.gp.init(this);
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiStatButton = null;
         if(_context)
         {
            _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         }
         for each(_loc1_ in this._buttons_stat)
         {
            _loc1_.cleanup();
            _loc1_.setDownFunction(this.buttonStatHandler);
         }
         this._callback_visible = null;
         if(this.gp)
         {
            this.gp.cleanup();
            this.gp = null;
         }
      }
      
      public function showTalentsForStat(param1:StatType) : void
      {
         var _loc3_:GuiStatButton = null;
         var _loc2_:Boolean = this.visible;
         this.visible = true;
         for each(_loc3_ in this._buttons_stat)
         {
            _loc3_.toggled = _loc3_.statType != param1;
         }
         this.updateStatTalentDisplay(param1);
         if(!_loc2_)
         {
            this.updateUpgradable();
            this.gp.handleActivateTalents();
         }
         else
         {
            this.updateTalentControls();
         }
         this.updateRanksDisplay();
         this._callback_visible();
      }
      
      private function updateStatTalentDisplay(param1:StatType) : void
      {
         var _loc6_:int = 0;
         if(!param1 || !this._talents)
         {
            return;
         }
         this._lastStat = param1;
         var _loc2_:String = tokens[param1];
         var _loc3_:String = _context.translate(_loc2_);
         this._text_stat.htmlText = !!_loc3_ ? _loc3_ : "";
         var _loc4_:Locale = _context.locale;
         _loc4_.fixTextFieldFormat(this._text_stat);
         var _loc5_:Talent = this._talents.getTalentByParentStatType(param1);
         if(Boolean(_loc5_) && Boolean(_loc5_.rank))
         {
            this._talentDefsForStat = new Vector.<TalentDef>();
            this._talentDefsForStat.push(_loc5_.def);
         }
         else
         {
            this._talentDefsForStat = this.talentDefs.getDefsByParentStatType(param1);
         }
         if(this._talentDefsForStat.length > 1)
         {
            this._chits.numVisibleChits = this._talentDefsForStat.length;
            _loc6_ = this._talentDefsForStat.indexOf(this._talentDef);
            if(_loc6_ >= 0)
            {
               this._chits.activeChitIndex = _loc6_;
            }
            else
            {
               this._chits.activeChitIndex = 0;
            }
            this._chits.visible = true;
         }
         else
         {
            this._chits.activeChitIndex = 0;
            this._chits.visible = false;
         }
         this._button_left.visible = this._chits.visible;
         this._button_right.visible = this._chits.visible;
         if(this._talentDefsForStat.length)
         {
            this.talentDef = this._talentDefsForStat[this._chits.activeChitIndex];
         }
      }
      
      private function buttonStatHandler(param1:GuiStatButton) : void
      {
         var _loc2_:* = null;
         var _loc3_:StatType = null;
         var _loc4_:GuiStatButton = null;
         if(param1.toggled)
         {
            for(_loc2_ in tokens)
            {
               _loc3_ = _loc2_ as StatType;
               _loc4_ = this._buttons_stat[_loc2_];
               if(_loc4_ == param1)
               {
                  this.showTalentsForStat(_loc3_);
                  return;
               }
            }
         }
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         if(this.visible)
         {
            this.visible = false;
            this._callback_visible();
         }
         this.gp.handleDeactivateTalents();
      }
      
      public function get talentDef() : TalentDef
      {
         return this._talentDef;
      }
      
      public function set talentDef(param1:TalentDef) : void
      {
         var _loc2_:Talent = null;
         if(this._talentDef == param1)
         {
            return;
         }
         if(this._talentDef)
         {
            _loc2_ = this._talents.getTalentById(this._talentDef.id);
            if(Boolean(_loc2_) && !_loc2_.rank)
            {
               this._talents.removeTalent(_loc2_);
               _loc2_ = null;
            }
         }
         this._talentDef = param1;
         if(!this._talentDef)
         {
            return;
         }
         this.updateRanksDisplay();
      }
      
      private function updateRanksDisplay() : void
      {
         var _loc11_:StatType = null;
         var _loc12_:StatType = null;
         var _loc13_:Item = null;
         var _loc14_:StatModDef = null;
         var _loc15_:StatModDef = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:String = null;
         var _loc19_:String = null;
         var _loc20_:String = null;
         if(!this._talentDef)
         {
            return;
         }
         var _loc1_:* = "<font color=\'" + ColorUtil.colorStr(this._talentDef.parentStatType.color) + "\'>";
         var _loc2_:String = "<font color=\'#A7B2B7\'>";
         var _loc3_:Locale = _context.locale;
         this._text_name.htmlText = _loc1_ + this._talentDef.getLocalizedName(_loc3_) + "</font>";
         this._text_desc.htmlText = this._talentDef.getLocalizedDesc(_loc3_);
         _loc3_.fixTextFieldFormat(this._text_name);
         _loc3_.fixTextFieldFormat(this._text_desc);
         var _loc4_:* = "";
         var _loc5_:Talent = this._talents.getTalentByDef(this._talentDef,true);
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(_loc5_)
         {
            _loc7_ = _loc5_.rank;
            _loc6_ = _loc7_;
            if(this._entitydef)
            {
               _loc11_ = this._talentDef.parentStatType;
               _loc12_ = BonusedTalents.getBonusStat(_loc11_);
               _loc13_ = this._entitydef.defItem;
               if(Boolean(_loc13_) && Boolean(_loc12_))
               {
                  _loc14_ = _loc13_.def.getStatModDefByType(StatType.TAL_BONUS_ALL);
                  _loc15_ = _loc13_.def.getStatModDefByType(_loc12_);
                  _loc16_ = !!_loc14_ ? _loc14_.amount : 0;
                  _loc17_ = !!_loc15_ ? _loc15_.amount : 0;
                  _loc8_ = Math.max(_loc16_,_loc17_);
                  if(_loc7_)
                  {
                     _loc6_ += _loc8_;
                  }
               }
            }
         }
         if(_loc8_)
         {
            _loc18_ = _context.translate("pg_talent_item_pfx");
            this._text_item.htmlText = _loc18_ + _loc8_.toString();
            this._text_item.visible = true;
            _loc3_.fixTextFieldFormat(this._text_item);
         }
         else
         {
            this._text_item.visible = false;
         }
         var _loc9_:* = _loc3_.translateGui("rank") + " ";
         var _loc10_:int = 0;
         while(_loc10_ < this._talentDef.maxUpgradableRankIndex)
         {
            if(_loc4_)
            {
               _loc4_ += "\n";
            }
            _loc19_ = (_loc10_ + 1).toString();
            _loc20_ = this._talentDef.getLocalizedRank(_loc3_,_loc10_ + 1);
            if(_loc10_ + 1 == _loc6_)
            {
               _loc4_ += _loc1_ + _loc9_ + _loc19_ + ":</font> ";
               _loc4_ += _loc20_;
            }
            else
            {
               _loc4_ += _loc2_ + _loc9_ + _loc19_ + ": " + _loc20_ + "</font>";
            }
            _loc10_++;
         }
         if(_loc6_ > this._talentDef.maxUpgradableRankIndex)
         {
            _loc20_ = this._talentDef.getLocalizedRank(_loc3_,_loc6_);
            _loc4_ += "\n" + _loc1_ + _loc9_ + _loc6_ + ":</font> " + _loc20_;
         }
         this._text_ranks.htmlText = _loc4_;
         _loc3_.fixTextFieldFormat(this._text_ranks);
         this.guiIcon = _context.getIcon(this._talentDef.getIconPath());
         super.scaleTextfields();
      }
      
      private function buttonRightHandler(param1:*) : void
      {
         ++this._chits.activeChitIndex;
         this.talentDef = this._talentDefsForStat[this._chits.activeChitIndex];
      }
      
      private function buttonLeftHandler(param1:*) : void
      {
         --this._chits.activeChitIndex;
         this.talentDef = this._talentDefsForStat[this._chits.activeChitIndex];
      }
      
      private function buttonMinusHandler(param1:*) : void
      {
         if(!this._talents)
         {
            return;
         }
         if(this._talentDef)
         {
            this._talents.decrementRank(this._talentDef);
            this.showTalentsForStat(this._talentDef.parentStatType);
            this._callback_pointsAllocator();
         }
      }
      
      private function buttonPlusHandler(param1:*) : void
      {
         if(this._pointsAvailable < 0 || !this._talents)
         {
            return;
         }
         if(this._talentDef)
         {
            this._talents.incrementRank(this._talentDef);
            this.showTalentsForStat(this._talentDef.parentStatType);
            this._callback_pointsAllocator();
         }
      }
      
      public function get guiIcon() : GuiIcon
      {
         return this._guiIcon;
      }
      
      public function set guiIcon(param1:GuiIcon) : void
      {
         if(this._guiIcon == param1)
         {
            return;
         }
         if(this._guiIcon)
         {
            removeChild(this._guiIcon);
            this._guiIcon.release();
         }
         this._guiIcon = param1;
         if(this._guiIcon)
         {
            addChild(this._guiIcon);
            this._guiIcon.layout = GuiIconLayoutType.CENTER;
            this._guiIcon.setTargetSize(0,0);
            this._guiIcon.x = this._placeholder.x + this._placeholder.width / 2;
            this._guiIcon.y = this._placeholder.y + this._placeholder.height / 2;
         }
      }
      
      public function get talents() : Talents
      {
         return this._talents;
      }
      
      public function set talents(param1:Talents) : void
      {
         var _loc2_:GuiStatButton = null;
         this._talents = param1;
         for each(_loc2_ in this._buttons_stat)
         {
            _loc2_.talents = param1;
         }
      }
      
      public function set entity(param1:IEntityDef) : void
      {
         if(this._entitydef == param1)
         {
            return;
         }
         if(this._entitydef)
         {
            this._entitydef.removeEventListener(EntityDefEvent.ITEM,this.entityItemHandler);
         }
         this._entitydef = param1;
         if(this._entitydef)
         {
            this._entitydef.addEventListener(EntityDefEvent.ITEM,this.entityItemHandler);
         }
      }
      
      private function entityItemHandler(param1:EntityDefEvent) : void
      {
         this.updateRanksDisplay();
      }
   }
}
