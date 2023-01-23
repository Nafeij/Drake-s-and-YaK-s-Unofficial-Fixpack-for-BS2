package engine.landscape.travel.view
{
   import as3isolib.utils.IsoUtil;
   import engine.core.math.spline.CatmullRomSpline2d;
   import engine.core.render.BoundedCamera;
   import engine.landscape.def.ILandscapeLayerDef;
   import engine.landscape.travel.def.TravelReactorDef;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import engine.landscape.view.LandscapeViewBase;
   import engine.saga.Saga;
   import engine.saga.SpeakEvent;
   import flash.geom.Point;
   
   public class TravelView
   {
      
      public static var allowCaravanView:Boolean = true;
       
      
      public var travel:Travel;
      
      public var caravan:CaravanView;
      
      public var landscapeView:LandscapeViewBase;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      public var overlay:TravelViewOverlay;
      
      public var reactor:TravelReactorView;
      
      public function TravelView(param1:Travel, param2:LandscapeViewBase)
      {
         var _loc3_:TravelReactorDef = null;
         var _loc4_:String = null;
         var _loc5_:ILandscapeLayerDef = null;
         var _loc6_:Point = null;
         super();
         this.displayObjectWrapper = IsoUtil.createDisplayObjectWrapper();
         this.displayObjectWrapper.name = "travelView";
         this.travel = param1;
         this.landscapeView = param2;
         if(allowCaravanView)
         {
            if(param1.def.close)
            {
               this.caravan = new CaravanViewClose(this);
            }
            else
            {
               this.caravan = new CaravanViewWorld(this);
            }
         }
         if(param2.camera.drift)
         {
            param2.camera.drift.CAMERA_SNAP_THRESHOLD = 10;
         }
         if(TravelReactorView.ENABLED)
         {
            if(param1.def.reactors)
            {
               for each(_loc3_ in param1.def.reactors)
               {
                  this.reactor = new TravelReactorView(this,_loc3_);
               }
            }
         }
         if(param1.def.spline)
         {
            _loc4_ = "layer_3_walk_back";
            if(param2.hasLayerSprite(_loc4_))
            {
               _loc5_ = param2.landscape.def.getLayer(_loc4_);
               _loc6_ = !!_loc5_ ? _loc5_.getOffset() : null;
               if(this.caravan)
               {
                  param2.addExtraToLayer(_loc4_,this.caravan.displayObjectWrapper);
                  this.caravan.displayObjectWrapper.x = -_loc6_.x;
                  this.caravan.displayObjectWrapper.y = -_loc6_.y;
               }
               if(this.reactor)
               {
                  param2.addExtraToLayer(_loc4_,this.reactor.dow);
                  this.reactor.dow.x = -_loc6_.x;
                  this.reactor.dow.y = -_loc6_.y;
               }
            }
            else
            {
               param1.landscape.scene._context.logger.error("TravelView unable to find caravan-layer [layer_3_walk_back] in " + param1.landscape.scene._def.url);
               if(this.caravan)
               {
                  this.displayObjectWrapper.addChild(this.caravan.displayObjectWrapper);
               }
               if(this.reactor)
               {
                  this.displayObjectWrapper.addChild(this.reactor.dow);
               }
            }
         }
         if(this.displayObjectWrapper is DisplayObjectWrapperFlash)
         {
            this.overlay = new TravelViewOverlay(this);
            this.displayObjectWrapper.addChild(this.overlay.displayObjectWrapper);
         }
      }
      
      public function cleanup() : void
      {
         if(this.overlay)
         {
            this.overlay.cleanup();
            this.displayObjectWrapper.removeChild(this.overlay.displayObjectWrapper);
            this.overlay = null;
         }
         this.displayObjectWrapper.removeAllChildren();
         this.displayObjectWrapper.cleanup();
         this.displayObjectWrapper = null;
         if(this.caravan)
         {
            this.caravan.cleanup();
            this.caravan = null;
         }
         this.travel = null;
         this.landscapeView = null;
      }
      
      public function get spline() : CatmullRomSpline2d
      {
         return this.travel.def.spline;
      }
      
      public function update(param1:int) : void
      {
         if(this.caravan)
         {
            this.caravan.update(param1);
         }
         if(this.reactor)
         {
            this.reactor.update(param1);
         }
      }
      
      public function handleSpeak(param1:SpeakEvent, param2:String) : Boolean
      {
         var _loc4_:Saga = null;
         if(param1.speakerDef)
         {
            _loc4_ = this.travel.landscape.scene._context.saga as Saga;
            if(Boolean(_loc4_) && Boolean(_loc4_.caravan))
            {
               if(!_loc4_.caravan._legend.roster.getEntityDefById(param1.speakerDef.id))
               {
                  return true;
               }
               param2 = "travel.caravan.0";
            }
         }
         var _loc3_:String = "travel.";
         if(!param2 || param2.indexOf(_loc3_) == 0)
         {
            if(this.caravan)
            {
               if(this.caravan.handleSpeak(param1,param2))
               {
                  return true;
               }
            }
            return true;
         }
         return false;
      }
      
      public function centerOnLocation(param1:int) : void
      {
         var _loc2_:Point = this.travel.def.getPointAtLocation(param1);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:BoundedCamera = this.landscapeView.camera;
         var _loc4_:Number = _loc3_.zoom;
         _loc4_ = 1;
         _loc3_.enableDrift = true;
         _loc3_.drift.anchorSpeed = 2500 * _loc4_;
         _loc3_.drift.anchor = new Point(_loc2_.x,_loc3_.y);
      }
      
      public function isTravelFalling() : Boolean
      {
         return Boolean(this.caravan) && this.caravan.isTravelFalling();
      }
   }
}
