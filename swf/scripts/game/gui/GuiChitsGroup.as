package game.gui
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   
   public class GuiChitsGroup extends GuiBase
   {
       
      
      public var chits:Vector.<GuiChit>;
      
      private var _numVisibleChits:int = -1;
      
      private var _activeChitIndex:int = -1;
      
      private var spacing:Point;
      
      private var maxSize:Point;
      
      private var _showLeadingChits:Boolean;
      
      public function GuiChitsGroup()
      {
         this.chits = new Vector.<GuiChit>();
         super();
      }
      
      public function init(param1:IGuiContext) : void
      {
         var _loc2_:Point = null;
         var _loc4_:GuiChit = null;
         super.initGuiBase(param1);
         this.maxSize = new Point(width,height);
         var _loc3_:int = 0;
         while(_loc3_ < numChildren)
         {
            _loc4_ = getChildAt(_loc3_) as GuiChit;
            if(_loc4_)
            {
               this.chits.push(_loc4_);
            }
            _loc3_++;
         }
         if(this.chits.length < 2)
         {
            throw new ArgumentError("Invalid chits.  Require 2 or more GuiChit children");
         }
         this.measureSpacing();
         this.numVisibleChits = 0;
      }
      
      private function measureSpacing() : void
      {
         var _loc1_:GuiChit = null;
         var _loc2_:GuiChit = null;
         this.spacing = new Point(this.maxSize.x,this.maxSize.y);
         if(this.chits.length > 1)
         {
            _loc1_ = this.chits[0];
            _loc2_ = this.chits[1];
            this.spacing.x = Math.abs(_loc2_.x - _loc1_.x);
            this.spacing.y = Math.abs(_loc2_.y - _loc1_.y);
         }
      }
      
      public function get activeChitIndex() : int
      {
         return this._activeChitIndex;
      }
      
      public function set activeChitIndex(param1:int) : void
      {
         if(!_context)
         {
            throw new IllegalOperationError("init first");
         }
         if(param1 < 0)
         {
            param1 = this._numVisibleChits - 1;
         }
         else if(param1 >= this._numVisibleChits)
         {
            param1 = 0;
         }
         if(this._activeChitIndex == param1)
         {
            return;
         }
         this._activeChitIndex = param1;
         this.updateActiveChit();
      }
      
      public function get numVisibleChits() : int
      {
         return this._numVisibleChits;
      }
      
      public function set numVisibleChits(param1:int) : void
      {
         var _loc8_:Number = NaN;
         var _loc12_:GuiChit = null;
         if(!_context)
         {
            throw new IllegalOperationError("init first");
         }
         if(this._numVisibleChits == param1)
         {
            return;
         }
         this._numVisibleChits = param1;
         var _loc2_:int = this._numVisibleChits - 1;
         var _loc3_:Number = _loc2_ * this.spacing.x;
         var _loc4_:Number = _loc2_ * this.spacing.y;
         var _loc5_:Number = !!_loc3_ ? Math.min(1,this.maxSize.x / _loc3_) : 1;
         var _loc6_:Number = !!_loc4_ ? Math.min(1,this.maxSize.y / _loc4_) : 1;
         var _loc7_:Number = Math.min(_loc5_,_loc6_);
         _loc8_ = this.spacing.x * _loc7_;
         var _loc9_:Number = this.spacing.y * _loc7_;
         var _loc10_:Point = new Point(-_loc2_ * _loc8_ / 2,-_loc2_ * _loc9_ / 2);
         var _loc11_:int = 0;
         while(_loc11_ < this.chits.length)
         {
            _loc12_ = this.chits[_loc11_];
            if(_loc11_ < this._numVisibleChits)
            {
               _loc12_.x = _loc10_.x;
               _loc12_.y = _loc10_.y;
               _loc10_.setTo(_loc10_.x + _loc8_,_loc10_.y + _loc9_);
               _loc12_.visible = true;
            }
            else
            {
               _loc12_.visible = false;
            }
            _loc11_++;
         }
         this.activeChitIndex = this._activeChitIndex;
      }
      
      public function set showLeadingChits(param1:Boolean) : void
      {
         if(this._showLeadingChits == param1)
         {
            return;
         }
         this._showLeadingChits = param1;
         this.updateActiveChit();
      }
      
      private function updateActiveChit() : void
      {
         var _loc2_:GuiChit = null;
         var _loc3_:Boolean = false;
         var _loc1_:int = 0;
         while(_loc1_ < this.chits.length)
         {
            _loc2_ = this.chits[_loc1_];
            _loc3_ = _loc1_ == this._activeChitIndex || this._showLeadingChits && _loc1_ <= this._activeChitIndex;
            _loc2_.highlighted = _loc3_;
            _loc1_++;
         }
      }
      
      public function prevChit() : void
      {
         this.activeChitIndex = (this._activeChitIndex + this._numVisibleChits - 1) % this._numVisibleChits;
      }
      
      public function nextChit() : void
      {
         this.activeChitIndex = (this._activeChitIndex + 1) % this._numVisibleChits;
      }
   }
}
