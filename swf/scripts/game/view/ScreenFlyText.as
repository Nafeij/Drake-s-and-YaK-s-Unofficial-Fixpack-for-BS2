package game.view
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Linear;
   import com.greensock.easing.Quad;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import game.gui.IGuiContext;
   
   public class ScreenFlyText extends Sprite
   {
       
      
      private var bmpd:BitmapData;
      
      private var bmp:Bitmap;
      
      private var callback:Function;
      
      private var container:DisplayObjectContainer;
      
      private var gc:IGuiContext;
      
      private var soundId:String;
      
      private var linger:Number;
      
      private var _delingered:Boolean;
      
      private var _tweeningOut:Boolean;
      
      public function ScreenFlyText(param1:IGuiContext, param2:String, param3:uint, param4:DisplayObjectContainer, param5:Number, param6:String, param7:Number, param8:Function)
      {
         this.callback = param8;
         this.container = param4;
         this.gc = param1;
         this.soundId = param6;
         this.linger = param7;
         super();
         this.mouseChildren = this.mouseEnabled = false;
         this.bmpd = param1.generateTextBitmap("vinque",40,param3,0,param2,0);
         this.bmp = new Bitmap(this.bmpd,PixelSnapping.NEVER,true);
         addChild(this.bmp);
         this.bmp.x = -this.bmp.width / 2;
         this.bmp.y = -this.bmp.height / 2;
         this.y = param5;
      }
      
      public function cleanup() : void
      {
         TweenMax.killTweensOf(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp = null;
         this.bmpd.dispose();
         this.bmpd = null;
      }
      
      public function start() : void
      {
         if(Boolean(parent) || !this.bmpd)
         {
            throw new IllegalOperationError("what?");
         }
         this.x = this.container.width / 2;
         this.container.addChild(this);
         this.scaleX = this.scaleY = 0;
         TweenMax.to(this,0.4,{
            "scaleX":1,
            "scaleY":1,
            "ease":Back.easeOut,
            "onComplete":this.tweenInHandler
         });
         if(this.soundId)
         {
            this.gc.playSound(this.soundId);
         }
         else
         {
            this.gc.playSound("ui_stats_hi");
         }
      }
      
      public function delinger() : void
      {
         if(!this._tweeningOut)
         {
            this._delingered = true;
            TweenMax.killTweensOf(this);
            scaleX = 1;
            scaleY = 1;
            this.notifyCallback();
            this.tweenInHandler();
         }
      }
      
      private function tweenInHandler() : void
      {
         var _loc1_:Number = this._delingered ? 0 : 0.5 + this.linger;
         var _loc2_:Function = this._delingered ? Linear.easeNone : Quad.easeIn;
         TweenMax.to(this,0.5,{
            "delay":_loc1_,
            "y":-height,
            "ease":_loc2_,
            "onStart":this.tweenOutStartHandler,
            "onComplete":this.tweenOutHandler
         });
      }
      
      private function tweenOutStartHandler() : void
      {
         this._tweeningOut = true;
      }
      
      private function notifyCallback() : void
      {
         if(this.callback != null)
         {
            this.callback(this);
            this.callback = null;
         }
      }
      
      private function tweenOutHandler() : void
      {
         this.notifyCallback();
         this.cleanup();
      }
   }
}
