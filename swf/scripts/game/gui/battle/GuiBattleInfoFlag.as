package game.gui.battle
{
   import engine.gui.GuiUtil;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   import engine.stat.model.Stats;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class GuiBattleInfoFlag extends MovieClip implements IGuiGameBattleInfoFlag
   {
       
      
      private var maxPosition:Number = -56.15;
      
      private var strength_info_text:MovieClip;
      
      private var armor_info_text:MovieClip;
      
      private var willpower_info_text:TextField;
      
      private var _will_star:MovieClip;
      
      private var offsetPosition:Point;
      
      private var blue:MovieClip;
      
      private var red:MovieClip;
      
      protected var _stats:Stats;
      
      private var _dirty:Boolean;
      
      private var _entityId:String;
      
      private var _scale_emphasis_cur:Number = 1;
      
      private var _scale_emphasis:Number = 1;
      
      private var _scale_zoom:Number = 1;
      
      private const SCALE_SPEED:Number = 0.01;
      
      protected var _statStr:Stat;
      
      protected var _statArm:Stat;
      
      protected var _statWil:Stat;
      
      private var _ctorClazz:Class;
      
      public function GuiBattleInfoFlag()
      {
         this.offsetPosition = new Point(0,-100);
         super();
         GuiUtil.attemptStopAllMovieClips(this);
         this.mouseEnabled = this.mouseChildren = false;
         this.strength_info_text = getChildByName("str_text") as MovieClip;
         this.armor_info_text = getChildByName("arm_text") as MovieClip;
         this.willpower_info_text = getChildByName("will_text") as TextField;
         this._will_star = getChildByName("will_star") as MovieClip;
         this.blue = getChildByName("blue") as MovieClip;
         this.red = getChildByName("red") as MovieClip;
         this.visible = false;
      }
      
      public function cleanup() : void
      {
         stop();
      }
      
      public function get movieClip() : MovieClip
      {
         return this;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(!param1)
         {
            this.scale_emphasis_cur = this._scale_emphasis;
         }
      }
      
      public function set scale_emphasis(param1:Number) : void
      {
         if(this._scale_emphasis == param1)
         {
            return;
         }
         this._scale_emphasis = param1;
         if(!super.visible)
         {
            this.scale_emphasis_cur = param1;
         }
      }
      
      public function set scale_zoom(param1:Number) : void
      {
         if(this._scale_zoom == param1)
         {
            return;
         }
         this._scale_zoom = param1;
         scaleX = scaleY = this._scale_emphasis_cur * this._scale_zoom;
      }
      
      public function set scale_emphasis_cur(param1:Number) : void
      {
         if(this._scale_emphasis_cur == param1)
         {
            return;
         }
         this._scale_emphasis_cur = param1;
         scaleX = scaleY = this._scale_emphasis_cur * this._scale_zoom;
      }
      
      public function update(param1:int) : void
      {
         if(this._scale_emphasis == this._scale_emphasis_cur)
         {
            return;
         }
         var _loc2_:Number = param1 * this.SCALE_SPEED;
         if(this._scale_emphasis < this._scale_emphasis_cur)
         {
            this.scale_emphasis_cur = Math.max(this._scale_emphasis,this._scale_emphasis_cur - _loc2_ / 2);
         }
         else if(this._scale_emphasis > this._scale_emphasis_cur)
         {
            this.scale_emphasis_cur = Math.min(this._scale_emphasis,this._scale_emphasis_cur + _loc2_);
         }
      }
      
      public function cacheStat(param1:Stat, param2:Stat) : Stat
      {
         if(param1 != param2)
         {
            if(param1)
            {
               param1.removeEventListener(StatEvent.CHANGE,this.statChangeHandler);
            }
            if(param2)
            {
               param2.addEventListener(StatEvent.CHANGE,this.statChangeHandler);
            }
         }
         return param2;
      }
      
      public function setEntityAndStats(param1:String, param2:Stats, param3:Boolean, param4:Boolean) : void
      {
         if(this._stats == param2 && this._entityId == param1)
         {
            return;
         }
         this._entityId = param1;
         name = !!this._entityId ? this._entityId : "unused";
         if(param3)
         {
            this.gotoAndStop(2);
         }
         else
         {
            this.gotoAndStop(1);
         }
         if(this._stats)
         {
            this._statStr = this.cacheStat(this._statStr,null);
            this._statArm = this.cacheStat(this._statArm,null);
            this._statWil = this.cacheStat(this._statWil,null);
         }
         this._stats = param2;
         if(this._stats)
         {
            this.handleCacheStats(param4);
            this.statChangeHandler(null);
         }
         else
         {
            this._statStr = null;
            this._statArm = null;
            this._statWil = null;
         }
      }
      
      protected function handleCacheStats(param1:Boolean) : void
      {
         this._statStr = this.cacheStat(this._statStr,this._stats.getStat(StatType.STRENGTH,param1));
         this._statArm = this.cacheStat(this._statArm,this._stats.getStat(StatType.ARMOR,false));
         this._statWil = this.cacheStat(this._statWil,this._stats.getStat(StatType.WILLPOWER,false));
      }
      
      private function statChangeHandler(param1:StatEvent) : void
      {
         var _loc2_:int = 0;
         if(!this._stats)
         {
            return;
         }
         if(this._statStr)
         {
            this.strength_info_text.textField.text = this._statStr.value.toString();
            this.red.y = Math.max(this.maxPosition,this.maxPosition * (this._statStr.value / this._statStr.original));
         }
         else
         {
            this.strength_info_text.textField.text = "";
         }
         if(Boolean(this._statArm) && Boolean(this._statWil))
         {
            if(this.armor_info_text && this.willpower_info_text && Boolean(this.blue))
            {
               this.armor_info_text.textField.text = this._statArm.value.toString();
               _loc2_ = this._statWil.value;
               this.willpower_info_text.text = _loc2_.toString();
               this.blue.y = Math.max(this.maxPosition,this.maxPosition * (this._statArm.value / this._statArm.original));
            }
         }
         cacheAsBitmap = true;
      }
      
      public function get dirty() : Boolean
      {
         return this._dirty;
      }
      
      public function set dirty(param1:Boolean) : void
      {
         this._dirty = param1;
      }
      
      public function get entityId() : String
      {
         return this._entityId;
      }
      
      public function set ctorClazz(param1:Class) : void
      {
         this._ctorClazz = param1;
      }
      
      public function get ctorClazz() : Class
      {
         return this._ctorClazz;
      }
   }
}
