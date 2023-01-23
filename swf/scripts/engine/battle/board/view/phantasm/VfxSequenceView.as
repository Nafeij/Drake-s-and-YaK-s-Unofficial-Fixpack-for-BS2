package engine.battle.board.view.phantasm
{
   import as3isolib.display.IsoSprite;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.anim.view.XAnimClipSpriteFlash;
   import engine.anim.view.XAnimClipSpriteStarling;
   import engine.battle.ability.phantasm.model.VfxSequence;
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class VfxSequenceView extends IsoSprite
   {
      
      public static const EVENT_CLIP_FINISHED:String = "VfxSequenceView.EVENT_CLIP_FINISHED";
      
      public static const EVENT_SEQUENCE_COMPLETE:String = "VfxSequenceView.EVENT_SEQUENCE_COMPLETE";
       
      
      public var dispatcher:EventDispatcher;
      
      public var vfx:VfxSequence;
      
      public var sprite:XAnimClipSpriteBase;
      
      public var logger:ILogger;
      
      public var smoothing:Boolean;
      
      public var orientationOffset:Point;
      
      public var spriteOffsetY:Number = 0;
      
      public function VfxSequenceView(param1:VfxSequence, param2:ILogger, param3:Boolean = true)
      {
         this.dispatcher = new EventDispatcher();
         this.orientationOffset = new Point(0,0);
         super("vfx");
         this.vfx = param1;
         this.logger = param2;
         this.smoothing = param3;
         param1.addEventListener(Event.CHANGE,this.vfxChangeHandler);
         param1.addEventListener(VfxSequence.EVENT_CLIP_FINISHED,this.clipFinishedHandler);
         param1.addEventListener(VfxSequence.EVENT_SEQUENCE_COMPLETE,this.sequenceCompleteHandler);
         this.vfxChangeHandler(null);
         parent;
      }
      
      public function get displayObjectWrapper() : DisplayObjectWrapper
      {
         if(this.sprite)
         {
            return this.sprite.displayObjectWrapper;
         }
         return null;
      }
      
      private function sequenceCompleteHandler(param1:Event) : void
      {
         this.vfx.removeEventListener(VfxSequence.EVENT_SEQUENCE_COMPLETE,this.sequenceCompleteHandler);
         this.dispatcher.dispatchEvent(new Event(VfxSequenceView.EVENT_SEQUENCE_COMPLETE));
      }
      
      private function clipFinishedHandler(param1:Event) : void
      {
         this.dispatcher.dispatchEvent(new Event(VfxSequenceView.EVENT_CLIP_FINISHED));
      }
      
      public function cleanup() : void
      {
         if(this.sprite)
         {
            if(this.sprite.clip)
            {
               this.sprite.clip.cleanup();
            }
            this.sprite.cleanup();
            this.sprite = null;
         }
         if(this.vfx)
         {
            this.vfx.removeEventListener(Event.CHANGE,this.vfxChangeHandler);
            this.vfx.removeEventListener(VfxSequence.EVENT_CLIP_FINISHED,this.clipFinishedHandler);
            this.vfx.removeEventListener(VfxSequence.EVENT_SEQUENCE_COMPLETE,this.sequenceCompleteHandler);
            if(this.vfx.transient)
            {
               this.vfx.cleanup();
            }
         }
         this.vfx = null;
         this.dispatcher = null;
      }
      
      private function vfxChangeHandler(param1:Event) : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         if(Boolean(this.vfx.clip) && Boolean(this.vfx.clip.def))
         {
            if(PlatformStarling.instance)
            {
               this.sprite = new XAnimClipSpriteStarling(null,this.vfx.clip,this.logger,this.smoothing);
            }
            else
            {
               this.sprite = new XAnimClipSpriteFlash(null,this.vfx.clip,this.logger,this.smoothing);
            }
            this.sprite.x = this.orientationOffset.x;
            this.sprite.y = this.spriteOffsetY + this.orientationOffset.y;
            _loc2_ = this.sprite.displayObjectWrapper;
            _loc2_.scaleY = this.vfx.vd.scale;
            _loc2_.scaleX = this.vfx.vd.scale;
            if(this.vfx.vd.flip)
            {
               _loc2_.scaleX *= -1;
            }
            if(this.vfx.def.blendMode)
            {
               _loc2_.blendMode = this.vfx.def.blendMode;
            }
            sprites = [this.sprite.displayObjectWrapper];
         }
         else
         {
            this.sprite = null;
            sprites = [];
         }
      }
      
      public function updatePosition() : void
      {
         if(this.sprite)
         {
            this.sprite.x = this.orientationOffset.x;
            this.sprite.y = this.spriteOffsetY + this.orientationOffset.y;
         }
      }
      
      public function update(param1:int) : void
      {
         if(this.sprite)
         {
            this.sprite.update();
         }
      }
   }
}
