package game.gui.battle.initiative
{
   import com.stoicstudio.platform.PlatformFlash;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.model.IEntity;
   import engine.heraldry.Heraldry;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   import engine.stat.model.Stats;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.GuiBase;
   import game.gui.GuiBattleStatFlagTooltip;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.IGuiContext;
   
   public class GuiInitiativeStatFlag extends GuiBase
   {
      
      private static const MAX_STAT_CACHE:int = 30;
      
      private static var _statTextCache:Array = new Array(MAX_STAT_CACHE * MAX_STAT_CACHE + MAX_STAT_CACHE);
       
      
      private const crownX:Number = 8;
      
      private const crownY:Number = -467;
      
      private const crownChitX:Number = 41;
      
      private const crownChitY:Number = -484;
      
      private const heraldryX:Number = 57;
      
      private const heraldryY:Number = -420;
      
      private var crown:DisplayObject;
      
      private var crownChit:DisplayObject;
      
      public var _textStrength:TextField;
      
      public var _textArmor:TextField;
      
      public var _textWillpower:TextField;
      
      public var _textExertion:TextField;
      
      public var _textArmorBreak:TextField;
      
      public var _injury_icon:MovieClip;
      
      public var _tooltip:GuiBattleStatFlagTooltip;
      
      private var _stats:Stats;
      
      private var _defStats:Stats;
      
      private var heraldryBmp:Bitmap;
      
      private var heraldry:Heraldry;
      
      private var _tooltip_hit_left:int = 0;
      
      private var _tooltip_hit_right:int = 100;
      
      private var _tooltip_hit_top:int = 0;
      
      private var _tooltip_hit_bottom:int = 100;
      
      private var _statTexts:Dictionary;
      
      private var bb:int;
      
      private var _entity:IEntity;
      
      private var _iconsForStat:Dictionary;
      
      public function GuiInitiativeStatFlag()
      {
         this._statTexts = new Dictionary();
         this._iconsForStat = new Dictionary();
         super();
         this._textStrength = requireGuiChild("textStrength") as TextField;
         this._textArmor = requireGuiChild("textArmor") as TextField;
         this._textWillpower = requireGuiChild("textWillpower") as TextField;
         this._textExertion = requireGuiChild("textExertion") as TextField;
         this._textArmorBreak = requireGuiChild("textArmorBreak") as TextField;
         this._injury_icon = requireGuiChild("injury_icon") as MovieClip;
         this._tooltip = requireGuiChild("tooltip") as GuiBattleStatFlagTooltip;
         this._textStrength.cacheAsBitmap = true;
         this._textArmor.cacheAsBitmap = true;
         this._textWillpower.cacheAsBitmap = true;
         this._textExertion.cacheAsBitmap = true;
         this._textArmorBreak.cacheAsBitmap = true;
         this._statTexts[StatType.STRENGTH] = this._textStrength;
         this._statTexts[StatType.ARMOR] = this._textArmor;
         this._statTexts[StatType.WILLPOWER] = this._textWillpower;
         this._statTexts[StatType.EXERTION] = this._textExertion;
         this._statTexts[StatType.ARMOR_BREAK] = this._textArmorBreak;
         this._tooltip_hit_left = 0;
         this._tooltip_hit_right = this._textArmor.x + this._textArmor.width + 10;
         this._tooltip_hit_bottom = this._textArmorBreak.y + this._textArmorBreak.height;
         this._tooltip_hit_top = this._textArmor.y;
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         scaleTextfields();
      }
      
      public function init(param1:IGuiContext, param2:Heraldry) : void
      {
         this.mouseEnabled = false;
         this.mouseChildren = false;
         super.initGuiBase(param1);
         this._tooltip.init(param1);
         this.crown = param1.getCrownIcon();
         if(this.crown)
         {
            this.addChildAt(this.crown,0);
            this.crown.x = this.crownX;
            this.crown.y = this.crownY;
         }
         this.crownChit = param1.getCrownChitIcon();
         if(this.crownChit)
         {
            this.addChildAt(this.crownChit,1);
            this.crownChit.x = this.crownChitX;
            this.crownChit.y = this.crownChitY;
         }
         this.heraldry = param2;
         if(Boolean(param2) && Boolean(param2.smallCrestBmpd))
         {
            this.heraldryBmp = new Bitmap(param2.smallCrestBmpd);
            this.addChildAt(this.heraldryBmp,1);
            this.heraldryBmp.x = this.heraldryX - this.heraldryBmp.width / 2;
            this.heraldryBmp.y = this.heraldryY - this.heraldryBmp.height / 2;
         }
         this._textStrength.mouseEnabled = false;
         this._textArmor.mouseEnabled = false;
         this._textWillpower.mouseEnabled = false;
         this._textExertion.mouseEnabled = false;
         this._textArmorBreak.mouseEnabled = false;
         this._textStrength.selectable = false;
         this._textArmor.selectable = false;
         this._textWillpower.selectable = false;
         this._textExertion.selectable = false;
         this._textArmorBreak.selectable = false;
         this.hideAllTooltips();
         this.handleLocaleChange();
      }
      
      private function hideAllTooltips() : void
      {
         this._tooltip.visible = false;
      }
      
      public function activateTooltips() : void
      {
         this.mouseEnabled = true;
         this.mouseChildren = false;
         addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         addEventListener(MouseEvent.ROLL_OUT,this.mouseOutHandler);
      }
      
      public function deactivateTooltips() : void
      {
         if(this._tooltip)
         {
            this._tooltip.setContent(null,null);
            this._tooltip.visible = false;
         }
         this.mouseEnabled = false;
         this.mouseChildren = false;
         removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         removeEventListener(MouseEvent.ROLL_OUT,this.mouseOutHandler);
      }
      
      public function cleanup() : void
      {
         this.deactivateTooltips();
         this._tooltip.cleanup();
         this._tooltip = null;
         super.cleanupGuiBase();
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         ++this.bb;
      }
      
      private function _getTooltipStat() : StatType
      {
         var _loc1_:int = this.mouseX;
         var _loc2_:int = this.mouseY;
         if(_loc1_ < this._tooltip_hit_left || _loc1_ > this._tooltip_hit_right)
         {
            return null;
         }
         if(_loc2_ < this._tooltip_hit_top || _loc2_ > this._tooltip_hit_bottom)
         {
            return null;
         }
         if(_loc2_ >= this._textArmorBreak.y)
         {
            return StatType.ARMOR_BREAK;
         }
         if(_loc2_ >= this._textExertion.y)
         {
            return StatType.EXERTION;
         }
         if(_loc2_ >= this._textWillpower.y)
         {
            return StatType.WILLPOWER;
         }
         if(_loc2_ >= this._textStrength.y)
         {
            return StatType.STRENGTH;
         }
         if(_loc2_ >= this._textArmor.y)
         {
            return StatType.ARMOR;
         }
         return null;
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         this._updateTooltip();
      }
      
      private function _updateTooltip() : void
      {
         var _loc1_:StatType = null;
         var _loc2_:TextField = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         _loc1_ = this._getTooltipStat();
         if(!_loc1_)
         {
            this._tooltip.setContent(null,null);
            this._tooltip.visible = false;
         }
         else
         {
            this._tooltip.visible = true;
            if(this._tooltip.setContent(this._entity as IBattleEntity,_loc1_))
            {
               _loc2_ = this._statTexts[_loc1_];
               _loc3_ = !!_loc2_ ? int(_loc2_.x + _loc2_.width) : int(this.mouseX);
               _loc3_ += 10;
               _loc4_ = !!_loc2_ ? int(_loc2_.y) : int(this.mouseY);
               _loc5_ = new Point(_loc3_,_loc4_);
               _loc6_ = this.localToGlobal(_loc5_);
               if(this._tooltip.parent == this)
               {
                  this.removeChild(this._tooltip);
               }
               if(!this._tooltip.parent)
               {
                  PlatformFlash.stage.addChild(this._tooltip);
               }
               this._tooltip.x = _loc6_.x;
               this._tooltip.y = _loc6_.y;
            }
         }
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         ++this.bb;
         this.hideAllTooltips();
      }
      
      public function set entity(param1:IEntity) : void
      {
         this._entity = param1;
         if(this._tooltip.visible)
         {
            this._updateTooltip();
         }
         this._defStats = !!param1 ? param1.def.stats : null;
         this.stats = !!param1 ? param1.stats : null;
      }
      
      private function set stats(param1:Stats) : void
      {
         var _loc2_:int = 0;
         if(this._stats == param1)
         {
            return;
         }
         if(this._stats)
         {
            this._stats.getStat(StatType.STRENGTH).removeEventListener(StatEvent.CHANGE,this.statHandler);
            this._stats.getStat(StatType.ARMOR).removeEventListener(StatEvent.CHANGE,this.statHandler);
            this._stats.getStat(StatType.WILLPOWER).removeEventListener(StatEvent.CHANGE,this.statHandler);
            this._stats.getStat(StatType.EXERTION).removeEventListener(StatEvent.CHANGE,this.statHandler);
            this._stats.getStat(StatType.ARMOR_BREAK).removeEventListener(StatEvent.CHANGE,this.statHandler);
         }
         this._stats = param1;
         if(this._stats)
         {
            this._stats.getStat(StatType.STRENGTH).addEventListener(StatEvent.CHANGE,this.statHandler);
            this._stats.getStat(StatType.ARMOR).addEventListener(StatEvent.CHANGE,this.statHandler);
            this._stats.getStat(StatType.WILLPOWER).addEventListener(StatEvent.CHANGE,this.statHandler);
            this._stats.getStat(StatType.EXERTION).addEventListener(StatEvent.CHANGE,this.statHandler);
            this._stats.getStat(StatType.ARMOR_BREAK).addEventListener(StatEvent.CHANGE,this.statHandler);
            if(this._injury_icon)
            {
               _loc2_ = this._stats.getValue(StatType.INJURY);
               this._injury_icon.visible = _loc2_ > 0;
               this._injury_icon.visible = false;
            }
            this.setIconsForStatTypes();
         }
         this.statHandler(null);
      }
      
      private function clearIcons() : void
      {
         var _loc1_:Object = null;
         var _loc2_:StatType = null;
         var _loc3_:Vector.<GuiIcon> = null;
         var _loc4_:GuiIcon = null;
         for(_loc1_ in this._iconsForStat)
         {
            _loc2_ = _loc1_ as StatType;
            _loc3_ = this._iconsForStat[_loc1_];
            if(_loc3_)
            {
               for each(_loc4_ in _loc3_)
               {
                  if(_loc4_)
                  {
                     if(_loc4_.parent)
                     {
                        _loc4_.parent.removeChild(_loc4_);
                     }
                     _loc4_.release();
                  }
               }
               this._iconsForStat[_loc1_] = null;
            }
         }
      }
      
      private function setIconsForStatTypes() : void
      {
         this.clearIcons();
         this.setIconsForStatType(StatType.STRENGTH);
         this.setIconsForStatType(StatType.ARMOR);
         this.setIconsForStatType(StatType.WILLPOWER);
         this.setIconsForStatType(StatType.EXERTION);
         this.setIconsForStatType(StatType.ARMOR_BREAK);
      }
      
      private function setIconsForStatType(param1:StatType) : void
      {
         var _loc3_:int = 0;
         var _loc4_:GuiIcon = null;
         var _loc5_:TextField = null;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc2_:Vector.<GuiIcon> = GuiBattleStatFlagTooltip.getIconsForStat(_context,this._entity as IBattleEntity,param1);
         if(_loc2_)
         {
            _loc3_ = 0;
            for each(_loc4_ in _loc2_)
            {
               _loc4_.layout = GuiIconLayoutType.CENTER_FIT;
               _loc5_ = this._statTexts[param1];
               addChild(_loc4_);
               if(_loc5_)
               {
                  _loc6_ = _loc5_.height;
                  _loc7_ = _loc4_.scaleX;
                  _loc4_.setTargetSize(_loc6_,_loc6_);
                  _loc4_.x = _loc5_.x + _loc5_.width + _loc3_ - (_loc7_ - 1) * _loc6_ / 2;
                  _loc4_.y = _loc5_.y - (_loc7_ - 1) * _loc6_ / 2;
               }
               _loc3_ += _loc4_.targetWidth;
            }
         }
         this._iconsForStat[param1] = _loc2_;
      }
      
      private function statHandler(param1:StatEvent) : void
      {
         if(!this._stats)
         {
            return;
         }
         if(!this._textStrength)
         {
            return;
         }
         this._textStrength.htmlText = this.makeStatText(StatType.STRENGTH);
         this._textArmor.htmlText = this.makeStatText(StatType.ARMOR);
         this._textWillpower.htmlText = this.makeStatText(StatType.WILLPOWER);
         if(this._textExertion)
         {
            this._textExertion.text = this._stats.getValue(StatType.EXERTION).toString();
         }
         if(this._textArmorBreak)
         {
            this._textArmorBreak.text = this._stats.getValue(StatType.ARMOR_BREAK).toString();
         }
      }
      
      private function makeStatText(param1:StatType) : String
      {
         var _loc5_:* = null;
         var _loc6_:int = 0;
         var _loc2_:Stat = this._stats.getStat(param1);
         var _loc3_:int = _loc2_.value;
         var _loc4_:int = _loc2_.original;
         if(_loc3_ >= 0 && _loc4_ >= 0 && _loc3_ <= MAX_STAT_CACHE && _loc4_ <= MAX_STAT_CACHE)
         {
            _loc6_ = _loc4_ * (MAX_STAT_CACHE + 1) + _loc3_;
            _loc5_ = String(_statTextCache[_loc6_]);
            if(!_loc5_)
            {
               _loc5_ = "<font size=\'22\'>" + _loc3_ + "/</font><font size=\'16.5\'>" + _loc4_ + "</font>";
               _statTextCache[_loc6_] = _loc5_;
            }
            return _loc5_;
         }
         return "<font size=\'22\'>" + _loc3_ + "/</font><font size=\'16.5\'>" + _loc4_ + "</font>";
      }
   }
}
