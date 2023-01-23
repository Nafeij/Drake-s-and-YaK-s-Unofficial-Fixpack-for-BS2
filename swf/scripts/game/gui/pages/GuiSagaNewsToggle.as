package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.IGuiSagaNews;
   import game.gui.IGuiSagaNewsToggle;
   
   public class GuiSagaNewsToggle extends GuiBase implements IGuiSagaNewsToggle
   {
       
      
      public var _button:ButtonWithIndex;
      
      public var _buttonUnseen:ButtonWithIndex;
      
      public var news:GuiSagaNews;
      
      public var gp_y:GuiGpBitmap;
      
      private var cmd_y:Cmd;
      
      private var _showButtonUnseen:Boolean;
      
      private var BUTTON_HIDE_Y:Number = 30;
      
      private var BUTTON_SHOW_Y:Number = 220;
      
      private var BUTTON_UNSEEN_SHOW_X:Number = 460;
      
      private var BUTTON_UNSEEN_HIDE_X:Number = 60;
      
      private var TWEEN_SPEED:Number = 2;
      
      public function GuiSagaNewsToggle()
      {
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.Y,true);
         this.cmd_y = new Cmd("cmd_news_y",this.cmdfunc_y);
         super();
         this._button = requireGuiChild("button") as ButtonWithIndex;
         this._buttonUnseen = requireGuiChild("unseen") as ButtonWithIndex;
         addChild(this.gp_y);
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaNews) : void
      {
         super.initGuiBase(param1);
         this.news = param2 as GuiSagaNews;
         this._button.guiButtonContext = param1;
         this._buttonUnseen.guiButtonContext = param1;
         this._button.setDownFunction(this.buttonHandler);
         this._buttonUnseen.setDownFunction(this.buttonUnseenHandler);
      }
      
      public function setUnseen(param1:int) : void
      {
         var _loc2_:Boolean = false;
         _loc2_ = this._buttonUnseen.visible;
         var _loc3_:* = param1 > 0;
         this._buttonUnseen.buttonText = param1.toString();
         this._showButtonUnseen = _loc3_;
         if(_loc2_ && !_loc3_)
         {
            TweenMax.to(this._buttonUnseen,0.25,{
               "scaleX":0,
               "scaleY":0,
               "ease":Quad.easeIn
            });
         }
         else
         {
            this._buttonUnseen.visible = _loc3_;
            this._buttonUnseen.scaleX = this._buttonUnseen.scaleY = 1;
         }
      }
      
      private function buttonHandler(param1:*) : void
      {
         this.news.isShowing = !this.news.isShowing;
         this.handleNewsUpdated();
      }
      
      private function buttonUnseenHandler(param1:*) : void
      {
         this.news.selectNextUnseen();
      }
      
      private function setupGp() : void
      {
         this.teardownGp();
         GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_y);
         GuiGp.placeIconLeft(this._button,this.gp_y,GuiGpAlignV.C,GuiGpAlignH.W_LEFT);
         this.gp_y.visible = this._button.visible && this.visible && Boolean(this.parent);
      }
      
      private function teardownGp() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_y);
      }
      
      public function cleanup() : void
      {
         this._button.cleanup();
         this._buttonUnseen.cleanup();
         GuiGp.releasePrimaryBitmap(this.gp_y);
         GpBinder.gpbinder.unbind(this.cmd_y);
         this.cmd_y.cleanup();
      }
      
      private function cmdfunc_y(param1:CmdExec) : void
      {
         if(!visible || !parent)
         {
            return;
         }
         this.gp_y.pulse();
         this._button.press();
      }
      
      public function handleNewsUpdated() : void
      {
         if(!this.news.visible)
         {
            this.teardownGp();
            this.visible = false;
            return;
         }
         TweenMax.killTweensOf(this._button);
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         if(this.news.isShowing)
         {
            _loc3_ = this.BUTTON_SHOW_Y;
            _loc2_ = this.BUTTON_UNSEEN_SHOW_X;
         }
         else
         {
            _loc3_ = this.BUTTON_HIDE_Y;
            _loc1_ = 180;
            _loc2_ = this.BUTTON_UNSEEN_HIDE_X;
         }
         var _loc4_:Number = Math.abs(this._button.rotation - _loc1_) / 180;
         _loc4_ /= this.TWEEN_SPEED;
         TweenMax.to(this._button,_loc4_,{"rotation":_loc1_});
         _loc4_ = Math.abs(this._button.y - _loc3_) / Math.abs(this.BUTTON_SHOW_Y - this.BUTTON_HIDE_Y);
         _loc4_ /= this.TWEEN_SPEED;
         TweenMax.to(this._button,_loc4_,{"y":_loc3_});
         _loc4_ = Math.abs(this._buttonUnseen.x - _loc2_) / Math.abs(this.BUTTON_UNSEEN_SHOW_X - this.BUTTON_UNSEEN_HIDE_X);
         _loc4_ /= this.TWEEN_SPEED;
         TweenMax.to(this._buttonUnseen,_loc4_,{"x":_loc2_});
         this._buttonUnseen.visible = this._showButtonUnseen;
         this._button.visible = true;
         this.setupGp();
      }
   }
}
