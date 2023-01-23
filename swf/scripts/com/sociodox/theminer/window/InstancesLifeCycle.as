package com.sociodox.theminer.window
{
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Localization;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class InstancesLifeCycle extends Sprite implements IWindow
   {
      
      private static const COLOR_ALPHA:Number = 0.3;
       
      
      private var mRenderTargetData:BitmapData = null;
      
      private var mRenderTargetDataReuse:BitmapData = null;
      
      private var mRenderTargetDataCreate:BitmapData = null;
      
      private var mRenderTargetDataRemoved:BitmapData = null;
      
      private var mRenderTargetDataGC:BitmapData = null;
      
      private var mRenderTarget:Bitmap = null;
      
      private var mAssetsDict:Dictionary = null;
      
      private var renderTarget1:Shape = null;
      
      private var renderTarget2:Shape = null;
      
      private var currentRenderTarget:Shape = null;
      
      private var mLegend:Sprite = null;
      
      private var mInfos:TextField;
      
      private var mLegendTxt:Array = null;
      
      private var mAddedLastSecond:int = 0;
      
      private var mRemovedLastSecond:int = 0;
      
      private var mDOTotal:int = 0;
      
      private var mDOToCollect:int = 0;
      
      private var mLastTick:int = 0;
      
      private var mEnterTime:int = 0;
      
      private var mBiggerRect:Rectangle;
      
      private var mMinRect:Rectangle;
      
      private var pos:Point;
      
      public function InstancesLifeCycle()
      {
         this.mBiggerRect = new Rectangle();
         this.mMinRect = new Rectangle(0,0,4,4);
         this.pos = new Point();
         super();
         this.Init();
         this.mEnterTime = getTimer();
      }
      
      private function Init() : void
      {
         var _loc2_:Sprite = null;
         Analytics.Track("Tab","LifeCycle","LifeCycle Enter");
         this.mouseChildren = false;
         this.mouseEnabled = false;
         this.mLegend = new Sprite();
         this.mAssetsDict = new Dictionary(true);
         this.mRenderTargetData = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mRenderTargetDataReuse = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mRenderTargetDataReuse.fillRect(this.mRenderTargetData.rect,1476395008 + (16777215 & SkinManager.COLOR_LIFLECYCLE_REUSE));
         this.mRenderTargetDataCreate = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mRenderTargetDataCreate.fillRect(this.mRenderTargetData.rect,1476395008 + (16777215 & SkinManager.COLOR_LIFLECYCLE_CREATE));
         this.mRenderTargetDataRemoved = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mRenderTargetDataRemoved.fillRect(this.mRenderTargetData.rect,1476395008 + (16777215 & SkinManager.COLOR_LIFLECYCLE_REMOVED));
         this.mRenderTargetDataGC = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mRenderTargetDataGC.fillRect(this.mRenderTargetData.rect,1476395008 + (16777215 & SkinManager.COLOR_LIFLECYCLE_GC));
         this.mRenderTarget = new Bitmap();
         this.mRenderTarget.bitmapData = this.mRenderTargetData;
         this.addChild(this.mRenderTarget);
         Stage2D.addEventListener(Event.ADDED_TO_STAGE,this.OnAddedToStage,true);
         Stage2D.addEventListener(Event.REMOVED_FROM_STAGE,this.OnRemovedToStage,true);
         var _loc1_:int = int(Stage2D.stageWidth);
         _loc2_ = new Sprite();
         _loc2_.graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,0.3);
         _loc2_.graphics.drawRect(0,0,_loc1_,17);
         _loc2_.graphics.endFill();
         _loc2_.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE_DARK,0.6);
         _loc2_.graphics.drawRect(0,1,_loc1_,1);
         _loc2_.graphics.endFill();
         _loc2_.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,0.8);
         _loc2_.graphics.drawRect(0,0,_loc1_,1);
         _loc2_.graphics.endFill();
         addChild(_loc2_);
         _loc2_.y = Number(Stage2D.stageHeight) - _loc2_.height;
         var _loc3_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
         var _loc4_:TextFormat = new TextFormat("_sans",9,SkinManager.COLOR_GLOBAL_TEXT,false);
         var _loc5_:GlowFilter = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         this.mInfos = new TextField();
         this.mInfos.autoSize = TextFieldAutoSize.LEFT;
         this.mInfos.defaultTextFormat = _loc3_;
         this.mInfos.selectable = false;
         this.mInfos.text = "";
         this.mInfos.filters = [_loc5_];
         this.mInfos.x = 2;
         addChild(this.mInfos);
         this.mInfos.y = Number(Stage2D.stageHeight) - _loc2_.height;
         this.mLegendTxt = [new TextField(),new TextField(),new TextField(),new TextField()];
         var _loc6_:int = 0;
         while(_loc6_ < 4)
         {
            this.mLegendTxt[_loc6_].autoSize = TextFieldAutoSize.LEFT;
            this.mLegendTxt[_loc6_].defaultTextFormat = _loc4_;
            this.mLegendTxt[_loc6_].selectable = false;
            this.mLegendTxt[_loc6_].filters = [_loc5_];
            this.mLegend.addChild(this.mLegendTxt[_loc6_]);
            this.mLegendTxt[_loc6_].y = -4;
            _loc6_++;
         }
         this.mLegend.y = Number(Stage2D.stageHeight) - 28;
         this.mLegend.graphics.clear();
         this.mLegend.graphics.beginFill(SkinManager.COLOR_LIFLECYCLE_CREATE,1);
         this.mLegend.graphics.drawRect(3,0,10,7);
         this.mLegend.graphics.endFill();
         this.mLegendTxt[0].x = 12;
         this.mLegendTxt[0].text = Localization.Lbl_DOLC_Create;
         this.mLegend.graphics.beginFill(SkinManager.COLOR_LIFLECYCLE_REUSE,1);
         this.mLegend.graphics.drawRect(this.mLegendTxt[0].x + this.mLegendTxt[0].textWidth + 6,0,10,7);
         this.mLegend.graphics.endFill();
         this.mLegendTxt[1].x = this.mLegendTxt[0].x + this.mLegendTxt[0].textWidth + 15;
         this.mLegendTxt[1].text = Localization.Lbl_DOLC_ReUse;
         this.mLegend.graphics.beginFill(SkinManager.COLOR_LIFLECYCLE_REMOVED,1);
         this.mLegend.graphics.drawRect(this.mLegendTxt[1].x + this.mLegendTxt[1].textWidth + 6,0,10,7);
         this.mLegend.graphics.endFill();
         this.mLegendTxt[2].x = this.mLegendTxt[1].x + this.mLegendTxt[1].textWidth + 15;
         this.mLegendTxt[2].text = Localization.Lbl_DOLC_Removed;
         this.mLegend.graphics.beginFill(SkinManager.COLOR_LIFLECYCLE_GC,1);
         this.mLegend.graphics.drawRect(this.mLegendTxt[2].x + this.mLegendTxt[2].textWidth + 6,0,10,7);
         this.mLegend.graphics.endFill();
         this.mLegendTxt[3].x = this.mLegendTxt[2].x + this.mLegendTxt[2].textWidth + 15;
         this.mLegendTxt[3].text = Localization.Lbl_DOLC_WaitingGC;
         addChild(this.mLegend);
         this.mLegend.alpha = 0.5;
         this.ParseStage(Stage2D);
      }
      
      public function Dispose() : void
      {
         var _loc1_:* = undefined;
         Analytics.Track("Tab","LifeCycle","LifeCycle Exit",int((getTimer() - this.mEnterTime) / 1000));
         Stage2D.removeEventListener(Event.ADDED_TO_STAGE,this.OnAddedToStage,true);
         Stage2D.removeEventListener(Event.REMOVED_FROM_STAGE,this.OnRemovedToStage,true);
         if(this.mRenderTargetData)
         {
            this.mRenderTargetData.dispose();
         }
         if(this.mRenderTargetDataReuse)
         {
            this.mRenderTargetDataReuse.dispose();
         }
         if(this.mRenderTargetDataCreate)
         {
            this.mRenderTargetDataCreate.dispose();
         }
         if(this.mRenderTargetDataRemoved)
         {
            this.mRenderTargetDataRemoved.dispose();
         }
         if(this.mRenderTargetDataGC)
         {
            this.mRenderTargetDataGC.dispose();
         }
         this.mRenderTarget = null;
         for(_loc1_ in this.mAssetsDict)
         {
            delete this.mAssetsDict[_loc1_];
         }
         this.mAssetsDict = null;
         this.renderTarget1 = null;
         this.renderTarget2 = null;
         this.currentRenderTarget = null;
         this.mLegend = null;
         this.mInfos = null;
         this.mLegendTxt = null;
         this.mBiggerRect = null;
         this.mMinRect = null;
         this.pos = null;
      }
      
      public function Update() : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(getTimer() - this.mLastTick >= 1000)
         {
            this.mLastTick = getTimer();
            _loc3_ = Localization.Lbl_DOLC_DisplayObjectOnStage + "[ " + this.mDOTotal + " ]  " + Localization.Lbl_DOLC_AddedToStage + "[ " + this.mAddedLastSecond + " ]  " + Localization.Lbl_DOLC_RemovedFromStage + "[ " + this.mRemovedLastSecond + " ]  " + Localization.Lbl_DOLC_WaitingGC + "[ " + this.mDOToCollect + " ]";
            this.mInfos.text = _loc3_;
            this.mDOTotal = this.mDOTotal + this.mAddedLastSecond - this.mRemovedLastSecond;
            this.mRemovedLastSecond = this.mAddedLastSecond = 0;
         }
         this.mRenderTargetData.fillRect(this.mRenderTargetData.rect,(SkinManager.COLOR_GLOBAL_BG & 16777215) + 2281701376);
         var _loc1_:Rectangle = null;
         this.mDOToCollect = 0;
         for(_loc2_ in this.mAssetsDict)
         {
            if(_loc2_.stage != null && this.mAssetsDict[_loc2_] == false)
            {
               ++this.mDOToCollect;
               _loc1_ = _loc2_.getRect(Stage2D);
               this.pos.x = _loc1_.x;
               this.pos.y = _loc1_.y;
               this.mRenderTargetData.copyPixels(this.mRenderTargetDataGC,_loc1_,this.pos,null,null,true);
            }
         }
      }
      
      private function OnAddedToStage(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_ == Stage2D)
         {
            return;
         }
         if(_loc2_ == parent)
         {
            return;
         }
         var _loc3_:Rectangle = _loc2_.getRect(Stage2D);
         this.pos.x = _loc3_.x;
         this.pos.y = _loc3_.y;
         var _loc4_:Boolean = true;
         if(this.mAssetsDict[_loc2_] == true)
         {
            _loc4_ = false;
         }
         if(_loc4_)
         {
            ++this.mAddedLastSecond;
            if(_loc3_.width < 8 && _loc3_.width < 8)
            {
               this.mMinRect.x = _loc3_.x;
               this.mMinRect.y = _loc3_.y;
               this.mRenderTargetData.copyPixels(this.mRenderTargetDataCreate,this.mMinRect,this.pos,null,null,true);
            }
            else
            {
               this.mRenderTargetData.copyPixels(this.mRenderTargetDataCreate,_loc3_,this.pos,null,null,true);
            }
            this.mAssetsDict[_loc2_] = true;
         }
         else if(_loc3_.width < 8 && _loc3_.width < 8)
         {
            this.mMinRect.x = _loc3_.x;
            this.mMinRect.y = _loc3_.y;
            this.mRenderTargetData.copyPixels(this.mRenderTargetDataReuse,this.mMinRect,this.pos,null,null,true);
         }
         else
         {
            this.mRenderTargetData.copyPixels(this.mRenderTargetDataReuse,_loc3_,this.pos,null,null,true);
         }
      }
      
      private function OnRemovedToStage(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_ == Stage2D)
         {
            return;
         }
         if(_loc2_ == parent)
         {
            return;
         }
         if(this.mAssetsDict[_loc2_] == true)
         {
            ++this.mRemovedLastSecond;
         }
         var _loc3_:Rectangle = _loc2_.getRect(Stage2D);
         this.pos.x = _loc3_.x;
         this.pos.y = _loc3_.y;
         this.mBiggerRect.x = _loc3_.x - 2;
         this.mBiggerRect.y = _loc3_.y - 2;
         this.mBiggerRect.width = _loc3_.width + 4;
         this.mBiggerRect.height = _loc3_.height + 4;
         this.mRenderTargetData.copyPixels(this.mRenderTargetDataRemoved,this.mBiggerRect,this.pos,null,null,true);
         this.mAssetsDict[_loc2_] = false;
      }
      
      private function ParseStage(param1:DisplayObjectContainer) : void
      {
         if(param1 == null || param1 == parent)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            ++this.mDOTotal;
            this.ParseStage(param1.getChildAt(_loc2_) as DisplayObjectContainer);
            _loc2_++;
         }
      }
      
      public function Unlink() : void
      {
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }
      
      public function Link(param1:DisplayObjectContainer, param2:int) : void
      {
         param1.addChildAt(this,param2);
      }
   }
}
