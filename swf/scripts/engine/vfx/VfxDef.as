package engine.vfx
{
   import engine.anim.def.IAnimClipDef;
   import engine.core.locale.LocaleId;
   import flash.errors.IllegalOperationError;
   
   public class VfxDef
   {
       
      
      protected var _name:String;
      
      protected var _clipUrls:Vector.<String>;
      
      protected var _clips:Vector.<IAnimClipDef>;
      
      protected var _flip:Boolean = false;
      
      protected var _localize:Boolean;
      
      public var scale:Number = 1;
      
      public var error:Boolean;
      
      public var depth:String;
      
      public function VfxDef()
      {
         this._clipUrls = new Vector.<String>();
         this._clips = new Vector.<IAnimClipDef>();
         super();
      }
      
      public function resolveLocalization(param1:LocaleId) : void
      {
         var _loc3_:String = null;
         if(!this.localize || !param1)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._clipUrls.length)
         {
            _loc3_ = this._clipUrls[_loc2_];
            this._clipUrls[_loc2_] = param1.translateLocaleUrl(_loc3_);
            _loc2_++;
         }
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function getClip(param1:int) : IAnimClipDef
      {
         return this._clips[param1];
      }
      
      public function setClip(param1:int, param2:IAnimClipDef) : void
      {
         if(param1 != this._clips.length)
         {
            throw new IllegalOperationError("Add clips in order");
         }
         this._clips.push(param2);
      }
      
      public function get numClipUrls() : int
      {
         return this._clipUrls.length;
      }
      
      public function getIndex(param1:Number) : int
      {
         return Math.max(0,Math.min(this._clipUrls.length - 1,Math.round(this._clipUrls.length * param1 - 0.5)));
      }
      
      public function getClipUrl(param1:int) : String
      {
         return this._clipUrls[param1];
      }
      
      public function set flip(param1:Boolean) : void
      {
         this._flip = param1;
      }
      
      public function get flip() : Boolean
      {
         return this._flip;
      }
      
      public function get localize() : Boolean
      {
         return this._localize;
      }
   }
}
