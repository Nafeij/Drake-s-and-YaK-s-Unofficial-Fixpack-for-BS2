package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import engine.gui.GuiGpNavButtonGlowy;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.SagaSurvivalDef_ScoreData;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.getTimer;
   import game.gui.IGuiContext;
   
   public class GuiSagaSurvivalWin_Trio
   {
      
      public static var RIBBON_X_START:int = -853;
      
      public static var RIBBON_X_MIN:int = -590;
      
      public static var RIBBON_X_MAX:int = 129;
       
      
      public var num:TextField;
      
      public var score:TextField;
      
      public var label:TextField;
      
      public var ribbon:GuiGpNavButtonGlowy;
      
      public var win:GuiSagaSurvivalWin;
      
      private var _value_num:int;
      
      private var _value_score:int;
      
      private var _display_num:int;
      
      private var glisten_throttle:int;
      
      public var name:String;
      
      private var sd:SagaSurvivalDef_ScoreData;
      
      private var _tooltipHandle:int;
      
      private var tm0:TweenMax;
      
      private var tm1:TweenMax;
      
      private var _context:IGuiContext;
      
      private var _mustVictory:Boolean;
      
      private var _hovering:Boolean;
      
      public function GuiSagaSurvivalWin_Trio(param1:String, param2:GuiSagaSurvivalWin, param3:TextField, param4:TextField, param5:TextField, param6:GuiGpNavButtonGlowy)
      {
         super();
         this._context = param2.context;
         this.label = param3;
         this.name = param1;
         this.win = param2;
         this.num = param4;
         this.score = param5;
         this.ribbon = param6;
         param3.visible = false;
         param6.visible = false;
         param4.mouseEnabled = param5.mouseEnabled = false;
         this.sd = this._context.saga.survival.def.getScoreData(param1);
         param6.mouseEnabled = true;
         param3.mouseEnabled = true;
         param6.addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         param6.addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         param6.addEventListener(Event.SELECT,this.selectHandler);
      }
      
      public function get hovering() : Boolean
      {
         return this._hovering;
      }
      
      public function set hovering(param1:Boolean) : void
      {
         var _loc2_:Saga = null;
         var _loc3_:SagaSurvivalDef_ScoreData = null;
         var _loc4_:String = null;
         var _loc5_:* = false;
         this._hovering = param1;
         if(this._hovering)
         {
            _loc2_ = this.win.context.saga;
            if(_loc2_)
            {
               if(_loc2_.survival)
               {
                  _loc3_ = _loc2_.survival.def.getScoreData(this.name);
                  if(_loc3_)
                  {
                     _loc4_ = _loc3_.getDisplayString(_loc2_.locale);
                     if(Boolean(_loc3_) && _loc3_.descending)
                     {
                        _loc5_ = _loc2_.survivalProgress >= _loc2_.survivalTotal;
                        if(!_loc5_)
                        {
                           _loc4_ += "\n<font color=\'#ff0000\'>" + _loc2_.locale.translateGui("ss_win_score_not_on_defeat") + "</font>";
                        }
                     }
                     this._tooltipHandle = this.win.showTooltip(_loc4_,this.num.x,this.num.y + this.num.height + 20);
                  }
               }
            }
         }
         else
         {
            this.win.hideTooltip(this._tooltipHandle);
            this._tooltipHandle = 0;
         }
      }
      
      public function cleanup() : void
      {
         this.ribbon.removeEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         this.ribbon.removeEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         this.ribbon.removeEventListener(Event.SELECT,this.selectHandler);
         TweenMax.killTweensOf(this);
         TweenMax.killTweensOf(this.ribbon);
         TweenMax.killTweensOf(this.score);
         this.num = null;
         this.score = null;
         this.label = null;
         this.ribbon = null;
         this.win = null;
      }
      
      public function set display_num(param1:int) : void
      {
         if(this._display_num == param1)
         {
            return;
         }
         this._display_num = param1;
         this.num.htmlText = this._display_num.toString();
         var _loc2_:int = getTimer();
         if(_loc2_ > this.glisten_throttle)
         {
            this.win.context.playSound("ui_stats_glisten");
            this.glisten_throttle = _loc2_ + 50;
         }
      }
      
      public function get display_num() : int
      {
         return this._display_num;
      }
      
      private function rollOutHandler(param1:MouseEvent) : void
      {
         this.hovering = false;
      }
      
      private function rollOverHandler(param1:MouseEvent) : void
      {
         this.hovering = true;
      }
      
      private function selectHandler(param1:Event) : void
      {
         this.hovering = true;
      }
      
      public function showValue(param1:int, param2:int) : void
      {
         this.num.htmlText = "";
         this.score.htmlText = "";
         this._display_num = 0;
         this._value_num = param1;
         this._value_score = param2;
         this.ribbon.x = RIBBON_X_START;
      }
      
      public function startAnimating() : void
      {
         var _loc1_:Saga = this.win.saga;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:SagaSurvivalDef_ScoreData = _loc1_.def.survival.scoreDatasByName[this.name];
         var _loc3_:int = _loc2_.maxDisplayScore;
         if(_loc2_.descending)
         {
            this._display_num = _loc2_.max;
         }
         this.label.visible = true;
         this.ribbon.visible = true;
         this.num.htmlText = this._display_num.toString();
         var _loc4_:Number = 0.5;
         this.tm0 = TweenMax.to(this,this.win._tt(_loc4_),{
            "display_num":this._value_num,
            "ease":Quad.easeIn,
            "onComplete":this.tweenCompleteHandler
         });
         var _loc5_:Number = MathUtil.clampValue(this._value_score / _loc3_,0,1);
         var _loc6_:int = MathUtil.lerp(RIBBON_X_MIN,RIBBON_X_MAX,_loc5_);
         this.tm1 = TweenMax.to(this.ribbon,this.win._tt(_loc4_),{
            "x":_loc6_,
            "ease":Quad.easeIn
         });
      }
      
      public function tweenCompleteHandler() : void
      {
         if(!this.score || !this.num)
         {
            return;
         }
         this.score.htmlText = this._value_score.toString();
         this.score.scaleX = this.score.scaleY = 1;
         var _loc1_:Number = this.score.x;
         var _loc2_:Number = this.score.y;
         var _loc3_:Number = 2;
         this.score.scaleX = this.score.scaleY = _loc3_;
         this.score.x -= 171 * 2;
         this.score.y -= 30;
         this.tm0 = TweenMax.to(this.score,this.win._tt(0.25),{
            "scaleX":1,
            "scaleY":1,
            "x":_loc1_,
            "y":_loc2_,
            "onComplete":this.scoreCompleteHandler
         });
         this.tm1 = null;
         this.win.context.playSound("ui_stats_total");
         this.win.showScoreLabel();
      }
      
      public function scoreCompleteHandler() : void
      {
         this.tm0 = null;
         this.win.handleTrioComplete(this);
      }
      
      public function speedThroughResults() : void
      {
         if(this.tm0)
         {
            this.tm0.complete();
         }
         if(this.tm1)
         {
            this.tm1.complete();
         }
      }
   }
}
