package engine.gui.core
{
   import com.greensock.TweenMax;
   import engine.gui.MonoFont;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   
   public class GuiApplication extends GuiSprite
   {
       
      
      public var buildVersion:String;
      
      public var buildTag:String;
      
      public var buildRelease:String;
      
      public var invoked:Boolean;
      
      private var _allowDelayedResize:Boolean;
      
      private var _resizeDirty:Boolean;
      
      private var _hasResized:Boolean;
      
      public function GuiApplication(param1:String, param2:String, param3:String)
      {
         super();
         this.buildVersion = param1;
         this.buildTag = param2;
         this.buildRelease = param3;
         MonoFont.init();
         stage.align = StageAlign.TOP_LEFT;
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.addEventListener(Event.RESIZE,this.stageResizeHandler);
         this._updateFromStateSize();
      }
      
      public function allowDelayedResize() : void
      {
         if(this._allowDelayedResize)
         {
            return;
         }
         this._allowDelayedResize = true;
         if(this._resizeDirty)
         {
            this._scheduleResize();
         }
      }
      
      private function _scheduleResize() : void
      {
         this._resizeDirty = true;
         if(stage)
         {
            if(this._allowDelayedResize)
            {
               TweenMax.killDelayedCallsTo(this._updateFromStateSize);
            }
            if(this._hasResized && this._allowDelayedResize && this.invoked)
            {
               TweenMax.delayedCall(0.25,this._updateFromStateSize);
            }
            else
            {
               this._updateFromStateSize();
            }
         }
      }
      
      protected function stageResizeHandler(param1:Event) : void
      {
         this._scheduleResize();
      }
      
      private function _updateFromStateSize() : void
      {
         if(stage)
         {
            this._hasResized = true;
            this._resizeDirty = false;
            this.setSize(stage.stageWidth,stage.stageHeight);
         }
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         var _loc3_:Boolean = false;
         if(this.width != param1)
         {
            param1 = param1;
         }
         if(this.height != param2)
         {
            param2 = param2;
         }
         super.setSize(param1,param2);
      }
   }
}
