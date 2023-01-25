package engine.battle.ability.phantasm.model
{
   import com.greensock.TweenMax;
   import engine.anim.def.IAnimFacing;
   import engine.anim.view.AnimClip;
   import engine.battle.ability.phantasm.def.VfxSequenceDef;
   import engine.core.logging.ILogger;
   import engine.resource.AnimClipResource;
   import engine.resource.IResource;
   import engine.resource.IResourceManager;
   import engine.resource.Resource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.vfx.VfxDef;
   import engine.vfx.VfxLibrary;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class VfxSequence extends EventDispatcher
   {
      
      public static const EVENT_CLIP_FINISHED:String = "VfxSequence.EVENT_CLIP_FINISHED";
      
      public static const EVENT_SEQUENCE_COMPLETE:String = "VfxSequence.EVENT_SEQUENCE_COMPLETE";
       
      
      public var def:VfxSequenceDef;
      
      public var _stage:String;
      
      private var _clip:AnimClip;
      
      public var resources:Dictionary;
      
      public var vds:Dictionary;
      
      public var vd:VfxDef;
      
      public var resource:AnimClipResource;
      
      private var logger:ILogger;
      
      private var elapsed:int;
      
      public var complete:Boolean;
      
      private var waits:int;
      
      private var lib:VfxLibrary;
      
      private var _doEnd:Boolean;
      
      private var _facing:IAnimFacing;
      
      private var parameter:Number;
      
      private var finishedCallback:Function;
      
      public var transient:Boolean;
      
      private var _vfxAlpha:Number = 1;
      
      private var cleanedup:Boolean;
      
      private var _fadingOut:Boolean;
      
      public function VfxSequence(param1:VfxSequenceDef, param2:IResourceManager, param3:VfxLibrary, param4:ILogger, param5:Number, param6:IAnimFacing = null, param7:Function = null)
      {
         this.resources = new Dictionary();
         this.vds = new Dictionary();
         super();
         this.def = param1;
         this.logger = param4;
         this.lib = param3;
         this._facing = param6;
         this.parameter = param5;
         this.finishedCallback = param7;
         this.loadClip("start",param2);
         this.loadClip("loop",param2);
         this.loadClip("end",param2);
      }
      
      public function get depth() : String
      {
         var _loc1_:String = !!this.vd ? this.vd.depth : null;
         if(!_loc1_)
         {
            _loc1_ = !!this.def ? this.def.depth : null;
         }
         if(!_loc1_)
         {
            _loc1_ = "main0";
         }
         return _loc1_;
      }
      
      public function get flip() : Boolean
      {
         return Boolean(this.vd) && this.vd.flip;
      }
      
      public function cleanup() : void
      {
         var _loc1_:Resource = null;
         if(this.cleanedup)
         {
            return;
         }
         this.cleanedup = true;
         this.complete = true;
         this.stage = null;
         for each(_loc1_ in this.resources)
         {
            if(_loc1_)
            {
               _loc1_.removeResourceListener(this.resourceCompleteHandler);
               _loc1_.release();
            }
         }
         this.resources = null;
         this.def = null;
         this.lib = null;
      }
      
      override public function toString() : String
      {
         return "VfxSequence: [def=" + this.def + ", stage=" + this._stage + ", clip=" + this._clip + "]";
      }
      
      public function randomize() : void
      {
         this.update(Math.random() * 5000,true);
         if(!this._clip)
         {
            this.update(Math.random() * 5000,true);
         }
      }
      
      public function update(param1:int, param2:Boolean = false) : void
      {
         if(this.complete)
         {
            return;
         }
         this.elapsed += param1;
         if(this.elapsed < this.def.delay)
         {
            return;
         }
         if(this.waits > 0)
         {
            return;
         }
         if(this._doEnd && this._stage != "end")
         {
            this.stage = "end";
         }
         if(!this._fadingOut)
         {
            if(!this._stage || this._clip && !this._clip.playing && this._stage != "loop" || !this._clip)
            {
               this.nextStage();
               this.checkStage();
            }
         }
         if(this._clip)
         {
            if(param2 || this._clip.playing)
            {
               this._clip.advance(param1);
            }
         }
      }
      
      public function doEnd() : void
      {
         this._doEnd = true;
      }
      
      private function loadClip(param1:String, param2:IResourceManager) : void
      {
         var _loc4_:VfxDef = null;
         var _loc7_:IResource = null;
         var _loc3_:String = String(this.def[param1]);
         if(!_loc3_ || !this.lib)
         {
            return;
         }
         if(this.def.oriented == true)
         {
            _loc4_ = this.lib.getVfxDefByFacing(_loc3_,this._facing);
            if(!_loc4_)
            {
               this.logger.error("No such oriented VfxDef " + _loc3_ + " in library " + this.lib);
            }
         }
         if(!_loc4_)
         {
            _loc4_ = this.lib.getVfxDef(_loc3_);
            if(!_loc4_)
            {
               this.logger.error("No such VfxDef " + _loc3_ + " in library " + this.lib);
               return;
            }
         }
         if(_loc4_.error)
         {
            this.logger.error("VfxDef [" + _loc3_ + "] has errors");
            return;
         }
         this.vds[param1] = _loc4_;
         var _loc5_:int = _loc4_.getIndex(this.parameter);
         var _loc6_:String = _loc4_.getClipUrl(_loc5_);
         if(_loc6_)
         {
            _loc7_ = this.resources[param1] = param2.getResource(_loc6_,AnimClipResource);
            ++this.waits;
            _loc7_.addResourceListener(this.resourceCompleteHandler);
         }
         else
         {
            this.logger.error("VfxSequence.loadClip " + this + " No VFX URL for which=" + param1 + ", name=" + _loc3_);
         }
      }
      
      private function resourceCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         param1.resource.removeResourceListener(this.resourceCompleteHandler);
         --this.waits;
      }
      
      public function set stage(param1:String) : void
      {
         var _loc2_:Boolean = false;
         if(this._stage == param1)
         {
            return;
         }
         this._stage = param1;
         if(this._clip)
         {
            if(this.def.fadeOut)
            {
               _loc2_ = false;
               if(this._stage == "end")
               {
                  _loc2_ = true;
               }
               else if(!this.def.end)
               {
                  if(this._stage == "loop")
                  {
                     _loc2_ = true;
                  }
                  else if(!this.def.loop)
                  {
                     _loc2_ = true;
                  }
               }
               if(_loc2_)
               {
                  this._clip.alpha = this._vfxAlpha * this.def.alpha;
                  this._fadingOut = true;
                  TweenMax.to(this._clip,1,{
                     "alpha":0,
                     "onComplete":this.fadeOutCompleteHandler
                  });
                  this.resource = null;
                  this.vd = null;
                  return;
               }
            }
         }
         if(this._clip)
         {
            this._clip.stop();
            TweenMax.killTweensOf(this._clip);
         }
         if(this._stage)
         {
            this.resource = this.resources[this._stage];
            this.vd = this.vds[this._stage];
         }
         else
         {
            this.resource = null;
            this.vd = null;
         }
         this.checkStage();
         if(this._clip)
         {
            if(this._stage == "loop")
            {
               this._clip.repeatLimit = 0;
            }
            if(this.def.fadeIn)
            {
               if(this._stage == "loop" && !this.def.start || this._stage == "start")
               {
                  this._clip.alpha = 0;
                  TweenMax.to(this._clip,1,{"alpha":this._vfxAlpha * this.def.alpha});
               }
            }
         }
      }
      
      private function fadeOutCompleteHandler() : void
      {
         this.clip = null;
         this._fadingOut = false;
      }
      
      private function checkStage() : void
      {
         if(this._fadingOut)
         {
            return;
         }
         if(this._stage)
         {
            if(!this._clip)
            {
               if(this.resource)
               {
                  this.clip = this.resource.clip;
               }
            }
            else if(this.resource)
            {
               if(this._clip.def != this.resource.clipDef)
               {
                  this.clip = this.resource.clip;
               }
            }
            else
            {
               this.clip = null;
            }
         }
         else if(this._clip)
         {
            this.clip = null;
         }
      }
      
      private function nextStage() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Event = null;
         if(this._stage == null)
         {
            this.stage = "start";
         }
         else if(this._stage == "start")
         {
            this.stage = "loop";
         }
         else if(this._stage == "loop")
         {
            this.stage = "end";
         }
         else if(this._stage == "end")
         {
            this.complete = true;
            this.stage = null;
            _loc1_ = hasEventListener(VfxSequence.EVENT_SEQUENCE_COMPLETE);
            if(_loc1_)
            {
               _loc2_ = new Event(VfxSequence.EVENT_SEQUENCE_COMPLETE);
               dispatchEvent(_loc2_);
            }
         }
      }
      
      public function get clip() : AnimClip
      {
         return this._clip;
      }
      
      public function set clip(param1:AnimClip) : void
      {
         if(this._clip == param1)
         {
            return;
         }
         if(this._clip)
         {
            this._clip.finishedCallback = null;
            this._clip.stop();
            this._clip.cleanup();
         }
         this._clip = param1;
         if(this._clip)
         {
            this._clip.finishedCallback = this.clipFinishedHandler;
            this._clip.start(0);
            this._clip.alpha = this._vfxAlpha * this.def.alpha;
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function clipFinishedHandler(param1:AnimClip) : void
      {
         if(this.finishedCallback != null)
         {
            this.finishedCallback(this);
         }
         dispatchEvent(new Event(VfxSequence.EVENT_CLIP_FINISHED));
      }
      
      public function get vfxAlpha() : Number
      {
         return this._vfxAlpha;
      }
      
      public function set vfxAlpha(param1:Number) : void
      {
         if(this._vfxAlpha == param1)
         {
            return;
         }
         this._vfxAlpha = param1;
         if(this._clip)
         {
            this._clip.alpha = this._vfxAlpha * this.def.alpha;
         }
      }
   }
}
