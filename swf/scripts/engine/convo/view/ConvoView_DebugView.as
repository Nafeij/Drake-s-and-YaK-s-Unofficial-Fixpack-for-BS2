package engine.convo.view
{
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.ILandscapeView;
   import engine.landscape.view.LandscapeViewBase;
   import engine.scene.ITextBitmapGenerator;
   import engine.scene.view.SceneViewSprite;
   import flash.display.BitmapData;
   
   public class ConvoView_DebugView
   {
       
      
      public var cv:ConvoView;
      
      public var sceneView:SceneViewSprite;
      
      public var bmpdFront:BitmapData;
      
      public var bmpdBack:BitmapData;
      
      public var bmpdPan:BitmapData;
      
      public var bmpdFrontLblMark:Vector.<BitmapData>;
      
      public var bmpdBackLblMark:Vector.<BitmapData>;
      
      private var _extras:Vector.<Vector.<DisplayObjectWrapper>>;
      
      public function ConvoView_DebugView(param1:ConvoView)
      {
         this._extras = new Vector.<Vector.<DisplayObjectWrapper>>();
         super();
         this.cv = param1;
         this.sceneView = param1.sceneView;
         this._extras.push(new Vector.<DisplayObjectWrapper>());
         this._extras.push(new Vector.<DisplayObjectWrapper>());
         this.renderDebugConvoView();
      }
      
      public function cleanup() : void
      {
         var _loc2_:Vector.<DisplayObjectWrapper> = null;
         var _loc3_:ILandscapeView = null;
         var _loc4_:LandscapeViewBase = null;
         var _loc5_:DisplayObjectWrapper = null;
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this._extras.length)
         {
            _loc2_ = this._extras[_loc1_];
            _loc3_ = this.sceneView.getLandscapeView(_loc1_) as ILandscapeView;
            _loc4_ = _loc3_ as LandscapeViewBase;
            for each(_loc5_ in _loc2_)
            {
               _loc4_.removeExtraFromLayer(_loc5_);
            }
            _loc1_++;
         }
         this._extras = null;
         this.bmpdFront && this.bmpdFront.dispose();
         this.bmpdBack && this.bmpdBack.dispose();
         this.bmpdPan && this.bmpdPan.dispose();
         if(this.bmpdFrontLblMark)
         {
            _loc1_ = 1;
            while(_loc1_ <= 4)
            {
               this.bmpdFrontLblMark[_loc1_ - 1].dispose();
               this.bmpdBackLblMark[_loc1_ - 1].dispose();
               _loc1_++;
            }
         }
      }
      
      private function generateResources() : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:BitmapData = null;
         var _loc8_:BitmapData = null;
         if(this.bmpdFront)
         {
            return;
         }
         this.bmpdFront = new BitmapData(3,1,false,4294902015);
         this.bmpdBack = new BitmapData(3,1,false,4278255615);
         this.bmpdPan = new BitmapData(3,1,false,4278255360);
         this.bmpdFrontLblMark = new Vector.<BitmapData>();
         this.bmpdBackLblMark = new Vector.<BitmapData>();
         var _loc1_:ILandscapeView = this.sceneView.getLandscapeView(0) as ILandscapeView;
         var _loc2_:LandscapeViewBase = _loc1_ as LandscapeViewBase;
         var _loc3_:ITextBitmapGenerator = _loc2_.sceneView.scene.context.textBitmapGenerator;
         var _loc4_:int = 1;
         while(_loc4_ <= 4)
         {
            _loc5_ = " Mark " + _loc4_;
            _loc6_ = " Back Mark " + _loc4_;
            _loc7_ = _loc3_.generateTextBitmap("minion",40,4294902015,4278190080,_loc5_,1000);
            _loc8_ = _loc3_.generateTextBitmap("minion",40,4278255615,4278190080,_loc6_,1000);
            this.bmpdFrontLblMark.push(_loc7_);
            this.bmpdBackLblMark.push(_loc8_);
            _loc4_++;
         }
      }
      
      private function renderDebugConvoView() : void
      {
         this.generateResources();
         this._renderDebugLandscape(0);
         this._renderDebugLandscape(1);
      }
      
      private function _renderDebugLandscape(param1:int) : void
      {
         var _loc11_:Boolean = false;
         var _loc12_:String = null;
         var _loc13_:Number = NaN;
         var _loc14_:BitmapData = null;
         var _loc15_:Vector.<BitmapData> = null;
         var _loc16_:Number = NaN;
         var _loc17_:DisplayObjectWrapper = null;
         var _loc18_:DisplayObjectWrapper = null;
         var _loc2_:Vector.<DisplayObjectWrapper> = this._extras[param1];
         var _loc3_:Number = 2731;
         var _loc4_:Number = 1162;
         var _loc5_:Number = _loc3_ / 2;
         var _loc6_:ILandscapeView = this.sceneView.getLandscapeView(param1) as ILandscapeView;
         var _loc7_:LandscapeViewBase = _loc6_ as LandscapeViewBase;
         var _loc8_:String = ConvoView.getLayerForActor(true);
         var _loc9_:String = ConvoView.getLayerForActor(false);
         var _loc10_:int = 1;
         while(_loc10_ <= 4)
         {
            _loc11_ = ConvoView.isActorFacingCamera(_loc10_,param1);
            _loc12_ = _loc11_ ? _loc8_ : _loc9_;
            _loc16_ = 0;
            if(_loc11_)
            {
               _loc13_ = Number(this.cv.facingXs[_loc10_ - 1]);
               _loc14_ = this.bmpdFront;
               _loc15_ = this.bmpdFrontLblMark;
               _loc16_ = 100;
            }
            else
            {
               _loc13_ = Number(this.cv.backXs[_loc10_ - 1]);
               _loc14_ = this.bmpdBack;
               _loc15_ = this.bmpdBackLblMark;
               _loc16_ = 40;
            }
            _loc17_ = _loc7_.createDisplayObjectWrapperForBitmapData(this,_loc14_);
            _loc17_.scaleY = _loc4_;
            _loc17_.x = _loc13_ + _loc5_ - 1;
            _loc7_.addExtraToLayer(_loc12_,_loc17_);
            _loc18_ = _loc7_.createDisplayObjectWrapperForBitmapData(this,_loc15_[_loc10_ - 1]);
            _loc18_.x = _loc13_ + _loc5_ - 1;
            _loc18_.y = _loc16_;
            _loc7_.addExtraToLayer(_loc12_,_loc18_);
            _loc2_.push(_loc17_);
            _loc2_.push(_loc18_);
            _loc10_++;
         }
      }
   }
}
