package game.gui.battle.initiative
{
   import com.greensock.TweenMax;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.ColorUtil;
   import engine.entity.def.IEntityDef;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   import engine.stat.model.Stats;
   import flash.display.Sprite;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiInitiativeUnitInfoBanner extends GuiBase
   {
       
      
      private var _stats:Stats;
      
      private var _defStats:Stats;
      
      private var startingParent:Sprite;
      
      public var _textName:TextField;
      
      private var oldStatText_str:OldStatText;
      
      private var oldStatText_arm:OldStatText;
      
      private var oldStatText_wil:OldStatText;
      
      private var oldStatText_exe:OldStatText;
      
      private var oldStatText_brk:OldStatText;
      
      private var _cachedColorStr:String;
      
      private var _cachedColorStr_color:uint;
      
      private var _cachedEntityName:String;
      
      public function GuiInitiativeUnitInfoBanner()
      {
         super();
         this.oldStatText_str = new OldStatText(StatType.STRENGTH,requireGuiChild("textStrength") as TextField);
         this.oldStatText_arm = new OldStatText(StatType.ARMOR,requireGuiChild("textArmor") as TextField);
         this.oldStatText_wil = new OldStatText(StatType.WILLPOWER,requireGuiChild("textWillpower") as TextField);
         this.oldStatText_exe = new OldStatText(StatType.EXERTION,getChildByName("textExertion") as TextField);
         this.oldStatText_brk = new OldStatText(StatType.ARMOR_BREAK,getChildByName("textArmorBreak") as TextField);
         this._textName = getChildByName("textName") as TextField;
      }
      
      public function set entity(param1:IBattleEntity) : void
      {
         var _loc2_:uint = 0;
         if(param1 == null)
         {
            this.clear();
         }
         else
         {
            _loc2_ = 44799;
            if(Boolean(param1) && Boolean(param1.isEnemy))
            {
               _loc2_ = 16718876;
            }
            this.setEntityName(param1.name,_loc2_);
            this._defStats = param1.def.stats;
            this.stats = param1.stats;
            if(param1.isPlayer)
            {
               gotoAndStop(1);
            }
            else
            {
               gotoAndStop(2);
            }
         }
      }
      
      public function setEntityByDef(param1:IEntityDef, param2:Boolean) : void
      {
         var _loc3_:uint = 0;
         if(param1 == null)
         {
            this.clear();
         }
         else
         {
            _loc3_ = 44799;
            if(!param2)
            {
               _loc3_ = 16718876;
            }
            this.setEntityName(param1.name,_loc3_);
            this.stats = this._defStats = param1.stats;
            if(param2)
            {
               gotoAndStop(1);
            }
            else
            {
               gotoAndStop(2);
            }
         }
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         this.startingParent = parent as Sprite;
         mouseEnabled = false;
         mouseChildren = false;
         this._textName.mouseEnabled = false;
         this._textName.text = "";
         stop();
         this.setVisible(false);
      }
      
      public function cleanup() : void
      {
         this.stats = null;
         super.cleanupGuiBase();
      }
      
      private function set stats(param1:Stats) : void
      {
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
         }
         this.statHandler(null);
      }
      
      private function clear() : void
      {
         this.stats = null;
         this._defStats = null;
         this._textName.text = "";
         this._cachedEntityName = "";
         this._cachedColorStr = "";
      }
      
      private function statHandler(param1:StatEvent) : void
      {
         if(!this._stats)
         {
            return;
         }
         this.makeStatText(this.oldStatText_str);
         this.makeStatText(this.oldStatText_arm);
         this.makeStatText(this.oldStatText_wil);
         this.makeStatTextSimple(this.oldStatText_exe);
         this.makeStatTextSimple(this.oldStatText_brk);
      }
      
      private function makeStatText(param1:OldStatText) : Boolean
      {
         if(!param1.field)
         {
            return false;
         }
         var _loc2_:Stat = this._stats.getStat(param1.statType);
         var _loc3_:int = _loc2_.value;
         var _loc4_:int = _loc2_.original;
         if(_loc3_ != param1.cur || _loc4_ != param1.max)
         {
            param1.cur = _loc3_;
            param1.max = _loc4_;
            param1.text = "<font size=\'22\'>" + _loc3_ + "/</font><font size=\'16\'>" + _loc4_ + "</font>";
            param1.field.htmlText = param1.text;
            return true;
         }
         return false;
      }
      
      private function makeStatTextSimple(param1:OldStatText) : Boolean
      {
         if(!param1.field)
         {
            return false;
         }
         var _loc2_:Stat = this._stats.getStat(param1.statType);
         var _loc3_:int = _loc2_.value;
         if(_loc3_ != param1.cur)
         {
            param1.cur = _loc3_;
            param1.text = _loc3_.toString();
            param1.field.text = param1.text;
            return true;
         }
         return false;
      }
      
      private function onDoneHiding() : void
      {
         visible = false;
      }
      
      public function setVisible(param1:Boolean) : void
      {
         TweenMax.killTweensOf(this);
         if(param1)
         {
            visible = true;
            if(alpha != 1)
            {
               TweenMax.to(this,0.2,{"alpha":1});
            }
         }
         else if(alpha != 0)
         {
            TweenMax.to(this,0.2,{
               "alpha":0,
               "onComplete":this.onDoneHiding
            });
         }
         else
         {
            this.onDoneHiding();
         }
      }
      
      public function setEntityName(param1:String, param2:uint) : void
      {
         if(this._cachedEntityName == param1 && this._cachedColorStr_color == param2)
         {
            return;
         }
         this._cachedEntityName = param1;
         if(param2 != this._cachedColorStr_color || !this._cachedColorStr)
         {
            this._cachedColorStr_color = param2;
            this._cachedColorStr = ColorUtil.colorStr(param2);
         }
         var _loc3_:* = "<font color=\'" + this._cachedColorStr + "\'>" + param1 + "</font>";
         this._textName.htmlText = _loc3_;
         _context.currentLocale.fixTextFieldFormat(this._textName);
      }
   }
}

import engine.stat.def.StatType;
import flash.text.TextField;

class OldStatText
{
    
   
   public var statType:StatType;
   
   public var text:String;
   
   public var cur:int = 2147483647;
   
   public var max:int;
   
   public var field:TextField;
   
   public function OldStatText(param1:StatType, param2:TextField)
   {
      super();
      this.statType = param1;
      this.field = param2;
   }
}
