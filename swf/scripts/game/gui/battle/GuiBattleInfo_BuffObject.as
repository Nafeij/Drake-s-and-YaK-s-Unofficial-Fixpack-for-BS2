package game.gui.battle
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.model.EffectSymbols;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import game.gui.GuiIcon;
   import game.gui.IGuiContext;
   
   public class GuiBattleInfo_BuffObject
   {
       
      
      private var gbi:GuiBattleInfo;
      
      private var logger:ILogger;
      
      private var context:IGuiContext;
      
      private var _icon:GuiIcon;
      
      private var _ability:BattleAbility;
      
      private var _target:IBattleEntity;
      
      private var _tooltips:Array;
      
      public var buffMovieClip:MovieClip;
      
      public var buffTextField:TextField;
      
      public function GuiBattleInfo_BuffObject(param1:GuiBattleInfo, param2:MovieClip)
      {
         var _loc4_:DisplayObject = null;
         super();
         this.gbi = param1;
         this.context = param1.context;
         this.logger = this.context.logger;
         this.buffMovieClip = param2;
         this.buffTextField = this.buffMovieClip.getChildByName("buffTextField") as TextField;
         this.buffMovieClip.visible = false;
         this.buffMovieClip.mouseEnabled = this.buffMovieClip.mouseChildren = true;
         this.buffTextField.mouseEnabled = true;
         var _loc3_:int = 0;
         while(_loc3_ < this.buffMovieClip.numChildren)
         {
            _loc4_ = this.buffMovieClip.getChildAt(_loc3_);
            if(_loc4_ != this.buffTextField)
            {
               _loc4_.visible = false;
            }
            _loc3_++;
         }
         this.buffMovieClip.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.buffMovieClip.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
      }
      
      public function setBuffInfo(param1:IBattleEntity, param2:BattleAbility) : void
      {
         if(this._ability == param2 && this._target == param1)
         {
            return;
         }
         this._ability = param2;
         this._target = param1;
         this.doSetup();
      }
      
      public function set icon(param1:GuiIcon) : void
      {
         if(this._icon == param1)
         {
            return;
         }
         if(this._icon)
         {
            if(this._icon.parent)
            {
               this._icon.parent.removeChild(this._icon);
            }
            this._icon.release();
         }
         this._icon = param1;
         if(this._icon)
         {
            this._icon.name = "buff_icon";
            this.buffMovieClip.addChild(this._icon);
         }
      }
      
      private function doSetup() : void
      {
         if(!this._ability)
         {
            this.buffMovieClip.visible = false;
            return;
         }
         this._tooltips = null;
         this.buffMovieClip.visible = true;
         var _loc1_:* = this._ability.def.name;
         var _loc2_:String = this._ability.def.id;
         if(!_loc1_)
         {
            _loc1_ = "NONAME {" + _loc2_ + "}";
         }
         if(this._ability.def.level > 1)
         {
            _loc1_ += " (" + this._ability.def.level + ")";
         }
         this.buffTextField.text = !!_loc1_ ? _loc1_ : "";
         this.context.locale.fixTextFieldFormat(this.buffTextField);
         this.buffTextField.width = this.buffTextField.textWidth + 10;
         this.icon = this.context.getAbilityBuffIcon(this._ability.def);
      }
      
      private function performStringReplacement(param1:String) : String
      {
         var _loc2_:Effect = null;
         var _loc3_:EffectSymbols = null;
         if(!param1)
         {
            return param1;
         }
         for each(_loc2_ in this._ability.effects)
         {
            if(this._ability.caster == this._target || _loc2_.target == this._target)
            {
               _loc3_ = new EffectSymbols(_loc2_);
               param1 = _loc3_.replaceSymbols(param1);
            }
         }
         return param1;
      }
      
      private function getTooltipText() : String
      {
         if(!this._ability)
         {
            return null;
         }
         var _loc1_:String = this._ability.def.id;
         var _loc2_:String = this.context.translateCategoryRaw(_loc1_ + "_buff_verbose",LocaleCategory.ABILITY);
         if(_loc2_)
         {
            return this.performStringReplacement(_loc2_);
         }
         var _loc3_:String = this._ability.def.descriptionBrief;
         return this.performStringReplacement(_loc3_);
      }
      
      public function cleanup() : void
      {
         this.icon = null;
         if(this.buffMovieClip)
         {
            this.buffMovieClip.removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
            this.buffMovieClip.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         }
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         if(!this.buffMovieClip || !this.buffMovieClip.visible)
         {
            return;
         }
         this.killAllTooltips();
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         if(!this.buffMovieClip || !this.buffMovieClip.visible)
         {
            return;
         }
         if(!this._tooltips)
         {
            _loc4_ = this.getTooltipText();
            this._tooltips = [];
            this._tooltips.push(_loc4_);
         }
         var _loc2_:Point = new Point(this.buffMovieClip.width / 2,this.buffMovieClip.height);
         var _loc3_:Point = this.buffMovieClip.localToGlobal(_loc2_);
         this.gbi.listener.guiInitiativeTooltipOverride(this._tooltips,_loc3_);
      }
      
      public function killAllTooltips() : void
      {
         if(this._tooltips)
         {
            if(Boolean(this.gbi) && Boolean(this.gbi.listener))
            {
               this.gbi.listener.guiInitiativeCancelTooltipOverride(this._tooltips);
            }
            this._tooltips = null;
         }
      }
   }
}
