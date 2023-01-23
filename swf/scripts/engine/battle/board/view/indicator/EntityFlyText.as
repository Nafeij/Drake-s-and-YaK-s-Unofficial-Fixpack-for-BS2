package engine.battle.board.view.indicator
{
   import as3isolib.display.IsoSprite;
   import as3isolib.utils.IsoUtil;
   import engine.battle.entity.view.EntityView;
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.scene.ITextBitmapGenerator;
   import engine.tile.Tile;
   import flash.display.BitmapData;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class EntityFlyText extends IsoSprite
   {
      
      public static const DURATION:int = 2000;
      
      public static const MAX_ENTRIES:int = 4;
       
      
      private var entries:Vector.<EntityFlyTextEntry>;
      
      private var popped:Vector.<EntityFlyTextEntry>;
      
      private var timer:Timer;
      
      private var sliderWrapper:DisplayObjectWrapper;
      
      public var view:EntityView;
      
      public var tile:Tile;
      
      private var ids:int;
      
      public var flytextId:String;
      
      public var logger:ILogger;
      
      public function EntityFlyText(param1:EntityView, param2:Tile)
      {
         this.entries = new Vector.<EntityFlyTextEntry>();
         this.popped = new Vector.<EntityFlyTextEntry>();
         this.timer = new Timer(1000,1);
         super("flytext");
         this.view = param1;
         this.tile = param2;
         this.flytextId = param1.entity.id;
         this.logger = param1.logger;
         this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         this.sliderWrapper = IsoUtil.createDisplayObjectWrapper();
         sprites = [this.sliderWrapper];
      }
      
      public function cleanup() : void
      {
         var _loc1_:EntityFlyTextEntry = null;
         this.logger.info("EntityFlyText.cleanup " + this.flytextId);
         for each(_loc1_ in this.popped)
         {
            _loc1_.cleanup();
         }
         this.popped = null;
      }
      
      public function push(param1:String, param2:uint, param3:String, param4:int) : void
      {
         var _loc5_:ITextBitmapGenerator = this.view.entity.board.scene.context.textBitmapGenerator;
         var _loc6_:BitmapData = !!_loc5_ ? _loc5_.generateTextBitmap(param3,param4,param2,0,param1,0) : null;
         if(!_loc6_)
         {
            return;
         }
         var _loc7_:EntityFlyTextEntry = this.view.createFlyTextEntry(this.view.entity.id + "__" + ++this.ids,_loc6_);
         this.sliderWrapper.addChild(_loc7_.displayObjectWrapper);
         this.entries.push(_loc7_);
         _loc7_.enter();
         this.popFirst();
         this.checkTimer();
      }
      
      public function toString() : String
      {
         return "EntityFlyText [view=" + this.view + ", tile=" + this.tile + ", entries=" + this.entries.length + "]";
      }
      
      public function flyTextEntryCompleteHandler(param1:EntityFlyTextEntry) : void
      {
         var _loc2_:int = this.popped.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.popped.splice(_loc2_,1);
         }
      }
      
      protected function timerCompleteHandler(param1:TimerEvent) : void
      {
         this.popFirst();
         this.checkTimer();
      }
      
      private function popFirst() : void
      {
         var _loc4_:EntityFlyTextEntry = null;
         var _loc5_:int = 0;
         if(this.entries.length == 0)
         {
            return;
         }
         this.timer.stop();
         var _loc1_:EntityFlyTextEntry = this.entries[0];
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for each(_loc4_ in this.popped)
         {
            if(_loc4_.isOverlappingY(_loc1_))
            {
               _loc5_ = _loc4_.horizontalMargin + _loc1_.horizontalMargin;
               _loc2_ = Math.min(_loc2_,_loc4_.x - _loc5_);
               _loc3_ = Math.max(_loc3_,_loc4_.x + _loc5_);
            }
         }
         if(Math.abs(_loc2_) <= Math.abs(_loc3_))
         {
            _loc1_.x = _loc2_;
         }
         else
         {
            _loc1_.x = _loc3_;
         }
         this.popped.push(_loc1_);
         _loc1_.depart();
         this.entries.splice(0,1);
      }
      
      private function checkTimer() : void
      {
         var _loc1_:EntityFlyTextEntry = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(!this.timer.running)
         {
            if(this.entries.length > 0)
            {
               _loc1_ = this.entries[0];
               _loc2_ = getTimer();
               _loc3_ = Math.max(200,_loc1_.timestamp + DURATION - _loc2_);
               this.timer.reset();
               this.timer.delay = _loc3_;
               this.timer.start();
            }
         }
      }
   }
}
