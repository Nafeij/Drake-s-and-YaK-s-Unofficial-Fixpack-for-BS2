package game.gui.battle
{
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiUtil;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiDeploymentTimer extends GuiBase implements IGuiDeploymentTimer
   {
       
      
      public var _deployText:TextField;
      
      public var _deploymentFrame:ButtonWithIndex;
      
      public var _timerRing:MovieClip;
      
      public var readyTextColor:uint = 15811878;
      
      public var holdTextColor:uint = 8759646;
      
      public var listener:IGuiBattleHudListener;
      
      public var startingParent:Sprite;
      
      private var gp_y:GuiGpBitmap;
      
      private var holding:Boolean;
      
      public function GuiDeploymentTimer()
      {
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.Y,true);
         super();
         this.gp_y.scale = 0.75;
         addChild(this.gp_y);
         mouseEnabled = false;
         mouseChildren = true;
      }
      
      public function init(param1:IGuiContext, param2:IGuiBattleHudListener) : void
      {
         super.initGuiBase(param1);
         this._timerRing = getChildByName("timerRing") as MovieClip;
         this._timerRing.gotoAndStop(1);
         this._timerRing.mouseChildren = this._timerRing.mouseEnabled = false;
         this._deploymentFrame = getChildByName("deploymentFrame") as ButtonWithIndex;
         this._deploymentFrame.mouseEnabled = false;
         this._deploymentFrame.mouseChildren = true;
         this._deployText = getChildByName("deployText") as TextField;
         this._deployText.mouseEnabled = false;
         this.listener = param2;
         this.startingParent = this.parent as Sprite;
         registerScalableTextfield(this._deployText);
         this.gp_y.x = -this.gp_y.width / 2;
         this.gp_y.y = this._timerRing.height - this.gp_y.height / 2;
         this.handleLocaleChange();
      }
      
      public function refreshDeploymentTimer() : void
      {
         this._deployText.textColor = this.readyTextColor;
         this._deploymentFrame.setStateToNormal();
         this._deploymentFrame.disableGotoOnStateChange = false;
         this._deploymentFrame.enabled = true;
         this._deploymentFrame.mouseDown = this._deploymentFrame.mouseChildren = true;
         this.holding = false;
         this.handleLocaleChange();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         if(this.holding)
         {
            this._deployText.htmlText = context.translate("hold");
         }
         else
         {
            this._deployText.htmlText = context.translate("ready");
         }
         _context.currentLocale.fixTextFieldFormat(this._deployText);
         scaleTextfields();
      }
      
      public function cleanup() : void
      {
         GuiGp.releasePrimaryBitmap(this.gp_y);
         this.gp_y = null;
         this.listener = null;
         this._deploymentFrame.cleanup();
         super.cleanupGuiBase();
      }
      
      private function readyButtonDownHandler(param1:ButtonWithIndex) : void
      {
         if(!visible)
         {
            return;
         }
         if(this.listener.guiBattleHudDeployReady())
         {
            this.holding = true;
            this.handleLocaleChange();
            this._deployText.textColor = this.holdTextColor;
            this._deploymentFrame.setStateToNormal();
            this._deploymentFrame.disableGotoOnStateChange = true;
            this._deploymentFrame.enabled = false;
            this._deploymentFrame.mouseDown = this._deploymentFrame.mouseChildren = false;
         }
         else
         {
            _context.playSound("ui_error");
         }
      }
      
      public function deployTimerPercent(param1:Number) : void
      {
         var _loc2_:int = 1 + (this._timerRing.framesLoaded - 1) * param1;
         this._timerRing.gotoAndStop(_loc2_);
      }
      
      public function showDeploy(param1:Boolean, param2:Boolean) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         visible = param1;
         GuiUtil.updateDisplayList(this,this.startingParent);
         mouseChildren = param1;
         if(param1)
         {
            this._deploymentFrame.forceHovering(false);
            this._deploymentFrame.setDownFunction(this.readyButtonDownHandler);
            _loc3_ = parent;
            if(_loc3_)
            {
               if(_loc3_.getChildIndex(this) != _loc3_.numChildren - 1)
               {
                  _loc3_.removeChild(this);
                  _loc3_.addChild(this);
               }
            }
         }
         else
         {
            this._deploymentFrame.setDownFunction(null);
         }
      }
   }
}
