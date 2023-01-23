package engine.anim.def
{
   import engine.anim.view.IAnim;
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   
   public class OrientedAnimMix
   {
       
      
      public var def:AnimMixDef;
      
      private var _currentEntryDef:AnimMixEntryDef;
      
      public var _current:OrientedAnims;
      
      public var library:IAnimLibrary;
      
      public var logger:ILogger;
      
      private var _facing:IAnimFacing;
      
      private var _callback:Function;
      
      private var _enabled:Boolean;
      
      private var _masterState:Boolean = false;
      
      private var _eventCallback:Function;
      
      public var layer:String;
      
      public function OrientedAnimMix(param1:String, param2:AnimMixDef, param3:IAnimLibrary, param4:Function, param5:ILogger)
      {
         super();
         this.layer = param1;
         this.def = param2;
         this.library = param3;
         this.logger = param5;
         this._eventCallback = param4;
         if(param2.start)
         {
            this.currentEntryDef = param2.start;
         }
      }
      
      public function set masterState(param1:Boolean) : void
      {
         this._masterState = param1;
      }
      
      public function toString() : String
      {
         return "[" + this.def.name + "]";
      }
      
      public function next() : OrientedAnims
      {
         if(!this._enabled)
         {
            throw new IllegalOperationError("next not enabled");
         }
         if(this._masterState == true)
         {
            this.currentEntryDef = this.def.getMix("master");
            if(this.currentEntryDef != null)
            {
               return this.current;
            }
         }
         this.currentEntryDef = this.def.randomlySelect(this._currentEntryDef);
         return this._current;
      }
      
      public function get current() : OrientedAnims
      {
         if(!this._current)
         {
            if(this._enabled)
            {
               this.next();
            }
         }
         return this._current;
      }
      
      public function set current(param1:OrientedAnims) : void
      {
         if(this._current == param1)
         {
            return;
         }
         if(this._current)
         {
            this._current.stop();
         }
         this._current = param1;
         if(this._current)
         {
            this._current.facing = this.facing;
         }
         if(this._callback != null)
         {
            this._callback(this);
         }
      }
      
      private function animCallback(param1:IAnim) : void
      {
         this.next();
      }
      
      private function animEventCallback(param1:OrientedAnims, param2:IAnim, param3:String) : void
      {
         if(this._eventCallback != null)
         {
            this._eventCallback(param1,param2,param3);
         }
      }
      
      public function get currentEntryDef() : AnimMixEntryDef
      {
         return this._currentEntryDef;
      }
      
      public function set currentEntryDef(param1:AnimMixEntryDef) : void
      {
         if(this._currentEntryDef == param1)
         {
            if(Boolean(this._current) && Boolean(this._current.anim))
            {
               this._current.anim.restart();
               return;
            }
         }
         this._currentEntryDef = param1;
         if(this._currentEntryDef)
         {
            this.current = this.library.getOrientedAnims(this.layer,this._currentEntryDef.anim,this.animEventCallback,this.animCallback);
            if(this._current)
            {
               this._current.repeatLimit = this._currentEntryDef.repeats;
               this._current.timeLimitMs = this._currentEntryDef.lengthMs;
               if(this._current.anim)
               {
                  this._current.anim.start(0);
               }
            }
         }
         else
         {
            this.current = null;
         }
      }
      
      public function get facing() : IAnimFacing
      {
         return this._facing;
      }
      
      public function set facing(param1:IAnimFacing) : void
      {
         this._facing = param1;
         if(this._current)
         {
            this._current.facing = this._facing;
         }
      }
      
      public function get callback() : Function
      {
         return this._callback;
      }
      
      public function set callback(param1:Function) : void
      {
         this._callback = param1;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
            return;
         }
         this._enabled = param1;
         if(!this._enabled)
         {
            this.current = null;
         }
         else
         {
            this.next();
         }
      }
   }
}
