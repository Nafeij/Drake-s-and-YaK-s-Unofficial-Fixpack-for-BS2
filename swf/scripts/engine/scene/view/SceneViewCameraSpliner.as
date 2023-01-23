package engine.scene.view
{
   import com.greensock.TweenMax;
   import engine.core.logging.ILogger;
   import engine.landscape.def.LandscapeSplineDef;
   import engine.scene.model.Scene;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.getTimer;
   
   public class SceneViewCameraSpliner extends EventDispatcher
   {
       
      
      private var scene:Scene;
      
      private var sv:SceneViewSprite;
      
      private var _spline:LandscapeSplineDef;
      
      private var _t:Number = 0;
      
      private var logger:ILogger;
      
      private var tmpPt:Point;
      
      private var _paused:Boolean;
      
      private var _speed:Number;
      
      private var _time:Number;
      
      private var _start:int = 0;
      
      private var _dur:Number = 0;
      
      public function SceneViewCameraSpliner(param1:SceneViewSprite)
      {
         this.tmpPt = new Point();
         super();
         this.sv = param1;
         this.scene = param1.scene;
         this.logger = this.scene._context.logger;
      }
      
      public function cleanup() : void
      {
         this.setSpline(null,0,0);
      }
      
      public function get t() : Number
      {
         return this._t;
      }
      
      public function set paused(param1:Boolean) : void
      {
         this._paused = param1;
         if(this._paused)
         {
            TweenMax.killTweensOf(this);
         }
         else
         {
            this.startTween();
         }
      }
      
      public function set t(param1:Number) : void
      {
         this._t = param1;
         if(!this._spline)
         {
            return;
         }
         var _loc2_:Number = this._spline.computeSplineT(this._t);
         this._spline.spline.sample(_loc2_,this.tmpPt);
         var _loc3_:Number = this._spline.zoom.sample(_loc2_);
         this.tmpPt.x += this._spline.layer.offset.x;
         this.tmpPt.y += this._spline.layer.offset.y;
         this.scene._camera.zoom = _loc3_;
         this.scene._camera.setPosition(this.tmpPt.x,this.tmpPt.y);
      }
      
      public function setSpline(param1:LandscapeSplineDef, param2:Number, param3:Number) : void
      {
         this._spline = param1;
         if(!this._spline)
         {
            TweenMax.killTweensOf(this);
            return;
         }
         this._speed = param2;
         this._time = param3;
         this.scene._camera.drift.anchor = null;
         this.scene._camera.drift.pause = true;
         this.t = 0;
         this.startTween();
      }
      
      private function startTween() : void
      {
         if(this.t >= 1)
         {
            this.logger.info("Camera startTween nowhere to go, ignoring");
            return;
         }
         this._dur = this._time;
         this._start = getTimer();
         if(this._dur <= 0)
         {
            if(this._speed > 0)
            {
               this._dur = (1 - this._t) * this._spline.spline.totalLength / this._speed;
            }
         }
         var _loc1_:Function = this._spline.getEaseFunction();
         TweenMax.to(this,this._dur,{
            "t":1,
            "onComplete":this.tweenCompleteHandler,
            "ease":_loc1_
         });
      }
      
      public function get splineId() : String
      {
         return !!this._spline ? this._spline.id : null;
      }
      
      private function tweenCompleteHandler() : void
      {
         this.setSpline(null,0,0);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}
