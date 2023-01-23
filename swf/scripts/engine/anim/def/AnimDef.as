package engine.anim.def
{
   import flash.geom.Point;
   
   public class AnimDef implements IAnimDef
   {
       
      
      protected var _name:String;
      
      protected var _flip:Boolean;
      
      protected var _clip:IAnimClipDef;
      
      protected var _moveSpeed:Number = 0;
      
      protected var _clipUrl:String;
      
      public var _offset:Point;
      
      public function AnimDef()
      {
         super();
      }
      
      public function toString() : String
      {
         return "AnimDef: [ name=" + this._name + ", clip=" + this.clip + "]";
      }
      
      public function clone() : AnimDef
      {
         var _loc1_:AnimDef = new AnimDef();
         _loc1_._name = this._name;
         _loc1_._flip = this._flip;
         _loc1_._clip = this._clip;
         _loc1_._moveSpeed = this._moveSpeed;
         _loc1_._clipUrl = this._clipUrl;
         _loc1_._offset = !!this._offset ? this._offset.clone() : null;
         return _loc1_;
      }
      
      public function get offset() : Point
      {
         if(this._offset)
         {
            this._offset = this._offset;
         }
         return this._offset;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get flip() : Boolean
      {
         return this._flip;
      }
      
      public function set flip(param1:Boolean) : void
      {
         this._flip = param1;
      }
      
      public function get clip() : IAnimClipDef
      {
         return this._clip;
      }
      
      public function set clip(param1:IAnimClipDef) : void
      {
         this._clip = param1;
         if(this._clip)
         {
            if(this._clip.aframes.locomotive)
            {
               this._moveSpeed = 0;
            }
         }
      }
      
      public function set moveSpeed(param1:Number) : void
      {
         this._moveSpeed = param1;
      }
      
      public function get moveSpeed() : Number
      {
         return this._moveSpeed * AnimClipDef.oo_playbackMod;
      }
      
      public function get clipUrl() : String
      {
         return !!this._clip ? this._clip.url : this._clipUrl;
      }
      
      public function set clipUrl(param1:String) : void
      {
         this._clipUrl = param1;
      }
   }
}
