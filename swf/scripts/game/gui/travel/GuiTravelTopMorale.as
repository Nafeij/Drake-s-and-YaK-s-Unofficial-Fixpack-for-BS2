package game.gui.travel
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Elastic;
   import engine.core.util.ColorUtil;
   import engine.core.util.StringUtil;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiTravelTopMorale extends GuiBase
   {
      
      private static var COLOR_RED:uint = 14037788;
      
      private static var COLOR_GREEN:uint = 1889843;
       
      
      public var _button$morale_tt_low:ButtonWithIndex;
      
      public var _button$morale_tt_high:ButtonWithIndex;
      
      public var _button$morale_tt_med:ButtonWithIndex;
      
      public var _button$morale_tt_medlow:ButtonWithIndex;
      
      public var _button$morale_tt_medhigh:ButtonWithIndex;
      
      private var _sagaDispatcher:IEventDispatcher;
      
      private var _textWillpowerAmount:TextField;
      
      public var _holderOfText:MovieClip;
      
      public var _tooltip:MovieClip;
      
      private var _caravanVars:IVariableBag;
      
      private var _mouseHovering:Boolean;
      
      private var _hovering:Boolean;
      
      public function GuiTravelTopMorale()
      {
         super();
         this._holderOfText = getChildByName("holderOfText") as MovieClip;
         this._tooltip = getChildByName("tooltip") as MovieClip;
      }
      
      public function get caravanVars() : IVariableBag
      {
         return this._caravanVars;
      }
      
      public function set caravanVars(param1:IVariableBag) : void
      {
         if(this._caravanVars == param1)
         {
            return;
         }
         if(this._caravanVars)
         {
            this._caravanVars.removeEventListener(VariableEvent.TYPE,this.caravanVarHandler);
         }
         this._caravanVars = param1;
         if(this._caravanVars)
         {
            this._caravanVars.addEventListener(VariableEvent.TYPE,this.caravanVarHandler);
         }
      }
      
      public function get sagaDispatcher() : IEventDispatcher
      {
         return this._sagaDispatcher;
      }
      
      public function set sagaDispatcher(param1:IEventDispatcher) : void
      {
         if(this._sagaDispatcher == param1)
         {
            return;
         }
         if(this._sagaDispatcher)
         {
            this._sagaDispatcher.removeEventListener(SagaEvent.EVENT_CLEANUP,this.sagaCleanupHandler);
         }
         this._sagaDispatcher = param1;
         if(this._sagaDispatcher)
         {
            this._sagaDispatcher.addEventListener(SagaEvent.EVENT_CLEANUP,this.sagaCleanupHandler);
         }
      }
      
      private function sagaCleanupHandler(param1:Event) : void
      {
         this.sagaDispatcher = null;
         this.caravanVars = null;
      }
      
      public function init(param1:IGuiContext, param2:IEventDispatcher, param3:IVariableBag) : void
      {
         super.initGuiBase(param1);
         this._button$morale_tt_low = requireGuiChild("button$morale_tt_low") as ButtonWithIndex;
         this._button$morale_tt_high = requireGuiChild("button$morale_tt_high") as ButtonWithIndex;
         this._button$morale_tt_med = requireGuiChild("button$morale_tt_med") as ButtonWithIndex;
         this._button$morale_tt_medlow = requireGuiChild("button$morale_tt_medlow") as ButtonWithIndex;
         this._button$morale_tt_medhigh = requireGuiChild("button$morale_tt_medhigh") as ButtonWithIndex;
         this._button$morale_tt_low.guiButtonContext = param1;
         this._button$morale_tt_high.guiButtonContext = param1;
         this._button$morale_tt_med.guiButtonContext = param1;
         this._button$morale_tt_medlow.guiButtonContext = param1;
         this._button$morale_tt_medhigh.guiButtonContext = param1;
         this.sagaDispatcher = param2;
         this.caravanVars = param3;
         if(!param3)
         {
            param1.logger.error("Attempt to show travel hud with no caravan set!");
            return;
         }
         if(this._holderOfText)
         {
            this._holderOfText.visible = false;
            this._textWillpowerAmount = this._holderOfText.getChildByName("textWillpowerAmount") as TextField;
            this._holderOfText.mouseEnabled = this._holderOfText.mouseChildren = false;
         }
         if(this._tooltip)
         {
            this._tooltip.mouseEnabled = this._tooltip.mouseChildren = false;
            this._tooltip.visible = false;
            addEventListener(MouseEvent.ROLL_OVER,this.mouseOverHandler);
            addEventListener(MouseEvent.ROLL_OUT,this.mouseOutHandler);
         }
         this.update();
      }
      
      public function showBattleWillpower() : void
      {
         if(!this._holderOfText || !this.sagaDispatcher || !this.caravanVars)
         {
            return;
         }
         this._holderOfText.visible = true;
         var _loc1_:int = this.caravanVars.fetch(SagaVar.VAR_MORALE_BONUS_WILLPOWER,VariableType.INTEGER).asInteger;
         var _loc2_:String = _loc1_ >= 0 ? ColorUtil.colorStr(COLOR_GREEN) : ColorUtil.colorStr(COLOR_RED);
         this._textWillpowerAmount.htmlText = "<font color=\'" + _loc2_ + "\'>" + StringUtil.numberWithSign(_loc1_,0) + "</font>";
         if(_loc1_ != 0)
         {
            this._holderOfText.scaleX = this._holderOfText.scaleY = 0;
            TweenMax.to(this._holderOfText,0.5,{
               "delay":1,
               "scaleX":1,
               "scaleY":1,
               "ease":Elastic.easeInOut,
               "onComplete":this.tweenHolderTextComplete
            });
         }
         else
         {
            this._holderOfText.visible = false;
         }
      }
      
      private function tweenHolderTextComplete() : void
      {
         TweenMax.to(this._holderOfText,0,{
            "delay":2,
            "visible":false
         });
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         this._mouseHovering = true;
         this.checkTooltips();
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         this._mouseHovering = false;
         this.checkTooltips();
      }
      
      public function setHovering(param1:Boolean) : void
      {
         this._hovering = param1;
         this.checkTooltips();
      }
      
      private function checkTooltips() : void
      {
         var _loc1_:Boolean = this._hovering || this._mouseHovering;
         this._button$morale_tt_high.setHovering(_loc1_);
         this._button$morale_tt_low.setHovering(_loc1_);
         this._button$morale_tt_med.setHovering(_loc1_);
         this._button$morale_tt_medhigh.setHovering(_loc1_);
         this._button$morale_tt_medlow.setHovering(_loc1_);
         if(this._tooltip)
         {
            if(this._holderOfText)
            {
               TweenMax.killTweensOf(this._holderOfText);
               this._holderOfText.visible = _loc1_;
               this._holderOfText.scaleX = this._holderOfText.scaleY = 1;
            }
            this._tooltip.visible = _loc1_;
         }
      }
      
      private function caravanVarHandler(param1:VariableEvent) : void
      {
         if(!this.caravanVars)
         {
            return;
         }
         if(!param1 || param1.value.def.name == SagaVar.VAR_MORALE)
         {
            this.updateMorale();
         }
      }
      
      public function cleanup() : void
      {
         removeEventListener(MouseEvent.ROLL_OVER,this.mouseOverHandler);
         removeEventListener(MouseEvent.ROLL_OUT,this.mouseOutHandler);
         this.sagaDispatcher = null;
         this.caravanVars = null;
         this._button$morale_tt_high.cleanup();
         this._button$morale_tt_low.cleanup();
         this._button$morale_tt_med.cleanup();
         this._button$morale_tt_medhigh.cleanup();
         this._button$morale_tt_medlow.cleanup();
         cleanupGuiBase();
      }
      
      private function update() : void
      {
         this.caravanVarHandler(null);
      }
      
      private function updateMorale() : void
      {
         var _loc2_:MovieClip = null;
         if(!this._caravanVars)
         {
            return;
         }
         var _loc1_:int = this._caravanVars.fetch(SagaVar.VAR_MORALE_CATEGORY,VariableType.INTEGER).asInteger;
         switch(_loc1_)
         {
            case 1:
               _loc2_ = this._button$morale_tt_low;
               break;
            case 2:
               _loc2_ = this._button$morale_tt_medlow;
               break;
            case 3:
               _loc2_ = this._button$morale_tt_med;
               break;
            case 4:
               _loc2_ = this._button$morale_tt_medhigh;
               break;
            default:
               _loc2_ = this._button$morale_tt_high;
         }
         this.onlyVisible(this._button$morale_tt_low,_loc2_);
         this.onlyVisible(this._button$morale_tt_medlow,_loc2_);
         this.onlyVisible(this._button$morale_tt_med,_loc2_);
         this.onlyVisible(this._button$morale_tt_medhigh,_loc2_);
         this.onlyVisible(this._button$morale_tt_high,_loc2_);
      }
      
      private function onlyVisible(param1:MovieClip, param2:MovieClip) : void
      {
         param1.visible = param1 == param2;
      }
   }
}
