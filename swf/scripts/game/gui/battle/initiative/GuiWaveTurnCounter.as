package game.gui.battle.initiative
{
   import com.greensock.TweenMax;
   import engine.battle.wave.BattleWave;
   import engine.core.util.ColorUtil;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.GuiNineSliceToolTip;
   import game.gui.IGuiContext;
   import game.gui.battle.IGuiWaveTurnCounter;
   
   public class GuiWaveTurnCounter extends GuiBase implements IGuiWaveTurnCounter
   {
      
      public static const COUNTDOWN_TIME:Number = 0.25;
       
      
      private var _backgroundMC:MovieClip;
      
      private var _toolTip:GuiNineSliceToolTip;
      
      private var _countTextHolder:MovieClip;
      
      private var _countTextField:TextField;
      
      private var _turnsRemaining:int;
      
      private var _turnsRemainingSlider:MovieClip;
      
      private var _currentSliderFrame:int;
      
      private var _active:Boolean;
      
      public function GuiWaveTurnCounter()
      {
         super();
      }
      
      public function get currentSliderFrame() : int
      {
         return this._currentSliderFrame;
      }
      
      public function set currentSliderFrame(param1:int) : void
      {
         this._currentSliderFrame = param1;
         if(this._turnsRemainingSlider)
         {
            this._turnsRemainingSlider.gotoAndStop(this._currentSliderFrame);
         }
      }
      
      public function get textScale() : Number
      {
         return this._countTextHolder.scaleX;
      }
      
      public function set textScale(param1:Number) : void
      {
         this._countTextHolder.scaleX = this._countTextHolder.scaleY = param1;
      }
      
      public function init(param1:IGuiContext, param2:MovieClip) : void
      {
         initGuiBase(param1);
         this._backgroundMC = param2;
         this._countTextHolder = requireGuiChild("countTextHolder") as MovieClip;
         this._countTextField = requireGuiChild("countTextField",this._countTextHolder) as TextField;
         this._turnsRemainingSlider = requireGuiChild("timer_ring_wave") as MovieClip;
         this._toolTip = requireGuiChild("toolTip") as GuiNineSliceToolTip;
         this._toolTip.init(param1,GuiNineSliceToolTip.RIGHT,GuiNineSliceToolTip.BOTTOM);
         this._toolTip.setText(param1.translate("tt_wave_turn_counter"));
         this._toolTip.visible = false;
         addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         addEventListener(MouseEvent.ROLL_OUT,this.mouseOutHandler);
         this.UpdateTextField(null);
         this.currentSliderFrame = 1;
      }
      
      public function cleanup() : void
      {
         this._countTextField = null;
         removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         removeEventListener(MouseEvent.ROLL_OUT,this.mouseOutHandler);
         if(this._toolTip)
         {
            this._toolTip.cleanup();
            this._toolTip = null;
         }
         TweenMax.killTweensOf(this);
         cleanupGuiBase();
      }
      
      public function SetTurnCount(param1:BattleWave) : void
      {
         this._turnsRemaining = param1.turnsRemaining;
         this.UpdateTextField(param1);
         var _loc2_:int = this.calcFrame(1 - this._turnsRemaining / param1.turnsPerWave);
         TweenMax.killTweensOf(this);
         this.textScale = 1.2;
         TweenMax.to(this,COUNTDOWN_TIME,{
            "currentSliderFrame":_loc2_,
            "textScale":1
         });
         if(this._turnsRemaining <= 0 || param1.isFinalWave)
         {
            this.visible = false;
         }
         else
         {
            this.visible = true;
         }
      }
      
      private function calcFrame(param1:Number) : int
      {
         return Math.max(1,Math.min(this._turnsRemainingSlider.totalFrames,Math.round(this._turnsRemainingSlider.totalFrames * param1)));
      }
      
      override public function get visible() : Boolean
      {
         return super.visible;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         this._backgroundMC.visible = super.visible = param1;
      }
      
      private function UpdateTextField(param1:BattleWave) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = null;
         if(this._countTextField)
         {
            _loc2_ = this.GetColorForTurnsRemaining(param1);
            _loc3_ = "<font color=\'" + _loc2_ + "\'>" + this._turnsRemaining + "</font>";
            this._countTextField.htmlText = _loc3_;
            _context.currentLocale.fixTextFieldFormat(this._countTextField);
         }
      }
      
      private function GetColorForTurnsRemaining(param1:BattleWave) : String
      {
         if(param1 != null && this._turnsRemaining <= param1.lowTurnWarning && Boolean(param1.lowTurnColor))
         {
            return param1.lowTurnColor;
         }
         return ColorUtil.colorStr(16777215);
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         this._toolTip.visible = true;
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         this._toolTip.visible = false;
      }
      
      override public function handleLocaleChange() : void
      {
         this._toolTip.setText(context.translate("tt_wave_turn_counter"));
      }
   }
}
